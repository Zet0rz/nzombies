Mapping.Version = 400 --Note to Ali; Any time you make an update to the way this is saved, increment this.

function Mapping:SaveConfig(name)

	local main = {}

	--Check if the nz folder exists
	if !file.Exists( "nz/", "DATA" ) then
		file.CreateDir( "nz" )
	end

	main.version = self.Version

	local easter_eggs = {}
	for _, v in pairs(ents.FindByClass("easter_egg")) do
		table.insert(easter_eggs, {
		pos = v:GetPos(),
		angle = v:GetAngles(),
		model = v:GetModel(),
		})
	end

	local zed_spawns = {}
	for _, v in pairs(ents.FindByClass("zed_spawns")) do
		table.insert(zed_spawns, {
		pos = v:GetPos(),
		link = v.link,
		respawnable = v.respawnable
		})
	end
	
	local zed_special_spawns = {}
	for _, v in pairs(ents.FindByClass("zed_special_spawns")) do
		table.insert(zed_special_spawns, {
		pos = v:GetPos(),
		link = v.link
		})
	end

	local player_spawns = {}
	for _, v in pairs(ents.FindByClass("player_spawns")) do
		table.insert(player_spawns, {
		pos = v:GetPos(),
		})
	end

	local wall_buys = {}
	for _, v in pairs(ents.FindByClass("wall_buys")) do
		table.insert(wall_buys, {
		pos = v:GetPos(),
		wep = v.WeaponGive,
		price = v.Price,
		angle = v:GetAngles(),
		flipped = v:GetFlipped(),
		})
	end

	local buyableprop_spawns = {}
	for _, v in pairs(ents.FindByClass("prop_buys")) do

		-- Convert the table to a flag string - if it even has any
		local data = v:GetDoorData()
		local flagstr
		if data then
			flagstr = ""
			for k2, v2 in pairs(data) do
				flagstr = flagstr .. k2 .."=" .. v2 .. ","
			end
			flagstr = string.Trim(flagstr, ",")
		end

		table.insert(buyableprop_spawns, {
		pos = v:GetPos(),
		angle = v:GetAngles(),
		model = v:GetModel(),
		flags = flagstr,
		})
	end

	local prop_effects = {}
	for _, v in pairs(ents.FindByClass("nz_prop_effect")) do
		table.insert(prop_effects, {
		pos = v:GetPos(),
		angle = v:GetAngles(),
		model = v.AttachedEntity:GetModel(),
		})
	end

	local elec_spawn = {}
	for _, v in pairs(ents.FindByClass("power_box")) do
		table.insert(elec_spawn, {
		pos = v:GetPos(),
		angle = v:GetAngles( ),
		})
	end

	local block_spawns = {}
	for _, v in pairs(ents.FindByClass("wall_block")) do
		table.insert(block_spawns, {
		pos = v:GetPos(),
		angle = v:GetAngles(),
		model = v:GetModel(),
		})
	end

	local randombox_spawn = {}
	for _, v in pairs(ents.FindByClass("random_box_spawns")) do
		table.insert(randombox_spawn, {
		pos = v:GetPos(),
		angle = v:GetAngles(),
		})
	end

	local perk_machinespawns = {}
	for _, v in pairs(ents.FindByClass("perk_machine")) do
		table.insert(perk_machinespawns, {
			pos = v:GetPos(),
			angle = v:GetAngles(),
			id = v:GetPerkID(),
		})
	end

	//Normal Map doors
	local door_setup = {}
	for k,v in pairs(Doors.MapDoors) do
		local flags = ""
		for k2, v2 in pairs(v.flags) do
			flags = flags .. k2 .. "=" .. v2 .. ","
		end
		flags = string.Trim(flags, ",")
		door = Doors:DoorIndexToEnt(k)
		if door:IsDoor() then
			door_setup[k] = {
			flags = flags,
			}
			--print(door.Data)
		end
	end
	--PrintTable(door_setup)

	--barricades
	local break_entry = {}
	for _, v in pairs(ents.FindByClass("breakable_entry")) do
		table.insert(break_entry, {
			pos = v:GetPos(),
			angle = v:GetAngles(),
		})
	end

	local special_entities = {}
	for k, v in pairs(nz.QMenu.Data.SpawnedEntities) do
		if IsValid(v) then
			table.insert(special_entities, duplicator.CopyEntTable(v))
		else
			nz.QMenu.Data.SpawnedEntities[k] = nil
		end
	end
	--PrintTable(special_entities)
	
	-- Store all invisible walls with their boundaries and angles
	local invis_walls = {}
	for _, v in pairs(ents.FindByClass("invis_wall")) do
		table.insert(invis_walls, {
			pos = v:GetPos(),
			maxbound = v:GetMaxBound(),
		})
	end

	main["ZedSpawns"] = zed_spawns
	main["ZedSpecialSpawns"] = zed_special_spawns
	main["PlayerSpawns"] = player_spawns
	main["WallBuys"] = wall_buys
	main["BuyablePropSpawns"] = buyableprop_spawns
	main["ElecSpawns"] = elec_spawn
	main["BlockSpawns"] = block_spawns
	main["RandomBoxSpawns"] = randombox_spawn
	main["PerkMachineSpawns"] = perk_machinespawns
	main["DoorSetup"] = door_setup
	main["BreakEntry"] = break_entry
	main["EasterEggs"] = easter_eggs
	main["PropEffects"] = prop_effects
	main["SpecialEntities"] = special_entities
	main["InvisWalls"] = invis_walls

	--We better clear the merges in case someone played around with them in create mode (lua_run)
	nz.Nav.ResetNavGroupMerges()
	main["NavTable"] = nz.Nav.Data
	main["NavGroups"] = nz.Nav.NavGroups
	main["NavGroupIDs"] = nz.Nav.NavGroupIDs

	--Save this map's configuration
	main["MapSettings"] = self.Settings
	main["RemoveProps"] = self.MarkedProps

	local configname
	if name and name != "" then
		configname = "nz/nz_" .. game.GetMap() .. ";" .. name .. ".txt"
	else
		configname = "nz/nz_" .. game.GetMap() .. ";" .. os.date("%H_%M_%j") .. ".txt"
	end

	file.Write( configname, util.TableToJSON( main ) )
	PrintMessage( HUD_PRINTTALK, "[NZ] Saved to garrysmod/data/" .. configname)

end

function Mapping:ClearConfig()
	print("[NZ] Clearing current map")
	
	-- ALWAYS do this first!
	Mapping:UnloadScript()

	--Resets spawnpoints ther should be a function/accessor for this rather than jsu a table reset
	nz.Enemies.Data.RespawnableSpawnpoints = {}

	--Entities to clear:
	local entClasses = {
		["zed_spawns"] = true,
		["zed_special_spawns"] = true,
		["player_spawns"] = true,
		["wall_buys"] = true,
		["prop_buys"] = true,
		["button_elec"] = true,
		["wall_block"] = true,
		["random_box_spawns"] = true,
		["perk_machine"] = true,
		["easter_egg"] = true,
		["nz_prop_effect"] = true,
		["breakable_entry"] = true,
		["edit_fog"] = true,
		["edit_fog_special"] = true,
		["edit_sky"] = true,
		["edit_color"] = true,
		["edit_sun"] = true,
		["nz_triggerzone"] = true,
		["power_box"] = true,
		["invis_wall"] = true,
		["nz_script_triggerzone"] = true,
		["nz_script_prop"] = true,
	}

	--jsut loop once over all entities isntead of seperate findbyclass calls
	for k,v in pairs(ents.GetAll()) do
		if entClasses[v:GetClass()] then
			v:Remove()
		end
	end

	--Normal Map doors
	for k,v in pairs(Doors.MapDoors) do
		Doors:RemoveMapDoorLink( k )
	end

	--Reset Navigation table
	for k,v in pairs(nz.Nav.Data) do
		navmesh.GetNavAreaByID(k):SetAttributes(v.prev)
	end
	nz.Nav.Data = {}

	--Specially spawned entities
	for k,v in pairs(nz.QMenu.Data.SpawnedEntities) do
		if IsValid(v) then
			v:Remove()
		end
	end

	nz.QMenu.Data.SpawnedEntities = {}

	Mapping.Settings = {}
	Mapping.MarkedProps = {}

	Doors.MapDoors = {}
	Doors.PropDoors = {}

	-- Sync
	FullSyncModules["Round"]()

	-- Clear all door data
	net.Start("nzClearDoorData")
	net.Broadcast()
	
	-- Clear out the item objects creating with this config (if any)
	ItemCarry:CleanUp()
	
	Mapping.CurrentConfig = nil
	
	Mapping:CleanUpMap()
end

function Mapping:LoadConfig( name, loader )

	local filepath = "nz/" .. name
	local location = "DATA"
	
	if string.GetExtensionFromFilename(name) == "lua" then
		if file.Exists("gamemodes/nzombies3/officialconfigs/"..name, "GAME") then
			location, filepath = "GAME", "gamemodes/nzombies3/officialconfigs/"..name
		else
			location = "LUA"
		end
	end

	if file.Exists( filepath, location )then
		print("[NZ] MAP CONFIG FOUND!")

		-- Load a lua file for a specific map
		-- Make sure all hooks are removed before adding the new ones
		Mapping:UnloadScript()

		local data = util.JSONToTable( file.Read( filepath, location ) )

		local version = data.version

		-- Check the version of the config.
		if version == nil then
			print("This map config is too out of date to be used. Sorry about that!")
			return
		end

		if version < Mapping.Version then
			print("Warning: This map config was made with an older version of nZombies. After this has loaded, use the save command to save a newer version.")
		end

		if version < 300 then
			print("Warning: Inital Version: No changes have been made.")
		end

		if version < 350 then
			print("Warning: This map config does not contain any set barricades.")
		end

		self:ClearConfig()

		print("[NZ] Loading " .. filepath .. "...")


		//Start sorting the data

		if data.ZedSpawns then
			for k,v in pairs(data.ZedSpawns) do
				Mapping:ZedSpawn(v.pos, v.link, v.respawnable)
			end
		end
		
		if data.ZedSpecialSpawns then
			for k,v in pairs(data.ZedSpecialSpawns) do
				Mapping:ZedSpecialSpawn(v.pos, v.link)
			end
		end

		if data.PlayerSpawns then
			for k,v in pairs(data.PlayerSpawns) do
				Mapping:PlayerSpawn(v.pos)
			end
		end

		if data.WallBuys then
			for k,v in pairs(data.WallBuys) do
				Mapping:WallBuy(v.pos,v.wep, v.price, v.angle, nil, nil, v.flipped)
			end
		end

		if data.BuyablePropSpawns then
			for k,v in pairs(data.BuyablePropSpawns) do
				Mapping:PropBuy(v.pos, v.angle, v.model, v.flags)
			end
		end

		if data.ElecSpawns then
			for k,v in pairs(data.ElecSpawns) do
				Mapping:Electric(v.pos, v.angle)
			end
		end

		if data.BlockSpawns then
			for k,v in pairs(data.BlockSpawns) do
				Mapping:BlockSpawn(v.pos, v.angle, v.model)
			end
		end

		if data.RandomBoxSpawns then
			for k,v in pairs(data.RandomBoxSpawns) do
				Mapping:BoxSpawn(v.pos, v.angle)
			end
		end

		if data.PerkMachineSpawns then
			for k,v in pairs(data.PerkMachineSpawns) do
				Mapping:PerkMachine(v.pos, v.angle, v.id)
			end
		end

		if data.EasterEggs then
			for k,v in pairs(data.EasterEggs) do
				Mapping:EasterEgg(v.pos, v.angle, v.model)
			end
		end

		//Normal Map doors
		if data.DoorSetup then
			for k,v in pairs(data.DoorSetup) do
				--print(v.flags)
				Doors:CreateMapDoorLink(k, v.flags)
			end
		end

		if version >= 350 then
			//Barricades
			if data.BreakEntry then
				for k,v in pairs(data.BreakEntry) do
					Mapping:BreakEntry(v.pos, v.angle)
				end
			end
		end

		//NavTable saved
		if data.NavTable then
			nz.Nav.Data = data.NavTable
			//Re-enable navmesh visualization
			for k,v in pairs(nz.Nav.Data) do
				local navarea = navmesh.GetNavAreaByID(k)
				if v.link then
					navarea:SetAttributes(NAV_MESH_STOP)
				else
					navarea:SetAttributes(NAV_MESH_AVOID)
				end
			end
		end

		if data.NavGroups then
			nz.Nav.NavGroups = data.NavGroups
		end
		if data.NavGroupIDs then
			nz.Nav.NavGroupIDs = data.NavGroupIDs
		end

		if data.PropEffects then
			for k,v in pairs(data.PropEffects) do
				Mapping:SpawnEffect(v.pos, v.angle, v.model)
			end
		end

		if data.SpecialEntities then
			for k,v in pairs(data.SpecialEntities) do
				PrintTable(v)
				local ent = duplicator.CreateEntityFromTable(Entity(1), v)
				table.insert(nz.QMenu.Data.SpawnedEntities, ent)
			end
		end

		if data.MapSettings then
			Mapping.Settings = data.MapSettings
			for k,v in pairs(player.GetAll()) do
				Mapping:SendMapData(v)
			end
		end
		
		if data.RemoveProps then
			Mapping.MarkedProps = data.RemoveProps
			if !Round:InState( ROUND_CREATE ) then
				for k,v in pairs(Mapping.MarkedProps) do
					local ent = ents.GetMapCreatedEntity(k)
					if IsValid(ent) then ent:Remove() end
				end
			else
				for k,v in pairs(Mapping.MarkedProps) do
					local ent = ents.GetMapCreatedEntity(k)
					if IsValid(ent) then ent:SetColor(Color(200,0,0)) end
				end
			end
		end
		
		if data.InvisWalls then
			for k,v in pairs(data.InvisWalls) do
				Mapping:CreateInvisibleWall(v.pos, v.maxbound)
			end
		end

		-- Generate all auto navmesh merging so we don't have to save that manually
		nz.Nav.Functions.AutoGenerateAutoMergeLinks()
		
		Mapping:CheckMismatch( loader )
		
		-- Set the current config name, we will use this to load scripts via mismatch window
		Mapping.CurrentConfig = name

		print("[NZ] Finished loading map config.")
	else
		print(filepath)
		print("[NZ] Warning: NO MAP CONFIG FOUND! Make a config in game using the /create command, then use /save to save it all!")
	end

end

hook.Add("Initialize", "nz_Loadmaps", function()
	timer.Simple(5, function()
		Mapping:LoadConfig("nz_"..game.GetMap()..".txt")
	end)
end)

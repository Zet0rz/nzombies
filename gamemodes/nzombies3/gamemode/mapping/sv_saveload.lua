//

nz.Mapping.Data.Version = 381 //Note to Ali; Any time you make an update to the way this is saved, increment this.

function nz.Mapping.Functions.SaveConfig()

	local main = {}
	
	//Check if the nz folder exists
	if !file.Exists( "nz/", "DATA" ) then
		file.CreateDir( "nz" )
	end
	
	main.version = nz.Mapping.Data.Version
	
	local easter_eggs = {}
	for k,v in pairs(ents.FindByClass("easter_egg")) do
		table.insert(easter_eggs, {
		pos = v:GetPos(),
		angle = v:GetAngles(),
		model = v:GetModel(),
		})
	end
	
	local player_handler = {}
	for k,v in pairs(ents.FindByClass("player_handler")) do
		table.insert(player_handler, {
		pos = v:GetPos(),
		startwep = v:GetStartWep(),
		startpoints = v:GetStartPoints(),
		numweps = v:GetNumWeps(),
		eeurl = v:GetEEURL(),
		angle = v:GetAngles( ),
		})
	end
	
	local random_box_handler = {}
	for k,v in pairs(ents.FindByClass("random_box_handler")) do
		table.insert(random_box_handler, {
		pos = v:GetPos(),
		guns = v:GetWeaponsList(),
		angle = v:GetAngles( ),
		})
	end
	
	local zed_spawns = {}
	for k,v in pairs(ents.FindByClass("zed_spawns")) do
		table.insert(zed_spawns, {
		pos = v:GetPos(),
		link = v.link,
		respawnable = v.respawnable
		})
	end
	
	local player_spawns = {}
	for k,v in pairs(ents.FindByClass("player_spawns")) do
		table.insert(player_spawns, {
		pos = v:GetPos(),
		})
	end
	
	local wall_buys = {}
	for k,v in pairs(ents.FindByClass("wall_buys")) do
		table.insert(wall_buys, {
		pos = v:GetPos(),
		wep = v.WeaponGive,
		price = v.Price,
		angle = v:GetAngles( ),
		})
	end
	
	local buyableprop_spawns = {}
	for k,v in pairs(ents.FindByClass("prop_buys")) do
		table.insert(buyableprop_spawns, {
		pos = v:GetPos(),
		angle = v:GetAngles(),
		model = v:GetModel(),
		flags = v.Data,
		})
	end
	
	local prop_effects = {}
	for k,v in pairs(ents.FindByClass("nz_prop_effect")) do
		table.insert(prop_effects, {
		pos = v:GetPos(),
		angle = v:GetAngles(),
		model = v:GetModel(),
		})
	end
	
	local elec_spawn = {}
	for k,v in pairs(ents.FindByClass("button_elec")) do
		table.insert(elec_spawn, {
		pos = v:GetPos(),
		angle = v:GetAngles( ),
		model = v:GetModel(),
		})
	end
	
	local block_spawns = {}
	for k,v in pairs(ents.FindByClass("wall_block")) do
		table.insert(block_spawns, {
		pos = v:GetPos(),
		angle = v:GetAngles(),
		model = v:GetModel(),
		modelX = v.CurModelX and v.CurModelX or 2,
		modelY = v.CurModelY and v.CurModelY or 2,
		modelZ = v.CurModelZ and v.CurModelZ or 0,
		})
	end
		
	local randombox_spawn = {}
	for k,v in pairs(ents.FindByClass("random_box_spawns")) do
		table.insert(randombox_spawn, {
		pos = v:GetPos(),
		angle = v:GetAngles(),
		})
	end
	
	local perk_machinespawns = {}
	for k,v in pairs(ents.FindByClass("perk_machine")) do
		table.insert(perk_machinespawns, {
			pos = v:GetPos(),
			angle = v:GetAngles(),
			id = v:GetPerkID(),
		})
	end
	
	//Normal Map doors
	local door_setup = {}
	for k,v in pairs(nz.Doors.Data.LinkFlags) do
		v = nz.Doors.Functions.doorIndexToEnt(k)
		if v:IsDoor() then
			door_setup[k] = {
			flags = v.Data,
			}
		end
	end
	--PrintTable(door_setup)
	
	//barricades
	local break_entry = {}
	for k,v in pairs(ents.FindByClass("breakable_entry")) do
		table.insert(break_entry, {
			pos = v:GetPos(),
			angle = v:GetAngles(),
		})
	end
	
	local special_entities = {}
	for k,v in pairs(nz.PropsMenu.Data.SpawnedEntities) do
		if IsValid(v) then
			table.insert(special_entities, duplicator.CopyEntTable(v))
		else
			nz.PropsMenu.Data.SpawnedEntities[k] = nil
		end
	end
	--PrintTable(special_entities)
	
	main["ZedSpawns"] = zed_spawns
	main["PlayerSpawns"] = player_spawns
	main["WallBuys"] = wall_buys
	main["BuyablePropSpawns"] = buyableprop_spawns
	main["ElecSpawns"] = elec_spawn
	main["BlockSpawns"] = block_spawns
	main["RandomBoxSpawns"] = randombox_spawn
	main["PerkMachineSpawns"] = perk_machinespawns
	main["DoorSetup"] = door_setup
	main["BreakEntry"] = break_entry
	main["RBoxHandler"] = random_box_handler
	main["PlayerHandler"] = player_handler
	main["EasterEggs"] = easter_eggs
	main["PropEffects"] = prop_effects
	main["SpecialEntities"] = special_entities
	
	//We better clear the merges in case someone played around with them in create mode (lua_run)
	nz.Nav.ResetNavGroupMerges()
	main["NavTable"] = nz.Nav.Data
	main["NavGroups"] = nz.Nav.NavGroups
	main["NavGroupIDs"] = nz.Nav.NavGroupIDs
	
	file.Write( "nz/nz_"..game.GetMap( ).."_"..os.date("%H_%M_%j")..".txt", util.TableToJSON( main ) )
	PrintMessage( HUD_PRINTTALK, "[NZ] Saved to garrysmod/data/nz/".."nz_"..game.GetMap( ).."_"..os.date("%H_%M_%j")..".txt" )
	
end

function nz.Mapping.Functions.ClearConfig()
	print("[NZ] Clearing current map")
	
	for k,v in pairs(ents.FindByClass("zed_spawns")) do
		v:Remove()
	end
	nz.Enemies.Data.RespawnableSpawnpoints = {}
	
	for k,v in pairs(ents.FindByClass("player_spawns")) do
		v:Remove()
	end

	for k,v in pairs(ents.FindByClass("wall_buys")) do
		v:Remove()
	end
	
	for k,v in pairs(ents.FindByClass("prop_buys")) do
		v:Remove()
	end
	
	for k,v in pairs(ents.FindByClass("button_elec")) do
		v:Remove()
	end
	
	for k,v in pairs(ents.FindByClass("wall_block")) do
		v:Remove()
	end
	
	for k,v in pairs(ents.FindByClass("random_box_spawns")) do
		v:Remove()
	end
	
	for k,v in pairs(ents.FindByClass("perk_machine")) do
		v:Remove()
	end
	
	for k,v in pairs(ents.FindByClass("player_handler")) do
		v:Remove()
	end
	
	for k,v in pairs(ents.FindByClass("random_box_handler")) do
		v:Remove()
	end
	
	for k,v in pairs(ents.FindByClass("easter_egg")) do
		v:Remove()
	end
	
	for k,v in pairs(ents.FindByClass("nz_prop_effect")) do
		v:Remove()
	end
	
	//Normal Map doors
	for k,v in pairs(nz.Doors.Data.LinkFlags) do
		nz.Doors.Functions.RemoveMapDoorLink( k )
	end
	
	for k,v in pairs(ents.FindByClass("breakable_entry")) do
		v:Remove()
	end
	
	//Reset Navigation table
	for k,v in pairs(nz.Nav.Data) do
		navmesh.GetNavAreaByID(k):SetAttributes(v.prev)
	end
	nz.Nav.Data = {}
	
	//Specially spawned entities
	for k,v in pairs(nz.PropsMenu.Data.SpawnedEntities) do
		if IsValid(v) then
			v:Remove()
		end
	end
	nz.PropsMenu.Data.SpawnedEntities = {}
	
	//Sync
	nz.Rounds.Functions.SendSync()
	nz.Doors.Functions.SendSync()
end

function nz.Mapping.Functions.LoadConfig( name )

	local filepath = "nz/"..name
	
	if file.Exists( filepath, "DATA" )then
		print("[NZ] MAP CONFIG FOUND!")
		
		local data = util.JSONToTable( file.Read( filepath, "DATA" ) )
		
		local version = data.version
		
		//Check the version of the config.
		if version == nil then
			print("This map config is too out of date to be used. Sorry about that!")
			return
		end
		
		if version < nz.Mapping.Data.Version then
			print("Warning: This map config was made with an older version of nZombies. After this has loaded, use the save command to save a newer version.")
		end
		
		if version < 300 then
			print("Warning: Inital Version: No changes have been made.")
		end
		
		if version < 350 then
			print("Warning: This map config does not contain any set barricades.")
		end

		nz.Mapping.Functions.ClearConfig()
		
		print("[NZ] Loading " .. filepath .. "...")
		
		
		//Start sorting the data
		
		if data.ZedSpawns then
			for k,v in pairs(data.ZedSpawns) do
				nz.Mapping.Functions.ZedSpawn(v.pos, v.link, v.respawnable)
			end
		end
		
		if data.PlayerSpawns then
			for k,v in pairs(data.PlayerSpawns) do
				nz.Mapping.Functions.PlayerSpawn(v.pos)
			end
		end
		
		if data.WallBuys then
			for k,v in pairs(data.WallBuys) do
				nz.Mapping.Functions.WallBuy(v.pos,v.wep, v.price, v.angle)
			end
		end
		
		if data.BuyablePropSpawns then
			for k,v in pairs(data.BuyablePropSpawns) do
				nz.Mapping.Functions.PropBuy(v.pos, v.angle, v.model, v.flags)
			end
		end
		
		if data.ElecSpawns then
			for k,v in pairs(data.ElecSpawns) do
				nz.Mapping.Functions.Electric(v.pos, v.angle, v.model)
			end
		end
		
		if data.BlockSpawns then
			for k,v in pairs(data.BlockSpawns) do
				//If X,Y,Z has been set on it, use those values
				if v.modelX and v.modelY and v.modelZ then
					nz.Mapping.Functions.BlockSpawn(v.pos, v.angle, v.model, v.modelX, v.modelY, v.modelZ)
				else
					nz.Mapping.Functions.BlockSpawn(v.pos, v.angle, v.model)
				end
			end
		end
		
		if data.RandomBoxSpawns then
			for k,v in pairs(data.RandomBoxSpawns) do
				nz.Mapping.Functions.BoxSpawn(v.pos, v.angle)
			end
		end
		
		if data.PerkMachineSpawns then
			for k,v in pairs(data.PerkMachineSpawns) do
				nz.Mapping.Functions.PerkMachine(v.pos, v.angle, v.id)
			end
		end
		
		if data.RBoxHandler then
			for k,v in pairs(data.RBoxHandler) do
				nz.Mapping.Functions.RBoxHandler(v.pos, v.guns, v.angle)
			end
		end
		
		if data.PlayerHandler then
			for k,v in pairs(data.PlayerHandler) do
				nz.Mapping.Functions.PlayerHandler(v.pos, v.angle, v.startwep, v.startpoints, v.numweps, v.eeurl)
			end
		end
		
		if data.EasterEggs then
			for k,v in pairs(data.EasterEggs) do
				nz.Mapping.Functions.EasterEgg(v.pos, v.angle, v.model)
			end
		end
		
		//Normal Map doors
		if data.DoorSetup then
			for k,v in pairs(data.DoorSetup) do
				print(v.flags)
				nz.Doors.Functions.CreateMapDoorLink(k, v.flags)
			end
		end
		
		if version >= 350 then
			//Barricades
			if data.BreakEntry then
				for k,v in pairs(data.BreakEntry) do
					nz.Mapping.Functions.BreakEntry(v.pos, v.angle)
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
				nz.Mapping.Functions.SpawnEffect(v.pos, v.angle, v.model)
			end
		end
		
		if data.SpecialEntities then
			for k,v in pairs(data.SpecialEntities) do
				PrintTable(v)
				local ent = duplicator.CreateEntityFromTable(Entity(1), v)
				table.insert(nz.PropsMenu.Data.SpawnedEntities, ent)
			end
		end
		
		print("[NZ] Finished loading map config.")
	else
		print(filepath)
		print("[NZ] Warning: NO MAP CONFIG FOUND! Make a config in game using the /create command, then use /save to save it all!")
	end
	
end

function nz.Mapping.Functions.CleanUpMap()
	game.CleanUpMap(true, {
		"breakable_entry",
		"breakable_entry_plank",
		"button_elec",
		"perk_machine",
		"player_handler",
		"player_spawns",
		"prop_buys",
		"random_box_spawns",
		"random_box_handler",
		"wall_block",
		"wall_buys",
		"zed_spawns",
		"easter_egg"
	})
	//Gotta reset the doors and other entites' values!
	for k,v in pairs(nz.Doors.Data.LinkFlags) do
		local door = nz.Doors.Functions.doorIndexToEnt(k)
		door.elec = tonumber(v.elec)
		door.price = tonumber(v.price)
		door.link = tonumber(v.link)
		door.buyable = tonumber(v.buyable)
		door.rebuyable = tonumber(v.rebuyable)
		door.Locked = true
		if door:IsDoor() then
			door:DoorLock()
		elseif door:IsButton() then
			door:ButtonLock()
		end
	end
end

hook.Add("Initialize", "nz_Loadmaps", function()
	timer.Simple(5, function()
		nz.Mapping.Functions.LoadConfig("nz_"..game.GetMap()..".txt")
	end)
end)
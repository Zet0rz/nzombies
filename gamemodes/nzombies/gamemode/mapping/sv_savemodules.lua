-- In here we have all default savemodules. You can add your own with the function used here:
-- nzMapping:AddSaveModule(id, {savefunc, loadfunc, cleanents, cleanfunc, prerestorefunc, postrestorefunc})

-- Savefunc should return the table to be written into the save file

-- Loadfunc takes 1 argument, data, which is the saved table

-- Cleanents is a table containing all entity types that should get cleaned when the config is cleared
-- and that should be spared when the map is cleanup for a simple game reset

-- Cleanfunc is run when the config is wiped, like when switching config or /clean (not after each game)
-- It should remove all entities related to your module that aren't in the cleanents table

-- Prerestorefunc is only used for modules that need to "reinitialize" post-map cleanup (NOT config cleanup, MAP cleanup)
-- This is run before the map cleanup, making you able to temporarily save data to use after the map cleanup again
-- This function should only be used for stuff that needs to mark how it is before map cleanup, to reset to that post-cleanup
-- such as SpecialEntities that need to be temporarily duplicate-saved so they can be spawned afterwards
-- It should return a table that will be used in the postrestorefunc

-- Postrestorefunc is only used for stuff that needs to "reintialize" after the map has been cleaned up, like Prerestorefunc
-- It gets an argument, data, which is the table stored from Prerestorefunc, if any
-- This function should be used for stuff such as doors, that otherwise would be cleaned up by map cleanup
-- and thus needs to get their data re-applied.

-- Put simply:
-- savefunc: Run when saved
-- loadfunc: Run when load
-- cleanents: A table containing entities related to module
-- cleanfunc: Run when CONFIG is cleaned (optional)
-- prerestorefunc: Run before MAP is cleaned and NOT config (optional)
-- postrestorefunc: Run after MAP is cleaned and NOT config (optional)

-- Note: MAP is cleaned after EVERY game (restore funcs)!
-- MAP cleanup ignores all entity types in CLEANENTS!
-- Always add entity types that relate to your module that should NOT be removed on reset, but SHOULD on clean!

nzMapping:AddSaveModule("ZedSpawns", {
	savefunc = function()
		local zed_spawns = {}
		for _, v in pairs(ents.FindByClass("nz_spawn_zombie_normal")) do
			table.insert(zed_spawns, {
			pos = v:GetPos(),
			link = v.link
			})
		end
		return zed_spawns
	end,
	loadfunc = function(data)
		for k,v in pairs(data) do
			nzMapping:ZedSpawn(v.pos, v.link)
		end
	end,
	cleanents = {"nz_spawn_zombie_normal"}, -- Simply clean entities of this type
})

nzMapping:AddSaveModule("ZedSpecialSpawns", {
	savefunc = function()
		local zed_special_spawns = {}
		for _, v in pairs(ents.FindByClass("nz_spawn_zombie_special")) do
			table.insert(zed_special_spawns, {
			pos = v:GetPos(),
			link = v.link
			})
		end
		return zed_special_spawns
	end,
	loadfunc = function(data)
		for k,v in pairs(data) do
			nzMapping:ZedSpecialSpawn(v.pos, v.link)
		end
	end,
	cleanents = {"nz_spawn_zombie_special"},
})

nzMapping:AddSaveModule("PlayerSpawns", {
	savefunc = function()
		local player_spawns = {}
		for _, v in pairs(ents.FindByClass("player_spawns")) do
			table.insert(player_spawns, {
			pos = v:GetPos(),
			})
		end
		return player_spawns
	end,
	loadfunc = function(data)
		for k,v in pairs(data) do
			nzMapping:PlayerSpawn(v.pos)
		end
	end,
	cleanents = {"player_spawns"},
})

nzMapping:AddSaveModule("WallBuys", {
	savefunc = function()
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
		return wall_buys
	end,
	loadfunc = function(data)
		for k,v in pairs(data) do
			nzMapping:WallBuy(v.pos,v.wep, v.price, v.angle, nil, nil, v.flipped)
		end
	end,
	cleanents = {"wall_buys"},
	postrestorefunc = function(data) -- Post-map cleanup restoration (game reset)
		-- Reset bought status on wall buys
		for k,v in pairs(ents.FindByClass("wall_buys")) do
			v:SetBought(false)
		end
	end,
})

nzMapping:AddSaveModule("BuyablePropSpawns", {
	savefunc = function()
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
			collision = v:GetCollisionGroup(),
			})
		end
		return buyableprop_spawns
	end,
	loadfunc = function(data)
		for k,v in pairs(data) do
			local prop = nzMapping:PropBuy(v.pos, v.angle, v.model, v.flags)
			prop:SetCollisionGroup(v.collision or COLLISION_GROUP_NONE)
		end
	end,
	cleanents = {"prop_buys"},
})

nzMapping:AddSaveModule("PropEffects", {
	savefunc = function()
		local prop_effects = {}
		for _, v in pairs(ents.FindByClass("nz_prop_effect")) do
			table.insert(prop_effects, {
			pos = v:GetPos(),
			angle = v:GetAngles(),
			model = v.AttachedEntity:GetModel(),
			})
		end
		return prop_effects
	end,
	loadfunc = function(data)
		for k,v in pairs(data) do
			nzMapping:SpawnEffect(v.pos, v.angle, v.model)
		end
	end,
	cleanents = {"nz_prop_effect", "nz_prop_effect_attachment"},
})

nzMapping:AddSaveModule("EasterEggs", {
	savefunc = function()
		local easter_eggs = {}
		for _, v in pairs(ents.FindByClass("easter_egg")) do
			table.insert(easter_eggs, {
			pos = v:GetPos(),
			angle = v:GetAngles(),
			model = v:GetModel(),
			})
		end
		return easter_eggs
	end,
	loadfunc = function(data)
		for k,v in pairs(data) do
			nzMapping:EasterEgg(v.pos, v.angle, v.model)
		end
	end,
	cleanents = {"easter_egg"},
})

nzMapping:AddSaveModule("ElecSpawns", {
	savefunc = function()
		local elec_spawn = {}
		for _, v in pairs(ents.FindByClass("power_box")) do
			table.insert(elec_spawn, {
			pos = v:GetPos(),
			angle = v:GetAngles( ),
			})
		end
		return elec_spawn
	end,
	loadfunc = function(data)
		for k,v in pairs(data) do
			nzMapping:Electric(v.pos, v.angle)
		end
	end,
	cleanents = {"power_box", "button_elec"}, -- Cleans two entity types
})
	
nzMapping:AddSaveModule("BlockSpawns", {
	savefunc = function()
		local block_spawns = {}
		for _, v in pairs(ents.FindByClass("wall_block")) do
			table.insert(block_spawns, {
			pos = v:GetPos(),
			angle = v:GetAngles(),
			model = v:GetModel(),
			})
		end
		return block_spawns
	end,
	loadfunc = function(data)
		for k,v in pairs(data) do
			nzMapping:BlockSpawn(v.pos, v.angle, v.model)
		end
	end,
	cleanents = {"wall_block"},
})

nzMapping:AddSaveModule("RandomBoxSpawns", {
	savefunc = function()
		local randombox_spawn = {}
		for _, v in pairs(ents.FindByClass("random_box_spawns")) do
			table.insert(randombox_spawn, {
			pos = v:GetPos(),
			angle = v:GetAngles(),
			spawn = v.PossibleSpawn,
			})
		end
		return randombox_spawn
	end,
	loadfunc = function(data)
		for k,v in pairs(data) do
			nzMapping:BoxSpawn(v.pos, v.angle, v.spawn)
		end
	end,
	cleanents = {"random_box_spawns"},
})

nzMapping:AddSaveModule("PerkMachineSpawns", {
	savefunc = function()
		local perk_machinespawns = {}
		for _, v in pairs(ents.FindByClass("perk_machine")) do
			table.insert(perk_machinespawns, {
				pos = v:GetPos(),
				angle = v:GetAngles(),
				id = v:GetPerkID(),
			})
		end
		for _, v in pairs(ents.FindByClass("wunderfizz_machine")) do
			table.insert(perk_machinespawns, {
				pos = v:GetPos(),
				angle = v:GetAngles(),
				id = "wunderfizz",
			})
		end
		return perk_machinespawns
	end,
	loadfunc = function(data)
		for k,v in pairs(data) do
			nzMapping:PerkMachine(v.pos, v.angle, v.id)
		end
	end,
	cleanents = {"perk_machine", "wunderfizz_machine", "wunderfizz_windup"},
})

nzMapping:AddSaveModule("DoorSetup", {
	savefunc = function()
		local door_setup = {}
		for k,v in pairs(nzDoors.MapDoors) do
			local flags = ""
			for k2, v2 in pairs(v.flags) do
				flags = flags .. k2 .. "=" .. v2 .. ","
			end
			flags = string.Trim(flags, ",")
			door = nzDoors:DoorIndexToEnt(k)
			if door:IsDoor() then
				door_setup[k] = {
				flags = flags,
				}
				--print(door.Data)
			end
		end
		return door_setup
	end,
	loadfunc = function(data)
		for k,v in pairs(data) do
			--print(v.flags)
			nzDoors:CreateMapDoorLink(k, v.flags)
		end
	end, 
	cleanfunc = function()
		-- Cleans up differently, does not return any entity types
		for k,v in pairs(nzDoors.MapDoors) do
			nzDoors:RemoveMapDoorLink( k )
		end
		
		-- This module is responsible for both prop doors and map doors
		nzDoors.MapDoors = {}
		nzDoors.PropDoors = {}
		-- Clear all door data on clients
		net.Start("nzClearDoorData")
		net.Broadcast()
	end, 
	postrestorefunc = function(data)
		-- Doors are reset by map cleanup, we loop through the data and reapply them!
		for k,v in pairs(nzDoors.MapDoors) do
			local door = nzDoors:DoorIndexToEnt(k)
			door:SetLocked(true)
			if door:IsDoor() then
				door:LockDoor()
			elseif door:IsButton() then
				door:LockButton()
			end
			nzDoors.SendSync( ply )
		end
	end,
})

nzMapping:AddSaveModule("BreakEntry", {
	savefunc = function()
		local break_entry = {}
		for _, v in pairs(ents.FindByClass("breakable_entry")) do
			table.insert(break_entry, {
				pos = v:GetPos(),
				angle = v:GetAngles(),
				planks = v:GetHasPlanks(),
				jump = v:GetTriggerJumps(),
			})
		end
		return break_entry
	end,
	loadfunc = function(data)
		for k,v in pairs(data) do
			nzMapping:BreakEntry(v.pos, v.angle, v.planks, v.jump)
		end
	end,
	cleanents = {"breakable_entry", "breakable_entry_plank"},
	postrestorefunc = function(data)
		-- Now we respawn them! :D
		for k,v in pairs(ents.FindByClass("breakable_entry")) do
			if IsValid(v) then
				v:ResetPlanks()
			end
		end
	end,
})

nzMapping:AddSaveModule("SpecialEntities", {
	savefunc = function()
		local special_entities = {}
		for k, v in pairs(nzQMenu.Data.SpawnedEntities) do
			if IsValid(v) then
				table.insert(special_entities, duplicator.CopyEntTable(v))
			else
				nzQMenu.Data.SpawnedEntities[k] = nil
			end
		end
		return special_entities
	end,
	loadfunc = function(data)
		for k,v in pairs(data) do
			--PrintTable(v)
			local ent = duplicator.CreateEntityFromTable(Entity(1), v)
			table.insert(nzQMenu.Data.SpawnedEntities, ent)
		end
	end,
	cleanfunc = function()
		--Specially spawned entities are directly removed, not by type
		for k,v in pairs(nzQMenu.Data.SpawnedEntities) do
			if IsValid(v) then
				v:Remove()
			end
		end
		nzQMenu.Data.SpawnedEntities = {} -- Also cleanup the table from it
	end,
	prerestorefunc = function() -- PRE-map cleanup! Save all special entities before they are wiped!
		local special_entities = {}
		for k,v in pairs(nzQMenu.Data.SpawnedEntities) do
			if IsValid(v) then
				special_entities[v] = duplicator.CopyEntTable(v)
			end
		end
		return special_entities -- Return the data to be used in the next function after the cleanup
	end,
	postrestorefunc = function(data)
		-- Now we respawn them! :D
		for k,v in pairs(data) do
			if !IsValid(k) then -- Only if they aren't still around
				local ent = duplicator.CreateEntityFromTable(Entity(1), v)
				table.insert(nzQMenu.Data.SpawnedEntities, ent)
			end
		end
	end,
})

nzMapping:AddSaveModule("InvisWalls", {
	savefunc = function()
		-- Store all invisible walls with their boundaries and angles
		local invis_walls = {}
		for _, v in pairs(ents.FindByClass("invis_wall")) do
			table.insert(invis_walls, {
				pos = v:GetPos(),
				maxbound = v:GetMaxBound(),
			})
		end
		return invis_walls
	end,
	loadfunc = function(data)
		for k,v in pairs(data) do
			nzMapping:CreateInvisibleWall(v.pos, v.maxbound)
		end
	end,
	cleanents = {"invis_wall"},
})

nzMapping:AddSaveModule("DamageWalls", {
	savefunc = function()
		local invis_damage_walls = {}
		for _, v in pairs(ents.FindByClass("invis_damage_wall")) do
			table.insert(invis_damage_walls, {
				pos = v:GetPos(),
				maxbound = v:GetMaxBound(),
				damage = v:GetDamage(),
				delay = v:GetDelay(),
				radiation = v:GetRadiation(),
				poison = v:GetPoison(),
				tesla = v:GetTesla(),
			})
		end
		return invis_damage_walls
	end,
	loadfunc = function(data)
		for k,v in pairs(data) do
			nzMapping:CreateInvisibleDamageWall(v.pos, v.maxbound, nil, v.damage, v.delay, v.radiation, v.poison, v.tesla)
		end
	end,
	cleanents = {"invis_damage_wall"},
})

//

function nz.Enemies.Functions.CheckIfSuitable(pos)

	local Ents = ents.FindInBox( pos + Vector( -16, -16, 0 ), pos + Vector( 16, 16, 64 ) )
	local Blockers = 0
	if Ents == nil then return true end
	for k, v in pairs( Ents ) do
		if ( IsValid( v ) and (v:GetClass() == "player" or nz.Config.ValidEnemies[v:GetClass()] ) ) then
			Blockers = Blockers + 1
		end
	end

	if Blockers == 0 then
		return true
	end

	return false

end

function nz.Enemies.Functions.ValidSpawns(zclass)

	local spawns = {}
	local spawntype = "zed_spawns"
	if nz.Config.ValidEnemies[zclass] and nz.Config.ValidEnemies[zclass].SpecialSpawn then
		spawntype = "zed_special_spawns"
	end
	
	-- Make a table of spawns
	for _, ply in pairs(player.GetAllPlayingAndAlive()) do
		-- Get all spawns in the range
		for _,v2 in pairs(ents.FindInSphere(ply:GetPos(), 2500)) do
			if v2:GetClass() == spawntype and (v2.spawnable == nil or tobool(v2.spawnable)) then
				-- If enable, then if the player is in the same area group as the spawnpoint
				if !GetConVar("nz_nav_grouptargeting"):GetBool() or nz.Nav.Functions.IsInSameNavGroup(ply, v2) then
					if v2:GetPos():DistToSqr(ply:GetPos()) > 22500 then
						local nav = navmesh.GetNearestNavArea( v2:GetPos() )
						--check if navmesh is close
						if IsValid(nav) and nav:GetClosestPointOnArea( v2:GetPos() ):DistToSqr( v2:GetPos() ) < 10000 then
							table.insert(spawns, v2)
						end
					end
				end
			end
		end
	end

	-- Removed unopened linked doors
	for k,v in pairs(spawns) do
		if v.link != nil then
			if !Doors.OpenedLinks[tonumber(v.link)] then -- Zombie Links
				spawns[k] = nil
			end
		end
	end

	return spawns
end

function nz.Enemies.Functions.TotalCurrentEnemies()
	local c = 0

	-- Count
	for k,v in pairs(nz.Config.ValidEnemies) do
		c = c + #ents.FindByClass(k)
	end

	return c
end

function nz.Enemies.Functions.SpawnZombie(spawnpoint, zclass)
	if nz.Enemies.Functions.TotalCurrentEnemies() < GetConVar("nz_difficulty_max_zombies_alive"):GetInt() then
		if !IsValid(spawnpoint) then return end

		local zombie = ents.Create(zclass)
		zombie:SetPos(spawnpoint:GetPos())
		zombie:Spawn()
		zombie:Activate()

		Round:IncrementZombiesSpawned()
		print("Spawning Enemy: " .. Round:GetZombiesSpawned() .. "/" .. Round:GetZombiesMax() )
	else
		print("Limit of Zombies Reached!")
	end
end


function nz.Enemies.Functions.ZombieSpawner()
	-- Not enough Zombies
	if CurTime() >= Round:GetNextSpawnTime() and Round:InState( ROUND_PROG ) then
		if Round:GetZombiesSpawned() < Round:GetZombiesMax() then
		
			local zclass = nz.Misc.Functions.WeightedRandom( Round:GetZombieData(), "chance")
			print(zclass)
			local valids = nz.Enemies.Functions.ValidSpawns(zclass)
			PrintTable(valids)

			if #valids == 0  then
				print("No valid spawns were found!")
				Round:SetNextSpawnTime(CurTime() + 1)
				return
				-- Since we couldn't find a valid spawn, just back out for now.
			end

			local spawnpoint = table.Random(valids)
			
			Round:SetNextSpawnTime(CurTime() + 1) -- Default to 1; zombies spawned below can change that

			if nz.Enemies.Functions.CheckIfSuitable(spawnpoint:GetPos()) then
				nz.Enemies.Functions.SpawnZombie(spawnpoint, zclass)
			end
		end
	end
end

hook.Add("Think", "ZombieSpawnThink", nz.Enemies.Functions.ZombieSpawner)

function nz.Enemies.Functions.ValidRespawns(cur, zclass)
	local spawns = nz.Enemies.Functions.ValidSpawns(zclass)
	table.RemoveByValue(spawns, cur)

	return spawns
end

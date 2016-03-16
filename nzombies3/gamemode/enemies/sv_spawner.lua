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

function nz.Enemies.Functions.ValidSpawns()

	local spawns = {}

	//Make a table of spawns
	for k,v in pairs(team.GetPlayers(TEAM_PLAYERS)) do
		//Get all spawns in the range
		for k2,v2 in pairs(ents.FindInSphere(v:GetPos(), 1200)) do
			if v2:GetClass() == "zed_spawns" and (v.spawnable == nil or tobool(v.spawnable)) then
				//If enable, then if the player is in the same area group as the spawnpoint
				if nz.Config.NavGroupTargeting and nz.Nav.Functions.IsInSameNavGroup(v, v2) then
					table.insert(spawns, v2)
				end
			end
		end
		//Remove all spawns that are too close
		for k2,v2 in pairs(ents.FindInSphere(v:GetPos(), 200)) do
			if table.HasValue(spawns, v2) then
				table.RemoveByValue(spawns, v2)
			end
		end
	end

	//Removed unopened linked doors
	for k,v in pairs(spawns) do
		if v.link != nil then
			if !Doors.OpenedLinks[tonumber(v.link)] then //Zombie Links
				spawns[k] = nil
			end
		end
	end

	return spawns
end

function nz.Enemies.Functions.TotalCurrentEnemies()
	local c = 0

	--Count
	for k,v in pairs(nz.Config.ValidEnemies) do
		c = c + #ents.FindByClass(k)
	end

	return c
end

function nz.Enemies.Functions.SpawnZombie(spawnpoint)
	if nz.Enemies.Functions.TotalCurrentEnemies() < nz.Config.MaxZombiesSim then
		local ent = "nz_zombie_walker"

		--Get the latest round number from the table
		for i = Round:GetNumber(), 0, -1 do
			if nz.Config.EnemyTypes[i] != nil then
				--Use weightkey "chance" as defined in the new config format
				ent = nz.Misc.Functions.WeightedRandom( Round:GetZombieData(), "chance")
				break
			end
		end

		if !IsValid(spawnpoint) then return end

		local zombie = ents.Create(ent)
		zombie:SetPos(spawnpoint:GetPos())
		zombie:Spawn()
		zombie:Activate()

		Round:IncrementZombiesSpawned()
		print("Spawning Enemy: " .. Round:GetZombiesSpawned().. "/" .. Round:GetZombiesMax() )
	else
		print("Limit of Zombies Reached!")
	end
end


function nz.Enemies.Functions.ZombieSpawner()
	//Not enough Zombies
	if Round:InState( ROUND_PROG ) then
		if Round:GetZombiesSpawned() < Round:GetZombiesMax() then

			local valids = nz.Enemies.Functions.ValidSpawns()

			if valids[1] == nil then
				print("No valid spawns were found!")
				return
				--Since we couldn't find a valid spawn, just back out for now.
			end

			local spawnpoint = table.Random(valids)

			if nz.Enemies.Functions.CheckIfSuitable(spawnpoint:GetPos()) then
				nz.Enemies.Functions.SpawnZombie(spawnpoint)
			end
		end
	end
end

timer.Create("nz.Rounds.ZombieSpawner", 1, 0, nz.Enemies.Functions.ZombieSpawner)

function nz.Enemies.Functions.ValidRespawns(cur)

	local spawns = {}

	//Make a table of spawns
	for k,v in pairs(team.GetPlayers(TEAM_PLAYERS)) do
		//Get all spawns in the range
		for k2,v2 in pairs(ents.FindInSphere(v:GetPos(), 1500)) do
			if v2:GetClass() == "zed_spawns" and (!v.spawnable or tobool(v.spawnable)) and v2 != cur then
				if nz.Config.NavGroupTargeting and nz.Nav.Functions.IsInSameNavGroup(v, v2) then
					table.insert(spawns, v2)
				end
			end
		end
		//Remove all spawns that are too close
		for k2,v2 in pairs(ents.FindInSphere(v:GetPos(), 200)) do
			if table.HasValue(spawns, v2) then
				table.RemoveByValue(spawns, v2)
			end
		end
	end

	//Removed unopened linked doors
	for k,v in pairs(spawns) do
		if v.link != nil then
			if Doors.OpenedLinks[tonumber(v.link)] == nil then //Zombie Links
				spawns[k] = nil
			end
		end
	end

	return spawns
end

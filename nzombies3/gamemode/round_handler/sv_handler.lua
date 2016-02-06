//

local CurRoundOverSpawned = false

function nz.Rounds.Functions.CheckPrerequisites()

	//If there is there is less than one player
	if #player.GetAll() < 1 then
		return //"Not enough players to start a game."
	end

	//Check if zed/player spawns have been setup
	if nz.Mapping.Functions.CheckSpawns() == false then
		return "No Zombie/Player spawns have been set."
	end

	//Check if we have enough player spawns
	if nz.Mapping.Functions.CheckEnoughPlayerSpawns() == false then
		return "Not enough player spawns have been set. We need " .. #player.GetAll() .. " but only have " .. #ents.FindByClass("player_spawns") .. "."
	end

	//If enough players are ready
	if nz.Rounds.Functions.CheckReady() == false then
		return "Not enough players have readied up."
	end


	//All Checks have passed, lets go!
	if nz.Rounds.Data.StartTime == nil then
		nz.Rounds.Data.StartTime = CurTime() + 5
		print("All checks passed, starting in 5 seconds.")
		PrintMessage( HUD_PRINTTALK, "5 seconds till start time." )
	end

	local str = ""
	//Get the players that are playing
	for k,v in pairs(player.GetAll()) do
		if v.Ready == 1 and v:IsValid() then
			str = str .. v:Nick() .. ", "
		end
	end
	PrintMessage( HUD_PRINTTALK, "Players that will be playing: " .. str )

	return true

end

function nz.Rounds.Functions.PrepareRound()

	//Main Behaviour
	nz.Rounds.Data.CurrentState = ROUND_PREP
	nz.Rounds.Functions.SendSync()
	nz.Rounds.Data.CurrentRound = nz.Rounds.Data.CurrentRound + 1

	if nz.Config.EnemyTypes[nz.Rounds.Data.CurrentRound] and nz.Config.EnemyTypes[nz.Rounds.Data.CurrentRound].count then
		nz.Rounds.Data.MaxZombies = nz.Config.EnemyTypes[nz.Rounds.Data.CurrentRound].count
		print("Round "..nz.Rounds.Data.CurrentRound.." has a special count: "..nz.Rounds.Data.MaxZombies)
	else
		nz.Rounds.Data.MaxZombies = nz.Curves.Data.SpawnRate[nz.Rounds.Data.CurrentRound]
	end
	nz.Rounds.Data.KilledZombies = 0
	nz.Rounds.Data.ZombiesSpawned = 0
	
	if nz.Config.EnemyTypes[nz.Rounds.Data.CurrentRound] then
		nz.Rounds.CurrentRoundData = nz.Config.EnemyTypes[nz.Rounds.Data.CurrentRound]
	end

	//Notify
	PrintMessage( HUD_PRINTTALK, "ROUND: "..nz.Rounds.Data.CurrentRound.." preparing" )
	hook.Run("nz.Round.Prep", nz.Rounds.Data.CurrentRound)
	//Play the sound
	if nz.Rounds.Data.CurrentRound == 1 then
		--nz.Mapping.Functions.CleanUpMap()
		--nz.Notifications.Functions.PlaySound("nz/round/round_start.mp3", 1)
	else
		nz.Notifications.Functions.PlaySound("nz/round/round_end.mp3", 1)
	end

	//Spawn all players
	//Check config for dropins
	//For now, only allow the players who started the game to spawn
	for k,v in pairs(nz.Rounds.Data.CurrentPlayers) do
		nz.Rounds.Functions.ReSpawn(v)
	end

	//Heal
	for k,v in pairs(nz.Rounds.Data.CurrentPlayers) do
		v:SetHealth(v:GetMaxHealth())
	end
	
	//Set this to reset the overspawn debug message status
	CurRoundOverSpawned = false

	//Start the next round
	timer.Simple(nz.Config.PrepareTime, function() nz.Rounds.Functions.StartRound() end)

end

function nz.Rounds.Functions.StartRound()

	if nz.Rounds.Data.CurrentState != ROUND_GO then
		//Main Behaviour
		nz.Rounds.Data.CurrentState = ROUND_PROG
		nz.Rounds.Functions.SendSync()
		//Notify
		PrintMessage( HUD_PRINTTALK, "ROUND: "..nz.Rounds.Data.CurrentRound.." started" )
		hook.Run("nz.Round.Start", nz.Rounds.Data.CurrentRound)
		nz.Notifications.Functions.PlaySound("nz/round/round_start.mp3", 1)
	end

end

function nz.Rounds.Functions.ResetGame()
	//Main Behaviour
	nz.Doors.Functions.LockAllDoors()
	nz.Rounds.Data.CurrentState = ROUND_INIT
	nz.Rounds.Functions.SendSync()
	//Notify
	PrintMessage( HUD_PRINTTALK, "GAME READY!" )
	//Reset variables
	nz.Rounds.Data.CurrentRound = 0

	nz.Rounds.Data.KilledZombies = 0
	nz.Rounds.Data.ZombiesSpawned = 0
	nz.Rounds.Data.MaxZombies = 0

	//Reset all player ready states
	for k,v in pairs(player.GetAll()) do
		nz.Rounds.Functions.UnReady(v)
	end
	//Reset all downed players' downed status
	for k,v in pairs(nz.Revive.Data.Players) do
		k:KillDownedPlayer(true, true) 	//We set nosync on because we only need to sync once.
	end
	nz.Revive.Functions.SendSync()
	//Remove all enemies
	for k,v in pairs(nz.Config.ValidEnemies) do
		for k2,v2 in pairs(ents.FindByClass(k)) do
			v2:Remove()
		end
	end
	//Empty the table of stored players
	table.Empty(nz.Rounds.Data.CurrentPlayers)
	//Reset the electricity
	nz.Elec.Functions.Reset()
	//Remove the random box
	nz.RandomBox.Functions.RemoveBox()

	//Reset all perk machines
	for k,v in pairs(ents.FindByClass("perk_machine")) do
		v:TurnOff()
	end

	for k,v in pairs(player.GetAll()) do
		v:SetPoints(0) //Reset all player points
		v:RemovePerks() //Remove all players perks
	end

	//Clean up powerups
	nz.PowerUps.Functions.CleanUp()
	
	//Reset easter eggs
	nz.EE.Functions.Reset()
	
	//Reset merged navigation groups
	nz.Nav.ResetNavGroupMerges()

end

function nz.Rounds.Functions.EndRound()
	if nz.Rounds.Data.CurrentState != ROUND_GO then
		//Main Behaviour
		nz.Rounds.Data.CurrentState = ROUND_GO
		nz.Rounds.Functions.SendSync()
		//Notify
		PrintMessage( HUD_PRINTTALK, "GAME OVER!" )
		PrintMessage( HUD_PRINTTALK, "Restarting in 10 seconds!" )
		nz.Notifications.Functions.PlaySound("nz/round/game_over_4.mp3", 21)
		timer.Simple(10, function()
			nz.Rounds.Functions.ResetGame()
		end)
	else
		//This if statement is to prevent the game from ending twice if all players die during preparing
	end
end

function nz.Rounds.Functions.CreateMode()

	if nz.Rounds.Data.CurrentState == ROUND_INIT then
		PrintMessage( HUD_PRINTTALK, "The mode has been set to creative mode!" )
		nz.Rounds.Data.CurrentState = ROUND_CREATE
		//We are in create
		for k,v in pairs(player.GetAll()) do
			if v:IsSuperAdmin() then
				nz.Rounds.Functions.Create(v)
			end
		end
		
		//Re-enable navmesh visualization
		for k,v in pairs(nz.Nav.Data) do
			local navarea = navmesh.GetNavAreaByID(k)
			if v.link then
				navarea:SetAttributes(NAV_MESH_STOP)
			else 
				navarea:SetAttributes(NAV_MESH_AVOID) 
			end
		end
		
	elseif nz.Rounds.Data.CurrentState == ROUND_CREATE then
		PrintMessage( HUD_PRINTTALK, "The mode has been set to play mode!" )
		nz.Rounds.Data.CurrentState = ROUND_INIT
		//We are in play mode
		for k,v in pairs(player.GetAll()) do
			v:SetAsSpec()
		end
		
		//Set them to not solid to make Traces go through (gunshots)
		for k,v in pairs(ents.FindByClass("nav_gate")) do
			v:SetNotSolid(true)
		end
		for k,v in pairs(ents.FindByClass("nav_room_controller")) do
			v:SetNotSolid(true)
		end
	end
	nz.Rounds.Functions.SendSync()
end

function nz.Rounds.Functions.SetupGame()

	//Store a session of all our players
	for k,v in pairs(player.GetAll()) do
		if v:IsValid() and !v:IsPermSpec() then
			nz.Rounds.Functions.AddPlayer(v)
		end
		v.Ready = 0
		v:SetFrags(0) //Reset all player kills
	end

	nz.Mapping.Functions.CleanUpMap()
	nz.Doors.Functions.LockAllDoors()
	
	//Reset navigation attributes so they don't save into the actual .nav file.
	for k,v in pairs(nz.Nav.Data) do
		navmesh.GetNavAreaByID(k):SetAttributes(v.prev)
	end

	//Open all doors with no price and electricity requirement
	for k,v in pairs(ents.GetAll()) do
		if v:IsDoor() or v:IsBuyableProp() then
			if v.price == 0 and v.elec == 0 then
				nz.Doors.Functions.OpenDoor( v )
			end
		end
		//Setup barricades
		if v:GetClass() == "breakable_entry" then
			v:ResetPlanks()
		end
	end

	//Empty the link table
	table.Empty(nz.Doors.Data.OpenedLinks)

	//All doors with Link 0 (No Link)
	nz.Doors.Data.OpenedLinks[0] = true
	nz.Doors.Functions.SendSync()

	//Spawn a random box
	nz.RandomBox.Functions.SpawnBox()
	//Clear the start time
	nz.Rounds.Data.StartTime = nil


end

function nz.Rounds.Functions.RoundHandler()

	//If the game hasn't been started yet
	if nz.Rounds.Data.CurrentState == ROUND_INIT then
		local pre = nz.Rounds.Functions.CheckPrerequisites()
		if pre == true then
			if CurTime() > nz.Rounds.Data.StartTime then
				nz.Rounds.Functions.SetupGame()
				nz.Rounds.Functions.PrepareRound()
			end
		else
			//Reset the start timer
			nz.Rounds.Data.StartTime = nil
			// notify why, just print for now
			--if pre != nil then print(pre) end
			return //Don't process any further than here
		end

	elseif nz.Rounds.Data.CurrentState == ROUND_CREATE then
		//Un-ready all players
		for k,v in pairs(player.GetAll()) do
			nz.Rounds.Functions.UnReady(v, "You have been set to un-ready since the game has been set to creative mode")
		end
		return //Don't process any further than here
	end

	//If all players are dead, then end the game.
	if !nz.Rounds.Functions.CheckAlive() and nz.Rounds.Functions.IsInGame() then
		nz.Rounds.Functions.EndRound()
	end

	local numzombies = nz.Enemies.Functions.TotalCurrentEnemies()
	
	//If we've killed all the zombies, then progress to the next level.
	if (nz.Rounds.Data.KilledZombies >= nz.Rounds.Data.MaxZombies) and nz.Rounds.Data.CurrentState == ROUND_PROG then
		if numzombies <= 0 then
			nz.Rounds.Functions.PrepareRound()
		elseif !CurRoundOverSpawned then //To not spam it every second upon overspawning - only once per round (reset on Prepare)
			print("The wave was overspawning by "..numzombies.."! Kill the remaining zombies to progress.")
			CurRoundOverSpawned = true
		end
	end
	
	//Uh-oh! Looks like all zombies have spawned, yet they aren't enough to satisfy the round limit!
	if (nz.Rounds.Data.ZombiesSpawned >= nz.Rounds.Data.MaxZombies) and numzombies < (nz.Rounds.Data.MaxZombies - nz.Rounds.Data.KilledZombies) and nz.Rounds.Data.CurrentState == ROUND_PROG then
		local diff = (nz.Rounds.Data.MaxZombies - nz.Rounds.Data.KilledZombies) - numzombies
		//Apparently not?
		if diff <= 0 then return end
		
		nz.Rounds.Data.ZombiesSpawned = nz.Rounds.Data.ZombiesSpawned - diff
		print("The wave was underspawning by "..diff.."! Spawning more zombies ...")
	end

end

timer.Create("nz.Rounds.Handler", 1, 0, nz.Rounds.Functions.RoundHandler)

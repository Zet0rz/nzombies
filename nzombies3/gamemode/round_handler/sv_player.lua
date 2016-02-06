//

//Player Functions

function nz.Rounds.Functions.ReadyUp(ply)
	if ply.Ready == nil then ply.Ready = 0 end

	if ply:IsPermSpec() then
		ply:PrintMessage( HUD_PRINTTALK, "You can't ready up because you are a perm spectator!" )
		return
	end

	if nz.Rounds.Data.CurrentState == ROUND_INIT then
		if ply.Ready == 0 then
			PrintMessage( HUD_PRINTTALK, ply:Nick().." is ready!" )
			ply.Ready = 1
		else
			ply:PrintMessage( HUD_PRINTTALK, "You are already ready!" )
		end
	elseif nz.Rounds.Data.CurrentState == ROUND_PROG or nz.Rounds.Data.CurrentState == ROUND_PREP then
		ply:PrintMessage( HUD_PRINTTALK, "You can't ready up right now, use /dropin to spawn next round." )
		nz.Rounds.Functions.DropIn(ply)
	end
end

function nz.Rounds.Functions.DropIn(ply)
	if nz.Config.AllowDropins == true and !table.HasValue(nz.Rounds.Data.CurrentPlayers, ply) then
		PrintMessage( HUD_PRINTTALK, ply:Nick().." will be dropping in next round!" )
		nz.Rounds.Functions.AddPlayer(ply)
	end
end

function nz.Rounds.Functions.DropOut(ply)
	if table.HasValue(nz.Rounds.Data.CurrentPlayers, ply) then
		PrintMessage( HUD_PRINTTALK, ply:Nick().." has dropped out of the game!" )
		nz.Rounds.Functions.RemovePlayer(ply)
		ply:RevivePlayer() 
		ply:KillSilent()
	end
end

function nz.Rounds.Functions.UnReady(ply, reason)
	if ply.Ready == nil then ply.Ready = 0 end
	if nz.Rounds.Data.CurrentState == ROUND_INIT then
		if ply.Ready == 1 then
			PrintMessage( HUD_PRINTTALK, ply:Nick().." is no longer ready!" )
			ply.Ready = 0
			if reason != nil then
				ply:PrintMessage( HUD_PRINTTALK, reason )
			end
		end
	elseif nz.Rounds.Data.CurrentState == ROUND_PROG or nz.Rounds.Data.CurrentState == ROUND_PREP then
		nz.Rounds.Functions.DropOut(ply)
	end
end

function nz.Rounds.Functions.ReSpawn(ply)

	if !ply:IsValid() then return end
	if ply:IsPermSpec() then return end

	//Setup a player
	ply:SetTeam( TEAM_PLAYERS )
	player_manager.SetPlayerClass( ply, "player_ingame" )
	if !ply:Alive() then
		ply:Spawn()
	end
end

function nz.Rounds.Functions.AddPlayer(ply)
	if ply:IsValid() then
		table.insert(nz.Rounds.Data.CurrentPlayers, ply)
	end
end

function nz.Rounds.Functions.RemovePlayer(ply)
	if table.HasValue(nz.Rounds.Data.CurrentPlayers, ply) then
		table.RemoveByValue(nz.Rounds.Data.CurrentPlayers, ply)
	end
end

function nz.Rounds.Functions.Create(ply)

	//Setup a player
	ply:SetTeam( TEAM_PLAYERS )
	player_manager.SetPlayerClass( ply, "player_create" )
	if !ply:Alive() then
		ply:Spawn()
	end
	//SetPos

end

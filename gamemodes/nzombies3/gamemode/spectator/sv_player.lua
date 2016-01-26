//

//Spectator Functions

function nz.Spectator.Functions.IsSpec(ply)

	if ply:Team() == TEAM_UNASSIGNED or ply:Team() == TEAM_SPECS  then
		return true
	end

	return false
	
end

function nz.Spectator.Functions.SetAsSpec(ply)

	//Set them on to the spectator team
	player_manager.SetPlayerClass( ply, "player_default" )
	ply:SetTeam( TEAM_SPECS )
	if ply:Alive() then
		ply:KillSilent()
	end
	
end

//Perm Spectator Functions
function nz.Spectator.Functions.IsPermSpec(ply)
	if ply.specFlag == nil then
		ply.specFlag = false
	end
	return ply.specFlag
end

function nz.Spectator.Functions.PermSpec(ply)
	if !ply:IsPermSpec() then
		ply.specFlag = true
		nz.Rounds.Functions.RemovePlayer(ply)
		//Notify
		PrintMessage( HUD_PRINTTALK, ply:Nick() .. " has been set to permanent spectator")
		ply:SetAsSpec()
	else
		PrintMessage( HUD_PRINTTALK, ply:Nick() .. " is no longer a permanent spectator")
		ply.specFlag = false
	end
end
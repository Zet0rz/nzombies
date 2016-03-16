//

//Gamemode Functions

function nz.Spectator.Functions.InitialSpawn(ply)

	//Spectator Vars
	if ply.SpecType == nil then
		ply.SpecType = 4
		ply:Spectate( ply.SpecType )
	end
	
	timer.Simple(1, function() ply:SetAsSpec() end)
	
end

function nz.Spectator.Functions.OnDeath(ply)
	if Round:InState( ROUND_CREATE ) and (ply:IsSuperAdmin()) then
		timer.Simple(1, function() ply:Spawn() end)
	else
		timer.Simple(1, function() ply:SetAsSpec() end)
	end
end

function nz.Spectator.Functions.DeathThink(ply)
	
	local livePlayers = team.GetPlayers( TEAM_PLAYERS )

	if ply:KeyPressed( IN_JUMP ) then
		ply.SpecType = ply.SpecType + 1
		if ply.SpecType > 6 then ply.SpecType = 4 end
		ply:Spectate( ply.SpecType )
	elseif ply:KeyPressed( IN_ATTACK ) then
		if !ply.SpecID then ply.SpecID = 1 end
		ply.SpecID = ply.SpecID + 1
		if ply.SpecID > #livePlayers then ply.SpecID = 1 end
		ply:SpectateEntity( livePlayers[ ply.SpecID ] )
	elseif ply:KeyPressed( IN_ATTACK2 ) then
		if !ply.SpecID then ply.SpecID = 1 end
		ply.SpecID = ply.SpecID - 1
		if ply.SpecID <= 0 then ply.SpecID = #livePlayers end
		ply:SpectateEntity( livePlayers[ ply.SpecID ] )
	end
	
end
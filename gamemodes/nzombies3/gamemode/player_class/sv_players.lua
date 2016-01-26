//

function nz.Players.Functions.PlayerNoClip( ply, desiredState )
	if ply:Alive() and nz.Rounds.Data.CurrentState == ROUND_CREATE then
		return ply:IsSuperAdmin()
	end
end

function nz.Players.Functions.FullSync( ply )
	//Electric
	nz.Elec.Functions.SendSync()
	//PowerUps
	nz.PowerUps.Functions.SendSync()
	//Doors
	nz.Doors.Functions.SendSync()
	//Perks
	nz.Perks.Functions.SendSync()
	//Rounds
	nz.Rounds.Functions.SendSync()
	//Revival System
	nz.Revive.Functions.SendSync()
	//Fog
	nz.Fog.Functions.SendSync()
end

function nz.Players.Functions.PlayerInitialSpawn( ply )
	timer.Simple(1, function()
		//Fully Sync
		nz.Players.Functions.FullSync( ply )
	end)
end

function nz.Players.Functions.PlayerDisconnected( ply )
	nz.Rounds.Functions.DropOut(ply)
end

function nz.Players.Functions.FriendlyFire( ply, ent )
	if !ply:GetNotDowned() then return false end
	if ent:IsPlayer() then
		if ply:Team() == ent:Team() then
			return false
		end
	end
end

function GM:PlayerNoClip( ply, desiredState )
	return nz.Players.Functions.PlayerNoClip(ply, desiredState)
end

hook.Add( "PlayerInitialSpawn", "nz.PlayerInitialSpawn", nz.Players.Functions.PlayerInitialSpawn )
hook.Add( "PlayerShouldTakeDamage", "nz.FriendlyFire", nz.Players.Functions.FriendlyFire )
hook.Add( "PlayerDisconnected", "nz.PlayerDisconnected", nz.Players.Functions.PlayerDisconnected )

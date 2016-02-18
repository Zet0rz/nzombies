//

function nz.Players.Functions.PlayerNoClip( ply, desiredState )
	-- We hardcode the "knife" special weapons category to be called from noclip
	local wep = ply:GetSpecialWeaponFromCategory( "knife" )
	if IsValid(wep) and !ply.UsingSpecialWep then
		SpecialWeapons.Weapons[wep:GetClass()].use(ply, wep)
	end
	
	if ply:Alive() and Round:InState( ROUND_CREATE ) then
		return ply:IsSuperAdmin()
	end
end

function nz.Players.Functions.FullSync( ply )
	--Electric
	nz.Elec.Functions.SendSync()
	--PowerUps
	nz.PowerUps.Functions.SendSync()
	--Doors
	--Doors.SendSync( ply )
	--Perks
	nz.Perks.Functions.SendSync()
	--Rounds
	--Round:SendSync( ply ) --handled differently since feb 2016
	--Revival System
	nz.Revive.Functions.SendSync()
	--Fog
	nz.Fog.Functions.SendSync()
	
	-- A full sync module using the new rewrites
	if IsValid(ply) then
		ply:SendFullSync()
	end
end

function nz.Players.Functions.PlayerInitialSpawn( ply )
	timer.Simple(1, function()
		--Fully Sync
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

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
	--nz.Revive.Functions.SendSync() -- Now sends full sync using the module below
	--Fog
	nz.Fog.Functions.SendSync()

	-- A full sync module using the new rewrites
	if IsValid(ply) then
		ply:SendFullSync()
	end
end

local function initialSpawn( ply )
	timer.Simple(1, function()
		-- Fully Sync
		nz.Players.Functions.FullSync( ply )
	end)
end

local function playerLeft( ply )
	-- this was previously hooked to  PlayerDisconnected
	-- it will now detect leaving players via entity removed, to take kicking banning etc into account.
	if ply:IsPlayer() then
		ply:DropOut()
	end
end

local function friendlyFire( ply, ent )
	if !ply:GetNotDowned() then return false end
	if ent:IsPlayer() then
		--Friendly fire is disabled for all players TODO make hardcore setting?
		return false
	end
end

function GM:PlayerNoClip( ply, desiredState )
	return nz.Players.Functions.PlayerNoClip(ply, desiredState)
end

hook.Add( "PlayerInitialSpawn", "nzPlayerInitialSpawn", initialSpawn )
hook.Add( "PlayerShouldTakeDamage", "nzFriendlyFire", friendlyFire )
hook.Add( "EntityRemoved", "nzPlayerLeft", playerLeft )

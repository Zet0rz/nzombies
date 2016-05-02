--Gamemode Overrides

function GM:PlayerInitialSpawn( ply )
	timer.Simple( 0, function() ply:SetSpectator() end )
end

function GM:PlayerDeath( ply, wep, killer )
	ply:SetSpectator()
	ply:SetTargetPriority(TARGET_PRIORITY_NONE)
end

function GM:PlayerDeathThink( ply )

	-- Allow players in creative mode to respawn
	if ply:IsSuperAdmin() and nzRound:InState( ROUND_CREATE ) then
		if ply:KeyDown(IN_JUMP) or ply:KeyDown(IN_ATTACK) then
			ply:Spawn()
			return true
		end
	end

	local players = player.GetAllPlayingAndAlive()

	if ply:KeyPressed( IN_RELOAD ) then
		ply:SetSpectatingType( ply:GetSpectatingType() + 1 )
		if ply:GetSpectatingType() > 5 then
			ply:SetSpectatingType( 4 )
			ply:SetupHands(players[ ply:GetSpectatingID() ])
		end
		ply:Spectate( ply:GetSpectatingType() )
	elseif ply:KeyPressed( IN_ATTACK ) then
		ply:SetSpectatingID( ply:GetSpectatingID() + 1 )
		if ply:GetSpectatingID() > #players then ply:SetSpectatingID( 1 ) end
		ply:SpectateEntity( players[ ply:GetSpectatingID() ] )
	elseif ply:KeyPressed( IN_ATTACK2 ) then
		ply:SetSpectatingID( ply:GetSpectatingID() - 1 )
		if ply:GetSpectatingID() <= 0 then ply:SetSpectatingID( #players ) end
		ply:SpectateEntity( players[ ply:GetSpectatingID() ] )
	end
end

local function disableDeadUse( ply, ent )
	if !ply:Alive() then return false end
end

hook.Add( "PlayerUse", "disableDeadUse", disableDeadUse)

local function disableDeadPickups( ply, ent )
	if !ply:Alive() then return false end
end

hook.Add( "AllowPlayerPickup", "disableDeadPickups", disableDeadPickups)

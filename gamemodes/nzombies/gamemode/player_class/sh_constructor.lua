-- Main Tables
nzPlayers = nzPlayers or AddNZModule("Players")
nzPlayers.Data = nzPlayers.Data or {}

-- Variables

-- Stops players from moving if downed
hook.Add( "SetupMove", "FreezePlayersDowned", function( ply, mv, cmd )
	if !ply:GetNotDowned() then
		mv:SetUpSpeed( 0 )
		cmd:SetUpMove( 0 )
		mv:SetSideSpeed( 0 )
		cmd:SetSideMove( 0 )
		mv:SetForwardSpeed( 0 )
		cmd:SetForwardMove( 0 )
		if cmd:KeyDown( IN_JUMP ) then
			cmd:RemoveKey( IN_JUMP )
		end
		if cmd:KeyDown( IN_DUCK ) then
			cmd:RemoveKey( IN_DUCK )
		end
	end
end )

hook.Add("PlayerSpawn", "SetupHands", function(ply)

	local mdl = ply:GetInfo( "cl_playermodel" )
	ply:SetModel(mdl)
	
	local col = ply:GetInfo( "cl_playercolor" )
	ply:SetPlayerColor( Vector( col ) )

	local col = Vector( ply:GetInfo( "cl_weaponcolor" ) )
	if col:Length() == 0 then
		col = Vector( 0.001, 0.001, 0.001 )
	end
	ply:SetWeaponColor( col )
	
	local skin = ply:GetInfoNum( "cl_playerskin", 0 )
	ply:SetSkin( skin )

	local groups = ply:GetInfo( "cl_playerbodygroups" )
	if ( groups == nil ) then groups = "" end
	local groups = string.Explode( " ", groups )
	for k = 0, ply:GetNumBodyGroups() - 1 do
		ply:SetBodygroup( k, tonumber( groups[ k + 1 ] ) or 0 )
	end
	
	timer.Simple(0, function()
		if IsValid(ply) then ply:SetupHands() end
	end)
	
end)

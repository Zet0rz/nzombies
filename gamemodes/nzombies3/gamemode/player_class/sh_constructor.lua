//Main Tables
nz.Players = {}
nz.Players.Functions = {}
nz.Players.Data = {}

//_ Variables

//Stops players from moving if downed
hook.Add( "SetupMove", "FreezePlayersDowned", function( ply, mv, cmd )
	if !ply:GetNotDowned() then
		mv:SetUpSpeed( 0 )
		cmd:SetUpMove( 0 )
		mv:SetSideSpeed( 0 )
		cmd:SetSideMove( 0 )
		mv:SetForwardSpeed( 0 )
		cmd:SetForwardMove( 0 )
	end
end )
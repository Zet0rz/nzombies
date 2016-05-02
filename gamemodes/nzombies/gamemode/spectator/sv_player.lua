--Get the meta Table
local plyMeta = FindMetaTable( "Player" )
--accessors
AccessorFunc( plyMeta, "iSpectatingID", "SpectatingID", FORCE_NUMBER )
AccessorFunc( plyMeta, "iSpectatingType", "SpectatingType", FORCE_NUMBER )

function plyMeta:SetSpectator()
	if self:Alive() then
		self:KillSilent()
	end
	self:SetTeam( TEAM_SPECTATOR )
	self:SetSpectatingType( OBS_MODE_CHASE )
	self:Spectate( self:GetSpectatingType() )
	self:SetSpectatingID( 1 )
end

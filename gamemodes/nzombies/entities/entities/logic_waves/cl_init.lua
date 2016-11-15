
function ENT:Initialize()
	self:DrawShadow(false)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
end

local GripMaterial = Material( "sprites/grip" )
function ENT:Draw()
	if !nzRound:InState( ROUND_CREATE ) then return end
	render.SetMaterial( GripMaterial )
	render.DrawSprite( self:GetPos(), 16, 16, color_white )
end
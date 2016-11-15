AddCSLuaFile( )

ENT.Type = "anim"
 
ENT.PrintName		= "random_box_spawns"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.NZOnlyVisibleInCreative = true

function ENT:Initialize()
	self:SetModel( "models/hoff/props/mysterybox/box.mdl" )
	self:SetColor( Color(255, 255, 255) )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	--self:SetNotSolid(true)
	--self:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self:DrawShadow( false )
end

if CLIENT then
	function ENT:Draw()
		if nzRound:InState( ROUND_CREATE ) then
			self:DrawModel()
		end
	end
end
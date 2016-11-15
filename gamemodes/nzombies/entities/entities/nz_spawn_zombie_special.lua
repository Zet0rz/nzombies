AddCSLuaFile( )

ENT.Base = "nz_spawn_zombie"
ENT.PrintName = "nz_spawn_zombie_special"

ENT.NZOnlyVisibleInCreative = true

function ENT:Initialize()
	self:SetModel( "models/player/odessa.mdl" )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self:SetColor(Color(255, 0, 0))
	self:DrawShadow( false )
	self:SetSpawnWeight(0)
	self:SetZombiesToSpawn(0)
	self:SetNextSpawn(CurTime())
end
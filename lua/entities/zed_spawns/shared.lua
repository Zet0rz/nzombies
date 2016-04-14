AddCSLuaFile( )

ENT.Type = "anim"
 
ENT.PrintName		= "zed_spawns"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

function ENT:SetupDataTables()

	self:NetworkVar( "String", 0, "Link" )
	
end

function ENT:Initialize()
	self:SetModel( "models/player/odessa.mdl" )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self:SetColor(Color(0, 255, 0))
	self:DrawShadow( false )
end

function ENT:OnRemove()
	if SERVER and table.HasValue(nz.Enemies.Data.RespawnableSpawnpoints, self) then
		table.RemoveByValue(nz.Enemies.Data.RespawnableSpawnpoints, self)
	end
end

if CLIENT then
	function ENT:Draw()
		if Round:InState( ROUND_CREATE ) then
			self:DrawModel()
		end
	end
end

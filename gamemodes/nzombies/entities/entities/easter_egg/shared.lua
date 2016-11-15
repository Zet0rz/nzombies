ENT.Type = "anim"

ENT.PrintName		= "easter_egg"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""


AddCSLuaFile()



function ENT:Initialize()

	self:SetModel( "models/props_lab/huladoll.mdl" )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self.Used = false
	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end
end

function ENT:Use( activator, caller )
	if !self.Used and nzRound:InProgress() then
		nzEE:ActivateEgg( self, activator )
	end
end

function ENT:Draw()
	self:DrawModel()
end

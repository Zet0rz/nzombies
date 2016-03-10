AddCSLuaFile( )

ENT.Type = "anim"

ENT.PrintName		= "pap_weapon_fly"
ENT.Author			= "Zet0r"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

function ENT:Initialize()

	self:SetMoveType( MOVETYPE_FLY )
	self:SetSolid( SOLID_OBB )
	--self:SetCollisionBounds(Vector(-5, -10, -3), Vector(5, 10, 3))
	--self:UseTriggerBounds(true, 1)
	self:SetMoveType(MOVETYPE_FLY)
	self:PhysicsInitBox(Vector(-5, -10, -3), Vector(5, 10, 3))
	self:GetPhysicsObject():EnableCollisions(false)
	self:SetNotSolid(true)
	self:DrawShadow( false )
	self.TriggerPos = self:GetPos()
	
	if SERVER then
		self:SetUseType( SIMPLE_USE )
	end
end

function ENT:SetWepClass(class)
	if IsValid(self.button) then
		self.button:SetWepClass(class)
	end
end

function ENT:CreateTriggerZone()
	if SERVER then
		self.button = ents.Create("pap_weapon_trigger")
		self.button:SetPos(self.TriggerPos)
		self.button:SetAngles(self:GetAngles() - Angle(90,90,0))
		self.button:Spawn()
		self.button:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
		self.button.Owner = self.Owner
		self.button.wep = self
		self.button:SetWepClass(self.WepClass)
	end
end

function ENT:OnRemove()
	if IsValid(self.button) then self.button:Remove() end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end

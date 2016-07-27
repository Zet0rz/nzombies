ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Frag Grenade"
ENT.Author = "Zet0r"

ENT.Spawnable = false
ENT.AdminSpawnable = false

if SERVER then
	AddCSLuaFile("nz_fraggrenade.lua")
end

function ENT:Initialize()
	if SERVER then
		self:SetModel("models/weapons/v_grenade.mdl")
		self:PhysicsInitSphere(2, "grenade")
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
		self:SetSolid(SOLID_VPHYSICS)
		phys = self:GetPhysicsObject()

		if phys and phys:IsValid() then
			phys:Wake()
		end
	end
end


function ENT:PhysicsCollide(data, physobj)
	if SERVER then
		local vel = physobj:GetVelocity():Length()
		if vel > 100 then
			self:EmitSound("weapons/hegrenade/he_bounce-1.wav", 75, 100)
		end

		local LastSpeed = math.max( data.OurOldVelocity:Length(), data.Speed )
		local NewVelocity = physobj:GetVelocity()
		NewVelocity:Normalize()

		LastSpeed = math.max( NewVelocity:Length(), LastSpeed )

		local TargetVelocity = NewVelocity * LastSpeed * 0.6

		physobj:SetVelocity( TargetVelocity )
		self:SetLocalAngularVelocity( AngleRand() )
	end
end

function ENT:SetExplosionTimer( time )

	SafeRemoveEntityDelayed( self, time +1 ) --fallback

	timer.Simple(time, function()
		if IsValid(self) then
			local pos = self:GetPos()
			local owner = self:GetOwner()

			util.BlastDamage(self, owner, pos, 350, 135)

			fx = EffectData()
			fx:SetOrigin(pos)
			fx:SetMagnitude(1)
			util.Effect("Explosion", fx)

			self:Remove()
		end
	end)
end

function ENT:Draw()
	self:DrawModel()
end

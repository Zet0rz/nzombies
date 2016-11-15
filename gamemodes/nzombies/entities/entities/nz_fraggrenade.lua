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
		self:SetModel("models/weapons/w_grenade.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
		self:SetSolid(SOLID_VPHYSICS)
		phys = self:GetPhysicsObject()

		if phys and IsValid(phys) then
			phys:SetMass(8)
			phys:Wake()
			phys:SetAngleDragCoefficient(1000)
			--print(phys:GetMass())
		end
		
		self:CollisionRulesChanged()
	end
end


function ENT:PhysicsCollide(data, physobj)
	if SERVER then
		if self.WidowsWine then
			physobj:SetVelocity(Vector(0,0,0))
			physobj:EnableMotion(false)
			physobj:Sleep()
			
			--self:SetAngles(data.HitNormal:Angle())
			
			if IsValid(data.HitEntity) then
				self:SetParent(data.HitEntity)
			end
		else
			local vel = physobj:GetVelocity():Length()
			if vel > 100 then
				self:EmitSound("weapons/hegrenade/he_bounce-1.wav", 75, 100)
			end

			local LastSpeed = math.max( data.OurOldVelocity:Length(), data.Speed )
			local NewVelocity = physobj:GetVelocity()
			NewVelocity:Normalize()

			LastSpeed = math.max( NewVelocity:Length(), LastSpeed )

			local TargetVelocity = NewVelocity * LastSpeed * 0.8

			physobj:SetVelocity( TargetVelocity )
			--physobj:SetLocalAngularVelocity( AngleRand() )
		end
	end
end

function ENT:SetExplosionTimer( time )

	SafeRemoveEntityDelayed( self, time +1 ) --fallback

	timer.Simple(time, function()
		if IsValid(self) then
			local pos = self:GetPos()
			local owner = self:GetOwner()
			
			util.BlastDamage(self, owner, pos, 350, 50)
			
			if self.WidowsWine then
				local zombls = ents.FindInSphere(pos, 350)
				
				local e = EffectData()
				e:SetMagnitude(1.5)
				e:SetScale(20) -- The time the effect lasts
				
				local fx = EffectData()
				fx:SetOrigin(pos)
				fx:SetMagnitude(1)
				util.Effect("web_explosion", fx)
				
				for k,v in pairs(zombls) do
					if IsValid(v) and v:IsValidZombie() then
						v:ApplyWebFreeze(20)
					end
				end
			end
			
			local fx = EffectData()
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

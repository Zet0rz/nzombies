AddCSLuaFile( )

-- Register teh trap
nzTraps:Register("nz_trap_turret")
ENT.PrintName = "Turret"
ENT.SpawnIcon = "models/weapons/w_mach_m249para.mdl"
ENT.Description = "Simple Turret trap that will attack zombies around it."

ENT.Type = "anim"
ENT.Base = "nz_trapbase"

ENT.fFireRate = 0.1

DEFINE_BASECLASS("nz_trapbase")

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)
	
	self:NetworkVar( "Int", 1, "AttackRange", {KeyName = "nz_turret_attack_range", Edit = {order = 10, type = "Int", min = 0, max = 100000}} )
	self:NetworkVar( "Int", 2, "DamagePerHit", {KeyName = "nz_turret_damage", Edit = {order = 11, type = "Int", min = 0, max = 100000}} )

	self:SetAttackRange(1200)
	self:SetDamagePerHit(20)
end

function ENT:Initialize()
	self:SetModel( "models/weapons/w_mach_m249para.mdl" )
	self:SetModelScale(1.5)
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	local phys = self:GetPhysicsObject()
	phys:EnableMotion(false)
	
	self.fLastTargetCheck = CurTime()
	self.fNextFire = CurTime()
end

-- IMPLEMENT ME
function ENT:OnActivation()
	self:SetActive(true)
end

function ENT:OnDeactivation()
	self:SetActive(false)
end

function ENT:OnReady() end

function ENT:OnRemove()
	
end

function ENT:Think()
	if SERVER then
		if not self:GetActive() then return end

		if self.fLastTargetCheck + 0.5 < CurTime() and not self:HasValidTarget() then
			self:SetTarget(self:GetPriorityTarget())
		end

		if self:HasValidTarget() then
			local targetpos = self.eTarget:GetPos() + self.eTarget:OBBCenter()
			local att = self:LookupAttachment( "muzzle" )
			local muzzlePos = self:GetAttachment( att ).Pos

			local angle = (targetpos - self:GetPos()):Angle()

			self:SetAngles(angle)

			if self.fNextFire < CurTime() then
				local bullet = {
					Damage = self:GetDamagePerHit(),
					Force = 3,
					Src = muzzlePos,
					Dir = self:GetForward(),
					Distance = self:GetAttackRange() * 2,
					Spread = Vector(0.2,0.2,0),
					AmmoType = "Pistol",
					Tracer = 1,
					TracerName
				}

				self:EmitSound("npc/sniper/sniper1.wav")

				self:FireBullets(bullet)

				self.fNextFire = CurTime() + self.fFireRate
			end
		end
	end
end

function ENT:SetTarget( target )
	self.eTarget = target
end

function ENT:GetTarget()
	return self.eTarget
end

function ENT:HasValidTarget()
	return IsValid(self:GetTarget()) and self:GetTarget():IsValidZombie() and self:GetPos():Distance(self.eTarget:GetPos()) < self:GetAttackRange() and self.eTarget:Health() > 0 and self.eTarget:Visible(self)
end

--Targetfinding
function ENT:GetPriorityTarget()

	self.fLastTargetCheck = CurTime()

	local possibleTargets = ents.FindInSphere(self:GetPos(), self:GetAttackRange())

	local zombies = {}

	for _, ent in pairs(possibleTargets) do
		if ent:IsValidZombie() and ent:Visible(self) then
			table.insert(zombies, ent)
		end
	end

	return table.Random(zombies)

end
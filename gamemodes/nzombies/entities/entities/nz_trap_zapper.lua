AddCSLuaFile( )

-- Register teh trap
nzTraps:Register("nz_trap_zapper")
ENT.PrintName = "Tesla Coil"
ENT.SpawnIcon = "models/nzprops/zapper_coil.mdl"
ENT.Description = "Tesla trap that will kill zombies in front of it."

ENT.Type = "anim"
ENT.Base = "nz_trapbase"

ENT.MatDebug = Material("cable/cable2")

DEFINE_BASECLASS("nz_trapbase")

function ENT:SetupDataTables()
	BaseClass.SetupDataTables( self )

	self:NetworkVar( "Float", 2, "ZapDelayMin", {KeyName = "nz_zap_delay_min", Edit = {order = 20, type = "Float", min = 0, max = 100000}} )
	self:NetworkVar( "Float", 3, "ZapDelayMax", {KeyName = "nz_zap_delay_max", Edit = {order = 21, type = "Float", min = 0, max = 100000}} )
	self:NetworkVar( "Float", 4, "NextZap" )

	self:SetZapDelayMin(0.5)
	self:SetZapDelayMax(1)
end

function ENT:Initialize()
	self:SetModel("models/nzprops/zapper_coil.mdl")
	self:SetModelScale(1.2)
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	local phys = self:GetPhysicsObject()
	phys:EnableMotion(false)

	-- self:SetAngles(Angle(180, 0, 0))
end

-- IMPLEMENT ME
function ENT:OnActivation()
	if SERVER then
		self:SetNextZap(CurTime() + math.Rand(self:GetZapDelayMin(), self:GetZapDelayMax()))
		
		--[[local tr = util.TraceLine({
			start = self:GetPos(),
			endpos = self:GetPos() + self:GetUp() * 500,
			mask = MASK_SOLID_BRUSHONLY,
		})
		
		debugoverlay.Cross(tr.HitPos, 30, 5)
		debugoverlay.Cross(self:GetPos(), 30, 5)
		print("Yeh", self:GetPos(), tr.HitPos, Entity(1):GetPos())
		
		
		
		self:SetCollisionBoundsWS(pos1, pos2)]]
	end
end

function ENT:OnDeactivation()
	
end

function ENT:OnReady() end

function ENT:Think()
	if SERVER and self:IsActive() and self:GetNextZap() < CurTime() then
		self:Zap()
	end
end

if CLIENT then
	function ENT:Draw()
		BaseClass.Draw(self)
		local texcoord = math.Rand( 0, 1 )
		render.SetMaterial(self.MatDebug)
		render.DrawBeam(self:GetPos() + self:GetUp() * 10, self:GetPos() + self:GetUp() * 70, 1, texcoord, texcoord + 1, Color( 250, 150, 106 ))
	end
end

function ENT:Zap()
	local tr = util.QuickTrace(self:GetPos(), self:GetUp() * 500, self)

	local ent = tr.Entity
	self:ZapTarget(ent)	

	self:SetNextZap(CurTime() + math.Rand(self:GetZapDelayMin(), self:GetZapDelayMax()))

	-- render effect
	effectData = EffectData()
	-- startpos
	effectData:SetStart(self:GetPos() + self:GetUp() * 10)
	-- end pos
	effectData:SetOrigin(tr.HitPos)
	-- duration
	effectData:SetMagnitude(0.5)

	util.Effect("zapper_lightning", effectData)
end

function ENT:ZapTarget(ent)
	if IsValid(ent) and ent:IsValidZombie() then
		ent:Kill()
	end
end
AddCSLuaFile( )

ENT.Type = "anim"
ENT.Base = "nz_trapbase"

ENT.PrintName = "Turret"

DEFINE_BASECLASS("nz_trapbase")

function ENT:Initialize()
	self:SetModel( "models/props_trainstation/trainstation_ornament001.mdl" )
	self:SetModelScale(0.6)
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )

	if SERVER then
		timer.Simple(0.1, function()
			self.Gun = ents.Create("nz_trap_turret_gun")
			self.Gun:SetParent(self)
			self.Gun:SetPos(self:GetPos() + Vector(0, 0, 56))
			self.Gun:Spawn()
		end)
	end
end

-- IMPLEMENT ME
function ENT:OnActivation()
	self.Gun:SetActive(true)
end

function ENT:OnDeactivation()
	self.Gun:SetActive(false)
end

function ENT:OnReady() end

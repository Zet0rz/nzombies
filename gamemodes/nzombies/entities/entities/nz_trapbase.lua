-- Use this class as base when creating traps

AddCSLuaFile( )

ENT.Type = "anim"
ENT.Base = "nz_activatable"

ENT.PrintName = "nz_trapbase"

DEFINE_BASECLASS("nz_activatable")

function ENT:SetupDataTables()
	BaseClass.SetupDataTables( self )

	self:SetRemoteActivated(true)
end

-- IMPLEMENT ME
function ENT:OnActivation() end

function ENT:OnDeactivation() end

function ENT:OnReady() end

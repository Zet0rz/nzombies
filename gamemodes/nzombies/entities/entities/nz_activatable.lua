AddCSLuaFile( )

-- Interface for stuff taht cna be activated by the player DO NOT USE THIS CLASS create subclasses!

ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.Editable = true

ENT.PrintName = "nz_activatable"

ENT.bIsActivatable = true

function ENT:SetupDataTables()
	self:NetworkVar( "String", 0, "NZName", {KeyName = "nz_name", Edit = {order = 1, type = "Generic"}} )

	self:NetworkVar( "Bool", 0, "Active")
	self:NetworkVar( "Bool", 1, "CooldownActive")
	self:NetworkVar( "Bool", 2, "ElectircityNeeded", {KeyName = "nz_electircityneeded", Edit = {order = 3, type = "Boolean"}} )
	self:NetworkVar( "Bool", 3, "RemoteActivated", {KeyName = "nz_remoteactivated", Edit = {order = 5, type = "Boolean"}} )

	self:NetworkVar( "Float", 0, "Duration", {KeyName = "nz_duration", Edit = {order = 7, type = "Float", min = 0, max = 100000}} )
	self:NetworkVar( "Float", 1, "Cooldown", {KeyName = "nz_cooldown", Edit = {order = 8, type = "Float", min = 0, max = 100000}} )

	self:NetworkVar( "Int", 0, "Cost", {KeyName = "nz_cost", Edit = {order = 9, type = "Int", min = 0, max = 100000}} )

	self:SetActive(false)
	self:SetDuration(60)
	self:SetCooldown(30)
	self:SetCost(0)
	self:SetCooldownActive(false)
	self:SetElectircityNeeded(true)
	self:SetRemoteActivated(false)

	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end
end

function ENT:IsActive() return self:GetActive() end

function ENT:IsCooldownActive() return self:GetCooldownActive() end

function ENT:IsElectircityNeeded() return self:GetElectircityNeeded() end

function ENT:IsRemoteActivated() return self:GetRemoteActivated() end

function ENT:Activation(activator, duration, cooldown)
	self:SetDuration(duration)
	self:SetCooldown(cooldown)
	self:SetActive(true)
	if self:GetDuration() > 0 then
		timer.Create("nz.activatable.timer." .. self:EntIndex(), self:GetDuration(), 1, function() if IsValid(self) then self:Deactivation() end end)
	end
	self:OnActivation(activator, duration, cooldown)
end

function ENT:Deactivation()
	self:SetActive(false)
	self:SetCooldownActive(true)
	if self:GetCooldown() > 0 then
		timer.Create("nz.activatable.cooldown.timer." .. self:EntIndex(), self:GetCooldown(), 1, function() if IsValid(self) then self:Ready() end end)
	end
	self:OnDeactivation()
end

function ENT:Ready()
	self:SetCooldownActive(false)
	self:OnReady()
end

function ENT:Use(act, caller, type, value )
	if not nzElec:IsOn() and self:IsElectircityNeeded() then return end
	if IsValid(caller) and caller:IsPlayer() and not self:IsRemoteActivated() and not self:IsCooldownActive() then
		if caller:CanAfford(self:GetCost()) then
			self:Activation(caller, self:GetCooldown(), self:GetDuration())
			if SERVER then
				caller:TakePoints(self:GetCost())
			end
		end
	end
end

-- IMPLEMENT ME
function ENT:OnActivation() end

function ENT:OnDeactivation() end

function ENT:OnReady() end

function ENT:OnPoweredOff() end

function ENT:GetNZTargetText()
	if self:IsActive() then return "Already activated" end
	if self:IsCooldownActive() then return "On cooldown" end
	if not self:IsElectircityNeeded() and nzElec:IsOn() and self:IsRemoteActivated() then
		return false
	end
	if self:IsElectircityNeeded() and not nzElec:IsOn() then
		return "Electricity required!"
	else
		if self:IsRemoteActivated() then return false end
		if self:GetCost() > 0 then
			return "Press E to activate " .. self:GetNZName() .. " for " .. self:GetCost() .. "points."
		else
			return "Press E to activate " .. self:GetNZName() .. "."
		end
	end
end

-- util
function ENT:GetEntsByNZName(name)
	local result = {}
	if not name or name == "" then return result end
	for _, ent in pairs(ents.GetAll()) do
		if ent:IsActivatable() then
			if ent:GetNZName() == name then
				table.insert(result, ent)
			end
		end
	end
	return result
end

--Default stuff
if CLIENT then

	function ENT:Draw()

		self:DrawModel()

	end

end

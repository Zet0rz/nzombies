AddCSLuaFile( )

ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.PrintName = "nz_button_and"

DEFINE_BASECLASS("nz_button")

function ENT:ButtonSetupDataTables()
	self:NetworkVar( "String", 1, "ActivatorNZName1", {KeyName = "nz_activator_name1", Edit = {order = 20, type = "Generic"}} )
	self:NetworkVar( "String", 2, "ActivatorNZName2", {KeyName = "nz_activator_name2", Edit = {order = 21, type = "Generic"}} )
	self:NetworkVar( "String", 3, "LinkedNZName", {KeyName = "nz_linked_name1", Edit = {order = 22, type = "Generic"}} )

	self:SetRemoteActivated(true)
end

function ENT:GetLinkedEnts()
	local result = {}
	table.insert(result, self:GetEntsByNZName(self:GetLinkedNZName()))
	return result
end

function ENT:GetActivatorEnts()
	local result = {}
	table.insert(result, self:GetEntsByNZName(self:GetActivatorNZName1()))
	table.insert(result, self:GetEntsByNZName(self:GetActivatorNZName2()))
	return result
end

function ENT:Activation(caller, duration, cooldown)
	local shouldBeActivated = true

	-- only activated if all activators are active
	for _, lEntsWithName in pairs(self:GetActivatorEnts()) do
		for _, lEnt in pairs(lEntsWithName) do
			if IsValid(lEnt) and not lEnt:IsPlayer() then
				print(lEnt, lEnt:IsActive())
				if not lEnt:IsActive() then
					shouldBeActivated = false
				end
			end
		end
	end

	if shouldBeActivated then
		BaseClass.Activation(self, caller, duration, cooldown)
	end
end

function ENT:Ready()
	BaseClass.Ready(self)
end

function ENT:Use()
	-- prevent using the and gate
	return false
end

-- IMPLEMENT ME
function ENT:OnActivation(caller, duration, cooldown) end

function ENT:OnDeactivation() end

function ENT:OnReady() end

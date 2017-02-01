AddCSLuaFile( )

ENT.Type = "anim"
ENT.Base = "base_entity"

nzLogic:Register("nz_button")
ENT.SpawnIcon = "models/nzprops/zapper_handle.mdl"
ENT.PrintName = "Button"
ENT.Description = "Simple Button that can trigger one or multiple other logic entities or traps."

ENT.WireMat = Material( "cable/cable2" )

ENT.ModelTranslate = {
	-- 1
	{model = "models/nzprops/zapper_handle.mdl", gmod_button = true}, -- This one is built like gmod buttons to flip
	-- 2
	{model = "models/nzprops/zombies_power_lever_short.mdl"},
	-- 3
	{model = "models/maxofs2d/button_01.mdl", gmod_button = true},
	-- 4
	{model = "models/maxofs2d/button_02.mdl", gmod_button = true},
	-- 5
	{model = "models/maxofs2d/button_03.mdl", gmod_button = true},
	-- 6
	{model = "models/maxofs2d/button_04.mdl", gmod_button = true},
	-- 7
	{model = "models/maxofs2d/button_05.mdl", gmod_button = true},
	-- 8
	{model = "models/maxofs2d/button_06.mdl", gmod_button = true},
	-- 9
	{model = "models/maxofs2d/button_slider.mdl", gmod_button = true}
}

DEFINE_BASECLASS("nz_activatable")

function ENT:SetupDataTables()
	BaseClass.SetupDataTables( self )

	local modelTbl = {}
	modelTbl["Trap Handle"] = 1
	modelTbl["Power Switch"] = 2
	modelTbl["Gmod Button 1"] = 3
	modelTbl["Gmod Button 2"] = 4
	modelTbl["Gmod Button 3"] = 5
	modelTbl["Gmod Button 4"] = 6
	modelTbl["Gmod Button 5"] = 7
	modelTbl["Gmod Button 6"] = 8
	modelTbl["Gmod Button 7"] = 9

	self:NetworkVar( "Int", 1, "ModelID", {KeyName = "nz_model_id", Edit = {order = -1, type = "Combo", text = "Select a model!", values = modelTbl}} )

	self:NetworkVarNotify( "ModelID", self.OnModelChange)

	self:SetModelID(1)

	--the name of the linked ents
	self:ButtonSetupDataTables()
end

function ENT:ButtonSetupDataTables()
	self:NetworkVar( "String", 1, "LinkedNZName1", {KeyName = "nz_linked_name1", Edit = {order = 20, type = "Generic"}} )
	self:NetworkVar( "String", 2, "LinkedNZName2", {KeyName = "nz_linked_name2", Edit = {order = 21, type = "Generic"}} )
	self:NetworkVar( "String", 3, "LinkedNZName3", {KeyName = "nz_linked_name3", Edit = {order = 22, type = "Generic"}} )
end

function ENT:GetLinkedEnts()
	local result = {}
	table.insert(result, self:GetEntsByNZName(self:GetLinkedNZName1()))
	table.insert(result, self:GetEntsByNZName(self:GetLinkedNZName2()))
	table.insert(result, self:GetEntsByNZName(self:GetLinkedNZName3()))

	return result
end

function ENT:OnModelChange(name, old, new)
	self:SetModel(self.ModelTranslate[new].model)
end

function ENT:Initialize()
	self:SetModel(self.ModelTranslate[self:GetModelID()].model)

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	local phys = self:GetPhysicsObject()
	phys:EnableMotion(false)
	self.PosePosition = 0
end

function ENT:Think()
	BaseClass.Think(self)

	if CLIENT then
		if self:GetModelInformation().gmod_button then
			self:UpdateLever()
		end
	end
end

if CLIENT then
	function ENT:Draw()
		BaseClass.Draw(self)

		if ConVarExists("nz_creative_preview") and !GetConVar("nz_creative_preview"):GetBool() and nzRound:InState( ROUND_CREATE ) then
			-- draw "wires" in creative this is very resource intensive
			for _, lEntsWithName in pairs(self:GetLinkedEnts()) do
				for _, lEnt in pairs(lEntsWithName) do
					if IsValid(lEnt) and !lEnt:IsPlayer() then
						local texcoord = math.Rand( 0, 1 )
						render.SetMaterial(self.WireMat)
						render.DrawBeam(self:GetPos() + self:OBBCenter(), lEnt:GetPos() + lEnt:OBBCenter(), 1, texcoord, texcoord + 1, Color( 20, 255, 30 ) )
					end
				end
			end
		end
	end
end

function ENT:Activation(caller, duration, cooldown)
	BaseClass.Activation(self, caller, duration, cooldown)

	nzDoors:OpenLinkedDoors(self:GetLinkedNZName1())
	nzDoors:OpenLinkedDoors(self:GetLinkedNZName2())
	nzDoors:OpenLinkedDoors(self:GetLinkedNZName3())

	for _, lEntsWithName in pairs(self:GetLinkedEnts()) do
		for _, lEnt in pairs(lEntsWithName) do
			if IsValid(lEnt) and !lEnt:IsPlayer() then
				lEnt:Activation(caller, duration, cooldown)
			end
		end
	end
end

function ENT:Ready()
	BaseClass.Ready(self)
end

-- IMPLEMENT ME
function ENT:OnActivation(caller, duration, cooldown)
	self:SetSkin(2)
end

function ENT:OnDeactivation()
	self:SetSkin(3)
end

function ENT:OnReady()
	self:SetSkin(1)
end

function ENT:GetModelInformation()
	return self.ModelTranslate[self:GetModelID()]
end

function ENT:UpdateLever()

	local TargetPos = 0.0
	if ( self:IsActive() ) then TargetPos = 1.0 end

	self.PosePosition = math.Approach( self.PosePosition, TargetPos, FrameTime() * 3.0 )

	self:SetPoseParameter( "switch", self.PosePosition )
	self:InvalidateBoneCache()

end

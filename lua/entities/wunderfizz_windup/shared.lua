AddCSLuaFile( )

ENT.Type = "anim"

ENT.PrintName		= "wunderfizz_windup"
ENT.Author			= "Zet0r"
ENT.Contact			= "youtube.com/Zet0r"
ENT.Purpose			= ""
ENT.Instructions	= ""

local perk_materials = {
	["jugg"] = "models/perk_bottle/c_perk_bottle_jugg",
	["speed"] = "models/perk_bottle/c_perk_bottle_speed",
	["dtap"] = "models/perk_bottle/c_perk_bottle_dtap",
	["revive"] = "models/perk_bottle/c_perk_bottle_revive",
	["dtap2"] = "models/perk_bottle/c_perk_bottle_dtap2",
	["staminup"] = "models/perk_bottle/c_perk_bottle_stamin",
	["phd"] = "models/perk_bottle/c_perk_bottle_phd",
	["deadshot"] = "models/perk_bottle/c_perk_bottle_deadshot",
	["mulekick"] = "models/perk_bottle/c_perk_bottle_mulekick",
	["cherry"] = "models/perk_bottle/c_perk_bottle_cherry",
	["tombstone"] = "models/perk_bottle/c_perk_bottle_tombstone",
	["whoswho"] = "models/perk_bottle/c_perk_bottle_whoswho",
	["vulture"] = "models/perk_bottle/c_perk_bottle_vulture",
	["teddy"] = "models/perk_bottle/c_perk_bottle_teddy",
}

function ENT:SetupDataTables()
	self:NetworkVar( "Bool", 0, "Winding" )
end

function ENT:RandomizeSkin()
	local skin
	if nzMapping.Settings.wunderfizzperks then
		skin = table.Random(perk_materials)
	else
		skin = table.Random(perk_materials)
	end
	
	if skin then
		self:SetMaterial(skin)
	end
end

function ENT:Initialize()

	self:SetMoveType(MOVETYPE_NONE)
	
	self:SetSolid( SOLID_OBB )
	self:DrawShadow( false )

	self:SetModel("models/alig96/perks/perkacola/perkacola.mdl")
	self:RandomizeSkin()
	local machine = self.WMachine

	if SERVER then
		self:SetWinding(true)
		//Stop winding up
		timer.Simple(5, function()
			self:SetWinding(false)
			self:SetMaterial(perk_materials[self.Perk])
			if self.Perk == "teddy" then 
				machine:SetIsTeddy(true)
				machine:GetUser():GivePoints(machine:GetPrice())
				timer.Simple(5, function() 
					if IsValid(self) and IsValid(machine) then
						self:Remove()
						machine:MoveLocation()
					end
				end)
			end
			machine:SetPerkID(self.Perk)
		end)
		-- If we time out, remove the object
		timer.Simple(25, function() if IsValid(self) then self:Remove() end end)
	end
end

function ENT:WindUp( )
	self:RandomizeSkin()
end

function ENT:TeddyFlyUp( )
	
end

function ENT:Think()
	if SERVER then
		if self:GetWinding() then
			self:WindUp()
		end
	end
end

function ENT:OnRemove()
	if IsValid(self.WMachine) then
		self.WMachine:SetBeingUsed(false)
		self.WMachine.Bottle = nil
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
		if self:GetWinding() then
			if !self:GetRenderAngles() then self:SetRenderAngles(self:GetAngles() + Angle(20,0,0)) end
			self:SetRenderAngles(self:GetRenderAngles()+(Angle(0,100,0)*FrameTime()))
		elseif !self.Stopped then
			self:SetRenderAngles(self:GetNetworkAngles())
			self.LightningAura = nil -- Kill the aura effect
			self.Stopped = true
		end
	end
end

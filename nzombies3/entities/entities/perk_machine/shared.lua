AddCSLuaFile()

ENT.Type			= "anim"

ENT.PrintName		= "perk_machine"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "PerkID")
	self:NetworkVar("Bool", 0, "Active")
	self:NetworkVar("Bool", 1, "BeingUsed")
end

function ENT:Initialize()
	if SERVER then
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_VPHYSICS )
		self:DrawShadow( false )
		self:SetUseType( SIMPLE_USE )
		self:SetBeingUsed(false)
	end
end

function ENT:TurnOn()
	local perkData = nz.Perks.Functions.Get(self:GetPerkID())
	self:SetModel(perkData.on_model)
	self:SetActive(true)
end

function ENT:TurnOff()
	local perkData = nz.Perks.Functions.Get(self:GetPerkID())
	self:SetModel(perkData.off_model)
	self:SetActive(false)
end

function ENT:IsOn()
	return self:GetActive()
end

local MachinesNoDrink = {
	["pap"] = true,
}

function ENT:Use(activator, caller)
	local perkData = nz.Perks.Functions.Get(self:GetPerkID())
	
	if self:IsOn() then
		local price = perkData.price
		-- As long as they have less than the max perks, unless it's pap
		if #activator:GetPerks() < nz.Config.MaxPerks or self:GetPerkID() == "pap" then
			-- If they have enough money
			if activator:CanAfford(price) then
				if !activator:HasPerk(self:GetPerkID()) then
					local given = activator:GivePerk(self:GetPerkID(), self)
					if given then
						activator:TakePoints(price)
						if !MachinesNoDrink[self:GetPerkID()] then
							local wep = activator:Give("nz_perk_bottle")
							wep:SetPerk(self:GetPerkID())
						end
						self:EmitSound("nz/machines/jingle/"..self:GetPerkID().."_get.wav", 75)
					end
				else
					print("already have perk")
				end
			end
		else
			print(activator:Nick().." already has max perks")
		end
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end
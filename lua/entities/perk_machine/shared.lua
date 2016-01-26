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
end

function ENT:Initialize()
	if SERVER then
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_VPHYSICS )
		self:DrawShadow( false )
		self:SetUseType( SIMPLE_USE )
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

function ENT:Use(activator, caller)
	local perkData = nz.Perks.Functions.Get(self:GetPerkID())
	
	if self:IsOn() then
		local price = perkData.price
		//If they have enough money
		if activator:CanAfford(price) then
			if !activator:HasPerk(self:GetPerkID()) then
				activator:TakePoints(price)
				activator:GivePerk(self:GetPerkID())
			else
				print("already have perk")
			end
		end
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end
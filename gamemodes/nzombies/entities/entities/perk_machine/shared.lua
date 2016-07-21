AddCSLuaFile()

ENT.Type			= "anim"

ENT.PrintName		= "perk_machine"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.DynLightColors = {
	["jugg"] = Color(255, 100, 100),
	["speed"] = Color(100, 255, 100),
	["dtap"] = Color(255, 255, 100),
	["revive"] = Color(100, 100, 255),
	["dtap2"] = Color(255, 255, 100),
	["staminup"] = Color(200, 255, 100),
	["phd"] = Color(255, 50, 255),
	["deadshot"] = Color(150, 200, 150),
	["mulekick"] = Color(100, 200, 100),
	["cherry"] = Color(50, 50, 200),
	["tombstone"] = Color(100, 100, 100),
	["whoswho"] = Color(100, 100, 255),
	["vulture"] = Color(255, 100, 100),
	["pap"] = Color(200, 220, 220),
}

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "PerkID")
	self:NetworkVar("Bool", 0, "Active")
	self:NetworkVar("Bool", 1, "BeingUsed")
	self:NetworkVar("Int", 0, "Price")
end

function ENT:Initialize()
	if SERVER then
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_VPHYSICS )
		self:DrawShadow( false )
		self:SetUseType( SIMPLE_USE )
		self:SetBeingUsed(false)
		local perkData = nzPerks:Get(self:GetPerkID())
		self:SetPrice(perkData.price)
	end
end

function ENT:TurnOn()
	self:SetActive(true)
	self:Update()
end

function ENT:TurnOff()
	self:SetActive(false)
	self:Update()
end

function ENT:Update()
	local perkData = nzPerks:Get(self:GetPerkID())
	self:SetModel(perkData and (self:IsOn() and perkData.on_model or perkData.off_model) or "")
end

function ENT:IsOn()
	return self:GetActive()
end

local MachinesNoDrink = {
	["pap"] = true,
}

function ENT:Use(activator, caller)
	local perkData = nzPerks:Get(self:GetPerkID())
	
	if self:IsOn() then
		local price = self:GetPrice()
		-- As long as they have less than the max perks, unless it's pap
		if #activator:GetPerks() < GetConVar("nz_difficulty_perks_max"):GetInt() or self:GetPerkID() == "pap" then
			-- If they have enough money
			if activator:CanAfford(price) then
				if !activator:HasPerk(self:GetPerkID()) then
					local given = activator:GivePerk(self:GetPerkID(), self)
					if given then
						activator:TakePoints(price)
						if !MachinesNoDrink[self:GetPerkID()] then
							local wep = activator:Give("nz_perk_bottle")
							wep:SetPerk(self:GetPerkID())
						else
							activator:Give("nz_packapunch_arms")
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
		if self:GetActive() then
			if !self.NextLight or CurTime() > self.NextLight then
				local dlight = DynamicLight( self:EntIndex() )
				if ( dlight ) then
					local col = self.DynLightColors[self:GetPerkID()]
					dlight.pos = self:GetPos() + self:OBBCenter()
					dlight.r = col.r
					dlight.g = col.g
					dlight.b = col.b
					dlight.brightness = 2
					dlight.Decay = 1000
					dlight.Size = 256
					dlight.DieTime = CurTime() + 1
				end
				if math.random(300) == 1 then self.NextLight = CurTime() + 0.05 end
			end
		end
	end
end
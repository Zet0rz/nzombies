AddCSLuaFile( )

ENT.Type = "anim"

ENT.PrintName		= "pap_weapon_trigger"
ENT.Author			= "Zet0r"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

function ENT:SetupDataTables()

	self:NetworkVar( "String", 0, "WepClass" )
	self:NetworkVar( "Entity", 0, "PaPOwner" )

end

function ENT:Initialize()
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_OBB )
	self:SetModel("models/hunter/blocks/cube05x1x025.mdl")
	self:DrawShadow(false)

	if SERVER then
		self:SetUseType( SIMPLE_USE )
	end
end

function ENT:Use( activator, caller )
	if activator == self:GetPaPOwner() then
		local class = self:GetWepClass()
		local weapon
		if self.RerollingAtts then
			weapon = activator:GiveNoAmmo(class)
		else
			weapon = activator:Give(class)
		end
		timer.Simple(0, function()
			if IsValid(weapon) and IsValid(activator) then
				if activator:HasPerk("speed") and weapon:IsFAS2() then
					weapon:ApplyNZModifier("speed")
				end
				if (activator:HasPerk("dtap") or activator:HasPerk("dtap2")) and weapon:IsFAS2()  then
					weapon:ApplyNZModifier("dtap")
				end
				weapon:ApplyNZModifier("pap")
				weapon:SetClip1(weapon.Primary.ClipSize)
				if IsValid(self.wep) then
					self.wep.machine:SetBeingUsed(false)
					self.wep:Remove()
				end
			end
			--[[if !self.RerollingAtts then -- A 2000 point reroll should not give max ammo
				print("Giving ammo")
				nzWeps:GiveMaxAmmoWep(activator, class, true) -- We give pap ammo count
			end]]
			self:Remove()
		end)
	else
		if IsValid(self:GetPaPOwner()) then
			activator:PrintMessage( HUD_PRINTTALK, "This is " .. self:GetPaPOwner():Nick() .. "'s gun. You cannot take it." )
		end
	end
end

if CLIENT then
	function ENT:Draw()
		return
	end
end

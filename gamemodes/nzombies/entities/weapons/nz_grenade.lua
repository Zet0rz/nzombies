if SERVER then
	AddCSLuaFile("nz_grenade.lua")
	SWEP.Weight			= 1
	SWEP.AutoSwitchTo	= false
	SWEP.AutoSwitchFrom	= true	
end

if CLIENT then

	SWEP.PrintName     	    = "M67 Grenade"			
	SWEP.Slot				= 1
	SWEP.SlotPos			= 1
	SWEP.DrawAmmo			= false
	SWEP.DrawCrosshair		= true

end


SWEP.Author			= "Zet0r"
SWEP.Contact		= "youtube.com/Zet0r"
SWEP.Purpose		= "Throws a grenade if you have any"
SWEP.Instructions	= "Let the gamemode give you it"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.HoldType = "grenade"

SWEP.ViewModel = "models/weapons/c_grenade.mdl"
SWEP.WorldModel	= "models/weapons/w_grenade.mdl"
SWEP.UseHands = true
SWEP.vModel = true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.NextReload				= 1

function SWEP:Initialize()

	self:SetHoldType( self.HoldType )

end

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
	--if !self.Owner:GetUsingSpecialWeapon() then
		--self.Owner:EquipPreviousWeapon()
	--end
end

function SWEP:PrimaryAttack()
	self:ThrowGrenade(6000)
end

function SWEP:ThrowGrenade(force)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:SendWeaponAnim(ACT_VM_THROW)
	
	if SERVER then
		local nade = ents.Create("nz_fraggrenade")
		nade:SetPos(self.Owner:EyePos() + (self.Owner:GetAimVector() * 20))
		nade:SetAngles( Angle(30,0,0)  )
		nade:Spawn()
		nade:Activate()
		nade:SetOwner(self.Owner)
		if self.Owner:HasPerk("widowswine") then
			nade.WidowsWine = true
		end
		
		local nadePhys = nade:GetPhysicsObject()
			if !IsValid(nadePhys) then return end
		nadePhys:ApplyForceCenter(self.Owner:GetAimVector():GetNormalized() * force + self.Owner:GetVelocity())
		nadePhys:AddAngleVelocity(Vector(1000,0,0))	
		nade:SetExplosionTimer(3)
	end
end

function SWEP:PostDrawViewModel()

end

function SWEP:DrawWorldModel()
end

function SWEP:OnRemove()
	
end

function SWEP:Holster( wep )
	--if not IsFirstTimePredicted() then return end
	return true
end
if SERVER then
	AddCSLuaFile("nz_death_machine.lua")
	SWEP.Weight			= 5
	SWEP.AutoSwitchTo	= true
	SWEP.AutoSwitchFrom	= false
end

if CLIENT then

	SWEP.PrintName     	    = "Death Machine"			
	SWEP.Slot				= 1
	SWEP.SlotPos			= 1
	SWEP.DrawAmmo			= false
	SWEP.DrawCrosshair		= true
	
	SWEP.Category			= "nZombies"

end


SWEP.Author			= "Zet0r"
SWEP.Contact		= "youtube.com/Zet0r"
SWEP.Purpose		= "Bringing Death to Zombies since 1999"
SWEP.Instructions	= "Find a powerup to get it"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.HoldType = "shotgun"

SWEP.ViewModel = "models/weapons/c_zombies_deathmachine.mdl"
SWEP.WorldModel = "models/weapons/w_zombies_deathmachine.mdl"
SWEP.UseHands = true
SWEP.vModel = true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.NZPreventBox = true
SWEP.NZTotalBlacklist = true
SWEP.NZSpecialCategory = "display" -- This makes it count as special, as well as what category it replaces
-- (display is generic stuff that should only be carried temporarily and never holstered and kept)

function SWEP:Initialize()

	self:SetHoldType( self.HoldType )

end

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
	self.WepOwner = self.Owner
end

function SWEP:Equip( owner )
	owner:SetActiveWeapon("nz_death_machine")
end

local shootsound = Sound("nz/deathmachine/loop_l_.wav")
function SWEP:PrimaryAttack()
	
	self:SetNextPrimaryFire(CurTime() + 0.05)
	self:EmitSound( shootsound )
	
	local shootpos = self.Owner:GetShootPos()
	local shootang = self.Owner:GetAimVector()
	
	local bullet = {}
	bullet.Damage = 9000
	bullet.Force = 10
	bullet.Tracer = 1
	bullet.TracerName = "AirboatGunHeavyTracer"
	bullet.Src = shootpos
	bullet.Dir = shootang + Vector(0,0,0)
	bullet.Spread = Vector(0.02, 0.02, 0)
	
	--local fx = EffectData()
	--fx:SetEntity(self)
	--fx:SetOrigin(shootpos)
	--fx:SetNormal(shootang)
	--fx:SetAttachment(self.MuzzleAttachment)
	self.Owner:MuzzleFlash()
	self.Owner:FireBullets( bullet )
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self.Owner:ViewPunch( Angle( math.Rand(-0.5,-0.3), math.Rand(-0.3,0.3), 0 ) )
	
end

function SWEP:PostDrawViewModel()

end

function SWEP:NZSpecialHolster(wep)
	if IsValid(self.Owner) then
		self.Owner:RemovePowerUp("deathmachine")
	end
	return true
end

function SWEP:OnRemove()
	if SERVER then
		if !IsValid(self.WepOwner:GetActiveWeapon()) or !self.WepOwner:GetActiveWeapon():IsSpecial() then
			self.WepOwner:SetUsingSpecialWeapon(false)
		end
		self.WepOwner:SetActiveWeapon(nil)
		self.WepOwner:EquipPreviousWeapon()
	end
end

function SWEP:GetViewModelPosition( pos, ang )
 
	
	return pos, ang
 
end
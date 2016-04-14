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

SWEP.ViewModel	= "models/weapons/c_grenade.mdl"
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
	if !self.Owner:GetUsingSpecialWeapon() then
		self.Owner:EquipPreviousWeapon()
	end
end

function SWEP:StartGrenadeModel()
	self.GrenadeModel = ClientsideModel("models/weapons/w_eq_fraggrenade.mdl")
end

function SWEP:EndGrenadeModel()
	if IsValid(self.GrenadeModel) then
		self.GrenadeModel:Remove()
		self.GrenadeModel = nil
	end
end

function SWEP:PrimaryAttack()
	--self:ThrowGrenade(1000)
end

function SWEP:ThrowGrenade(force)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:SendWeaponAnim(ACT_VM_THROW)
	
	local nade = ents.Create("nz_fraggrenade")
	nade:SetPos(self.Owner:EyePos() + (self.Owner:GetAimVector() * 20))
	nade:Spawn()
	nade:Activate()
	nade:SetOwner(self.Owner)
	
	local nadePhys = nade:GetPhysicsObject()
		if !IsValid(nadePhys) then return end
	nadePhys:ApplyForceCenter(self.Owner:GetAimVector():GetNormalized() * force + self.Owner:GetVelocity())
	
	nade:SetExplosionTimer(3)
end

function SWEP:PostDrawViewModel()

	if IsValid(self.GrenadeModel) then
		local pos = LocalPlayer():GetViewModel():GetBonePosition(  LocalPlayer():GetViewModel():LookupBone( "ValveBiped.Grenade_body" ) )
		local ang = EyeAngles()
		self.GrenadeModel:SetPos(pos - ang:Up()*2 - ang:Forward()*5 + ang:Right()*2)
		self.GrenadeModel:SetAngles(ang - Angle(25,0,20))
		--render.Model({model = "models/weapons/w_eq_fraggrenade.mdl", pos = pos, ang = ang})
	end

	LocalPlayer():GetViewModel():ManipulateBoneScale(  LocalPlayer():GetViewModel():LookupBone( "ValveBiped.Grenade_body" ), Vector(0,0,0) )
	LocalPlayer():GetViewModel():ManipulateBoneScale(  LocalPlayer():GetViewModel():LookupBone( "ValveBiped.Pin" ), Vector(0,0,0) )
end

function SWEP:DrawWorldModel()
end

function SWEP:OnRemove()
	self:EndGrenadeModel()
end

function SWEP:Holster( wep )
	if not IsFirstTimePredicted() then return end
	self:EndGrenadeModel()
end
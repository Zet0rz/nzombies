if SERVER then
	AddCSLuaFile("nz_bowie_knife.lua")
	SWEP.Weight			= 5
	SWEP.AutoSwitchTo	= false
	SWEP.AutoSwitchFrom	= true
end

if CLIENT then

	SWEP.PrintName     	    = "Bowie Knife"			
	SWEP.Slot				= 1
	SWEP.SlotPos			= 1
	SWEP.DrawAmmo			= false
	SWEP.DrawCrosshair		= true
	
	SWEP.Category			= "nZombies"

end


SWEP.Author			= "Zet0r"
SWEP.Contact		= "youtube.com/Zet0r"
SWEP.Purpose		= "Stab Stab Stab!"
SWEP.Instructions	= "Let the gamemode give you it"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.HoldType = "knife"

SWEP.ViewModel	= "models/weapons/c_bowie_knife.mdl"
SWEP.WorldModel	= "models/weapons/w_bowie_knife.mdl"
SWEP.UseHands = true
SWEP.vModel = true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"
SWEP.Primary.DamageType		= DMG_CLUB
SWEP.Primary.Force			= 0

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.NextReload				= 1

SWEP.Primary.Damage 		= 200
SWEP.Range					= 100


function SWEP:Initialize()

	self:SetHoldType( self.HoldType )

end

function SWEP:Deploy()
	--self:SendWeaponAnim(ACT_VM_DRAW)
	--self:SetHoldType( self.HoldType )
end

function SWEP:PrimaryAttack()
	// Only the player fires this way so we can cast
	
	if CurTime() < self.HolsterTime then return end
	
	local ply = self.Owner;

	if ( !ply ) then
		return
	end

	local vecSrc		= ply:GetShootPos()
	local vecDirection	= ply:GetAimVector()

	local trace			= {}
		trace.start		= vecSrc
		trace.endpos	= vecSrc + ( vecDirection * self.Range)
		trace.filter	= ply

	local traceHit		= util.TraceLine( trace )

	if ( traceHit.Hit ) then

		if math.random(0,1) == 0 then
			self:SendWeaponAnim( ACT_VM_HITCENTER )
			ply:SetAnimation( PLAYER_ATTACK1 )
			self.HolsterTime = CurTime() + 1
			self:EmitSound("nz/bowie/stab/bowie_stab_0"..math.random(0,2)..".wav")
		else
			self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
			ply:SetAnimation( PLAYER_ATTACK1 )
			self.HolsterTime = CurTime() + 0.5
			self:EmitSound("nz/bowie/swing/bowie_swing_0"..math.random(0,2)..".wav")
		end

		local vecSrc = ply:GetShootPos()

		if ( SERVER ) then
			ply:TraceHullAttack( vecSrc, traceHit.HitPos, Vector( -5, -5, -5 ), Vector( 5, 5, 36 ), self.Primary.Damage, self.Primary.DamageType, self.Primary.Force )
		end

		return

	end


	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	ply:SetAnimation( PLAYER_ATTACK1 )
	self:EmitSound("nz/bowie/swing/bowie_swing_0"..math.random(0,2)..".wav")

	self.HolsterTime = CurTime() + 0.5

	return
end

function SWEP:DrawAnim()
	self:SendWeaponAnim(ACT_VM_DRAW)
	self.HolsterTime = CurTime() + 2.5
	self:EmitSound("nz/bowie/draw/bowie_start.wav")
	
	timer.Simple(0.7, function()
		if IsValid(self) then
			self:EmitSound("nz/bowie/draw/bowie_turn.wav")
		end
	end)
	timer.Simple(1.4, function()
		if IsValid(self) then
			self:EmitSound("nz/bowie/draw/bowie_toss.wav")
		end
	end)
	
	timer.Simple(1.9, function()
		if IsValid(self) then
			self:EmitSound("nz/bowie/draw/bowie_catch.wav")
		end
	end)
end

function SWEP:PostDrawViewModel()

end

function SWEP:DrawWorldModel()

end

function SWEP:OnRemove()
	
end

function SWEP:Think()
	if engine.ActiveGamemode() == "nzombies3" then 
		if !self.Owner:GetUsingSpecialWeapon() or (self.HolsterTime  and CurTime() > self.HolsterTime) then
			self.Owner:SetUsingSpecialWeapon(false)
			self.Owner:EquipPreviousWeapon()
		end
	end
end

function SWEP:GetViewModelPosition( pos, ang )
 
 	local newpos = LocalPlayer():EyePos()
	local newang = LocalPlayer():EyeAngles()
	local up = newang:Up()
	
	newpos = newpos + LocalPlayer():GetAimVector()*6 - up*65
	
	return newpos, newang
 
end

if engine.ActiveGamemode() == "nzombies3" then 
	SpecialWeapons:AddWeapon( "nz_bowie_knife", "knife", function(ply, wep) -- Use function
		if SERVER then
			ply:SetUsingSpecialWeapon(true)
			ply:SetActiveWeapon(wep)
			wep:PrimaryAttack()
		end
	end, function(ply, wep)
		if SERVER then
			ply:SetUsingSpecialWeapon(true)
			ply:SetActiveWeapon(nil)
			ply:SelectWeapon("nz_bowie_knife")
			wep:DrawAnim()
		end
	end)
end
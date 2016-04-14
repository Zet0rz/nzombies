if SERVER then
	AddCSLuaFile("nz_monkey_bomb.lua")
	SWEP.Weight			= 5
	SWEP.AutoSwitchTo	= false
	SWEP.AutoSwitchFrom	= true
end

if CLIENT then

	SWEP.PrintName     	    = "Monkey Bomb"			
	SWEP.Slot				= 1
	SWEP.SlotPos			= 1
	SWEP.DrawAmmo			= false
	SWEP.DrawCrosshair		= true
	
	SWEP.Category			= "nZombies"

end


SWEP.Author			= "Zet0r"
SWEP.Contact		= "youtube.com/Zet0r"
SWEP.Purpose		= "Throws a monkey bomb if you have any"
SWEP.Instructions	= "Let the gamemode give you it"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.HoldType = "slam"

SWEP.ViewModel	= "models/weapons/c_monkey_bomb.mdl"
SWEP.WorldModel	= "models/nzprops/monkey_bomb.mdl"
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

SWEP.PrimeSounds = {
	"nz/monkey/voice_prime/raise_vox_00.wav",
	"nz/monkey/voice_prime/raise_vox_01.wav",
	"nz/monkey/voice_prime/raise_vox_02.wav",
	"nz/monkey/voice_prime/raise_vox_03.wav",
	"nz/monkey/voice_prime/raise_vox_04.wav",
	"nz/monkey/voice_prime/raise_vox_05.wav",
	"nz/monkey/voice_prime/raise_vox_06.wav",
	"nz/monkey/voice_prime/raise_vox_07.wav",
	"nz/monkey/voice_prime/raise_vox_08.wav",
	"nz/monkey/voice_prime/raise_vox_09.wav",
	"nz/monkey/voice_prime/raise_vox_10.wav",
	"nz/monkey/voice_prime/raise_vox_11.wav",
}

function SWEP:Initialize()

	self:SetHoldType( "slam" )

end

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
	self:SetHoldType( "slam" )
	timer.Simple(2, function() if IsValid(self) then self:SetHoldType("grenade") end end)
	if CLIENT then
		local sound = self.PrimeSounds[math.random(1,#self.PrimeSounds)]
		surface.PlaySound(sound)
		timer.Simple(1.2, function() 
			if IsValid(self) then
				surface.PlaySound("nz/monkey/hat1.wav")
				local i = 0
				timer.Create("MonkeyCymbalViewmodel", 0.23, 7, function()
					surface.PlaySound("nz/monkey/cymbals/monk_cymb_0"..math.Round(i/2)..".wav")
					i = i < 8 and i + 1 or 8
				end)
			end 
		end)
		
	else
		self:CallOnClient("Deploy")
	end
end

function SWEP:PrimaryAttack()
	
end

function SWEP:ThrowBomb(force)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:SendWeaponAnim(ACT_VM_THROW)
	
	local nade = ents.Create("nz_monkeybomb")
	local pos = self.Owner:EyePos() + (self.Owner:GetAimVector() * 20)
	local ang = Angle(0,(self.Owner:GetPos() - pos):Angle()[2]-90,0)
	nade:SetPos(pos)
	nade:SetAngles(ang)
	nade:Spawn()
	nade:Activate()
	nade:SetOwner(self.Owner)
	
	local nadePhys = nade:GetPhysicsObject()
		if !IsValid(nadePhys) then return end
	nadePhys:ApplyForceCenter(self.Owner:GetAimVector():GetNormalized() * force + self.Owner:GetVelocity())
	nade:EmitSound("nz/monkey/voice_throw/throw_0"..math.random(0,3)..".wav")
	
end

function SWEP:PostDrawViewModel()

end

function SWEP:DrawWorldModel()

end

function SWEP:OnRemove()
	
end

function SWEP:GetViewModelPosition( pos, ang )
 
 	local newpos = LocalPlayer():EyePos()
	local newang = LocalPlayer():EyeAngles()
	local up = newang:Up()
	
	newpos = newpos + LocalPlayer():GetAimVector()*6 - up*65
	
	return newpos, newang
 
end

if engine.ActiveGamemode() == "nzombies3" then 
	SpecialWeapons:AddWeapon( "nz_monkey_bomb", "specialgrenade", function(ply) -- Use function
		if SERVER then
			if ply:GetAmmoCount("nz_specialgrenade") <= 0 then return end
			ply:SetUsingSpecialWeapon(true)
			ply:SelectWeapon("nz_monkey_bomb")
			timer.Simple(3, function()
				if IsValid(ply) then
					local wep = ply:GetActiveWeapon()
					if wep:GetClass() == "nz_monkey_bomb" then
						if !ply:KeyDown(IN_GRENADE2) then
							wep:ThrowBomb(700)
							ply:SetAmmo(ply:GetAmmoCount("nz_specialgrenade") - 1, "nz_specialgrenade")
							timer.Simple(1, function()
								if IsValid(ply) then
									ply:SetUsingSpecialWeapon(false)
									ply:EquipPreviousWeapon()
								end
							end)
						else
							hook.Add("KeyRelease", "CheckMonkeyRelease"..ply:EntIndex(), function(kply, key)
								if kply == ply and key == IN_GRENADE2 then
									wep:ThrowBomb(700)
									ply:SetAmmo(ply:GetAmmoCount("nz_specialgrenade") - 1, "nz_specialgrenade")
									timer.Simple(1, function()
										if IsValid(ply) then
											ply:SetUsingSpecialWeapon(false)
											ply:EquipPreviousWeapon()
										end
									end)
									hook.Remove("KeyRelease", "CheckMonkeyRelease"..ply:EntIndex())
								end
							end)
						end
					else
						ply:SetUsingSpecialWeapon(false)
						ply:EquipPreviousWeapon()
					end
				end
			end)
		end
	end, function(ply) -- Equip Function
		ply:SetAmmo(3, "nz_specialgrenade")
	end, function(ply) -- Max Ammo function
		ply:SetAmmo(3, "nz_specialgrenade")
	end)
end
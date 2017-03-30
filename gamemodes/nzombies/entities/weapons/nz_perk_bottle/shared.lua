
AddCSLuaFile( "shared.lua" )

SWEP.Author			= "Zet0r"
SWEP.Instructions	= "Fancy Viewmodel Animations"
SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.ViewModel			= "models/weapons/c_perk_bottle.mdl"
SWEP.WorldModel			= ""

SWEP.UseHands 			= true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Delay = 1
SWEP.Primary.Ammo = -1
SWEP.ViewModelFOV = 75
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Ammo			= -1

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= false

SWEP.PrintName			= "Perk Bottle"			
SWEP.Slot				= 3
SWEP.SlotPos			= 1
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= false

SWEP.SwayScale = 0
SWEP.BobScale = 0

SWEP.NZPreventBox = true -- Prevents from being in the box by default

local oldmat
--[[local perk_materials = {
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
}]]

if SERVER then
	util.AddNetworkString("perk_blur_screen")
end

function SWEP:SetupDataTables()

	self:NetworkVar( "String", 0, "Perk" )

end

function SWEP:Initialize()
	if CLIENT then
		if self.Owner == LocalPlayer() then
			local vm = LocalPlayer():GetViewModel()
			print(self:GetPerk())
			local mat = nzPerks:Get(self:GetPerk()).material --perk_materials[self:GetPerk()]
			oldmat = vm:GetMaterial() or ""
			vm:SetMaterial(mat)
		end
	end
end

function SWEP:Equip( owner )
	
	timer.Simple(3.2,function()
		owner:SetUsingSpecialWeapon(false)
		owner:EquipPreviousWeapon()
	end)
	owner:SetActiveWeapon("nz_perk_bottle")
	
end

function SWEP:Deploy()

	timer.Simple(0.5,function()
		if IsValid(self) and IsValid(self.Owner) then
			if self.Owner:Alive() then
				self:EmitSound("nz/perks/open.wav")
				self.Owner:ViewPunch( Angle( -1, -1, 0 ) )
			end
		end
	end)

	timer.Simple(1.3,function()
		if IsValid(self) and IsValid(self.Owner) then
			if self.Owner:Alive() then
				self:EmitSound("nz/perks/drink.wav")
				self.Owner:ViewPunch( Angle( -3, 0, 0 ) )
			end
		end
	end)

	timer.Simple(2.3,function()
		if IsValid(self) and IsValid(self.Owner) then
			if self.Owner:Alive() then
				self:EmitSound("nz/perks/smash.wav")
				net.Start("perk_blur_screen")
				net.Send(self.Owner)
			end
		end
	end)

	timer.Simple(3,function()
		if IsValid(self) and IsValid(self.Owner) then
			if self.Owner:Alive() then
				self:EmitSound("nz/perks/burp.wav")
			end
		end
	end)


end

function PerkBlurScreen()
	local mat = Material( "pp/blurscreen" )
	local function blurhook()
		DrawMotionBlur(0.4, 0.8, 0.01)
	end
	hook.Add( "RenderScreenspaceEffects", "PaintPerkBlur", blurhook )
	timer.Simple(0.7,function() hook.Remove( "RenderScreenspaceEffects", "PaintPerkBlur" ) end)
end
net.Receive("perk_blur_screen", PerkBlurScreen)

function SWEP:Holster()
	return false
end

function SWEP:PrimaryAttack()
end

function SWEP:OnRemove()

	if CLIENT then
		if self.Owner == LocalPlayer() then
			local vm = LocalPlayer():GetViewModel()
			vm:SetMaterial(oldmat)
		end
	end
	
	hook.Remove( "RenderScreenspaceEffects", "PaintPerkBlur" )

end

function SWEP:GetViewModelPosition( pos, ang )
 
 	local newpos = LocalPlayer():EyePos()
	local newang = LocalPlayer():EyeAngles()
	local up = newang:Up()
	
	newpos = newpos + LocalPlayer():GetAimVector()*3 - up*65
	
	return newpos, newang
 
end

function SWEP:SecondaryAttack()
end

function SWEP:ShouldDropOnDie()
	return false
end

-- So it counts as special weapon in the gamemode
function SWEP:IsSpecial()
	return true
end
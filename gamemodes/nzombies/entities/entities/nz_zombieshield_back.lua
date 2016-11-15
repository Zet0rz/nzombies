
AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.PrintName		= "Zombie Shield (Back)"
ENT.Author			= "Zet0r"
ENT.Information		= "When the shield is holstered, it goes on the back"

ENT.Spawnable		= false
ENT.AdminOnly		= false
ENT.RenderGroup		= RENDERGROUP_BOTH

function ENT:Initialize()

	self:SetModel("models/weapons/w_zombieshield.mdl")
	if SERVER then
		self:SetHealth(450) -- 15 hits (30 damage per hit)
		self:SetMaxHealth(450)
	end
	self:SetParent(self.Owner)
	self:AddEffects(EF_BONEMERGE)
	
	self.Weapon = self:GetParent():GetWeapon("nz_zombieshield")
	
end

function ENT:Draw()
	self:DrawModel()
	if IsValid(self.Weapon) and self.Weapon:GetElectrified() then
		local pos, ang = self:GetBonePosition(1)
		nzEffects:DrawElectricArcs( self, pos, ang, 1, 1, 0.3 )
	end
end

local function DrawShields()
	
end
--hook.Add( "PostPlayerDraw", "nzZombieShieldDrawing", DrawShields )

function ENT:OnTakeDamage(dmginfo)
	local dmg = dmginfo:GetDamage()
	self:SetHealth(self:Health() - dmg)
	local att = dmginfo:GetAttacker()
	if att:IsValidZombie() and IsValid(self.Weapon) and self.Weapon:GetElectrified() then
		local d = DamageInfo()
		d:SetDamage( 250 )
		d:SetAttacker( self:GetParent() )
		d:SetDamageType( DMG_SHOCK )

		att:TakeDamageInfo( d )
	end
	if self:Health() <= 0 then
		self.Owner:EmitSound("physics/metal/metal_box_break"..math.random(1,2)..".wav")
		self.Owner:StripWeapon("nz_zombieshield")
		self.Owner:EquipPreviousWeapon()
	else
		local pct = self:Health()/self:GetMaxHealth()
		if pct < 0.2 then
			self:SetBodygroup(0,2)
			self.Weapon:SetDamage(2)
		elseif pct < 0.6 then
			self:SetBodygroup(0,1)
			self.Weapon:SetDamage(1)
		else
			self:SetBodygroup(0,0)
			self.Weapon:SetDamage(0)
		end
		self:EmitSound("physics/metal/metal_box_impact_hard"..math.random(1,3)..".wav")
	end
end

hook.Add("PostMapCleanup", "nzRestoreShields", function()
	for k,v in pairs(player.GetAll()) do
		local wep = v:GetWeapon("nz_zombieshield")
		if IsValid(wep) then
			wep:CreateBackShield(v)
		end
	end
end)
AddCSLuaFile()

ENT.Type = "anim"
 
ENT.PrintName		= "drop_vulture"
ENT.Author			= "Zet0r"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

function ENT:SetupDataTables()

	self:NetworkVar( "String", 0, "DropType" )
	
end

local vulturedrops = {
	["points"] =  {
		id = "points",
		model = Model("models/props_junk/garbage_bag001a.mdl"),
		effect = function(ply)
			ply:GivePoints(math.random(5,20))
			return true
		end,
		timer = 30,
		draw = function(self)
			self:DrawModel()
		end,
		initialize = function(self)
		
		end,
	},
	["ammo"] = {
		id = "ammo",
		model = Model("models/items/357ammo.mdl"),
		effect = function(ply)
			local wep = ply:GetActiveWeapon()
			if IsValid(wep) then
				local max = nz.Weps.Functions.CalculateMaxAmmo(wep:GetClass())
				local give = max/math.Rand(9,11)
				local ammo = wep.Primary.Ammo
				local cur = ply:GetAmmoCount(ammo)
				
				--print(give, max, cur)
				
				if cur + give > max then give = max - cur end
				if give <= 0 then return false end
				ply:GiveAmmo(give, ammo)
				return true
			end
		end,
		timer = 30,
		draw = function(self)
			self:DrawModel()
		end,
		initialize = function(self)
		
		end,
	},
	["gas"] = {
		id = "gas",
		model = Model(""),
		effect = function(ply)
			ply.vulturegas = CurTime() + 3
		end,
		timer = 5,
		draw = function(self)
			
		end,
		initialize = function(self)
			local sfx = EffectData()
			sfx:SetOrigin(self:GetPos())
			util.Effect("vulture_gascloud",sfx)
		end,
	},
}

function ENT:Initialize()
	
	-- 50/50 chance of either
	if SERVER then
		self:SetDropType(table.Random(vulturedrops).id)
	end
	self:SetModel(vulturedrops[self:GetDropType()].model)
	
	self:PhysicsInitSphere(50, "default_silent")
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	if SERVER then
		self:SetTrigger(true)
		self:SetUseType(SIMPLE_USE)
	end
	self:UseTriggerBounds(true, 0)
	self:SetMaterial("models/shiny.vtf")
	self:SetColor( Color(255,200,0) )
	self:DrawShadow(false)
	self.DeathTimer = 30

	timer.Create( self:EntIndex().."_deathtimer", vulturedrops[self:GetDropType()].timer, 1, function()
		if IsValid(self) then
			timer.Destroy(self:EntIndex().."_deathtimer")
			if SERVER then
				self:Remove()
			end	
		end
	end)
	
	vulturedrops[self:GetDropType()].initialize(self)
end

if SERVER then
	function ENT:StartTouch(hitEnt)
		if (hitEnt:IsValid() and hitEnt:IsPlayer()) then
			if hitEnt:HasPerk("vulture") then
				-- The return value indicate whether to consume the drop or not
				if vulturedrops[self:GetDropType()].effect(hitEnt) then
					self:Remove()
				end
			end
		end
	end
end

if CLIENT then
	function ENT:Draw()
		vulturedrops[self:GetDropType()].draw(self)
	end
	
	function ENT:Think()
		if !self:GetRenderAngles() then self:SetRenderAngles(self:GetAngles()) end
		self:SetRenderAngles(self:GetRenderAngles()+(Angle(0,50,0)*FrameTime()))
	end
	
	hook.Add( "PreDrawHalos", "drop_powerups_halos", function()
		halo.Add( ents.FindByClass( "drop_powerup" ), Color( 0, 255, 0 ), 2, 2, 2 )
	end )
end
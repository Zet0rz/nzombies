AddCSLuaFile()

ENT.Type = "anim"
 
ENT.PrintName		= "drop_tombstone"
ENT.Author			= "Zet0r"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

function ENT:SetupDataTables()

	self:NetworkVar( "Entity", 0, "PerkOwner" )
	
end

function ENT:Initialize()
	
	self:SetModel("models/props_c17/gravestone003a.mdl")
	
	--self:PhysicsInit(SOLID_VPHYSICS)
	self:PhysicsInitSphere(50, "default_silent")
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	if SERVER then
		self:SetTrigger(true)
	end
	self:UseTriggerBounds(true, 0)
	self:DrawShadow(false)
	self:SetMaterial("models/shiny.vtf")
	self:SetColor( Color(255,200,0) )
	
	self.OwnerData = {}
	
	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end
	
	timer.Create( self:EntIndex().."_deathtimer", 100, 1, function()
		if self:IsValid() then
			timer.Destroy(self:EntIndex().."_deathtimer")
			if SERVER then
				self:Remove()
			end
		end
	end)
end

if SERVER then
	function ENT:StartTouch(hitEnt)
		--print("Collided")
		if (hitEnt:IsValid() and hitEnt:IsPlayer() and hitEnt == self:GetPerkOwner()) then
			--PrintTable(self.OwnerData)
			
			-- Weapons are completely replaced
			hitEnt:StripWeapons()
			for k,v in pairs(self.OwnerData.weps) do
				local wep = hitEnt:Give(v.class)
				if v.pap then
					wep:ApplyNZModifier("pap")
				end
			end
			for k,v in pairs(self.OwnerData.perks) do
				if v != "tombstone" then
					hitEnt:GivePerk(v)
				end
			end
			nzWeps:GiveMaxAmmo(hitEnt)
			
			timer.Destroy(self:EntIndex().."_deathtimer")
			self:Remove()
		end
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
	
	function ENT:Think()
		if !self:GetRenderAngles() then self:SetRenderAngles(self:GetAngles()) end
		self:SetRenderAngles(self:GetRenderAngles()+(Angle(0,50,0)*FrameTime()))
	end
	
	hook.Add( "PreDrawHalos", "drop_powerups_halos", function()
		halo.Add( ents.FindByClass( "drop_powerup" ), Color( 0, 255, 0 ), 2, 2, 2 )
	end )
end
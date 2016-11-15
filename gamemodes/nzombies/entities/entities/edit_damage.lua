
AddCSLuaFile()
ENT.Type = "anim"

ENT.PrintName		= ""
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable		= false
ENT.AdminOnly		= false
ENT.Editable		= true

ENT.PrintName			= "Radiation"
ENT.Category			= "Editors"

ENT.NZOnlyVisibleInCreative = true

function ENT:Initialize()

	--BaseClass.Initialize( self )
	
	-- Set it up just like a prop_effect
	local Radius = 6
	local min = Vector( 1, 1, 1 ) * Radius * -0.5
	local max = Vector( 1, 1, 1 ) * Radius * 0.5

	if ( SERVER ) then

		self:SetModel( "models/props_junk/watermelon01.mdl" )

		-- Don't use the model's physics - create a box instead
		self:PhysicsInitBox(min, max)

		-- Set up our physics object here
		local phys = self:GetPhysicsObject()
		if ( IsValid( phys ) ) then
			phys:Wake()
			phys:EnableGravity( false )
			phys:EnableDrag( false )
		end

		self:DrawShadow( false )
		self:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )
		
		--self:SetTrigger(true)

	else

		self.GripMaterial = Material( "sprites/grip" )

	end
	
	self.NextDamage = 0

	-- Set collision bounds exactly
	self:SetCollisionBounds( min, max )

end

function ENT:Draw()

	if !nzRound:InState( ROUND_CREATE ) then return end

	-- Don't draw the grip if there's no chance of us picking it up
	local ply = LocalPlayer()
	local wep = ply:GetActiveWeapon()
	if ( !IsValid( wep ) ) then return end

	local weapon_name = wep:GetClass()

	if ( weapon_name != "weapon_physgun" && weapon_name != "weapon_physcannon" && weapon_name != "gmod_tool" ) then 
		return
	end

	render.SetMaterial( self.GripMaterial )
	render.DrawSprite( self:GetPos(), 16, 16, color_white )

end

function ENT:PhysicsUpdate( physobj )

	if ( CLIENT ) then return end

	-- Don't do anything if the player isn't holding us
	if ( !self:IsPlayerHolding() && !self:IsConstrained() ) then

		physobj:SetVelocity( Vector( 0, 0, 0 ) )
		physobj:Sleep()

	end

end

function ENT:OnRemove()
	
end


function ENT:SetupDataTables()

	self:NetworkVar( "Bool",	0, "On", { KeyName = "on", Edit = { type = "Boolean", order = 1 } }  );
	self:NetworkVar( "Int",	0, "Radius", { KeyName = "radius", Edit = { type = "Int", min = 0, max = 1000, order = 2 } }  );
	self:NetworkVar( "Int",	1, "Damage", { KeyName = "damage", Edit = { type = "Int", min = 0, max = 250, order = 3 } }  );
	self:NetworkVar( "Float",	0, "Delay", { KeyName = "delay", Edit = { type = "Float", min = 0, max = 10, order = 4 } }  );
	self:NetworkVar( "Bool",	1, "Tesla", { KeyName = "tesla", Edit = { type = "Boolean", order = 5 } }  );
	self:NetworkVar( "Bool",	2, "Poison", { KeyName = "poison", Edit = { type = "Boolean", order = 6 } }  );
	self:NetworkVar( "Bool",	3, "Radiation", { KeyName = "radiation", Edit = { type = "Boolean", order = 7 } }  );
	
	if SERVER then
		self:NetworkVarNotify("Radius", self.OnRadiusChanged)
	
		self:SetOn(true)
		self:SetRadius(50)
		self:SetDamage(1)
		self:SetDelay(0.1)
		self:SetTesla(false)
		self:SetPoison(false)
		self:SetRadiation(false)
	end

end

function ENT:OnRadiusChanged(name, old, new)
	self:UseTriggerBounds(true, new)
	print("Trigger bounds changed to ".. new)
end

function ENT:StartTouch(ent)
	print("Start", ent)
end

function ENT:Touch(ent)
	print("Touch", ent)
end

function ENT:EndTouch(ent)
	print("End", ent)
end

function ENT:Think()

	local ct = CurTime()
	
	if ct > self.NextDamage then
		if self:GetOn() then
			if SERVER then
				local dmg = DamageInfo()
				dmg:SetAttacker(self)
				dmg:SetDamage(self:GetDamage())
				dmg:SetDamageType(DMG_RADIATION)
				dmg:SetDamageForce(Vector(0,0,0))
				dmg:SetDamagePosition(self:GetPos())
				
				for k,v in pairs(ents.FindInSphere(self:GetPos(), self:GetRadius())) do
					if IsValid(v) and v:IsPlayer() and v:GetNotDowned() then
						v:TakeDamageInfo(dmg)
					end
				end
			else
				local e = EffectData()
				e:SetMagnitude(1.1)
				e:SetScale(1.5)
				for k,v in pairs(ents.FindInSphere(self:GetPos(), self:GetRadius())) do
					if IsValid(v) and v:IsPlayer() and v:GetNotDowned() then
						local islocal = v == LocalPlayer()
						if self:GetTesla() then
							if !v.LightningAura or v.LightningAura < ct then
								e:SetEntity(v)
								util.Effect("lightning_aura", e)
							end
							if islocal then
								surface.PlaySound("weapons/physcannon/superphys_small_zap" .. math.random(1,4) .. ".wav")
							end
							v.LightningAura = ct + 1
						end
						if islocal and self:GetRadiation() then
							surface.PlaySound("player/geiger" .. math.random(1,3) .. ".wav")
						end
					end
				end
			end
		end
		
		self.NextDamage = ct + self:GetDelay()
	end
	
end

function ENT:UpdateTransmitState()
	return TRANSMIT_PVS
end


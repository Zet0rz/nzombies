
AddCSLuaFile()
ENT.Type = "anim"

ENT.PrintName		= ""
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable		= false
ENT.AdminOnly		= false
ENT.Editable		= false

ENT.PrintName			= "Fire Effect"
ENT.Category			= "Editors"

ENT.NZOnlyVisibleInCreative = true

function ENT:Initialize()

	--BaseClass.Initialize( self )
	
	//Set it up just like a prop_effect
	local Radius = 6
	local min = Vector( 1, 1, 1 ) * Radius * -0.5
	local max = Vector( 1, 1, 1 ) * Radius * 0.5

	if ( SERVER ) then

		self:SetModel( "models/props_junk/watermelon01.mdl" )

		-- Don't use the model's physics - create a box instead
		self:PhysicsInitBox( min, max )

		-- Set up our physics object here
		local phys = self:GetPhysicsObject()
		if ( IsValid( phys ) ) then
			phys:Wake()
			phys:EnableGravity( false )
			phys:EnableDrag( false )
		end
		
		self:CreateFire()

		self:DrawShadow( false )
		self:SetCollisionGroup( COLLISION_GROUP_WEAPON )

	else

		self.GripMaterial = Material( "sprites/grip" )

		-- Get the attached entity so that clientside functions like properties can interact with it
		local tab = ents.FindByClassAndParent( "prop_dynamic", self )
		if ( tab && IsValid( tab[ 1 ] ) ) then self.AttachedEntity = tab[ 1 ] end

	end

	-- Set collision bounds exactly
	self:SetCollisionBounds( min, max )

end

function ENT:CreateFire()
	self.FireEffect = ents.Create("env_fire")
	self.FireEffect:SetPos( self:GetPos() )
	self.FireEffect:SetParent( self )
	self.FireEffect:Spawn()
	self.FireEffect:Activate()
	self.FireEffect:Fire("StartFire")
	self.FireEffect:SetKeyValue("spawnflags", "1")
	--print(self.FireEffect)
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

if SERVER then
	hook.Add("PostCleanupMap", "RestoreFireEffects", function()
		for k,v in pairs(ents.FindByClass("nz_fire_effect")) do
			v:CreateFire()
		end
	end)
end


	// Doesn't work :(
--[[function ENT:SetupDataTables()

	self:NetworkVar( "Bool",	0, "On", { KeyName = "on", Edit = { type = "Boolean", order = 1 } }  );
	self:NetworkVar( "Int",	0, "Size", { KeyName = "size", Edit = { type = "Int", min = 0, max = 1000, order = 2 } }  );
	self:NetworkVar( "Float",	0, "DmgMultiplier", { KeyName = "dmgmultiplier", Edit = { type = "Float", min = 0, max = 10, order = 3 } }  );
	self:NetworkVar( "Bool",	1, "Glow", { KeyName = "glow", Edit = { type = "Boolean", order = 4 } }  );
	self:NetworkVar( "Bool",	2, "Smoke", { KeyName = "smoke", Edit = { type = "Boolean", order = 5 } }  );
	
	self:SetOn(true)
	self:SetGlow(true)
	self:SetSmoke(true)
	
	if SERVER then
		self:NetworkVarNotify( "Glow", self.OnVarChanged )
		self:NetworkVarNotify( "DmgMultiplier", self.OnVarChanged )
		self:NetworkVarNotify( "Size", self.OnVarChanged )
		self:NetworkVarNotify( "On", self.OnVarChanged )
		self:NetworkVarNotify( "Smoke", self.OnVarChanged )
	end

end

function ENT:OnVarChanged(name, old, new)
	if name == "On" then
		if new then
			self.FireEffect:Fire("StartFire")
		else
			self.FireEffect:Fire("Extinguish")
		end
	elseif name == "Size" then
		self.FireEffect:SetKeyValue("firesize", tostring(new))
	elseif name == "DmgMultiplier" then
		self.FireEffect:SetKeyValue("damage scale", tostring(new))
	elseif name == "Glow" then
		if new then
			self:SetKeyValue("spawnflags", tostring(1 + 32 + (!self:GetSmoke() and 2 or 0)))
		else
			self:SetKeyValue("spawnflags", tostring(1 + (!self:GetSmoke() and 2 or 0)))
		end
	elseif name == "Smoke" then
		if new then
			self:SetKeyValue("spawnflags", tostring(1 + 2 + (!self:GetGlow() and 32 or 0)))
			print(1 + 2 + (!self:GetGlow() and 32 or 0))
		else
			self:SetKeyValue("spawnflags", tostring(1 + (!self:GetGlow() and 32 or 0)))
		end
	end
end]]

function ENT:UpdateTransmitState()
	return TRANSMIT_PVS
end


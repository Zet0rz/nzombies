
AddCSLuaFile()
DEFINE_BASECLASS( "base_edit" )

ENT.Spawnable			= true
ENT.AdminOnly			= true

ENT.PrintName			= "Dynamic Light"
ENT.Category			= "Editors"

function ENT:Initialize()

	BaseClass.Initialize( self )

	--self:SetMaterial( Material("gmod/demo.png",  "noclamp smooth") )
	
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

		self:DrawShadow( false )
		self:SetCollisionGroup( COLLISION_GROUP_WEAPON )

	else

		self.GripMaterial = Material( "sprites/grip" )

		-- Get the attached entity so that clientside functions like properties can interact with it
		local tab = ents.FindByClassAndParent( "prop_dynamic", self )
		if ( tab && IsValid( tab[ 1 ] ) ) then self.AttachedEntity = tab[ 1 ] end

	end
	
end

function ENT:SetupDataTables()

	self:NetworkVar( "Int",	0, "Brightness", { KeyName = "brightness", Edit = { type = "Int", min = 0, max = 5, order = 1 } }  )
	self:NetworkVar( "Vector",	0, "LightColor", { KeyName = "color", Edit = { type = "VectorColor", order = 2 } }  )
	self:NetworkVar( "Int",	1, "Size", { KeyName = "size", Edit = { type = "Int", min = 0, max = 1000, order = 3 } }  )
	
	self:NetworkVar( "Int",	2, "Style", { KeyName = "style", Edit = { type = "Int", min = 0, max = 12, order = 4 } }  )
	
	self:NetworkVar( "Bool", 0, "Elec", { KeyName = "electricity", Edit = { type = "Boolean" } }  )

	if ( SERVER ) then

		-- defaults
		self:SetLightColor( Vector(1, 1, 1) ) -- White
		self:SetBrightness( 2 )
		self:SetSize(256)
		self:SetStyle(0) -- Standard bright all the time
		self:SetElec(false)

	end

end

if CLIENT then
	function ENT:Draw()
		if !self:GetElec() or nzElec.Active then
			local size = self:GetSize()
			if !self.LightSize or self.LightSize != size then
				self:SetRenderBounds(Vector(-size, -size, -size), Vector(size, size, size))
				self.LightSize = size
			end
			local color = self:GetLightColor() * 255
			local brightness = self:GetBrightness()
			local style = self:GetStyle()
			local dlight = DynamicLight( self:EntIndex() )
			if ( dlight ) then
				dlight.pos = self:GetPos()
				dlight.r = color[1]
				dlight.g = color[2]
				dlight.b = color[3]
				dlight.brightness = brightness
				dlight.Decay = 1000
				dlight.Size = size
				dlight.DieTime = CurTime() + 1
				dlight.Style = style
			end
		end
		
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
end

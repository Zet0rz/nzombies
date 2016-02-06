AddCSLuaFile( )

ENT.Type = "anim"

ENT.PrintName		= "random_box_handler"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.Weapons			= {}

function ENT:Initialize()

	self:SetModel( "models/hoff/props/mysterybox/box.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self:DrawShadow( false )

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	
end

function ENT:AddWeapon(class)
	if !table.HasValue(self.Weapons, class) then
		table.insert(self.Weapons, class)
		print("Added "..class.." to the list of weapons the Random Box can spawn")
	else
		print("Random Box Handler already has "..class.." in it. Don't add it twice")
	end
end

function ENT:ClearWeapons()
	self.Weapons = {}
	print("Cleared all weapons from the list of the Random Box Handler")
end

function ENT:SetWeaponsList( guns )
	self.Weapons = guns
end

function ENT:RemoveWeapon(class)
	if table.HasValue(self.Weapons, class) then
		table.RemoveByValue(self.Weapons, class)
		print("Removed "..class.." from the list of weapons the Random Box can spawn")
	else
		print("Random Box Handler doesn't have "..class.." in it.")
	end
end

function ENT:GetWeaponsList()
	return self.Weapons
end

if CLIENT then
	function ENT:Draw()
		if nz.Rounds.Data.CurrentState == ROUND_CREATE then
			self:DrawModel()
		end
	end
end

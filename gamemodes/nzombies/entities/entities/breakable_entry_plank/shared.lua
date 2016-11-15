AddCSLuaFile( )

ENT.Type = "anim"
 
ENT.PrintName		= "breakable_entry_plank"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""
//models/props_interiors/elevatorshaft_door01a.mdl
//models/props_debris/wood_board02a.mdl
function ENT:Initialize()

	self:SetModel("models/props_debris/wood_board02a.mdl")
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetModelScale(1.25)
	
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end
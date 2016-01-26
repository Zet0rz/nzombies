AddCSLuaFile( )

ENT.Type = "anim"
 
ENT.PrintName		= "nav_room_controller"
ENT.Author			= "Zet0r"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

function ENT:SetupDataTables()

	--self:NetworkVar( "Bool", 0, "Locked" )
	
end

function ENT:Initialize()
	if SERVER then
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_BBOX )
		self:PhysWake( )
		self:SetNotSolid( false )
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
		self:DrawShadow( false )
		self:SetColor( Color(255, 100, 0, 100) )
		self:SetModel("models/props_combine/breenglobe.mdl")
	end
end

if CLIENT then
	function ENT:Draw()
		if nz.Rounds.Data.CurrentState == ROUND_CREATE then
			self:DrawModel()
		end
	end
end
AddCSLuaFile( )

ENT.Type = "anim"
 
ENT.PrintName		= "zed_special_spawns"
ENT.Author			= "Zet0r"
ENT.Contact			= "youtube.com/Zet0r"
ENT.Purpose			= ""
ENT.Instructions	= ""

function ENT:SetupDataTables()

	self:NetworkVar( "String", 0, "Link" )
	
end

function ENT:Initialize()
	self:SetModel( "models/player/odessa.mdl" )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self:SetColor(Color(255, 0, 0))
	self:DrawShadow( false )
end

if CLIENT then
	function ENT:Draw()
		if Round:InState( ROUND_CREATE ) then
			self:DrawModel()
		end
	end
end

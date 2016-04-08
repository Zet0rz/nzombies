AddCSLuaFile( )

-- Defining the entity type
ENT.Type = "anim"

-- Defining the name to call it by, the author, how to contact them, the purpose, and instruction on how to use this
ENT.PrintName		= "breakable_entry_plank"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

-- Loading models
//models/props_interiors/elevatorshaft_door01a.mdl
//models/props_debris/wood_board02a.mdl


function ENT:Initialize()

	self:SetModel("models/props_debris/wood_board02a.mdl")
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
end


-- Client side operations to draw plank model
if CLIENT then
	function ENT:Draw()
		//if nz.Rounds.Data.CurrentState == ROUND_CREATE then
			self:DrawModel()
	//	end
	end
end

AddCSLuaFile( )

ENT.Type = "anim"
 
ENT.PrintName		= "nz_script_prop"
ENT.Author			= "Zet0r"
ENT.Contact			= "youtube.com/Zet0r"
ENT.Purpose			= "Scriptable prop for nZombies"
ENT.Instructions	= ""

function ENT:Initialize()
	if SERVER then
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_VPHYSICS )
		--self:DrawShadow( false )
		self:SetUseType( SIMPLE_USE )
	end
end

function ENT:OnRemove()
	hook.Call("nzmapscript_PropRemoved", nil, self)
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end
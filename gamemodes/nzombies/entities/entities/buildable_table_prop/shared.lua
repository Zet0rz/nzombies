AddCSLuaFile( )

ENT.Type = "anim"
 
ENT.PrintName		= "buildable_table_prop"
ENT.Author			= "Zet0r"
ENT.Contact			= "youtube.com/Zet0r"
ENT.Purpose			= "Scriptable prop for nZombies"
ENT.Instructions	= ""

function ENT:SetupDataTables()
	self:NetworkVar( "Entity", 0, "Workbench" )
end

function ENT:Initialize()
	if SERVER then
		--if !IsValid(self.Table) then self:Remove() end
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_VPHYSICS )
		--self:DrawShadow( false )
		self:SetUseType( SIMPLE_USE )
		self.RelayUse = self:GetWorkbench()
	end
end

function ENT:Use(arg1, arg2, arg3, arg4)
	local tbl = self:GetWorkbench()
	if IsValid(tbl) then
		tbl:Use(arg1, arg2, arg3, arg4) -- Relay info
	end
end

if CLIENT then
	function ENT:GetNZTargetText()
		local tbl = self:GetWorkbench()
		if IsValid(tbl) then
			return tbl:GetNZTargetText() -- Relay info
		end
	end
end
AddCSLuaFile( )

ENT.Type = "anim"
 
ENT.PrintName		= "wall_block_buy"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

function ENT:SetupDataTables()

	self:NetworkVar( "Bool", 0, "Locked" )
	
end

function ENT:Initialize()
	if SERVER then
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_VPHYSICS )
		self:DrawShadow( false )
		self:SetUseType( SIMPLE_USE )
		self.Boundone,self.Boundtwo = self:GetCollisionBounds()
	end
	self:BlockLock()
end

function ENT:BlockUnlock()
	self.Locked = false
	--self:SetNoDraw( true )
	if SERVER then
		self:SetCollisionBounds( Vector(-4, -4, 0), Vector(4, 4, 64) )
	end
	self:SetSolid( SOLID_NONE )
	self:SetLocked(false)
end

function ENT:BlockLock()
	self.Locked = true
	--self:SetNoDraw( false )
	if SERVER then
		self:SetCollisionBounds( self.Boundone, self.Boundtwo )
	end
	self:SetSolid( SOLID_VPHYSICS )
	self:SetLocked(true) 
end

function ENT:OnRemove()
	if SERVER then
		nz.Doors.Functions.RemoveLink( self )
	end
end

if CLIENT then
	function ENT:Draw()
		if (nz.Rounds.Data.CurrentState == ROUND_PROG or nz.Rounds.Data.CurrentState == ROUND_PREP) then
			if self:GetLocked() then
				self:DrawModel()
			end
		else
			self:DrawModel()
		end
		if nz.Rounds.Data.CurrentState == ROUND_CREATE then
			if nz.Doors.Data.DisplayLinks[self] != nil then
				nz.Display.Functions.DrawLinks(self, nz.Doors.Data.BuyableProps[self:EntIndex()].link)
			end
		end
	end
end
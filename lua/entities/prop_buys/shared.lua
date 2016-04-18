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
	--self.Locked = false
	--self:SetNoDraw( true )
	if SERVER then
		self:SetCollisionBounds( Vector(-4, -4, 0), Vector(4, 4, 64) )
	end
	self:SetSolid( SOLID_NONE )
	self:SetNoDraw(true)
	self:SetLocked(false)
end

function ENT:BlockLock()
	--self.Locked = true
	--self:SetNoDraw( false )
	if SERVER then
		self:SetCollisionBounds( self.Boundone, self.Boundtwo )
	end
	self:SetSolid( SOLID_VPHYSICS )
	self:SetNoDraw(false)
	self:SetLocked(true)
end

function ENT:OnRemove()
	if SERVER then
		nzDoors:RemoveLink( self, true )
	else
		self:SetLocked(false)
	end
end

if CLIENT then
	function ENT:Draw()
		if nzRound:InProgress() then
			--if self:IsLocked() then
				self:DrawModel()
			--end
		else
			self:DrawModel()
		end
		if nzRound:InState( ROUND_CREATE ) then
			if nzDoors.DisplayLinks[self] then
				nzDisplay.DrawLinks(self, nzDoors.PropDoors[self:EntIndex()].link)
			end
		end
	end
end
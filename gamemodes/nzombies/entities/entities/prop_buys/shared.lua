AddCSLuaFile( )

ENT.Type = "anim"
 
ENT.PrintName		= "wall_block_buy"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

function ENT:SetupDataTables()

	self:NetworkVar( "Bool", 0, "NWLocked" )
	
end

function ENT:Initialize()
	if SERVER then
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_VPHYSICS )
		self:DrawShadow( false )
		self:SetUseType( SIMPLE_USE )
		self.Boundone,self.Boundtwo = self:GetCollisionBounds()
		self:BlockLock(true)
	end
end

function ENT:BlockUnlock(spawn)
	--self.Locked = false
	--self:SetNoDraw( true )
	if SERVER then
		--self:SetCollisionBounds( Vector(-4, -4, 0), Vector(4, 4, 64) )
		self:SetSolid( SOLID_NONE )
		self:SetNWLocked(false)
		self:EmitSound("nz/effects/gone.wav")
		if !spawn then -- Spawning a prop shouldn't register it to the doors list
			self:SetLocked(false)
		end
		local pos = self:GetPos()
		
		timer.Simple(0.5, function()
			if IsValid(self) then
				if !self:GetNWLocked() then
					self:SetNoDraw(true)
				end
			end
		end)
		
		local e = EffectData()
		e:SetRadius(1)
		e:SetMagnitude(0.5)
		e:SetScale(1)
		e:SetEntity(self)
		util.Effect("lightning_field", e)
	end
end

function ENT:BlockLock(spawn)
	--self.Locked = true
	--self:SetNoDraw( false )
	if SERVER then
		--self:SetCollisionBounds( self.Boundone, self.Boundtwo )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetNoDraw(false)
		self:SetNWLocked(true)
		if !spawn then
			self:SetLocked(true)
		end
	end
end

function ENT:OnRemove()
	if SERVER then
		nzDoors:RemoveLink( self, true )
		self:SetLocked(false)
	else
		--self:SetLocked(false)
	end
end

if CLIENT then
	
	function ENT:Think()
		if !self.ShakeEffectTime then
			if !self:GetNoDraw() and !self:GetNWLocked() then
				self.ShakeEffectTime = CurTime() + 0.3
				self.ShakePos = self:GetNetworkOrigin()
			end
		else
			if CurTime() > self.ShakeEffectTime then
				self.ShakePos = self.ShakePos + Vector(0,0,1000)*FrameTime()
				if CurTime() - self.ShakeEffectTime >= 0.5 then
					self.ShakePos = nil
					self.ShakeEffectTime = nil
					self:SetRenderOrigin(nil)
				end
			end
		end
	end

	function ENT:Draw()
		if self.ShakePos then
			--print("Yo shakey")
			self:SetRenderOrigin(self.ShakePos + Vector(math.Rand(-1,1), math.Rand(-1,1), math.Rand(-1,1)))
		end
		self:DrawModel()
		
		if nzRound:InState( ROUND_CREATE ) then
			if nzDoors.DisplayLinks[self] then
				nzDisplay.DrawLinks(self, nzDoors.PropDoors[self:EntIndex()].link)
			end
		end
	end
end
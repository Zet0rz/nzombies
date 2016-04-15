function EFFECT:Init( data )

	self.Start = data:GetOrigin()
	self.Catcher = data:GetEntity()
	self.ParticleDelay = 0.1
	self.MoveSpeed = 50
	self.DistToCatch = 100 -- Squared (10)
	
	self.NextParticle = CurTime()
	
	self.Emitter = ParticleEmitter( self.Start )
	
	print(self.Emitter, self.NextParticle, self, self.Catcher)
	
end


--[[---------------------------------------------------------
   THINK
-----------------------------------------------------------]]
function EFFECT:Think( )
	if CurTime() >= self.NextParticle then
		local particle = self.Emitter:Add("sprites/glow04_noz", self.Emitter:GetPos())
		if (particle) then		
			particle:SetVelocity( Vector(0,0,0) )
			particle:SetColor(math.random(200,255), math.random(100,200), math.random(100,150))
			particle:SetLifeTime( 0 )
			particle:SetDieTime( 0.3 )
			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( 25 )
			particle:SetEndSize( 25 )
			particle:SetRoll( math.Rand(0, 36)*10 )
			--particle:SetRollDelta( math.Rand(-200, 200) )
			particle:SetAirResistance( 400 )
			particle:SetGravity( Vector( 0, 0, 0 ) )
			
			self.NextParticle = CurTime() + self.ParticleDelay
		end
	end
	self.Emitter:SetPos( (self.Catcher:GetPos()-self.Emitter:GetPos()):GetNormal() * self.MoveSpeed * FrameTime() + self.Emitter:GetPos() )
	if self.Emitter:GetPos():DistToSqr(self.Catcher:GetPos()) <= self.DistToCatch then
		self.Catcher:CollectSoul()
		return false
	else
		return true
	end
end

--[[---------------------------------------------------------
   Draw the effect
-----------------------------------------------------------]]
function EFFECT:Render()
end


local mats = {
	Material( "decals/glass/shot1" ),
	Material( "decals/glass/shot2" ),
	Material( "decals/glass/shot3" ),
	Material( "decals/glass/shot4" ),
	Material( "decals/glass/shot5" ),
	nil
}

--[[---------------------------------------------------------
   Init( data table )
-----------------------------------------------------------]]
function EFFECT:Init( data )

	self.Size = data:GetScale() or 1
	self.Parent = data:GetEntity()
	self.Frequency = data:GetMagnitude() or 2
	self.Pos = self.Parent:GetPos()
	if self.Parent.WebAura then -- Already have an aura
		if data:GetScale() then
			self.Parent.WebAura = CurTime() + data:GetScale() -- Extend to new time
		else
			self.Parent.WebAura = CurTime() + 20
		end
		self.KILL = true -- and make sure to kill this effect
	else
		if data:GetScale() then
			self.Parent.WebAura = CurTime() + data:GetScale()
		else
			self.Parent.WebAura = CurTime() + 20 -- Default time for this effect
		end

		self:SetRenderBoundsWS( self.Pos, self.Pos, Vector(100,100,100) )
		self.MoveSpeed = 50
		
		self.NextParticle = CurTime()
		
		self.Emitter = ParticleEmitter( self.Pos )
	end
end

--[[---------------------------------------------------------
   THINK
-----------------------------------------------------------]]

function EFFECT:Think( )
	if self.KILL then return false end
	
	if CurTime() >= self.NextParticle then
		local diroffset = Vector(math.Rand(-1,1), math.Rand(-1,1),0):GetNormalized()*5
		local pos = self.Emitter:GetPos() + diroffset + Vector(0,0,20)
		local particle = self.Emitter:Add(mats[math.random(#mats)], pos)
		if (particle) then
			particle:SetVelocity( Vector(0,0,0) )
			particle:SetColor( 255, 255, 255 )
			particle:SetLifeTime( 5 )
			particle:SetDieTime( 10 )
			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( 15 )
			particle:SetEndSize( 25 )
			particle:SetRoll( math.Rand(0, 360)*10 )
			particle:SetRollDelta( math.Rand(-10, 10) )
			particle:SetAirResistance( 400 )
			particle:SetGravity( Vector( 0, 0, 0 ) )
			
			particle:SetNextThink(CurTime())
			particle.Dir = diroffset:Angle():Forward()
			particle.Vel = 30
			particle:SetThinkFunction( function()
				if !IsValid(self.Parent) and self.Emitter then self.Emitter:Finish() return end
				particle.Dir:Rotate(Angle(0,3,0))
				particle:SetVelocity( Vector(particle.Dir.x * particle.Vel, particle.Dir.y * particle.Vel, 5) )
				particle.Vel = particle.Vel + 0.1
				particle:SetNextThink(CurTime() + 0.01)
			end )
			
			self.NextParticle = CurTime() + self.Frequency
		end
	end
	if IsValid(self.Parent) then
		if (type(self.Parent.WebAura) == "number" and CurTime() > self.Parent.WebAura) or !self.Parent.WebAura then
			self.Emitter:Finish()
			self.Parent.WebAura = nil
			return false
		else
			self.Emitter:SetPos( self.Parent:GetPos() )
			return true
		end
	else
		self.Emitter:Finish()
		return false
	end
end

--[[---------------------------------------------------------
   Draw the effect
-----------------------------------------------------------]]
function EFFECT:Render()
end

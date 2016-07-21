function EFFECT:Init( data )
	
	local vOffset = data:GetOrigin()
	
	local NumParticles = 1
	
	local emitter = ParticleEmitter( vOffset )
	
		for i=0, NumParticles do
		
			local particle = emitter:Add( "sprites/physg_glow1", vOffset )
			if (particle) then
				
				particle:SetVelocity( Vector(0,0,0) )
				particle:SetColor(math.random(50,100), math.random(200,255), math.random(100,150))
				
				particle:SetLifeTime( 0 )
				particle:SetDieTime( 0.3 )
				
				particle:SetStartAlpha( 100 )
				particle:SetEndAlpha( 0 )
				
				particle:SetStartSize( 25 )
				particle:SetEndSize( 25 )
				
				particle:SetRoll( math.Rand(0, 36)*10 )
				--particle:SetRollDelta( math.Rand(-200, 200) )
				
				particle:SetAirResistance( 400 )
				
				particle:SetGravity( Vector( 0, 0, 0 ) )
			
			end
			
		end
		
	emitter:Finish()
	
end


--[[---------------------------------------------------------
   THINK
-----------------------------------------------------------]]
function EFFECT:Think( )
	return false
end

--[[---------------------------------------------------------
   Draw the effect
-----------------------------------------------------------]]
function EFFECT:Render()
end

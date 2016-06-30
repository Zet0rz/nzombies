AddCSLuaFile()

EFFECT.Mat = {
	Model("particle/particle_smokegrenade"),
	Model("particle/particle_noisesphere")
}

function EFFECT:Init( data )
	local pos = data:GetOrigin()
	local duration = data:GetMagnitude()
	local em = ParticleEmitter( pos )
		for i = 0, 20 do
			local p = em:Add( self.Mat[math.random(#self.Mat)] , pos )
			if p then
		        p:SetColor(math.random(100,120), math.random(100,150), math.random(150,170))
		        p:SetStartAlpha(255)
		        p:SetEndAlpha(150)
				local vel = VectorRand() * math.Rand(50,300)
				vel.z = 0
		        p:SetVelocity(vel)
		        p:SetLifeTime(0)

		        p:SetDieTime(math.Rand(duration + 0.75, duration + 1.5))

		        p:SetStartSize(math.random(45, 50))
		        p:SetEndSize(math.random(20, 30))
		        p:SetRoll(math.random(-180, 180))
		        p:SetRollDelta(math.Rand(-0.1, 0.1))
		        p:SetAirResistance(100)

		        p:SetCollide(true)
		        p:SetBounce(0.4)

		        p:SetLighting(false)
			end
		end
	em:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
	return false
end

local gasparticles = {
	Model("particle/particle_smokegrenade"),
	Model("particle/particle_noisesphere")
}

--Main function
function EFFECT:Init(data)
	--Create particle emitter
	local emitter = ParticleEmitter(data:GetOrigin())
		--Amount of particles to create
		for i=0, 16 do
			--Safeguard
			if !emitter then return end

			local Pos = (data:GetOrigin() + Vector( math.Rand(-5,5), math.Rand(-5,5), math.Rand(-5,5) ))
			local particle = emitter:Add( table.Random(gasparticles), Pos )
			if (particle) then
				particle:SetVelocity(VectorRand() * math.Rand(100,200))
				particle:SetLifeTime(0)
				particle:SetDieTime(math.Rand(4, 6))
				particle:SetColor(100,255,150)
				particle:SetLighting(false)
				particle:SetStartAlpha(255)
				particle:SetEndAlpha(0)
				
				local Size = math.Rand(10,20)
				particle:SetStartSize(Size)
				particle:SetEndSize(Size)
				particle:SetRoll(math.Rand(-360, 360))
				particle:SetRollDelta(math.Rand(-0.21, 0.21))
				particle:SetAirResistance(math.Rand(520,620))
				particle:SetGravity( Vector(0, 0, 0) )
				particle:SetCollide(false)
				particle:SetBounce(0.42)
				particle:SetLighting(1)
			end
		end
	--We're done with this emitter
	emitter:Finish()
end

--Kill effect
function EFFECT:Think()
return false
end

--Not used
function EFFECT:Render()
end
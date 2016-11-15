AddCSLuaFile()

local matground = {
	Model("particle/particle_smokegrenade"),
	Model("particle/particle_noisesphere")
}
local matshoot = {
	Model("particle/particle_debris_01"),
	Model("particle/particle_debris_02"),
	Model("particle/particle_noisesphere"),
	Model("particle/particle_smokegrenade")
}


function EFFECT:Init( data )
	local pos = data:GetOrigin()
	local duration = data:GetMagnitude()
	local em = ParticleEmitter( pos )
		for i = 0, 10 do
			local p = em:Add( matshoot[math.random(#matshoot)] , pos )
			if p then
		        p:SetColor(math.random(45,55), math.random(40,50), math.random(40,50))
		        p:SetStartAlpha(255)
		        p:SetEndAlpha(0)
				local vel = VectorRand() * math.Rand(40,70)
				vel.z = math.random(200,1000)
		        p:SetVelocity(vel)
				p:SetGravity(Vector(0,0,-1000))
		        p:SetLifeTime(0)

		        p:SetDieTime(math.Rand(duration + 0.5, duration + 1))

		        p:SetStartSize(math.random(35, 40))
		        p:SetEndSize(math.random(10, 20))
		        p:SetRoll(math.random(-180, 180))
		        p:SetRollDelta(math.Rand(-0.1, 0.1))
		        p:SetAirResistance(100)

		        p:SetCollide(true)
		        p:SetBounce(0.4)

		        p:SetLighting(false)
			end
		end
		for i = 0, 5 do
			local p = em:Add( matground[math.random(#matground)] , pos )
			if p then
		        p:SetColor(math.random(45,55), math.random(40,50), math.random(40,50))
		        p:SetStartAlpha(255)
		        p:SetEndAlpha(250)
				local vel = VectorRand() * math.Rand(10,50)
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

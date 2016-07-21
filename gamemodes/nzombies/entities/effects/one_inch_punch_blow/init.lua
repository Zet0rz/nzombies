local particles = {
	Model("particle/particle_ring_wave_8"),
}

local delay = 0.05
local amount = 3

--Main function
function EFFECT:Init(data)
	--Create particle emitter
	local emitter = ParticleEmitter(data:GetOrigin())
	local bone = math.Round(data:GetMagnitude())
	local num = 0
	timer.Create("one_inch_punch_effect", delay, amount, function()
		if IsValid(LocalPlayer()) and LocalPlayer():GetActiveWeapon():GetClass() == "nz_one_inch_punch" then
			num = num + 1
			local pos = LocalPlayer():GetViewModel():GetBoneMatrix(bone):GetTranslation()
			local particle = emitter:Add( table.Random(particles), pos )
			if (particle) then
				particle:SetVelocity(LocalPlayer():GetVelocity())
				particle:SetLifeTime(0)
				particle:SetDieTime(1.1)
				particle:SetColor(200,200,200)
				particle:SetLighting(false)
				particle:SetStartAlpha(100)
				particle:SetEndAlpha(0)
					
				local Size = math.Rand(5,10)
				particle:SetStartSize(Size)
				particle:SetEndSize(Size)
				particle:SetRoll(math.Rand(-360, 360))
				particle:SetRollDelta(math.Rand(-2, 2))
				particle:SetAirResistance(math.Rand(200, 400))
				particle:SetGravity( Vector(0, 0, 0) )
				particle:SetCollide(false)
				particle:SetBounce(0.42)
				--particle:SetLighting(1)
			end
			
			if num >= amount then
				emitter:Finish()
				timer.Destroy("one_inch_punch_effect")
			end
		else
			emitter:Finish()
			timer.Destroy("one_inch_punch_effect")
		end
	end)
end

function EFFECT:Think()
	if !self.NextParticle or self.NextParticle < CurTime() then
		
		self.NextParticle = CurTime() + delay
	end
	if self.KillTime and self.KillTime < CurTime() then
		print("Done")
		emitter:Finish()
		return false
	end
	self:NextThink(CurTime())
end

--Not used
function EFFECT:Render()
end
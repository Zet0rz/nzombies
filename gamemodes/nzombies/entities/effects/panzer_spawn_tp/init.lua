AddCSLuaFile()

EFFECT.MatEdge = Material( "effects/tool_tracer" )
EFFECT.MatCenter = Material( "sprites/physbeama" )
EFFECT.MatGlow1 = Material( "sprites/physg_glow1" )
EFFECT.MatGlow2 = Material( "sprites/physg_glow2" )
EFFECT.MatGlowCenter = Material( "sprites/glow04_noz" )

EFFECT.Mat = {
	--Model("gmod/scope-refract"),
	Model("particle/particle_sphere"),
	Model("particle/particle_smokegrenade"),
	Model("particle/particle_noisesphere")
}

local mid = Model("models/effects/comball_glow1")

local colors = {
	{150, 100, 200},
	{160, 100, 150},
	{150, 60, 150},
	{170, 80, 150},
	{120, 60, 200},
	{50, 20, 200}
}

function EFFECT:Init( data )

	self.Size = 5
	self.MaxArcs = 2
	self.Frequency = 0.05

	self.Alpha = 255
	self.Life = 0
	self.KillTime = CurTime() + 1.5
	self.NextArc = 0
	self.Arcs = {}
	self.Queue = 1

	local pos = data:GetOrigin()
	self.Pos = pos
	local duration = data:GetMagnitude()
	
	sound.Play("ambient/machines/teleport4.wav", self.Pos, 100, 100, 1)
	
	local em = ParticleEmitter( pos )
		for i = 0, 20 do
			local p = em:Add( self.Mat[math.random(#self.Mat)] , pos )
			if p then
				local col = math.random(1, #colors)
		        p:SetColor(colors[col][1], colors[col][2], colors[col][3])
		        p:SetStartAlpha(255)
		        p:SetEndAlpha(150)
				local vel = VectorRand() * math.Rand(150,200)
				vel.z = math.random(-10, 10)
				
				p:SetPos(pos + vel)
		        p:SetVelocity(vel * -10)
		        p:SetLifeTime(0)

		        p:SetDieTime(math.Rand(duration + 0.2, duration + 0.5))

		        p:SetStartSize(math.random(30, 40))
		        p:SetEndSize(math.random(10, 20))
		        p:SetRoll(math.random(-180, 180))
		        p:SetRollDelta(math.Rand(-0.1, 0.1))
		        p:SetAirResistance(350)

		        p:SetCollide(true)
		        p:SetBounce(0.4)

		        p:SetLighting(false)
			end
		end
		local p = em:Add( mid, pos )
		p:SetStartAlpha(255)
		p:SetEndAlpha(150)
	
		p:SetPos(pos)
		p:SetLifeTime(0)

		p:SetDieTime(1.5)

		p:SetStartSize(0)
		p:SetEndSize(400)
		timer.Simple(0.2, function()
			p:SetStartSize(60)
			p:SetEndSize(60)
		end)
		timer.Simple(1.3, function()
			p:SetStartSize(400)
			p:SetEndSize(0)
		end)
		p:SetRoll(math.random(-180, 180))
		p:SetRollDelta(math.Rand(-0.1, 0.1))
		p:SetAirResistance(300)

		p:SetCollide(false)

		p:SetLighting(false)
	em:Finish()
end

--[[---------------------------------------------------------
   THINK
-----------------------------------------------------------]]
function EFFECT:Think()

	self.Life = self.Life + FrameTime()
	--self.Alpha = 255 * ( 1 - self.Life )

	if self.NextArc <= self.Life then

		local size = #self.Arcs
		--add a arc to the array
		while self.Arcs[size] do
			size = size + 1
		end
		self.Arcs[size] = self:GenerateArc(self.Pos + AngleRand():Forward()*10*self.Size, self.Pos + AngleRand():Forward()*10*self.Size, 0.01, 4)
		self.NextArc = self.NextArc + self.Frequency

		if size >= self.MaxArcs then
			local i = 1
			while not self.Arcs[i] and i <= size do
				i = i + 1
			end
			self.Arcs[i] = nil
		end
	end

	return CurTime() < self.KillTime
end

function EFFECT:GenerateArc(startPos, endPos, branchChance, detail)
	-- MidPoint Displacement for arc lines
	local points = {}
	local maxPoints = 2^detail

	if maxPoints % 2 != 0 then
		maxPoints = maxPoints + 1
	end

	points[0] = startPos

	local randVec = VectorRand() * 10

	randVec.z = math.Clamp(randVec.z, 0, 10)

	points[maxPoints] = endPos + randVec

	local i = 1

	while i < maxPoints do
		local j = (maxPoints / i) / 2
		while j < maxPoints do
			points[j] = ((points[j - (maxPoints / i) / 2] + points[j + (maxPoints / i) / 2]) / 2);
			points[j] = points[j] + VectorRand() * 10
			if math.Rand(0,1) < branchChance then
				points[#points + 1] = self:GenerateArc(points[j], points[j] + Vector(math.random(-50 * branchChance, 50 * branchChance), math.random(-50 * branchChance, 50 * branchChance), math.random(-50 * branchChance, 10 * branchChance)), branchChance/1.3, detail)
			end
			j = j + maxPoints / i
		end
		i = i * 2
	end

	points.size = math.random(1,3)*self.Size
	points.color = Color(200, 240, math.random(230, 255), math.random(200, 255))
	points.dietime = CurTime() + 0.07

	return points
end

--[[---------------------------------------------------------
   Draw the effect
-----------------------------------------------------------]]
function EFFECT:Render()

	if ( self.Alpha < 1 ) then return end

	render.SetMaterial( self.MatCenter )

	for _, arc in pairs(self.Arcs) do
		if arc.dietime <= CurTime() then
			self.Arcs[_] = nil
		else
			self:RenderArc(arc)
		end
	end
	
	render.SetMaterial( self.MatEdge )

	for _, arc in pairs(self.Arcs) do
		self:RenderArc(arc, true)
	end
	
	render.SetMaterial( self.MatGlow1 )
	render.DrawSprite( self.Pos, math.random(40,120)*self.Size, math.random(40,120)*self.Size, Color(math.random(50,150),math.random(100,200),255,math.random(100,200)))
	
	if math.random(0,10) == 0 then
		render.SetMaterial( self.MatGlow2 )
		render.DrawSprite( self.Pos, math.random(20,60)*self.Size, math.random(40,120)*self.Size, Color(math.random(50,150),math.random(100,200),255,math.random(100,200)))
	end
	
	render.SetMaterial( self.MatGlowCenter )
	render.DrawSprite( self.Pos, math.random(15,40)*self.Size, math.random(15,40)*self.Size, Color(math.random(50,150),math.random(100,200),255,math.random(200,250)))
end

function EFFECT:RenderArc(arc, edge)
	for j = 1, #arc - 1 do

		if istable(arc[j]) then
			self:RenderArc(arc[j])
		elseif !istable(arc[j+1]) then

			local texcoord = math.Rand( 0, 1 )

			local startPos = arc[j]
			local endPos = arc[j + 1]

			render.DrawBeam(
				startPos,
				endPos,
				(edge and arc.size*3 or arc.size),
				texcoord,
				texcoord + ((startPos - endPos):Length() / 128),
				arc.color
			)
		end
	end
end
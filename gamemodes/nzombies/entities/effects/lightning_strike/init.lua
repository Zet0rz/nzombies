--Name: Lightning strike using midpoint displacement
--Author: Lolle

--EFFECT.MatCenter = Material( "lightning.png", "unlitgeneric smooth" )
EFFECT.MatEdge = Material( "effects/tool_tracer" )
EFFECT.MatCenter = Material( "sprites/physbeama" )
EFFECT.MatGlow = Material( "sprites/glow04_actual_noz" )

--[[---------------------------------------------------------
   Init( data table )
-----------------------------------------------------------]]
function EFFECT:Init( data )

	self.StartPos = data:GetStart()
	self.EndPos = data:GetOrigin() + VectorRand() * 10
	self.Duration = data:GetMagnitude() or 10
	self.Count = self.Duration * 40
	self.MaxArcs = 5
	self.Radius = 30

	self.Flash = DynamicLight( LocalPlayer():EntIndex() )

	self.Flash.pos = self.EndPos
	self.Flash.r = 255
	self.Flash.g = 255
	self.Flash.b = 255
	self.Flash.brightness = 2
	self.Flash.Decay = 200
	self.Flash.Size = 1500
	self.Flash.style = 6
	self.Flash.DieTime = CurTime() + 0.2


	self.Alpha = 255
	self.Life = 0
	self.NextArc = 0
	self.Arcs = {}
	self.Queue = 1

	self:SetRenderBoundsWS( self.StartPos, self.EndPos )

	sound.Play("nz/hellhound/spawn/strike.wav", self.EndPos, 100, 100, 1)

end

--[[---------------------------------------------------------
   THINK
-----------------------------------------------------------]]
function EFFECT:Think()


	self.Life = self.Life + FrameTime()
	--self.Alpha = 255 * ( 1 - self.Life )

	if self.NextArc <= self.Life and self.Life <= self.Duration - self.Duration * 0.25 then

		local size = #self.Arcs
		--add a arc to the array
		while self.Arcs[size] do
			size = size + 1
		end
		self.Arcs[size] = self:GenerateArc(self.StartPos, self.EndPos, 0.1, 4)
		self.NextArc = self.NextArc + 0.05

		if size >= self.MaxArcs then
			local i = 1
			while not self.Arcs[i] and i <= size do
				i = i + 1
			end
			self.Arcs[i] = nil
		end
	end

	return ( self.Life < self.Duration )
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
			points[j] = points[j] + VectorRand() * 25
			if math.Rand(0,1) < branchChance then
				points[#points + 1] = self:GenerateArc(points[j], points[j] + Vector(math.random(-5000 * branchChance, 5000 * branchChance), math.random(-5000 * branchChance, 5000 * branchChance), math.random(-5000 * branchChance, 100 * branchChance)), branchChance/1.3, detail)
			end
			j = j + maxPoints / i
		end
		i = i * 2
	end

	points.size = math.random(10,30)
	points.color = Color(200, 240, math.random(230, 255), math.random(200, 255))

	return points
end

--[[---------------------------------------------------------
   Draw the effect
-----------------------------------------------------------]]
function EFFECT:Render()

	if ( self.Alpha < 1 ) then return end

	render.SetMaterial( self.MatCenter )

	for _, arc in pairs(self.Arcs) do
		self:RenderArc(arc)
	end

	render.SetMaterial( self.MatEdge )

	for _, arc in pairs(self.Arcs) do
		self:RenderArc(arc, true)
	end

	render.SetMaterial( self.MatGlow )

	render.DrawSprite( self.EndPos + Vector(0,0,30), math.random(400,1000), math.random(400,1000), Color(255,255,255,math.random(0,250)))

	util.ScreenShake( EyePos(), 0.5, 1, 0.1, 10 )

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
				edge and arc.size*1.5 or arc.size,
				texcoord,
				texcoord + ((startPos - endPos):Length() / 128),
				arc.color
			)
		end
	end
end

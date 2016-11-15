--Name: Lightning strike using midpoint displacement
--Author: Lolle

--EFFECT.MatCenter = Material( "lightning.png", "unlitgeneric smooth" )
EFFECT.MatEdge = Material( "effects/tool_tracer" )
EFFECT.MatCenter = Material( "sprites/physbeama" )
EFFECT.MatGlow1 = Material( "sprites/physg_glow1_noz" )
EFFECT.MatGlow2 = Material( "sprites/physg_glow2_noz" )
EFFECT.MatGlowCenter = Material( "sprites/glow04_actual_noz" )

--[[---------------------------------------------------------
   Init( data table )
-----------------------------------------------------------]]
function EFFECT:Init( data )

	self.Pos = data:GetOrigin() + VectorRand() * 10
	self.Duration = data:GetMagnitude() or 2
	self.Count = self.Duration * 40
	self.MaxArcs = 2
	self.Radius = 30
	self.Parent = data:GetEntity()

	self.Alpha = 255
	self.Life = 0
	self.NextArc = 0
	self.Arcs = {}
	self.Queue = 1

	self:SetRenderBounds( Vector(0,0,0), Vector(0,0,0), Vector(100,100,100) )

	sound.Play("nz/hellhound/spawn/prespawn.wav", self.Pos, 100, 100, 1)

end

--[[---------------------------------------------------------
   THINK
-----------------------------------------------------------]]
function EFFECT:Think()

	if IsValid(self.Parent) then
		self.Pos = self.Parent:GetPos()
		self:SetPos(self.Pos)
	end

	self.Life = self.Life + FrameTime()
	--self.Alpha = 255 * ( 1 - self.Life )

	if self.NextArc <= self.Life and self.Life <= self.Duration - self.Duration * 0.25 then

		local size = #self.Arcs
		--add a arc to the array
		while self.Arcs[size] do
			size = size + 1
		end
		self.Arcs[size] = self:GenerateArc(self.Pos + AngleRand():Forward()*100, self.Pos + AngleRand():Forward()*100, 0.1, 4)
		self.NextArc = self.NextArc + 0.1

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
			points[j] = points[j] + VectorRand() * 10
			if math.Rand(0,1) < branchChance then
				points[#points + 1] = self:GenerateArc(points[j], points[j] + Vector(math.random(-50 * branchChance, 50 * branchChance), math.random(-50 * branchChance, 50 * branchChance), math.random(-50 * branchChance, 10 * branchChance)), branchChance/1.3, detail)
			end
			j = j + maxPoints / i
		end
		i = i * 2
	end

	points.size = math.random(2,10)
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
	
	render.SetMaterial( self.MatGlow1 )
	render.DrawSprite( self.Pos + Vector(0,0,30), math.random(200,600), math.random(200,600), Color(255,255,255,math.random(0,100)))
	
	if math.random(0,10) == 0 then
		render.SetMaterial( self.MatGlow2 )
		render.DrawSprite( self.Pos + Vector(0,0,30), math.random(200,600), math.random(200,600), Color(255,255,255,math.random(0,200)))
	end
	
	render.SetMaterial( self.MatGlowCenter )
	render.DrawSprite( self.Pos + Vector(0,0,30), math.random(75,200), math.random(75,200), Color(255,255,255,math.random(200,250)))
	
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
				edge and arc.size*3 or arc.size,
				texcoord,
				texcoord + ((startPos - endPos):Length() / 128),
				arc.color
			)
		end
	end
end

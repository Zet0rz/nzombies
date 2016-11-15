
--EFFECT.MatCenter = Material( "lightning.png", "unlitgeneric smooth" )
EFFECT.MatEdge = Material( "effects/tool_tracer" )
EFFECT.MatCenter = Material( "sprites/physbeama" )
EFFECT.MatGlow1 = Material( "sprites/physg_glow1" )
EFFECT.MatGlow2 = Material( "sprites/physg_glow2" )
EFFECT.MatGlowCenter = Material( "sprites/glow04_noz" )

--[[---------------------------------------------------------
   Init( data table )
-----------------------------------------------------------]]
function EFFECT:Init( data )

	self.Size = data:GetRadius() or 1
	self.MaxArcs = 2
	self.Parent = data:GetEntity()
	self.Frequency = data:GetMagnitude()/10 or 0.01
	self.Pos = self.Parent:GetPos() + self.Parent:OBBCenter()
	self.OBBMax = self.Parent:OBBMaxs()
	self.OBBMin = self.Parent:OBBMins()
	self.Angle = self.Parent:GetAngles()
	
	if self.Parent.LightningAura then
		if data:GetScale() then
			self.Parent.LightningAura = CurTime() + data:GetScale()
		else
			self.Parent.LightningAura = CurTime() + 10 -- Default time for this effect
		end
		self.KILL = true
	else
		if data:GetScale() then
			self.Parent.LightningAura = CurTime() + data:GetScale()
		else
			self.Parent.LightningAura = CurTime() + 10 -- Default time for this effect
		end

		self.Alpha = 255
		self.Life = 0
		self.NextArc = 0
		self.Arcs = {}
		self.Queue = 1

		self:SetRenderBoundsWS( self.Pos, self.Pos, Vector(100,100,100) )
	end

end

--[[---------------------------------------------------------
   THINK
-----------------------------------------------------------]]
function EFFECT:Think()
	
	if self.KILL then return false end

	if IsValid(self.Parent) then
		--self.Pos = self.Parent:GetPos()
	end

	self.Life = self.Life + FrameTime()
	--self.Alpha = 255 * ( 1 - self.Life )

	if self.NextArc <= self.Life then

		local size = #self.Arcs
		--add a arc to the array
		while self.Arcs[size] do
			size = size + 1
		end
		
		local randx = math.Rand(self.OBBMin.x, self.OBBMax.x)
		local randy = math.Rand(self.OBBMin.y, self.OBBMax.y)
		local zdist = self.OBBMax.z - self.OBBMin.z
		local offz = 0
		if zdist < 30 then
			offz = 30
		end
		
		local startpos = self.Angle:Forward() * randx + self.Angle:Right() * randy + Vector(0,0,offz + self.OBBMax.z)
		local originpos = self.Pos + startpos
		local endpos = originpos - Vector(0,0, zdist + offz)
		
		self.Arcs[size] = self:GenerateArc(originpos, endpos, 0.01, 4)
		self.NextArc = self.NextArc + self.Frequency

		if size >= self.MaxArcs then
			local i = 1
			while not self.Arcs[i] and i <= size do
				i = i + 1
			end
			self.Arcs[i] = nil
		end
	end

	if IsValid(self.Parent) then
		if !(type(self.Parent.LightningAura) == "number" and CurTime() < self.Parent.LightningAura or self.Parent.LightningAura == true) then
			self.Parent.LightningAura = nil
			return false
		end
	else
		return false
	end
	
	return true
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

	if ( self.KILL or self.Alpha < 1 ) then return end

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
	
	--render.SetColorMaterial() 
	--render.DrawBox(self.Pos, Angle(0,0,0), self.OBBMin, self.OBBMax, Color(255,255,255,100),false)
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

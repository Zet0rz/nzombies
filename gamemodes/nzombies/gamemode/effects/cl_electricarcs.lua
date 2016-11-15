
local mat = Material( "effects/tool_tracer" )

local function GenerateArc(startPos, endPos, branchChance, detail, size)
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
				points[#points + 1] = GenerateArc(points[j], points[j] + Vector(math.random(-50 * branchChance, 50 * branchChance), math.random(-50 * branchChance, 50 * branchChance), math.random(-50 * branchChance, 10 * branchChance)), branchChance/1.3, detail, size)
			end
			j = j + maxPoints / i
		end
		i = i * 2
	end

	points.size = math.random(1,3)*size
	points.color = Color(200, 240, math.random(230, 255), math.random(200, 255))
	points.dietime = CurTime() + 0.07

	return points
end

local function RenderArc(arc)
	render.SetMaterial( mat )
	for j = 1, #arc - 1 do

		if istable(arc[j]) then
			RenderArc(arc[j])
		elseif !istable(arc[j+1]) then

			local texcoord = math.Rand( 0, 1 )

			local startPos = arc[j]
			local endPos = arc[j + 1]

			render.DrawBeam(
				startPos,
				endPos,
				arc.size,
				texcoord,
				texcoord + ((startPos - endPos):Length() / 128),
				arc.color
			)
		end
	end
end

function nzEffects:DrawElectricArcs( entity, epos, normal, effectsize, maxarcs, freq )

	if !IsValid(entity) then return end

	if !entity.NextElecArc or entity.NextElecArc <= CurTime() then
		if !entity.ElecArcs then entity.ElecArcs = {} end

		local size = #entity.ElecArcs
		--add a arc to the array
		while entity.ElecArcs[size] do
			size = size + 1
		end
		local norm = VectorRand()
		entity.ElecArcs[size] = GenerateArc(epos - norm*effectsize, epos + norm*effectsize, 0.01, 4, effectsize)
		entity.NextElecArc = CurTime() + freq

		if size >= maxarcs then
			local i = 1
			while not entity.ElecArcs[i] and i <= size do
				i = i + 1
			end
			entity.ElecArcs[i] = nil
		end
	end
	
	for _, arc in pairs(entity.ElecArcs) do
		if arc.dietime <= CurTime() then
			entity.ElecArcs[_] = nil
		else
			RenderArc(arc)
		end
	end

end

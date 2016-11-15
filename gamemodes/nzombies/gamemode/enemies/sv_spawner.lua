-- Class for spawning zombies. This can be used t create different Spawners for different spawnpoints.
-- Warning! Creating multiple instances of this class for the same spawnpoint entity will overwrite prior instances.
-- Author: Lolle

if Spawner == nil then
	Spawner = nzClass({
		-- CONSTRUCTOR
		-- sPointClass: The class of spawnpoints this spawner will create entities from.
		--              A spawnpoint class should only be used by one spawner at a time.
		-- data: information about the entities that are spawned, required are a entity class and chance.
		-- zombiesToSpawn: the amount of zombies this type of spawner will spawn in total.
		-- spawnDelay: delays the next spawn by the amount set in this value
		-- roundNum: the round this spawner was created (after this round teh spawn will be removed)
		constructor = function(self, spointClass, data, zombiesToSpawn, spawnDelay, roundNum)
			self.sSpointClass = spointClass or "nz_spawn_zombie_normal"
			self.tData = data or {["nz_zombie_walker"] = {chance = 100}}
			self.iZombiesToSpawn = zombiesToSpawn or 5
			self.tSpawns = ents.FindByClass(self.sSpointClass)
			self.tValidSpawns = {}
			self:SetDelay(spawnDelay or 0.25)
			self:SetNextSpawn(CurTime())
			self:SetZombieData(self.tData)
			-- not really sure if this is 100% unique but for our purpose it will be enough
			self.sUniqueName = self.sSpointClass .. "." .. CurTime()
			self.iRoundNumber = roundNum or nzRound:GetNumber()
			self:Activate()
		end
	})
end

AccessorFunc(Spawner, "dDelay", "Delay", FORCE_NUMBER)
AccessorFunc(Spawner, "dNextSpawn", "NextSpawn", FORCE_NUMBER)

function Spawner:Activate()
	for _, spawn in pairs(self.tSpawns) do
		spawn:SetSpawner(self)
	end
	-- curently does the costly zombie distribution 4 seconds can be lowered (without any problems)
	timer.Create("nzZombieSpawnThink" .. self.sUniqueName, GetConVar("nz_spawnpoint_update_rate"):GetInt(), 0, function() self:Update() end)
end

function Spawner:DecrementZombiesToSpawn()
	self.iZombiesToSpawn = self.iZombiesToSpawn - 1
end

function Spawner:IncrementZombiesToSpawn()
	self.iZombiesToSpawn = self.iZombiesToSpawn + 1
end

function Spawner:GetZombiesToSpawn()
	return nzRound:GetNumber() == -1 and 50 or self.iZombiesToSpawn -- Round Infinity always has 50 zombies to spawn (even after they spawn ;) )
end

function Spawner:SetZombiesToSpawn(value)
	self.iZombiesToSpawn = value
end

function Spawner:GetSpawns()
	return self.tSpawns
end

function Spawner:GetData()
	return self.tData
end

function Spawner:Update()
	-- garbage collect the spawner object if a round is over
	if (self.iRoundNumber != nzRound:GetNumber() or nzRound:InState(ROUND_GO)) and timer.Exists("nzZombieSpawnThink" .. self.sUniqueName) then
		self:Remove()
	end

	self:UpdateWeights()
	self:UpdateValidSpawns()
end

function Spawner:UpdateWeights()
	local plys = player.GetAllTargetable()
	for _, spawn in pairs(self.tSpawns) do
		-- reset
		spawn:SetSpawnWeight(0)
		local weight = math.huge
		for _, ply in pairs(plys) do
			local dist = spawn:GetPos():Distance(ply:GetPos())
			if dist < weight then
				weight = dist
			end
		end
		spawn:SetSpawnWeight(10000/weight) -- The spawnweight is inversely related to the distance
		-- E.g. Distance = 10, 20, weights = 10000/10, 10000/20 = 1000, 500
		-- We could do 1/weight, but 10000 makes then number easier to read (often around 10-50 depending on the amount of spawns)
	end
end

function Spawner:UpdateValidSpawns()

	if self:GetZombiesToSpawn() <= 0 then return end

	-- reset
	self.tValidSpawns = {}

	local average = self:GetAverageWeight()
	local total = 0
	for _, spawn in pairs(self.tSpawns) do
		-- reset the zombiesToSpawn value on every Spawnpoint
		spawn:SetZombiesToSpawn(0)
		if spawn:GetSpawnWeight() <= average then
			if spawn.link == nil or nzDoors:IsLinkOpened( spawn.link ) then
				table.insert(self.tValidSpawns, spawn)
				total = total + spawn:GetSpawnWeight()
			end
		end
	end
	table.sort(self.tValidSpawns, function(a, b) return a:GetSpawnWeight() < b:GetSpawnWeight() end )
	
	local zombiesToSpawn = self:GetZombiesToSpawn()
	local numspawns = table.Count(self.tValidSpawns)

	-- distribute zombies to spawn on to the valid spawnpoints
	
	if numspawns == 1 then -- 1 spawnpoint, give it all the zomblez
		local vspawn = self.tValidSpawns[1]
		vspawn:SetZombiesToSpawn(zombiesToSpawn)
		debugoverlay.Text(vspawn:GetPos() + Vector(0,0,75), "%: 100, #: "..tostring(toSpawn)..", B: "..tostring(vspawn:IsSuitable())..", T: "..math.Round(vspawn:GetNextSpawn()-CurTime(), 2)..", ST: "..(vspawn:GetSpawner() and math.Round(vspawn:GetSpawner():GetNextSpawn() - CurTime(), 2) or "nil"), 4)
	else
		local totalDistributed = 0
		
		for k, vspawn in pairs(self.tValidSpawns) do
			local w = vspawn:GetSpawnWeight() -- The weight
			if w > 0 then -- 0 weight is disabled (or it'd take all the zombies)
				local toSpawn = math.Round((w/total) * zombiesToSpawn)
				
				if zombiesToSpawn - totalDistributed - toSpawn <= 0 or k == numspawns then -- If we're using more than our total or it's the last one
					toSpawn = zombiesToSpawn - totalDistributed -- Then just give the rest
					vspawn:SetZombiesToSpawn(toSpawn)
					debugoverlay.Text(vspawn:GetPos() + Vector(0,0,75), "W: "..math.Round(w, 2)..", %: "..math.Round((w/total), 2)..", #: "..tostring(toSpawn)..", B: "..tostring(vspawn:IsSuitable())..", T: "..math.Round(vspawn:GetNextSpawn()-CurTime(), 2)..", ST: "..(vspawn:GetSpawner() and math.Round(vspawn:GetSpawner():GetNextSpawn() - CurTime(), 2) or "nil"), 4)
					break -- Just stop here, we got no more zombies to distribute
				end
				
				vspawn:SetZombiesToSpawn(toSpawn)
				totalDistributed = totalDistributed + toSpawn
				debugoverlay.Text(vspawn:GetPos() + Vector(0,0,75), "W: "..math.Round(w, 2)..", %: "..math.Round((w/total), 2)..", #: "..tostring(toSpawn)..", B: "..tostring(vspawn:IsSuitable())..", T: "..math.Round(vspawn:GetNextSpawn()-CurTime(), 2)..", ST: "..(vspawn:GetSpawner() and math.Round(vspawn:GetSpawner():GetNextSpawn() - CurTime(), 2) or "nil"), 4)
			end
		end
	end
end

function Spawner:GetAverageWeight()
	local sum = 0
	for _, spawn in pairs(self.tSpawns) do
		sum = sum + spawn:GetSpawnWeight()
	end
	return ((sum / #self.tSpawns) * 0.5) + 1500
end

function Spawner:GetValidSpawns()
	return self.tValidSpawns
end

function Spawner:SetZombieData(data)
	for _, spawn in pairs(self.tSpawns) do
		spawn:SetZombieData(data)
	end
end

function Spawner:Remove()
	timer.Remove("nzZombieSpawnThink" .. self.sUniqueName)
	for _, spawn in pairs(self.tSpawns) do
		if IsValid(spawn) then
			spawn:SetSpawner(nil)
		end
	end
	self = nil
end

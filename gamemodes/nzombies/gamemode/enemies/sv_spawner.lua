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
		-- spawnDelay: delays the next spawn by the amont set in this value
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
	-- curently does the costly zombie distribution 3 seconds can be lowered (without any problems)
	timer.Create("nzZombieSpawnThink" .. self.sUniqueName, GetConVar("nz_spawnpoint_update_rate"):GetInt(), 0, function() self:Update() end)
end

function Spawner:DecrementZombiesToSpawn()
	self.iZombiesToSpawn = self.iZombiesToSpawn - 1
end

function Spawner:IncrementZombiesToSpawn()
	self.iZombiesToSpawn = self.iZombiesToSpawn + 1
end

function Spawner:GetZombiesToSpawn()
	return self.iZombiesToSpawn
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
		spawn:SetSpawnWeight(weight)
	end
end

function Spawner:UpdateValidSpawns()

	if self.iZombiesToSpawn <= 0 then return end

	-- reset
	self.tValidSpawns = {}

	local average = self:GetAverageWeight()
	local total = 0
	for _, spawn in pairs(self.tSpawns) do
		-- reset the zombiesToSpawn value on every Spawnpoint
		spawn:SetZombiesToSpawn(0)
		if spawn:GetSpawnWeight() <= average then
			if spawn.link == nil or nzDoors.OpenedLinks[tonumber(spawn.link)] then
				table.insert(self.tValidSpawns, spawn)
				total = total + spawn:GetSpawnWeight()
			end
		end
	end
	table.sort(self.tValidSpawns, function(a, b) return a:GetSpawnWeight() < b:GetSpawnWeight() end )

	-- distribute zombies to spawn on to the valid spawnpoints
	local zombiesToSpawn = self.iZombiesToSpawn
	local totalDistributed = 0
	for k, vspawn in pairs(self.tValidSpawns) do
		local toSpawn = math.Round((total - vspawn:GetSpawnWeight()) / total)
		if zombiesToSpawn - totalDistributed - toSpawn <= 0 then
			toSpawn = zombiesToSpawn - totalDistributed
		end
		vspawn:SetZombiesToSpawn(toSpawn)
		totalDistributed = totalDistributed + toSpawn
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
		spawn:SetSpawner(nil)
	end
	self = nil
end

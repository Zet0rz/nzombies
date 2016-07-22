if SERVER then
	function nzRound:SetNextBossRound( num )
		self.NextBossRound = num
	end

	function nzRound:GetNextBossRound()
		return self.NextBossRound
	end
	
	function nzRound:MarkedForBoss( num )
		return self.NextBossRound == num and self.BossType and self.BossData[self.BossType] and true -- Valid boss
	end
	
	function nzRound:SetBossType(id)
		if id == "None" then
			self.BossType = nil -- "None" makes a nil key
		else
			self.BossType = id or "Panzer" -- A nil id defaults to "Panzer", otherwise id
		end
	end
	
	function nzRound:GetBossType(id)
		return self.BossType
	end
	
	function nzRound:GetBossData()
		if !self.BossType then return nil end
		return self.BossData[self.BossType]
	end
	
	-- This runs at the start of every round
	hook.Add("OnRoundStart", "nzBossRoundHandler", function(round)
		if nzRound:MarkedForBoss(round) then -- If this round is a boss round
			if nzRound:IsSpecial() then nzRound:SetNextBossRound(round + 1) return end -- If special round, delay 1 more round and back out
			
			local spawntime = math.random(1, nzRound:GetZombiesMax() - 2) -- Set a random time to spawn
			hook.Add("OnZombieSpawned", "nzBossSpawnHandler", function() -- Add a hook for each zombie spawned
				if !nzRound:MarkedForBoss(nzRound:GetNumber()) then
					hook.Remove("OnZombieSpawned", "nzBossSpawnHandler") -- Cancel if we're no longer on a boss round!
				return end
				
				if nzRound:GetZombiesSpawned() >= spawntime then -- If we've spawned the amount of zombies that we randomly set
					local data = nzRound:GetBossData() -- Check if we got boss data
					if !data then hook.Remove("OnZombieSpawned", "nzBossSpawnHandler") return end -- If not, remove and cancel
					
					local spawnpoint = data.specialspawn and "nz_spawn_zombie_special" or "nz_spawn_zombie_normal" -- Check what spawnpoint type we're using
					local spawnpoints = {}
					for k,v in pairs(ents.FindByClass(spawnpoint)) do -- Find and add all valid spawnpoints that are opened and not blocked
						if (v.link == nil or nzDoors.OpenedLinks[tonumber(v.link)]) and v:IsSuitable() then
							table.insert(spawnpoints, v)
						end
					end
					
					local spawn = spawnpoints[math.random(#spawnpoints)] -- Pick a random one
					if IsValid(spawn) then -- If we this exists, spawn here
						local boss = ents.Create(data.class)
						boss:SetPos(spawn:GetPos())
						boss:Spawn()
						boss.NZBossType = nzRound:GetBossType()
						data.spawnfunc(boss)
						hook.Remove("OnZombieSpawned", "nzBossSpawnHandler") -- Only remove the hook when we spawned the boss
					end
					
					-- If there is no valid spawnpoint to spawn at, it will try again next zombie that spawns
					-- until we get out of the boss round, then it gives up
				end
			end)
		end
	end)
	
	hook.Add( "OnGameBegin", "nzBossInit", function()
		nzRound:SetBossType(nzMapping.Settings.bosstype)
		local data = nzRound:GetBossData()
		if data then
			data.initfunc()
		end
	end)
	
end

nzRound.BossData = nzRound.BossData or {}
function nzRound:AddBossType(id, class, specialspawn, initfunc, spawnfunc, deathfunc, onhit)
	if SERVER then
		if class then
			local data = {}
			-- Which entity to spawn
			data.class = class
			-- Whether to spawn at special spawnpoints
			data.specialspawn = specialspawn
			-- Runs on game begin with this boss set, use to set first boss round
			data.initfunc = initfunc
			-- Run when the boss spawns, arguments are (boss)
			data.spawnfunc = spawnfunc
			-- Run when the boss dies, arguments are (boss, attacker, dmginfo, hitgroup)
			data.deathfunc = deathfunc
			-- Whenever the boss is damaged, arguments are (boss, attacker, dmginfo, hitgroup) Called before damage applied (can scale dmginfo)
			data.onhit = onhit
			-- All functions are optional, but death/spawn func is needed to set next boss round! (Unless you got another way)
			nzRound.BossData[id] = data
		else
			nzRound.BossData[id] = nil -- Remove it if no valid class was added
		end
	else
		-- Clients only need it for the dropdown, no need to actually know the data and such
		nzRound.BossData[id] = class
	end
end

nzRound:AddBossType("Panzer", "nz_zombie_boss_panzer", true, function()
	nzRound:SetNextBossRound(math.random(6,8)) -- Randomly spawn in rounds 6-8
end, function(panzer)
	panzer:SetHealth(nzRound:GetNumber() * 75 + 500)
end, function(panzer, killer, dmginfo, hitgroup)
	nzRound:SetNextBossRound(nzRound:GetNumber() + math.random(3,6)) -- Delay further boss spawning by 3-6 rounds after its death
	if IsValid(attacker) and attacker:IsPlayer() and attacker:GetNotDowned() then
		attacker:GivePoints(500) -- Give killer 500 points if not downed
	end
end) -- No onhit function, we don't give points on hit for this guy
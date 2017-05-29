if !engine.ActiveGamemode == "nzombies" then return end

if (SERVER) then AddCSLuaFile("shared.lua")end
----------------------------------------------
ENT.Base     = "base_nextbot"
ENT.Spawnable= false

ENT.Model = ""
ENT.health = 0
ENT.Damage = 0
ENT.Speed = 0
ENT.WalkAnim = (NONE)
ENT.UseFootSteps = 1
ENT.FootStepInterval = 1
ENT.AttackWaitTime = 0
ENT.AttackFinishTime = 0
ENT.NextAttack = 1.3
ENT.InitialAttackRange = 90
ENT.AttackRange = 60

function ENT:CustomInit()end
function ENT:OnSpawn()end
function ENT:CustomThink()end
function ENT:CustomChaseEnemy()
	local ent = ents.FindInSphere(self:GetPos(), self.AttackRange)  -- Generic attack function, use as you will.
	for k,v in pairs(ent) do
	
		if ((v:IsNPC() || (v:IsPlayer() && v:Alive() && !self.IgnorePlayer))) then
			if not (v:IsValid() && v:Health() > 0) then return end
		
			coroutine.wait(self.AttackWaitTime)
			if v:IsPlayer() then
				-- So what exactly do we do if the enemy is in range?
				
			end
		end
	end
end
function ENT:OnPathTimeOut() -- nZombies func

end
function ENT:FootSteps()end
function ENT:IdleFunction()
	self:MovementFunctions("sequence", 0, 1)
end
function ENT:OnIgnite()end
function ENT:CustomKilled(dmginfo)end
function ENT:OnInjured(dmginfo)end

--Helper functions - you don't need to use them but it'll probably make your life easier.
-----------------------------------------------------------------------------------------
-- self:MovementFunctions(Sequence seq, Integer speed, Integer cycle, Integer playbackrate)
-- Ex: self:MovementFunctions("idle",1,0,1)
function ENT:MovementFunctions(seq, speed, cycle, playbackrate)
	speed = speed or 0
	cycle = cycle or 0
	playbackrate = playbackrate or 1
	if cycle > 1 then ErrorNoHalt("Nextbot MovementFunctions error: cycle must be less than 1.") cycle = 0 end

	self:ResetSequence(seq)
	self:SetCycle(cycle)
	self:SetPlaybackRate(playbackrate)
	self.loco:SetDesiredSpeed(speed)
end

-- CreateBeamParticle(String pcf, Vector pos1, Vector pos2, Angle ang1, Angle ang2, Entity parent, Boolean candie, Integer dietime)
-- Ex: CreateBeamParticle("error",self:GetPos(),Vector(0,0,0),self:GetAngles(),Angle(0,0,0),self,false)
function CreateBeamParticle(pcf,pos1,pos2,ang1,ang2,parent,candie,dietime)
	if SERVER then
		local P_End = ents.Create("info_particle_system") 
		P_End:SetKeyValue("effect_name",pcf)
		P_End:SetName("info_particle_system_MajikPoint_"..pcf)
		P_End:SetPos(pos2) 
		P_End:SetAngles((ang2 or Angle(0,0,0))) 
		P_End:Spawn()
		P_End:Activate()
		P_End:SetParent(parent or nil)
		
		local P_Start = ents.Create("info_particle_system")
		P_Start:SetKeyValue("effect_name",pcf)
		P_Start:SetKeyValue("cpoint1",P_End:GetName())
		P_Start:SetKeyValue("start_active",tostring(1))
		P_Start:SetPos(pos1)
		P_Start:SetAngles((ang1 or Angle(0,0,0)))
		P_Start:Spawn()
		P_Start:Activate() 
		P_Start:SetParent(parent or nil)
		
		if candie then P_End:Fire("Kill",nil,dietime)P_Start:Fire("Kill",nil,dietime) end
	end
end 
---------------------------------------------------------------------------------------------
-- Everything below this line is all default stuff that comes with the base. Feel free to delete it in your NPC.
function ENT:Initialize()
	self.Interval = self.FootStepInterval 
	self:CustomInit()
	self.Entity:SetCollisionBounds(Vector(-4,-4,0), Vector(4,4,64))
	self:SetHealth(self.health)
	self:SetModel(self.Model)
	self.LoseTargetDist	= 250000000 
	self.SearchRadius 	= 999000000 
	if SERVER then 
		self.loco:SetStepHeight(35)
		self.loco:SetAcceleration(900)
		self.loco:SetDeceleration(900)
		
		self.BarricadeJumpTries = 0 --nZombies
	end 
	self.ZombieAlive = true --nZombies
	self.StuckCounter = 0 --nZombies
	self.StuckAt = nil --nZombies
end
function ENT:BodyUpdate()
	self:BodyMoveXY()
end
function ENT:Think()
	if not SERVER then return end 
	if !IsValid(self) then return end 
	self:CustomThink()
	if self.UseFootSteps == 1 then 
		if !self.nxtThink then self.nxtThink = 0 end 
		if CurTime() < self.nxtThink then return end 
			self.nxtThink = CurTime() + 0.025 
			self:DoFootstep()
			
		if !self.IsAttacking and !self.IsTimedOut then
			if self:GetPos():Distance(self.StuckAt or Vector(0,0,0)) < 10 then
				self.StuckCounter = self.StuckCounter + 1
			else
				self.StuckCounter = 0
			end

			if self.StuckCounter > 2 then

				local tr = util.TraceHull({
					start = self:GetPos(),
					endpos = self:GetPos(),
					maxs = self:OBBMaxs(),
					mins = self:OBBMins(),
					filter = self
				})
				if tr.Hit then
					--if there bounding box is intersecting with something there is now way we can unstuck them just respawn.
					--make a dust cloud to make it look less ugly
					local effectData = EffectData()
					effectData:SetStart(self:GetPos() + Vector(0,0,32))
					effectData:SetOrigin(self:GetPos() + Vector(0,0,32))
					effectData:SetMagnitude(1)
					util.Effect("zombie_spawn_dust", effectData)

					self:RespawnZombie()
					self.StuckCounter = 0
				end

				if self.StuckCounter <= 3 then
					--try to unstuck via random velocity
					self:ApplyRandomPush()
				end

				if self.StuckCounter > 5 then
					--Worst case:
					--respawn the zombie after 32 seconds with no postion change
					self:RespawnZombie()
					self.StuckCounter = 0
				end

			end
			self.StuckAt = self:GetPos()
		end
	end 
end
function ENT:DoFootstep()
	if self:GetVelocity() == Vector(0,0,0) then return end 
	if CurTime() < self.Interval then return end 
		self:FootSteps()
	self.Interval = CurTime() + self.FootStepInterval 
end
function ENT:GetEnemy()
	return self.Enemy 
end
function ENT:SetEnemy(ent)
	self.Enemy = ent 
end
function ENT:HaveEnemy()
	if (self:GetEnemy() and IsValid(self:GetEnemy())) then 
		if (self:GetRangeTo(self:GetEnemy():GetPos()) > self.LoseTargetDist) then 
			return self:FindEnemy()
		elseif (self:GetEnemy():IsPlayer() and !self:GetEnemy():Alive()) then 
			return self:FindEnemy()
		end 
		return true 
	else 
		return self:FindEnemy()
	end 
end
function ENT:FindEnemy()
	local _ents = ents.FindInSphere(self:GetPos(), self.SearchRadius)
		for k,v in pairs(_ents) do 
			if (v:IsPlayer()) then 
				self:SetEnemy(v)
			return true 
		end 
	end 
	self:SetEnemy(nil)
	return false 
end
function ENT:SpawnIn()
	local nav = navmesh.GetNearestNavArea(self:GetPos())
	if !self:IsInWorld() or !IsValid(nav) or nav:GetClosestPointOnArea(self:GetPos()):DistToSqr(self:GetPos()) >= 10000 then 
		-- ErrorNoHalt("Nextbot ["..self:GetClass().."]["..self:EntIndex().."] spawned too far away from a navmesh!")
		for k,v in pairs(player.GetAll()) do
			if (string.find(v:GetUserGroup(),"admin")) then
				v:PrintMessage(HUD_PRINTTALK,"Nextbot ["..self:GetClass().."]["..self:EntIndex().."] spawned too far away from a navmesh!")
			end
		end
		SafeRemoveEntity(self)
	end 
	self:OnSpawn()
end
function ENT:RunBehaviour()
	self:SpawnIn()
	while (true) do 
		if (self:HaveEnemy()) then 
			self.loco:SetDesiredSpeed(self.Speed)
			self:ResetSequence(self.WalkAnim)
			if self:HaveEnemy() then
				local pathResult = self:ChaseEnemy({
					maxage = 1,
					draw = false,
					tolerance = ((self.AttackRange -30) > 0) and self.AttackRange - 20
				})
				if pathResult == "timeout" then -- If failed then possibly a barricade is blocking us
					local barricade = self:CheckForBarricade()
					if barricade then
						self:OnBarricadeBlocking(barricade)
					else
						self:OnPathTimeOut()
					end
				end
			else
				self:OnNoTarget()
			end
		else 
			self:IdleFunction()
		end 
		coroutine.wait(2)
	end 
end
function ENT:ChaseEnemy(options)
	local options = options or {}
	if !options.target then
		options.target = self:GetTarget()
	end
	local path = self:ChaseEnemiesPath(options)
	if (!IsValid(path)) then return "failed" end
	while (path:IsValid() and self:HasTarget() and !self:TargetInAttackRange()) do

		path:Update(self)

		--Timeout the pathing so it will rerun the entire behaviour (break barricades etc)
		if (path:GetAge() > options.maxage) then
			local segment = path:FirstSegment()
			self.BarricadeCheckDir = segment and segment.forward or Vector(0,0,0)
			return "timeout"
		end

		path:Update(self)	-- This function moves the bot along the path

		-- If we're stuck, then call the HandleStuck function and abandon
		if (self.loco:IsStuck()) then
			self:HandleStuck()
			return "stuck"
		end

		if self.loco:GetVelocity():Length() < 10 then
			self:ApplyRandomPush()
		end
	
		self:CustomChaseEnemy()
		
		coroutine.yield()
	end
	return "ok"
end
function ENT:ChaseEnemiesPath(options)
	options = options or {}
	local path = Path("Follow")
	path:SetMinLookAheadDistance(options.lookahead or 300)
	path:SetGoalTolerance(options.tolerance or 30)
	--Custom path computer, the same as default but not pathing through locked nav areas.
	path:Compute(self, options.target:GetPos(),  function(area, fromArea, ladder, elevator, length)
		if (!IsValid(fromArea)) then
			--first area in path, no cost
			return 0
		else
			if (!self.loco:IsAreaTraversable(area)) then
				--our locomotor says we can't move here
				return -1
			end
			--Prevent movement through either locked navareas or areas with closed doors
			if (nzNav.Locks[area:GetID()]) then
				--print("Has area")
				if nzNav.Locks[area:GetID()].link then
					--print("Area has door link")
					if !nzDoors.OpenedLinks[nzNav.Locks[area:GetID()].link] then
						--print("Door link is not opened")
						return -1
					end
				elseif nzNav.Locks[area:GetID()].locked then
					--print("Area is locked")
				return -1 end
			end
			return cost
		end
	end)

	-- this will replace nav groups
	-- we do this after pathing to know when this happens
	local lastSeg = path:LastSegment()

	-- a little more complicated that i thought but it should do the trick
	if lastSeg then
		if self:GetEnemyNavArea() and lastSeg.area:GetID() != self:GetEnemyNavArea():GetID() then
			if !nzNav.Locks[self:GetEnemyNavArea():GetID()] or nzNav.Locks[self:GetEnemyNavArea():GetID()].locked then
				table.insert(self.tIgnoreList, self:GetEnemy())
				-- trigger a retarget
				self:SetLastTargetCheck(CurTime() - 1)
				self:TimeOut(0.5)
				return nil
			end
		else
			self.tIgnoreList = {}
			return path
		end
	end

	return path
end

function ENT:OnKilled(dmginfo)
	self:CustomKilled(dmginfo)
	-- hook.Call("OnNPCKilled",engine.ActiveGamemode(),self,dmginfo:GetAttacker(),dmginfo:GetInflictor())
	-- It bugs out SLVBase so to stop Silverlan fanboys bitching I disabled it.
end

-- Completely nZombies funcs from here on out --
function ENT:OnBarricadeBlocking(barricade)
	if (IsValid(barricade) and barricade:GetClass() == "breakable_entry") then
		if barricade:GetNumPlanks() > 0 then
			timer.Simple(0.3, function()
				barricade:EmitSound("physics/wood/wood_plank_break" .. math.random(1, 4) .. ".wav", 100, math.random(90, 130))
				barricade:RemovePlank()
			end)

			self:SetAngles(Angle(0,(barricade:GetPos()-self:GetPos()):Angle()[2],0))
			local seq = self.AttackSequences[math.random(#self.AttackSequences)].seq
			local dur = self:SequenceDuration(self:LookupSequence(seq))
			self:PlaySequenceAndWait(seq, 1)
			if coroutine.running() then
				coroutine.wait(2 - dur)
			end

			-- this will cause zombies to attack the barricade until it's destroyed
			local stillBlocked = self:CheckForBarricade()
			if stillBlocked then
				self:OnBarricadeBlocking(stillBlocked)
			end

			-- Attacking a new barricade resets the counter
			self.BarricadeJumpTries = 0
		elseif barricade:GetTriggerJumps() and self.TriggerBarricadeJump then
			local dist = barricade:GetPos():DistToSqr(self:GetPos())
			if dist <= 3500 + (1000 * self.BarricadeJumpTries) then
				self:TriggerBarricadeJump()
				self.BarricadeJumpTries = 0
			else
				-- If we continuously fail, we need to increase the check range (if it is a bigger prop)
				self.BarricadeJumpTries = self.BarricadeJumpTries + 1
				-- Otherwise they'd get continuously stuck on slightly bigger props :(
			end
		end
	end
end

function ENT:OnNoTarget()
	-- Game over! Walk around randomly
	if nzRound:InState(ROUND_GO) then
		self:ResetSequence(self.WalkAnim)
		self.loco:SetDesiredSpeed(self.Speed)
		self:MoveToPos(self:GetPos() + Vector(math.random(-512, 512), math.random(-512, 512), 0), {
			repath = 3,
			maxage = 5
		})
	else
		coroutine.wait(0.5)
		-- Start off by checking for a new target
		local newtarget = self:GetPriorityTarget()
		if IsValid(newtarget) then
			self:SetEnemy(newtarget)
		else
			-- If not visible to players respawn immediately
			if !self:IsInSight() then
				self:RespawnZombie()
			else
				self:UpdateSequence() -- Updates the sequence to be idle animation
				self:StartActivity(self.CalcIdeal) -- Starts the newly updated sequence
				coroutine.wait(3) -- Time out even longer if seen
			end
		end
	end
end

--Target and pathfidning
function ENT:GetPriorityTarget()

	self:SetLastTargetCheck(CurTime())

	--if you really would want something that atracts the zombies from everywhere you would need something like this
	local allEnts = ents.GetAll()
	--[[for _, ent in pairs(allEnts) do
		if ent:GetEnemyPriority() == TARGET_PRIORITY_ALWAYS and self:IsValidTarget(ent) then
			return ent
		end
	end]]

	-- Disabled the above for for now since it just might be better to use that same loop for everything

	local bestTarget = nil
	local highestPriority = TARGET_PRIORITY_NONE
	local maxdistsqr = self:GetEnemyCheckRange()^2
	local targetDist = maxdistsqr + 10

	--local possibleTargets = ents.FindInSphere(self:GetPos(), self:GetEnemyCheckRange())

	for _, target in pairs(allEnts) do
		if self:IsValidTarget(target) and !self:IsIgnoredTarget(target) then

			if target:GetEnemyPriority() == TARGET_PRIORITY_ALWAYS then return target end

			local dist = self:GetRangeSquaredTo(target:GetPos())
			if maxdistsqr <= 0 or dist <= maxdistsqr then -- 0 distance is no distance restrictions
				local priority = target:GetEnemyPriority()
				if target:GetEnemyPriority() > highestPriority then
					highestPriority = priority
					bestTarget = target
					targetDist = dist
				elseif target:GetEnemyPriority() == highestPriority then
					if targetDist > dist then
						highestPriority = priority
						bestTarget = target
						targetDist = dist
					end
				end
				--print(highestPriority, bestTarget, targetDist, maxdistsqr)
			end
		end
	end

	return bestTarget
end

function ENT:CheckForBarricade()
	--we try a line trace first since its more efficient
	local dataL = {}
	dataL.start = self:GetPos() + Vector(0, 0, self:OBBCenter().z)
	dataL.endpos = self:GetPos() + Vector(0, 0, self:OBBCenter().z) + self.BarricadeCheckDir * 48
	dataL.filter = function(ent) if (ent:GetClass() == "breakable_entry") then return true end end
	dataL.ignoreworld = true
	local trL = util.TraceLine(dataL)

	--debugoverlay.Line(self:GetPos() + Vector(0, 0, self:OBBCenter().z), self:GetPos() + Vector(0, 0, self:OBBCenter().z) + self.BarricadeCheckDir * 32)
	--debugoverlay.Cross(self:GetPos() + Vector(0, 0, self:OBBCenter().z), 1)

	if IsValid(trL.Entity) and trL.Entity:GetClass() == "breakable_entry" then
		return trL.Entity
	end

	--perform a hull trace if line didnt hit just to make sure
	local dataH = {}
	dataH.start = self:GetPos()
	dataH.endpos = self:GetPos() + self.BarricadeCheckDir * 48
	dataH.filter = function(ent) if (ent:GetClass() == "breakable_entry") then return true end end
	dataH.mins = self:OBBMins() * 0.65
	dataH.maxs = self:OBBMaxs() * 0.65
	local trH = util.TraceHull(dataH)

	if IsValid(trH.Entity) and trH.Entity:GetClass() == "breakable_entry" then
		return trH.Entity
	end

	return nil

end

function ENT:RespawnZombie()
	if SERVER then
		if self:GetSpawner() then
			self:GetSpawner():IncrementZombiesToSpawn()
		end

		self:Remove()
	end
end

function ENT:IsInSight()
	for _, ply in pairs(player.GetAll()) do
		--can player see us or the teleport location
		if ply:Alive() and ply:IsLineOfSightClear(self) then
			if ply:GetAimVector():Dot((self:GetPos() - ply:GetPos()):GetNormalized()) > 0 then
				return true
			end
		end
	end
end

function ENT:ApplyRandomPush(power)
	if CurTime() < self:GetLastPush() + 0.2 or !self:IsOnGround() then return end
	power = power or 100
	local vec =  self.loco:GetVelocity() + VectorRand() * power
	vec.z = math.random(100)
	self.loco:SetVelocity(vec)
	self:SetLastPush(CurTime())
end

function ENT:GetEnemyNavArea()
	return self:HaveEnemy() and navmesh.GetNearestNavArea(self:GetEnemy():GetPos(), false, 100)
end

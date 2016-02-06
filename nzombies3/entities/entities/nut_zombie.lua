AddCSLuaFile()

ENT.Base = "base_nextbot"
ENT.PrintName = "Zombie"
ENT.Category = "Dissolution"
ENT.Author = "Chessnut"
ENT.Spawnable = true
ENT.AdminOnly = true

for i = 2, 4 do
	util.PrecacheModel("models/zed/malezed_0"..(i * 2)..".mdl")
end

function ENT:Initialize()
	self:SetModel("models/zed/malezed_0"..(math.random(2, 4) * 2)..".mdl")
	self.breathing = CreateSound(self, "npc/zombie_poison/pz_breathe_loop1.wav")
	self.breathing:Play()
	self.breathing:ChangePitch(60, 0)
	self.breathing:ChangeVolume(0.1, 0)
	if SERVER then
		self.loco:SetDeathDropHeight(700)
		self:SetHealth(nz.Curves.Data.Health[nz.Rounds.Data.CurrentRound])
		--self:SetCollisionBounds(Vector(-9,-9, 0), Vector(9, 9, 64))
		self.loco:SetStepHeight(22)
		self.Jumped = CurTime() + 5 -- prevent jumping for the first 5 seconds since the spawn is crowded
		self.IsJumping = false
	end
	self:SetSkin(math.random(0, self:SkinCount() - 1))

	hook.Add("EntityRemoved", self, function()
		if (self.breathing) then
			self.breathing:Stop()
			self.breathing = nil
		end
	end)

end

function ENT:TimedEvent(time, callback)
	timer.Simple(time, function()
		if (IsValid(self)) then
			callback()
		end
	end)
end

function ENT:GetPriorityEnemy()
	local pos = self:GetPos()

	local min_dist, closest_target = -1, nil

	for _, target in pairs(player.GetAll()) do
		if (IsValid(target) and target:Alive() and target:GetNotDowned()) then
			if !nz.Config.NavGroupTargeting or nz.Nav.Functions.IsInSameNavGroup(target, self) then
				local dist = target:NearestPoint(pos):Distance(pos)
				if ((dist < min_dist||min_dist==-1)) then
					closest_target = target
					min_dist = dist
				end
			end
		end
	end
	if !closest_target then closest_target = self:GetClosestAvailableRespawnPoint() end

	return closest_target
end

function ENT:RunBehaviour()
	while (true) do
		local target = self.target

		if self:HasTarget() then
			local data = {}
				data.start = self:GetPos()
				data.endpos = self:GetPos() + self:GetForward()*128
				data.filter = self
				data.mins = self:OBBMins() * 0.65
				data.maxs = self:OBBMaxs() * 0.65
			local trace = util.TraceHull(data)
			local entity = trace.Entity
			--print(entity, "UNDER FAIHH")

			//Barricades
			if (IsValid(entity) and entity:GetClass() == "breakable_entry" ) then
				if entity:Health() != 0 then
					timer.Simple(0.3, function()

						entity:EmitSound("physics/wood/wood_plank_break"..math.random(1, 4)..".wav", 100, math.random(90, 130))

						entity:RemovePlank()

					end)

					self:PlaySequenceAndWait("swing", 1)
				end
			end
		end

		if self:HasTarget() then --and self:GetRangeTo(target) <= 1500
			self.loco:FaceTowards(target:GetPos())

			if (self:GetRangeTo(target) <= 50) then
				if target:IsPlayer() and target:Alive() then
					self:EmitSound("npc/zombie_poison/pz_throw2.wav", 50, math.random(75, 125))

					self:TimedEvent(0.1, function()
						self:EmitSound("npc/vort/claw_swing"..math.random(1, 2)..".wav")
					end)

					self:TimedEvent(0.3, function()
						if (IsValid(target) and self:GetRangeTo(target) <= 60) then
							local damageInfo = DamageInfo()
								damageInfo:SetAttacker(self)
								damageInfo:SetDamage(math.random(50, 70))
								damageInfo:SetDamageType(DMG_CLUB)

								local force = target:GetAimVector() * -300
								force.z = 16

								damageInfo:SetDamageForce(force)
							target:TakeDamageInfo(damageInfo)
							target:EmitSound("npc/zombie/zombie_hit.wav", 50, math.random(80, 160))
							target:ViewPunch(VectorRand():Angle() * 0.05)
							target:SetVelocity(force)
						end
					end)

					self:TimedEvent(0.45, function()
						if (IsValid(target) and !target:Alive()) then
							target.target = nil
						end
					end)

					self:PlaySequenceAndWait("swing", 1)
				elseif	target:GetClass() == "zed_spawns" then
					self:RespawnAtPoint(target)
				end
			else
				if nz.Curves.Data.Speed[nz.Rounds.Data.CurrentRound] >= 160 then
					self:StartActivity(ACT_RUN)
				else
					self:StartActivity(ACT_WALK)
				end
				if (self.breathing) then
					self.breathing:ChangePitch(80, 1)
					self.breathing:ChangeVolume(1.25, 1)
				end

				if (math.random(1, 2) == 2 and (self.nextYell or 0) < CurTime()) then
					self:EmitSound("npc/zombie_poison/pz_pain"..math.random(1, 3)..".wav", 40, math.random(30, 50))
					self.nextYell = CurTime() + math.random(4, 8)
				end

				self.loco:SetDesiredSpeed(nz.Curves.Data.Speed[nz.Rounds.Data.CurrentRound])
				--[[self:MoveToPos(target:GetPos(), {
					maxage = 0.67
				})]]
				self:ChaseEnemy({
					maxage = 0.67,
					draw = false,
					enemy = target,
					tolerance = 50
				})
			end
		else
			self.target = nil
			self:StartActivity(ACT_WALK)
			self.loco:SetDesiredSpeed(40)
			self:MoveToPos(self:GetPos() + Vector(math.random(-256, 256), math.random(-256, 256), 0), {
				repath = 3,
				maxage = 2
			})

			if (math.random(1, 8) == 2) then
				self:EmitSound("npc/zombie/zombie_voice_idle"..math.random(2, 7)..".wav", 50, 60)

				if (math.random(1, 2) == 2) then
					self:PlaySequenceAndWait("scaredidle")
				else
					self:PlaySequenceAndWait("photo_react_startle")
				end
			end
			//New AI Stuffz
			if (!self.target) then
				local v = self:GetPriorityEnemy()
				self.target = v
				self:AlertNearby(v)
				self.target = v
				self:PlaySequenceAndWait("wave_smg1", 0.9)
			end
		end
		coroutine.yield()
	end
end

function ENT:ChaseEnemy( options )

	local options = options or {}

	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( options.lookahead or 300 )
	path:SetGoalTolerance( options.tolerance or 50 )

	//Custom path computer, the same as default but not pathing through locked nav areas.
	path:Compute( self, options.enemy:GetPos() or self:GetEnemy():GetPos(), function( area, fromArea, ladder, elevator, length )
		--print("Pathing!")
		--print(area, fromArea, ladder, elevator, length)
		if ( !IsValid( fromArea ) ) then
			// first area in path, no cost
			--print("Area is the first area in path!")
			return 0
		else
			if ( !self.loco:IsAreaTraversable( area ) ) then
				// our locomotor says we can't move here
				--print("Area not traversable!")
				return -1
			end

			//Prevent movement through either locked navareas or areas with closed doors
			if (nz.Nav.Data[area:GetID()]) then
				--print("Has area")
				if nz.Nav.Data[area:GetID()].link then
					--print("Area has door link")
					if !nz.Doors.Data.OpenedLinks[nz.Nav.Data[area:GetID()].link] then
						--print("Door link is not opened")
						return -1
					end
				elseif nz.Nav.Data[area:GetID()].locked then
					--print("Area is locked")
				return -1 end
			end
			// compute distance traveled along path so far
			local dist = 0
			if ( IsValid( ladder ) ) then
				dist = ladder:GetLength()
			elseif ( length > 0 ) then
				// optimization to avoid recomputing length
				dist = length
			else
				dist = ( area:GetCenter() - fromArea:GetCenter() ):GetLength()
			end

			local cost = dist + fromArea:GetCostSoFar()
			// check height change
			local deltaZ = fromArea:ComputeAdjacentConnectionHeightChange( area )
			if ( deltaZ >= self.loco:GetStepHeight() ) then
				if ( deltaZ >= self.loco:GetMaxJumpHeight() ) then
					local fromLadds = fromArea:GetLadders()
					local toLadds = area:GetLadders()
					for _,f in pairs( fromLadds ) do
						for _,t in pairs(toLadds) do
							if f:GetID() == t:GetID() then return cost end
						end
					end
					// too high to reach
					return -1
				end
				// jumping is slower than flat ground
				local jumpPenalty = 0
				cost = cost + jumpPenalty * dist
			elseif ( deltaZ < -self.loco:GetDeathDropHeight() ) then
				// too far to drop
				return -1
			end
			return cost
		end
	end)

	if ( !path:IsValid() ) then return "failed" end

	while ( path:IsValid() and IsValid(self.target) ) do

		//Timeout the pathing so it will rerun the entire behaviour (break barricades etc)
		if ( path:GetAge() > options.maxage ) then
			return "timeout"
		end
		path:Update( self )	-- This function moves the bot along the path

		if ( options.draw ) then path:Draw() end

		--the jumping part simple and buggy
		--local scanDist = (self.loco:GetVelocity():Length()^2)/(2*900) + 15
		local scanDist
		--this will probaly need asjustments to fit the zombies speed
		if self:GetVelocity():Length2D() > 150 then scanDist = 30 else scanDist = 20 end

		--debugoverlay.Line( self:GetPos(),  path:GetClosestPosition(self:EyePos() + self:EyeAngles():Forward() * scanDist), 0.1, Color(255,0,0,0), true )
		--debugoverlay.Line( self:GetPos(),  path:GetPositionOnPath(path:GetCursorPosition() + scanDist), 0.1, Color(0,255,0,0), true )
		local goal = path:GetCurrentGoal()
		if path:IsValid() and goal.type == 2 and goal.how == 9 and goal.distanceFromStart <= scanDist then
			if #goal.area:GetLaddersAtSide(0) >= 1 then
				self:Jump(path:GetClosestPosition(self:EyePos() + self:EyeAngles():Forward() * scanDist), scanDist, goal.area:GetLaddersAtSide(0)[1]:GetLength() + 10 )
			else
				self:Jump(path:GetClosestPosition(self:EyePos() + self:EyeAngles():Forward() * scanDist), scanDist)
			end
		elseif path:IsValid() and !self:IsOnGround() and self:GetPos().z > goal.pos.z then
			self:SetPos(self:GetPos() + self:EyeAngles():Forward())
		end

		-- If we're stuck, then call the HandleStuck function and abandon
		if ( self.loco:IsStuck() ) then
			self:HandleStuck()
			return "stuck"
		end

		coroutine.yield()

	end

	return "ok"

end

function ENT:Think()
	if SERVER then --think is shared since last update but all the stuff in here should be serverside
		//Retarget closest players. Don't put this in the function above or else mass lag due to constant rethinking of target
		self.target = self:GetPriorityEnemy()

		if !self.IsJumping && self:GetSolidMask() == MASK_NPCSOLID_BRUSHONLY then
			local occupied = false
			for _,ent in pairs(ents.FindInBox(self:GetPos() + Vector( -16, -16, 0 ), self:GetPos() + Vector( 16, 16, 70 ))) do
				if ent:GetClass() == "nut_zombie" && ent != self then occupied = true end
			end
			if !occupied then self:SetSolidMask(MASK_NPCSOLID) end
		end
	end

	self:NextThink(4)
end

function ENT:HasTarget()
	return IsValid(self.target) and (self.target:IsPlayer() and self.target:Alive() or self.target:GetClass() == "zed_spawns")
end

function ENT:OnStuck()
	print("Now I'm stuck", self)
end

function ENT:AlertNearby(target, range, noNoise)
	range = range or 2400
	noNoise = noNoise or (#ents.FindByClass("nut_zombie") < 1)

	if (IsValid(self.target)) then
		return
	end

	for k, v in pairs(ents.FindByClass("nut_zombie")) do
		if (self != v and !IsValid(v.target) and self:GetRangeTo(v) <= range) then
			timer.Create("zombieAlert_"..v:EntIndex(), self:GetRangeTo(v) / 800, 1, function()
				if (!IsValid(v) or !IsValid(target)) then
					return
				end

				v.target = target
				v:EmitSound("npc/zombie/zombie_alert"..math.random(1, 3)..".wav", 50, math.random(60, 120))
				v:AlertNearby(target, range + 640)
			end)

			noNoise = false
		end
	end

	if (!noNoise) then
		self:EmitSound("npc/zombie_poison/pz_call1.wav", 50, 120)
	end
end

--we do our own jump since the loco one is a bit weird.
 function ENT:Jump(goal, scanDist, heightOverride)
	if CurTime() < self.Jumped + 2 or navmesh.GetNavArea(self:GetPos(), 50):HasAttributes( NAV_MESH_NO_JUMP ) then return end
	if !self:IsOnGround() then return end
	local tr = util.TraceLine( {
		start = self:EyePos() + Vector(0,0,30),
		endpos = self:EyePos() + Vector(0,0,94),
		filter = self
		} )
	local tr2 = util.TraceLine( {
		start = self:EyePos() + Vector(0,0,30) + self:EyeAngles():Forward() * scanDist,
		endpos = self:EyePos() + self:EyeAngles():Forward() * scanDist + Vector(0,0,94),
		filter = self
		} )
	--debugoverlay.Line(self:EyePos() + Vector(0,0,30), self:EyePos() + Vector(0,0,94), 5, Color(255,255,0), true)
	--debugoverlay.Line(self:EyePos() + Vector(0,0,30) + self:EyeAngles():Forward() * scanDist, self:EyePos() + self:EyeAngles():Forward() * scanDist + Vector(0,0,94), 5, Color(255,255,0), true)
	local jmpHeight
	if tr.Hit then jmpHeight = tr.StartPos:Distance(tr.HitPos) else jmpHeight = 64 end
	if tr2.Hit and !tr.Hit then jmpHeight = tr2.StartPos:Distance(tr2.HitPos) end
	jmpHeight = heightOverride or jmpHeight
	self.loco:SetJumpHeight(jmpHeight)
	self.loco:SetDesiredSpeed( 450 )
	self.loco:SetAcceleration( 5000 )
	self.Jumped = CurTime()
	self.IsJumping = true
	self:SetSolidMask( MASK_NPCSOLID_BRUSHONLY )
	self.loco:Jump()
	--Boost them
	self.loco:Approach(goal, 1000)
end

function ENT:OnLandOnGround()
	self:EmitSound("physics/flesh/flesh_impact_hard"..math.random(1, 6)..".wav")
	self.IsJumping = false
	if self:HasTarget() then
		self.loco:SetDesiredSpeed(nz.Curves.Data.Speed[nz.Rounds.Data.CurrentRound])
	else
		self.loco:SetDesiredSpeed(40)
	end
	self.loco:SetAcceleration(400)
	self.loco:SetStepHeight( 22 )
end

function ENT:OnLeaveGround( ent )
	self.IsJumping = true
end

function ENT:OnContact( ent )
	if nz.Config.ValidEnemies[ent:GetClass()] and nz.Config.ValidEnemies[self:GetClass()] then
		--this is a poor approach to unstuck them when walking into each other
		self.loco:Approach( self:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 2000,1000)
		--important if the get stuck on top of each other!
		if math.abs(self:GetPos().z - ent:GetPos().z) > 30 then self:SetSolidMask( MASK_NPCSOLID_BRUSHONLY ) end
	end
	--buggy prop push away thing comment if you dont want this :)
	if  ( ent:GetClass() == "prop_physics_multiplayer" or ent:GetClass() == "prop_physics" ) and ent:IsOnGround() then
		--self.loco:Approach( self:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 2000,1000)
		local phys = ent:GetPhysicsObject()
		if !IsValid(phys) then return end
		phys:ApplyForceCenter( self:GetPos() - ent:GetPos() * 1.2 )
		DropEntityIfHeld( ent )
	end
end

local deathSounds = {
	"npc/zombie_poison/pz_die1.wav",
	"npc/zombie_poison/pz_die2.wav",
	"npc/zombie/zombie_die1.wav",
	"npc/zombie/zombie_die3.wav"
}

function ENT:OnKilled(damageInfo)
	local attacker = damageInfo:GetAttacker()

	if (IsValid(attacker) and self:GetRangeTo(attacker) <= 4800) then
		self:AlertNearby(attacker, 1600, true)
	else
		local entities = ents.FindInSphere(self:GetPos(), 2400)

		for k, v in pairs(entities) do
			if (v:IsPlayer()) then
				self:AlertNearby(v, 2400, true)

				break
			end
		end
	end

	self:EmitSound(table.Random(deathSounds), 50, math.random(75, 130))
	self:BecomeRagdoll(damageInfo)

	//Now handled with hooks globally
	--nz.Enemies.Functions.OnEnemyKilled( self, attacker )

end

local painSounds = {
	"npc/zombie_poison/pz_pain1.wav",
	"npc/zombie_poison/pz_pain2.wav",
	"npc/zombie_poison/pz_pain3.wav",
	"npc/zombie/zombie_die1.wav",
	"npc/zombie/zombie_die2.wav",
	"npc/zombie/zombie_die3.wav"
}

function ENT:OnInjured(damageInfo)
	local attacker = damageInfo:GetAttacker()
	--local hitgroup = util.QuickTrace( damageInfo:GetDamagePosition( ), damageInfo:GetDamagePosition( ) ).HitGroup
	--local range = self:GetRangeTo(attacker)
	//Deal an double damage if headshot

							//NOW HANDLED IN CONFIG FOR ONHIT AND ONKILLED

	--[[if hitgroup == HITGROUP_HEAD then
		if self:IsValid() and damageInfo:GetDamageType() != DMG_BLAST_SURFACE then
			local headshot = DamageInfo()
			headshot:SetDamage(damageInfo:GetDamage( ))
			headshot:SetAttacker(attacker)
			headshot:SetDamageType(DMG_BLAST_SURFACE)
			print("Headshot! ", headshot:GetDamage( ))
			//Delay so it doesn't "die" twice
			timer.Simple(0.1, function() if self:IsValid() then self:TakeDamageInfo( headshot ) end end)
		end
	end]]
	self:EmitSound(table.Random(painSounds), 50, math.random(50, 130))
	self.target = attacker
	self:AlertNearby(attacker, 1000)

	//Now handled with hooks globally
	--nz.Enemies.Functions.OnEnemyHurt( self, attacker, hitgroup )
end

function ENT:GetClosestAvailableRespawnPoint()
	local pos = self:GetPos()
	local min_dist, closest_target = -1, nil

	for k,v in pairs(nz.Enemies.Data.RespawnableSpawnpoints) do
		if IsValid(v) and (!nz.Config.NavGroupTargeting or nz.Nav.Functions.IsInSameNavGroup(self, v)) then
			local dist = v:GetPos():Distance(pos)
			if ((dist < min_dist||min_dist==-1)) then
				closest_target = v
				min_dist = dist
			end
		end
	end
	if IsValid(closest_target) then return closest_target end
	return nil
end

function ENT:RespawnAtPoint(cur)
	local valids = nz.Enemies.Functions.ValidRespawns()

	if valids[1] == nil then
		print("No valid spawns were found - Couldn't respawn!")
		return
	end

	local spawnpoint = table.Random(valids)

	if nz.Enemies.Functions.CheckIfSuitable(spawnpoint:GetPos()) then
		self:SetPos(spawnpoint:GetPos())
	end
end

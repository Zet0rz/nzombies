AddCSLuaFile()

--debug cvars
CreateConVar( "nz_zombie_debug", "0", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_CHEAT } )

--[[
This Base is not really spawnable but it contains a lot of useful functions for it's children
--]]

--Boring
ENT.Base = "base_nextbot"
ENT.PrintName = "Zombie"
ENT.Category = "Brainz"
ENT.Author = "Lolle & Zet0r"
ENT.Spawnable = true
ENT.AdminOnly = true

-- Zombie Stuffz
-- fallbacks
ENT.DeathDropHeight = 700
ENT.StepHeight = 22 --Default is 18 but it makes things easier
ENT.JumpHeight = 68
ENT.AttackRange = 65
ENT.RunSpeed = 200
ENT.WalkSpeed = 100
ENT.Acceleration = 400
ENT.DamageLow = 50
ENT.DamageHigh = 70

--The Accessors will be partially shared, but should only be used serverside
AccessorFunc( ENT, "fWalkSpeed", "WalkSpeed", FORCE_NUMBER)
AccessorFunc( ENT, "fRunSpeed", "RunSpeed", FORCE_NUMBER)
AccessorFunc( ENT, "fAttackRange", "AttackRange", FORCE_NUMBER)
AccessorFunc( ENT, "fLastJump", "LastJump", FORCE_NUMBER)
AccessorFunc( ENT, "fLastTargetCheck", "LastTargetCheck", FORCE_NUMBER)
AccessorFunc( ENT, "fLastAtack", "LastAttack", FORCE_NUMBER)
AccessorFunc( ENT, "fLastTargetChange", "LastTargetChange", FORCE_NUMBER)
AccessorFunc( ENT, "fTargetCheckRange", "TargetCheckRange", FORCE_NUMBER)

--sounds
AccessorFunc( ENT, "fNextMoanSound", "NextMoanSound", FORCE_NUMBER)

--Stuck prevention
AccessorFunc( ENT, "fLastPostionSave", "LastPostionSave", FORCE_NUMBER)
AccessorFunc( ENT, "fLastPush", "LastPush", FORCE_NUMBER)
AccessorFunc( ENT, "iStuckCounter", "StuckCounter", FORCE_NUMBER)
AccessorFunc( ENT, "vStuckAt", "StuckAt")

AccessorFunc( ENT, "bJumping", "Jumping", FORCE_BOOL)
AccessorFunc( ENT, "bAttacking", "Attacking", FORCE_BOOL)
AccessorFunc( ENT, "bClimbing", "Climbing", FORCE_BOOL)
AccessorFunc( ENT, "bStop", "Stop", FORCE_BOOL)
AccessorFunc( ENT, "bSpecialAnim", "SpecialAnimation", FORCE_BOOL)

AccessorFunc( ENT, "iActStage", "ActStage", FORCE_NUMBER)

ENT.ActStages = {
	[1] = {
		act = ACT_WALK,
		minspeed = 5,
	},
	[2] = {
		act = ACT_WALK_ANGRY,
		minspeed = 40,
	},
	[3] = {
		act = ACT_RUN,
		minspeed = 100,
	},
	[4] = {
		act = ACT_SPRINT,
		minspeed = 160,
	},
}

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "EmergeSequenceIndex")
end

function ENT:Precache()

	for _,v in pairs(self.Models) do
		util.PrecacheModel( v )
	end

	if self.AttackSounds then
		for _,v in pairs(self.AttackSounds) do
			util.PrecacheSound( v )
		end
	end

	if self.AttackHitSounds then
		for _,v in pairs(self.AttackHitSounds) do
			util.PrecacheSound( v )
		end
	end

	if self.PainSounds then
		for _,v in pairs(self.PainSounds) do
			util.PrecacheSound( v )
		end
	end

	if self.DeathSounds then
		for _,v in pairs(self.DeathSounds) do
			util.PrecacheSound( v )
		end
	end

	if self.WalkSounds then
		for _,v in pairs(self.WalkSounds) do
			util.PrecacheSound( v )
		end
	end

	if self.RunSounds then
		for _,v in pairs(self.RunSounds) do
			util.PrecacheSound( v )
		end
	end
end
--Init
function ENT:Initialize()

	self:Precache()

	self:SetModel( self.Models[math.random( #self.Models )] )

	self:SetJumping( false )
	self:SetLastJump( CurTime() + 3 ) --prevent jumping after spawn
	self:SetLastTargetCheck( CurTime() )
	self:SetLastTargetChange( CurTime() )

	--sounds
	self:SetNextMoanSound( CurTime() + 1 )

	--stuck prevetion
	self:SetLastPush( CurTime() )
	self:SetLastPostionSave( CurTime() )
	self:SetStuckAt( self:GetPos() )
	self:SetStuckCounter( 0 )

	self:SetAttacking( false )
	self:SetLastAttack( CurTime() )
	self:SetAttackRange( self.AttackRange )
	self:SetTargetCheckRange(0) -- 0 for no distance restriction (infinite)

	self:SetHealth( 75 ) --fallback

	self:SetRunSpeed( self.RunSpeed ) --fallback
	self:SetWalkSpeed( self.WalkSpeed ) --fallback

	self:SetCollisionBounds(Vector(-16,-16, 0), Vector(16, 16, 70))

	self:SetActStage(0)
	self:SetSpecialAnimation(false)

	self:StatsInitialize()
	self:SpecialInit()

	if SERVER then
		self.loco:SetDeathDropHeight( self.DeathDropHeight )
		self.loco:SetDesiredSpeed( self:GetRunSpeed() )
		self.loco:SetAcceleration( self.Acceleration )
		self.loco:SetJumpHeight( self.JumpHeight )
	end

	for i,v in ipairs(self:GetBodyGroups()) do
		self:SetBodygroup( i-1, math.random(0, self:GetBodygroupCount(i-1) - 1))
	end
	self:SetSkin( math.random(self:SkinCount()) - 1 )

	if GetConVar( "nz_zombie_debug" ):GetBool() then
		print(self, "Now spawning")
	end

end

--init for class related attributes hooks etc...
function ENT:SpecialInit()
	--print("PLEASE Override the base class!")
end

function ENT:StatsInit()
	--print("PLEASE Override the base class!")
end

function ENT:Think()
	if SERVER then --think is shared since last update but all the stuff in here should be serverside
		if !self:IsJumping() and !self:GetSpecialAnimation() and (self:GetSolidMask() == MASK_NPCSOLID_BRUSHONLY or self:GetSolidMask() == MASK_SOLID_BRUSHONLY) then
			local occupied = false
			local tr = util.TraceHull( {
				start = self:GetPos(),
				endpos = self:GetPos(),
				filter = self,
				mins = Vector( -20, -20, -0 ),
				maxs = Vector( 20, 20, 70 ),
				mask = MASK_NPCSOLID
			} )
			if !tr.HitNonWorld then self:SetSolidMask(MASK_NPCSOLID) end
			--[[for _,ent in pairs(ents.FindInBox(self:GetPos() + Vector( -16, -16, 0 ), self:GetPos() + Vector( 16, 16, 70 ))) do
				if ent:GetClass() == "nz_zombie*" and ent != self then occupied = true end
			end
			if !occupied then self:SetSolidMask(MASK_NPCSOLID) end]]
		end

		if self.loco:IsUsingLadder() then
			--self:SetSolidMask(MASK_NPCSOLID_BRUSHONLY)
		end

		--this is a very costly operation so we only do it every second
		if self:GetLastTargetCheck() + 1 < CurTime() then
			self:SetTarget(self:GetPriorityTarget())
			if GetConVar( "nz_zombie_debug" ):GetBool() then
				print(self, "Retargeting from Think.")
			end
		end

		if self:GetLastPostionSave() + 4 < CurTime() then
			if self:GetPos():Distance( self:GetStuckAt() ) < 10 then
				self:SetStuckCounter( self:GetStuckCounter() + 1)
				if GetConVar( "nz_zombie_debug" ):GetBool() then
					print(self, "Adding up stuck counter. Now at " .. self:GetStuckCounter())
				end
			else
				self:SetStuckCounter( 0 )
			end

			if self:GetStuckCounter() > 2 then

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
					effectData:SetStart( self:GetPos() + Vector(0,0,32) )
					effectData:SetOrigin( self:GetPos() + Vector(0,0,32) )
					effectData:SetMagnitude(1)
					util.Effect("zombie_spawn_dust", effectData)

					self:RespawnAtRandom()
					self:SetStuckCounter( 0 )
				end

				if self:GetStuckCounter() <= 3 then
					--try to unstuck via random velocity
					self:ApplyRandomPush()
				end

				if self:GetStuckCounter() > 3 and self:GetStuckCounter() <= 5 then
					--try to unstuck via jump
					self:Jump()
					if GetConVar( "nz_zombie_debug" ):GetBool() then
						print(self, "Jumping because stuck counter is 3 or 5.")
					end
				end

				if self:GetStuckCounter() > 5 then
					--Worst case:
					--respawn the zombie after 32 seconds with no postion change
					self:RespawnAtRandom()
					self:SetStuckCounter( 0 )
					if GetConVar( "nz_zombie_debug" ):GetBool() then
						print(self, "Respawned because stuck counter is over 5.")
					end
				end

			end
			self:SetLastPostionSave( CurTime() )
			self:SetStuckAt( self:GetPos() )
		end

		--sounds
		self:SoundThink()

		if self:ZombieWaterLevel() == 3 then
			self:RespawnAtRandom()
			if GetConVar( "nz_zombie_debug" ):GetBool() then
				print(self, "Respawning because submerged in water.")
			end
		end

	end
	self:OnThink()
	self:NextThink(0.5)
end

function ENT:SoundThink()
	if CurTime() > self:GetNextMoanSound() and !self:GetStop() then
		--local soundName = self:GetActivity() == ACT_RUN and self.RunSounds[ math.random(#self.RunSounds ) ] or self.WalkSounds[ math.random(#self.WalkSounds ) ]
		local soundName = self.WalkSounds[math.random(#self.WalkSounds)]
		self:EmitSound( soundName, 80 )
		local nextSound = SoundDuration( soundName ) + math.random(0,4) + CurTime()
		self:SetNextMoanSound( nextSound )
	end
end

function ENT:RunBehaviour()

	self:SpawnZombie()

	while (true) do
		if GetConVar( "nz_zombie_debug" ):GetBool() then
			print(self, "Performing a Run Behaviour loop.")
		end
		if !self:GetStop() then
			if self:HasTarget() then
				local pathResult = self:ChaseTarget( {
					maxage = 1,
					draw = false,
					tolerance = ((self:GetAttackRange() -20) > 0 ) and self:GetAttackRange() - 10
				} )
				if pathResult == "ok" then
					if self:TargetInAttackRange() then
						self:OnTargetInAttackRange()
					end
				elseif pathResult == "timeout" then --asume pathing timedout, maybe we are stuck maybe we are blocked by barricades
					local barricade = self:CheckForBarricade()
					if barricade then
						self:OnBarricadeBlocking( barricade )
					else
						self:OnPathTimeOut()
					end
				else
					if GetConVar( "nz_zombie_debug" ):GetBool() then
						print(self, "Pathing failed!")
					end
					self:TimeOut(2)
					--path failed what should we do :/?
				end
			else
				self:OnNoTarget()
			end
		else
			coroutine.wait(2)
			coroutine.yield()
		end
	end
end

function ENT:Stop()
	self:SetStop(true)
	self:SetTarget(nil)
	if GetConVar( "nz_zombie_debug" ):GetBool() then
		print(self, "Stopping all behaviour and removing target.")
	end
end

--Draw sppoky red eyes
local eyeGlow =  Material( "sprites/redglow1" )
local white = Color( 255, 255, 255, 255 )

function ENT:Draw()
	self:DrawModel()
	if self.RedEyes then
		--local eyes = self:GetAttachment(self:LookupAttachment("eyes")).Pos
		--local leftEye = eyes + self:GetRight() * -1.5 + self:GetForward() * 0.5
		--local rightEye = eyes + self:GetRight() * 1.5 + self:GetForward() * 0.5

		local leftEye = self:GetAttachment(self:LookupAttachment("lefteye")).Pos
		local rightEye = self:GetAttachment(self:LookupAttachment("righteye")).Pos
		cam.Start3D(EyePos(),EyeAngles())
			render.SetMaterial( eyeGlow )
			render.DrawSprite( leftEye, 4, 4, white)
			render.DrawSprite( rightEye, 4, 4, white)
		cam.End3D()
	end
	if GetConVar( "nz_zombie_debug" ):GetBool() then
		render.DrawWireframeBox(self:GetPos(), Angle(0,0,0), self:OBBMins(), self:OBBMaxs(), Color(255,0,0), true)
		render.DrawWireframeSphere(self:GetPos(), self:GetAttackRange(), 10, 10, Color(255,165,0), true)
	end
end

--[[
	Events
	You can easily override them.
	Todo: Add Hooks
--]]

function ENT:SpawnZombie()
	--BAIL if no navmesh is near
	local nav = navmesh.GetNearestNavArea( self:GetPos() )
	if !self:IsInWorld() or !IsValid(nav) or nav:GetClosestPointOnArea( self:GetPos() ):DistToSqr( self:GetPos() ) >= 10000 then
		ErrorNoHalt("Zombie ["..self:GetClass().."]["..self:EntIndex().."] spawned too far away from a navmesh!")
		self:Remove()
	end

	self:OnSpawn()
end

function ENT:OnSpawn()

end

function ENT:OnTargetInAttackRange()
	if GetConVar( "nz_zombie_debug" ):GetBool() then
		print(self, "Attacking", self:GetTarget())
	end
	self:Attack()
end

function ENT:OnBarricadeBlocking( barricade )
	if (IsValid(barricade) and barricade:GetClass() == "breakable_entry" ) then
		if GetConVar( "nz_zombie_debug" ):GetBool() then
			print(self, "Attacking barricade", barricade)
		end
		if barricade:GetNumPlanks() > 0 then
			timer.Simple(0.3, function()

				barricade:EmitSound("physics/wood/wood_plank_break" .. math.random(1, 4) .. ".wav", 100, math.random(90, 130))

				barricade:RemovePlank()

			end)

			self:PlaySequenceAndWait( self.AttackSequences[ math.random( #self.AttackSequences ) ].seq , 1)
			self:SetAttacking(true)
			
			self:TimedEvent(1, function()
				self:SetAttacking(false)
				self:SetLastAttack(CurTime())
			end)
		end
	end
end

function ENT:TimeOut(time)
	self:OnPathTimeOut()
	if coroutine.running() then
		coroutine.wait(time)
	end
end

function ENT:OnPathTimeOut()
	if GetConVar( "nz_zombie_debug" ):GetBool() then
		print(self, "Path timed out.")
	end
end

function ENT:OnNoTarget()
	-- Game over! Walk around randomly and wave
	if Round:InState( ROUND_GO ) then
		self:StartActivity(ACT_WALK)
		self.loco:SetDesiredSpeed(40)
		self:MoveToPos(self:GetPos() + Vector(math.random(-256, 256), math.random(-256, 256), 0), {
			repath = 3,
			maxage = 2
		})
	else
		-- Start off by checking for a new target
		local newtarget = self:GetPriorityTarget()
		if self:IsValidTarget(newtarget) then
			self:SetTarget(newtarget)
		else
			if GetConVar( "nz_zombie_debug" ):GetBool() then
				print(self, "Tried to retarget in OnNoTarget, but got no valid target.")
			end
			local sPoint = self:GetClosestAvailableRespawnPoint()
			if !sPoint then
				-- Something is wrong remove this zombie
				self:MoveToPos(self:GetPos() + Vector(math.random(-256, 256), math.random(-256, 256), 0), {
					repath = 3,
					maxage = 2
				})

				-- Wander a bit, then check again
				if !self:GetClosestAvailableRespawnPoint() then
					if GetConVar( "nz_zombie_debug" ):GetBool() then
						print(self, "Removing because no valid target.")
					end
					self:Remove()
				end
			else
				--if not visible to players respawn immediately
				if !self:IsInSight() then
					if GetConVar( "nz_zombie_debug" ):GetBool() then
						print(self, "Respawning from no valid target and not in sight.")
					end
					self:RespawnAtRandom( sPoint )
				else
					self:ChaseTarget( {
						maxage = 20,
						draw = false,
						target = sPoint,
						tolerance = self:GetAttackRange() / 10
					})
					if GetConVar( "nz_zombie_debug" ):GetBool() then
						print(self, "Respawning from no valid target and having walked around.")
					end
					self:RespawnAtRandom( sPoint )
				end
			end
		end
	end
end

function ENT:OnContactWithTarget()

end

function ENT:OnLandOnGroundZombie()

end

function ENT:OnThink()

end

--Default NEXTBOT Events
function ENT:OnLandOnGround()
	self:EmitSound("physics/flesh/flesh_impact_hard" .. math.random(1, 6) .. ".wav")
	self:SetJumping( false )
	if self:HasTarget() then
		self.loco:SetDesiredSpeed(self:GetRunSpeed())
	else
		self.loco:SetDesiredSpeed(self:GetWalkSpeed())
	end
	self.loco:SetAcceleration( self.Acceleration )
	self.loco:SetStepHeight( 22 )
	self:OnLandOnGroundZombie()
end

function ENT:OnLeaveGround( ent )
	self:SetJumping( true )
end

function ENT:OnNavAreaChanged(old, new)
	if bit.band(new:GetAttributes(), NAV_MESH_JUMP) != 0 then
		--dont make jumps in the wrong direction
		if old:ComputeGroundHeightChange( new ) < 0 then
			return
		end
		self:Jump()
	end
end

function ENT:OnContact( ent )
	if nz.Config.ValidEnemies[ent:GetClass()] and nz.Config.ValidEnemies[self:GetClass()] then
		--this is a poor approach to unstuck them when walking into each other
		self.loco:Approach( self:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 2000,1000)
		--important if the get stuck on top of each other!
		--if math.abs(self:GetPos().z - ent:GetPos().z) > 30 then self:SetSolidMask( MASK_NPCSOLID_BRUSHONLY ) end
	end
	--buggy prop push away thing comment if you dont want this :)
	if  ( ent:GetClass() == "prop_physics_multiplayer" or ent:GetClass() == "prop_physics" ) then
		--self.loco:Approach( self:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 2000,1000)
		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			local force = -physenv.GetGravity().z * phys:GetMass() / 12 * ent:GetFriction()
			local dir = ent:GetPos() - self:GetPos()
			dir:Normalize()
			phys:ApplyForceCenter( dir * force )
		end
	end

	if self:IsTarget( ent ) then
		self:OnContactWithTarget()
	end
end

function ENT:OnInjured( dmgInfo )
	local attacker = dmgInfo:GetAttacker()
	if self:IsValidTarget( attacker ) then
		self:SetTarget( attacker )
	end
	local soundName = self.PainSounds[ math.random( #self.PainSounds ) ]
	self:EmitSound( soundName, 90 )
end

function ENT:OnZombieDeath()
	self:BecomeRagdoll(dmgInfo)
end

function ENT:OnKilled(dmgInfo)

	self:OnZombieDeath(dmgInfo)
	hook.Call("OnZombieKilled", GAMEMODE, self, dmgInfo)

end

function ENT:OnRemove()

end

function ENT:OnStuck()
	--
	--self.loco:Approach( self:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 2000, 1000 )
	--print("Now I'm stuck", self)
	if GetConVar( "nz_zombie_debug" ):GetBool() then
		print(self, "Now stuck.")
	end
end

--Target and pathfidning
function ENT:GetPriorityTarget()

	if GetConVar( "nz_zombie_debug" ):GetBool() then
		print(self, "Retargeting")
	end

	self:SetLastTargetCheck( CurTime() )

	--if you really would want something that atracts the zombies from everywhere you would need something like this
	local allEnts = ents.GetAll()
	--[[for _, ent in pairs(allEnts) do
		if ent:GetTargetPriority() == TARGET_PRIORITY_ALWAYS and self:IsValidTarget(ent) then
			return ent
		end
	end]]

	-- Disabled the above for for now since it just might be better to use that same loop for everything

	local bestTarget = nil
	local highestPriority = TARGET_PRIORITY_NONE
	local maxdistsqr = self:GetTargetCheckRange()^2
	local targetDist = maxdistsqr + 10

	--local possibleTargets = ents.FindInSphere( self:GetPos(), self:GetTargetCheckRange())

	for _, target in pairs(allEnts) do
		if self:IsValidTarget(target) then
			if target:GetTargetPriority() == TARGET_PRIORITY_ALWAYS then return target end
			local dist = self:GetRangeSquaredTo( target:GetPos() )
			if maxdistsqr <= 0 or dist <= maxdistsqr then -- 0 distance is no distance restrictions
				local priority = target:GetTargetPriority()
				if target:GetTargetPriority() > highestPriority then
					highestPriority = priority
					bestTarget = target
					targetDist = dist
				elseif target:GetTargetPriority() == highestPriority then
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

function ENT:ChaseTarget( options )

	options = options or {}

	if !options.target then
		options.target = self:GetTarget()
	end

	local path = self:ChaseTargetPath( options )

	if ( !IsValid(path) ) then return "failed" end
	while ( path:IsValid() and self:HasTarget() and !self:TargetInAttackRange() ) do

		path:Update( self )

		--Timeout the pathing so it will rerun the entire behaviour (break barricades etc)
		if ( path:GetAge() > options.maxage ) then
			return "timeout"
		end
		path:Update( self )	-- This function moves the bot along the path
		if options.draw or GetConVar( "nz_zombie_debug" ):GetBool() then
			path:Draw()
		end
		--the jumping part simple and buggy
		--local scanDist = (self.loco:GetVelocity():Length()^2)/(2*900) + 15
		local scanDist
		--this will probaly need asjustments to fit the zombies speed
		if self:GetVelocity():Length2D() > 150 then scanDist = 30 else scanDist = 20 end
		--debug section
		if GetConVar( "nz_zombie_debug" ):GetBool() then
			debugoverlay.Line( self:GetPos(),  path:GetClosestPosition(self:EyePos() + self.loco:GetGroundMotionVector() * scanDist), 0.05, Color(0,0,255,0) )
			local losColor  = Color(255,0,0)
			if self:IsLineOfSightClear( self:GetTarget():GetPos() + Vector(0,0,35) ) then
				losColor = Color(0,255,0)
			end
			debugoverlay.Line( self:EyePos(),  self:GetTarget():GetPos() + Vector(0,0,35), 0.03, losColor )
			local nav = navmesh.GetNearestNavArea( self:GetPos() )
			if IsValid(nav) and nav:GetClosestPointOnArea( self:GetPos() ):DistToSqr( self:GetPos() ) < 2500 then
				debugoverlay.Line( nav:GetCorner( 0 ),  nav:GetCorner( 1 ), 0.05, Color(255,0,0), true )
				debugoverlay.Line( nav:GetCorner( 0 ),  nav:GetCorner( 3 ), 0.05, Color(255,0,0), true )
				debugoverlay.Line( nav:GetCorner( 1 ),  nav:GetCorner( 2 ), 0.05, Color(255,0,0), true )
				debugoverlay.Line( nav:GetCorner( 2 ),  nav:GetCorner( 3 ), 0.05, Color(255,0,0), true )
				for _,v in pairs(nav:GetAdjacentAreas()) do
					debugoverlay.Line( v:GetCorner( 0 ),  v:GetCorner( 1 ), 0.05, Color(150,80,0,80), true )
					debugoverlay.Line( v:GetCorner( 0 ),  v:GetCorner( 3 ), 0.05, Color(150,80,0,80), true )
					debugoverlay.Line( v:GetCorner( 1 ),  v:GetCorner( 2 ), 0.05, Color(150,80,0,80), true )
					debugoverlay.Line( v:GetCorner( 2 ),  v:GetCorner( 3 ), 0.05, Color(150,80,0,80), true )
				end
			end
		end
		--print(self.loco:GetGroundMotionVector(), self:GetForward())
		--local goal = path:GetCurrentGoal()
		if path:IsValid() and math.abs(self:GetPos().z - path:GetClosestPosition(self:EyePos() + self.loco:GetGroundMotionVector() * scanDist).z) > 22 then
			self:Jump()
		end

		--[[if path:IsValid() and goal.type == 4 then
			--self.loco:SetVelocity( Vector( 0, 0, 1000 ) )
			self:SetPos( path:GetClosestPosition( goal.ladder:GetTopForwardArea():GetCenter() ) )
			self:SetClimbing( true )
			coroutine.wait( 0.5 )
			self:SetSolidMask( MASK_NPCSOLID_BRUSHONLY )
			return "timeout"
			if self.loco:IsUsingLadder() then
				self.loco:SetVelocity( self.loco:GetVelocity() + Vector( 0, 0, 50 ) )
			end
		end --]]

		-- If we're stuck, then call the HandleStuck function and abandon
		if ( self.loco:IsStuck() ) then
			self:HandleStuck()
			return "stuck"
		end

		if self.loco:GetVelocity():Length() < 10 then
			self:ApplyRandomPush()
		end

		coroutine.yield()

	end

	--if the zombie isnt engaged in combat, make a time out if the path duration was to small, to prevent repath spam.
	if path:GetAge() < 0.3 and self:GetLastAttack() + 1 < CurTime() and !self:TargetInAttackRange() and self:GetLastTargetChange() + 1 < CurTime() then
		--target is probably not reachable wait a bit then try again
		coroutine.wait(2)
	end

	return "ok"

end

function ENT:ChaseTargetPath( options )

	options = options or {}

	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( options.lookahead or 300 )
	path:SetGoalTolerance( options.tolerance or 50 )

	--[[local targetPos = options.target:GetPos()
	--set the goal to the closet navmesh
	local goal = navmesh.GetNearestNavArea(targetPos, false, 100)
	goal = goal and goal:GetClosestPointOnArea(targetPos) or targetPos--]]

	--Custom path computer, the same as default but not pathing through locked nav areas.
	path:Compute( self, options.target:GetPos(),  function( area, fromArea, ladder, elevator, length )
		if ( !IsValid( fromArea ) ) then
			--first area in path, no cost
			return 0
		else
			if ( !self.loco:IsAreaTraversable( area ) ) then
				--our locomotor says we can't move here
				return -1
			end
			--Prevent movement through either locked navareas or areas with closed doors
			if (nz.Nav.Data[area:GetID()]) then
				--print("Has area")
				if nz.Nav.Data[area:GetID()].link then
					--print("Area has door link")
					if !Doors.OpenedLinks[nz.Nav.Data[area:GetID()].link] then
						--print("Door link is not opened")
						return -1
					end
				elseif nz.Nav.Data[area:GetID()].locked then
					--print("Area is locked")
				return -1 end
			end
			--compute distance traveled along path so far
			local dist = 0
			--[[if ( IsValid( ladder ) ) then
				dist = ladder:GetLength()
			elseif ( length > 0 ) then
				--optimization to avoid recomputing length
				dist = length
			else
				dist = ( area:GetCenter() - fromArea:GetCenter() ):GetLength()
			end]]--
			local cost = dist + fromArea:GetCostSoFar()
			--check height change
			local deltaZ = fromArea:ComputeAdjacentConnectionHeightChange( area )
			if ( deltaZ >= self.loco:GetStepHeight() ) then
				if ( deltaZ >= self.loco:GetMaxJumpHeight() ) then
					--Include ladders in pathing:
					--currently disableddue to the lack of a loco:Climb function
					--[[if IsValid( ladder ) then
						if ladder:GetTopForwardArea():GetID() == area:GetID() then
							return cost
						end
					end --]]
					--too high to reach
					return -1
				end
				--jumping is slower than flat ground
				local jumpPenalty = 1.1
				cost = cost + jumpPenalty * dist
			elseif ( deltaZ < -self.loco:GetDeathDropHeight() ) then
				--too far to drop
				return -1
			end
			return cost
		end
	end)

	return path
end

function ENT:GetLadderTop( ladder )
	return ladder:GetTopForwardArea() or ladder:GetTopBehindArea() or ladder:GetTopRightArea() or ladder:GetTopLeftArea()
end

function ENT:TargetInAttackRange()
	return self:TargetInRange( self:GetAttackRange() )
end

function ENT:TargetInRange( range )
	local target = self:GetTarget()
	if !IsValid(target) then return false end
	return self:GetRangeTo( target:GetPos() ) < range
end

function ENT:CheckForBarricade()
	--we try a line trace first since its more efficient
	local dataL = {}
	dataL.start = self:GetPos() + Vector( 0, 0, self:OBBCenter().z )
	dataL.endpos = self:GetPos() + Vector( 0, 0, self:OBBCenter().z ) + self:GetForward() * 64
	dataL.filter = self
	dataL.ignoreworld = true
	local trL = util.TraceLine( dataL )
	if IsValid( trL.Entity ) and trL.Entity:GetClass() == "breakable_entry" then
		return trL.Entity
	end

	--perform a hull trace if line didnt hit just to make sure
	local dataH = {}
	dataH.start = self:GetPos()
	dataH.endpos = self:GetPos() + self:GetForward() * 64
	dataH.filter = self
	dataH.mins = self:OBBMins() * 0.65
	dataH.maxs = self:OBBMaxs() * 0.65
	local trH = util.TraceHull(dataH )
	if IsValid( trH.Entity ) and trH.Entity:GetClass() == "breakable_entry" then
		return trH.Entity
	end

	return nil

end

--A standard attack you can use it or create something fancy yourself
function ENT:Attack( data )

	self:SetLastAttack(CurTime())

	--if self:Health() <= 0 then coroutine.yield() return end

	data = data or {}
	data.attackseq = data.attackseq or self.AttackSequences[ math.random( #self.AttackSequences ) ] or "swing"
	data.attacksound = data.attacksound or self.AttackSounds[ math.random( #self.AttackSounds) ] or Sound( "npc/vort/claw_swing1.wav" )
	data.hitsound = data.hitsound or self.AttackHitSounds[ math.random( #self.AttackHitSounds ) ]Sound( "npc/zombie/zombie_hit.wav" )
	data.viewpunch = data.viewpunch or VectorRand():Angle() * 0.05
	data.dmglow = data.dmglow or self.DamageLow or 50
	data.dmghigh = data.dmghigh or self.DamageHigh or 70
	data.dmgtype = data.dmgtype or DMG_CLUB
	data.dmgforce = data.dmgforce or (self:GetTarget():GetPos() - self:GetPos()) * 7 + Vector( 0, 0, 16 )
	data.dmgforce.z = math.Clamp(data.dmgforce.z, 1, 16)
	local seq, dur = self:LookupSequence( data.attackseq )
	data.attackdur = (seq != - 1 and dur) or 0.6
	data.dmgdelay = data.dmgdelay or ( ( data.attackdur != 0 ) and data.attackdur / 2 ) or 0.3

	self:EmitSound("npc/zombie_poison/pz_throw2.wav", 50, math.random(75, 125)) -- whatever this is!? I will keep it for now

	self:SetAttacking( true )

	self:TimedEvent(0.1, function()
		self:EmitSound( data.attacksound )
	end)

	self:TimedEvent( data.dmgdelay, function()
		if self:IsValidTarget( self:GetTarget() ) and self:TargetInRange( self:GetAttackRange() + 10 ) then
			local dmgAmount = math.random( data.dmglow, data.dmghigh )
			local dmgInfo = DamageInfo()
				dmgInfo:SetAttacker( self )
				dmgInfo:SetDamage( dmgAmount )
				dmgInfo:SetDamageType( data.dmgtype )
				dmgInfo:SetDamageForce( data.dmgforce )
			self:GetTarget():TakeDamageInfo(dmgInfo)
			self:GetTarget():EmitSound( data.hitsound, 50, math.random( 80, 160 ) )
			self:GetTarget():ViewPunch( data.viewpunch )
			self:GetTarget():SetVelocity( data.dmgforce )

			local blood = ents.Create("env_blood")
			blood:SetKeyValue("targetname", "carlbloodfx")
			blood:SetKeyValue("parentname", "prop_ragdoll")
			blood:SetKeyValue("spawnflags", 8)
			blood:SetKeyValue("spraydir", math.random(500) .. " " .. math.random(500) .. " " .. math.random(500))
			blood:SetKeyValue("amount", dmgAmount * 5)
			blood:SetCollisionGroup( COLLISION_GROUP_WORLD )
			blood:SetPos( self:GetTarget():GetPos() + self:GetTarget():OBBCenter() + Vector( 0, 0, 10 ) )
			blood:Spawn()
			blood:Fire("EmitBlood")
			SafeRemoveEntityDelayed( blood, 2) --just to make sure everything gets cleaned
		end
	end)

	self:TimedEvent(data.attackdur, function()
		self:SetAttacking(false)
		self:SetLastAttack(CurTime())
	end)

	self:PlayAttackAndWait(data.attackseq, 1)
end

function ENT:PlayAttackAndWait( name, speed )

	local len = self:SetSequence( name )
	speed = speed or 1

	self:ResetSequenceInfo()
	self:SetCycle( 0 )
	self:SetPlaybackRate( speed )

	local endtime = CurTime() + len / speed

	while ( true ) do

		if ( endtime < CurTime() ) then
			if !self:GetStop() then
				self:StartActivity( ACT_WALK )
				self.loco:SetDesiredSpeed( self:GetRunSpeed() )
			end
			return
		end
		if self:IsValidTarget( self:GetTarget() ) and self:TargetInRange( self:GetAttackRange() * 2  ) then
			self.loco:SetDesiredSpeed( self:GetRunSpeed() / 3 )
			self.loco:Approach( self:GetTarget():GetPos(), 10 )
			self.loco:FaceTowards( self:GetTarget():GetPos() )
		end

		coroutine.yield()

	end

end

--we do our own jump since the loco one is a bit weird.
function ENT:Jump()
	if CurTime() < self:GetLastJump() + 1.75 or navmesh.GetNavArea(self:GetPos(), 50):HasAttributes( NAV_MESH_NO_JUMP ) then return end
	if !self:IsOnGround() then return end
	self.loco:SetDesiredSpeed( 450 )
	self.loco:SetAcceleration( 5000 )
	self:SetLastJump( CurTime() )
	self:SetJumping( true )
	--self:SetSolidMask( MASK_NPCSOLID_BRUSHONLY )
	self.loco:Jump()
	--Boost them
	self:TimedEvent( 0.5, function() self.loco:SetVelocity( self:GetForward() * 5 ) end)
end

function ENT:Flames( state )
	if state then
		self.FlamesEnt = ents.Create("env_fire")
		if IsValid( self.FlamesEnt ) then
			self.FlamesEnt:SetParent(self)
			self.FlamesEnt:SetOwner(self)
			self.FlamesEnt:SetPos(self:GetPos() - Vector(0, 0, -50))
			--no glow + delete when out + start on + last forever
			self.FlamesEnt:SetKeyValue("spawnflags", tostring(128 + 32 + 4 + 2 + 1))
			self.FlamesEnt:SetKeyValue("firesize", (1 * math.Rand(0.7, 1.1)))
			self.FlamesEnt:SetKeyValue("fireattack", 0)
			self.FlamesEnt:SetKeyValue("health", 0)
			self.FlamesEnt:SetKeyValue("damagescale", "-10") -- only neg. value prevents dmg

			self.FlamesEnt:Spawn()
			self.FlamesEnt:Activate()
		end
	elseif IsValid( self.FlamesEnt )  then
		self.FlamesEnt:Remove()
		self.FlamesEnt = nil
	end
end

function ENT:Explode( dmg, suicide)

	suicide = suicide or true

	local ex = ents.Create("env_explosion")
	ex:SetPos(self:GetPos())
	ex:SetKeyValue( "iMagnitude", tostring( dmg ) )
	ex:SetOwner(self)
	ex:Spawn()
	ex:Fire("Explode",0,0)
	ex:EmitSound( "weapons/explode" .. math.random( 3, 5 ) .. ".wav" )
	ex:Fire("Kill",0,0)

	if suicide then self:TimedEvent( 0, function() self:Kill() end ) end

end

function ENT:Kill()
	self:TakeDamage( 10000, self, self )
end

function ENT:IsInSight()
	for _, ply in pairs( player.GetAllPlaying() ) do
		--can player see us or the teleport location
		if ply:Alive() and ply:IsLineOfSightClear( self ) then
			if ply:GetEyeTrace().Entity == self then
				return true
			end
		end
	end
end

function ENT:TeleportToTarget( silent )

	if !self:HasTarget() then return false end

	--that's probably not smart, just like me. SORRY D:
	local locations = {
		Vector( 256, 0, 0),
		Vector( -256, 0, 0),
		Vector( 0, 256, 0),
		Vector( 0, -256, 0),
		Vector( 256, 256, 0),
		Vector( -256, -256, 0),
		Vector( 512, 0, 0),
		Vector( -512, 0, 0),
		Vector( 0, 512, 0),
		Vector( 0, -512, 0),
		Vector( 512, 512, 0),
		Vector( -512, -512, 0),
		Vector( 1024, 0, 0),
		Vector( -1024, 0, 0),
		Vector( 0, 1024, 0),
		Vector( 0, -1024, 0),
		Vector( 1024, 1024, 0),
		Vector( -1024, -1024, 0)
	}

	--resource friendly shuffle
	local rand = math.random
	local n = #locations

	while n > 2 do

		local k = rand(n) -- 1 <= k <= n

		locations[n], locations[k] = locations[k], locations[n]
		n = n - 1

	end

	for _, v in pairs( locations ) do

		local area = navmesh.GetNearestNavArea( self:GetTarget():GetPos() + v )

		if area then

			local location = area:GetRandomPoint() + Vector( 0, 0, 2 )

			local tr = util.TraceHull( {
				start = location,
				endpos = location,
				maxs = Vector( 16, 16, 40 ), --DOGE is small
				mins = Vector( -16, -16, 0 ),
			} )

			--debugoverlay.Box( location, Vector( -16, -16, 0 ), Vector( 16, 16, 40 ), 5, Color( 255, 0, 0 ) )

			if silent then
				if !tr.Hit and nz.Nav.NavGroupIDs[navmesh.GetNearestNavArea(location):GetID()] == nz.Nav.NavGroupIDs[navmesh.GetNearestNavArea(self:GetPos()):GetID()] then
					local inFOV = false
					for _, ply in pairs( player.GetAllPlayingAndAlive() ) do
						--can player see us or the teleport location
						if ply:Alive() and ply:IsLineOfSightClear( location ) or ply:IsLineOfSightClear( self ) then
							inFOV = true
						end
					end
					if !inFOV then
						self:SetPos( location )
						return true
					end
				end
			else
				self:SetPos( location )
			end
		end
	end

	return false

end

--broken
function ENT:InFieldOfView( pos )

	local fov = math.rad( math.cos( 110 ) )
	local v = ( Vector( pos.x, pos.y, 0 ) - Vector( self:GetPos().x, self:GetPos().y, 0 ) ):GetNormalized()

	if self:GetAimVector():Dot( v ) > fov then
		local tr = util.TraceLine( {
			start = self:GetShootPos(),
			endpos = pos + Vector( 0, 0, 64),
			filter = self
		} )

		if !tr.Hit then return true end

	end

	return true

end

function ENT:BodyUpdate()

	self.CalcIdeal = ACT_IDLE

	local velocity = self:GetVelocity()

	local len2d = velocity:Length2D()

	local range = 10

	local curstage = self.ActStages[self:GetActStage()]
	local nextstage = self.ActStages[self:GetActStage() + 1]

	if self:GetActStage() <= 0 then -- We are currently idling, no range to start walking
		if nextstage and len2d >= nextstage.minspeed then -- We DO NOT apply the range here, he needs to walk at 5 speed!
			self:SetActStage( self:GetActStage() + 1 )
		end
		-- If there is no minspeed for the next stage, someone did something wrong and we just idle :/
	elseif (curstage and len2d <= curstage.minspeed - range) then
		self:SetActStage( self:GetActStage() - 1 )
	elseif (nextstage and len2d >= nextstage.minspeed + range) then
		self:SetActStage( self:GetActStage() + 1 )
	elseif !self.ActStages[self:GetActStage() - 1] and len2d < curstage.minspeed - 4 then -- Much smaller range to go back to idling
		self:SetActStage(0)
	end

	if self.ActStages[self:GetActStage()] then self.CalcIdeal = self.ActStages[self:GetActStage()].act end

	if self:IsJumping() and self:WaterLevel() <= 0 then
		self.CalcIdeal = ACT_JUMP
	end

	if !self:GetSpecialAnimation() and !self:IsAttacking() then
		if self:GetActivity() != self.CalcIdeal and !self:GetStop() then self:StartActivity(self.CalcIdeal) end

		if self.ActStages[self:GetActStage()] then
			self:BodyMoveXY()
		end
	end

	self:FrameAdvance()

end

function ENT:UpdateSequence()
	self:SetActStage(0)
	self:BodyUpdate()
end

function ENT:GetAimVector()

	return self:GetForward()

end

function ENT:GetShootPos()

	return self:EyePos()

end

function ENT:GetClosestAvailableRespawnPoint()
	local pos = self:GetPos()
	local min_dist, closest_target = -1, nil
	for k,v in pairs(nz.Enemies.Data.RespawnableSpawnpoints) do
		if IsValid(v) and (!GetConVar("nz_nav_grouptargeting"):GetBool() or nz.Nav.Functions.IsInSameNavGroup(self, v)) then
			local dist = self:GetRangeTo( v:GetPos() )
			if ((dist < min_dist or min_dist == -1)) then
				closest_target = v
				min_dist = dist
			end
		end
	end
	return closest_target or nil
end

function ENT:RespawnAtPos( point )
	if nz.Enemies.Functions.CheckIfSuitable( point ) then
		self:SetPos( point )
		self:SpawnZombie()
		return true
	end
	return false
end

function ENT:RespawnAtSpawnpoint( ent )
	--if ent:GetClass() != "zed_spawns" then return end
	if nz.Enemies.Functions.CheckIfSuitable( ent:GetPos() ) then
		self:SetPos( ent:GetPos() )
		self:SpawnZombie()
		return true
	end
	return false
end

function ENT:RespawnAtRandom( cur )
	local valids = nz.Enemies.Functions.ValidRespawns( cur )
	if valids[1] == nil then
		print("No valid spawns were found - Couldn't respawn!")
		self:TimeOut(1) -- Timeout for 1 second if it didn't work
		return
	end
	local spawnpoint = valids[ math.random(#valids) ]
	if IsValid(spawnpoint) and nz.Enemies.Functions.CheckIfSuitable(spawnpoint:GetPos()) then
		self:SetPos(spawnpoint:GetPos())
		self:SpawnZombie()
		return true
	end
	self:TimeOut(1) -- Woah! This shouldn't happen
	return false
end

--Helper function
function ENT:TimedEvent(time, callback)
	timer.Simple(time, function()
		if (IsValid(self) and self:Health() > 0) then
			callback()
		end
	end)
end

function ENT:ApplyRandomPush( power )
	if CurTime() < self:GetLastPush() + 0.2 or !self:IsOnGround() then return end
	power = power or 100
	local vec =  self.loco:GetVelocity() + VectorRand() * power
	vec.z = math.random( 100 )
	self.loco:SetVelocity( vec )
	self:SetLastPush( CurTime() )
end

function ENT:ZombieWaterLevel()
	local pos1 = self:GetPos()
	local halfSize = self:OBBCenter()
	local pos2 = pos1 + halfSize
	local pos3 = pos2 + halfSize
	if bit.band( util.PointContents( pos3 ), CONTENTS_WATER ) == CONTENTS_WATER or bit.band( util.PointContents( pos3 ), CONTENTS_SLIME ) == CONTENTS_SLIME then
		return 3
	elseif bit.band( util.PointContents( pos2 ), CONTENTS_WATER ) == CONTENTS_WATER or bit.band( util.PointContents( pos2 ), CONTENTS_SLIME ) == CONTENTS_SLIME then
		return 2
	elseif bit.band( util.PointContents( pos1 ), CONTENTS_WATER ) == CONTENTS_WATER or bit.band( util.PointContents( pos1 ), CONTENTS_SLIME ) == CONTENTS_SLIME then
		return 1
	end

	return 0
end

--Targets
function ENT:HasTarget()
	return self:IsValidTarget( self:GetTarget() )
end

function ENT:GetTarget()
	return self.Target
end

function ENT:SetTarget( target )
	self.Target = target
	if self.Target != target then
		self:SetLastTargetChange(CurTime())
	end
end

function ENT:IsTarget( ent )
	return self.Target == ent
end

function ENT:RemoveTarget()
	self:SetTarget( nil )
end

function ENT:IsValidTarget( ent )
	if !ent then return false end
	return IsValid( ent ) and ent:GetTargetPriority() != TARGET_PRIORITY_NONE
end

--AccessorFuncs
function ENT:IsJumping()
	return self:GetJumping()
end

function ENT:IsClimbing()
	return self:GetClimbing()
end

function ENT:IsAttacking()
	return self:GetAttacking()
end

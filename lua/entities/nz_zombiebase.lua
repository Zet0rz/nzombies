AddCSLuaFile()

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

--Zombie Stuffz
ENT.Models = { "models/error.mdl"  }
ENT.AttackSequences = { "swing" }
ENT.AttackSounds = {
	"npc/vort/claw_swing1.wav",
	"npc/vort/claw_swing2.wav"
}
ENT.AttackHitSounds = {
	"npc/zombie/zombie_hit.wav"
}
ENT.PainSounds = {
	"npc/zombie_poison/pz_pain1.wav",
	"npc/zombie_poison/pz_pain2.wav",
	"npc/zombie_poison/pz_pain3.wav",
	"npc/zombie/zombie_die1.wav",
	"npc/zombie/zombie_die2.wav",
	"npc/zombie/zombie_die3.wav"
}
ENT.DeathSounds = {
	"npc/zombie_poison/pz_die1.wav",
	"npc/zombie_poison/pz_die2.wav",
	"npc/zombie/zombie_die1.wav",
	"npc/zombie/zombie_die3.wav"
}
ENT.BreathSounds = {
	"npc/zombie_poison/pz_breathe_loop1.wav"
}
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

AccessorFunc( ENT, "bJumping", "Jumping", FORCE_BOOL)
AccessorFunc( ENT, "bAttacking", "Attacking", FORCE_BOOL)
AccessorFunc( ENT, "bClimbing", "Climbing", FORCE_BOOL)

--Init
function ENT:Initialize()
	self:SetModel( self.Models[math.random( #self.Models ) ] ) --Random model will not be shared (does it matter?)

	self.Breathing = CreateSound(self, self.BreathSounds[ math.random( #self.BreathSounds ) ] )
	self.Breathing:Play()
	self.Breathing:ChangePitch(60, 0)
	self.Breathing:ChangeVolume(0.1, 0)

	self:SetJumping( false )
	self:SetLastJump( CurTime() + 3 ) --prevent jumping after spawn
	self:SetLastTargetCheck( CurTime() )

	self:SetAttacking( false )
	self:SetAttackRange( self.AttackRange )

	self:SetHealth( 75 ) --fallback

	self:SetRunSpeed( self.RunSpeed ) --fallback
	self:SetWalkSpeed( self.WalkSpeed ) --fallback

	self:SetCollisionBounds(Vector(-16,-16, 0), Vector(16, 16, 70))

	self:SpecialInit()

	if SERVER then
		self.loco:SetDeathDropHeight( self.DeathDropHeight )
		self.loco:SetDesiredSpeed( self:GetRunSpeed() )
		self.loco:SetAcceleration( self.Acceleration )
		self.loco:SetJumpHeight( self.JumpHeight )
	end

end

--init for class related attributes hooks etc...
function ENT:SpecialInit()
	print("PLEASE Override the base class!")
end

function ENT:Think()
	if SERVER then --think is shared since last update but all the stuff in here should be serverside
		if  !self:IsJumping() and self:GetSolidMask() == MASK_NPCSOLID_BRUSHONLY then
			local occupied = false
			for _,ent in pairs(ents.FindInBox(self:GetPos() + Vector( -16, -16, 0 ), self:GetPos() + Vector( 16, 16, 70 ))) do
				if ent:GetClass() == "nz_zombie*" and ent != self then occupied = true end
			end
			if !occupied then self:SetSolidMask(MASK_NPCSOLID) end
		end

		if self.loco:IsUsingLadder() then
			self:SetSolidMask(MASK_NPCSOLID_BRUSHONLY)
		end

		if self:GetLastTargetCheck() + 2 < CurTime() then
			self:GetPriorityTarget()
		end

	end
	self:OnThink()
	self:NextThink(0.5)
end

function ENT:RunBehaviour()
	while (true) do
		if !self:HasTarget() then self:SetTarget( self:GetPriorityTarget() ) end
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
				--path failed what should we do :/?
			end
		else
			self:OnNoTarget()
			coroutine.wait( 1 ) --This is just here to make sure nothing gets spammed, probably unnecessary.
		end
	end
end

--Draw sppoky red eyes
local eyeGlow =  Material ( "sprites/redglow1" )
local white = Color( 255, 255, 255, 255 )

function ENT:Draw()
	self:DrawModel()
	local eyes = self:GetAttachment(self:LookupAttachment("eyes")).Pos
	local leftEye = eyes + self:GetRight() * -1.5 + self:GetForward() * 0.5
	local rightEye = eyes + self:GetRight() * 1.5 + self:GetForward() * 0.5
	cam.Start3D(EyePos(),EyeAngles())
		render.SetMaterial( eyeGlow )
		render.DrawSprite( leftEye, 4, 4, white)
		render.DrawSprite( rightEye, 4, 4, white)
	cam.End3D()
end

--[[
	Events
	You can easily override them.
	Todo: Add Hooks
--]]
function ENT:OnTargetInAttackRange()
	self:Attack()
end

function ENT:OnBarricadeBlocking( barricade )
	if (IsValid(barricade) and barricade:GetClass() == "breakable_entry" ) then
		if barricade:GetNumPlanks() > 0 then
			timer.Simple(0.3, function()

				barricade:EmitSound("physics/wood/wood_plank_break"..math.random(1, 4)..".wav", 100, math.random(90, 130))

				barricade:RemovePlank()

			end)

			self:PlaySequenceAndWait( self.AttackSequences[ math.random( #self.AttackSequences ) ] , 1)
		end
	end
end

function ENT:OnPathTimeOut()

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

		if (math.random(1, 8) == 2) then
			self:EmitSound("npc/zombie/zombie_voice_idle"..math.random(2, 7)..".wav", 50, 60)
			if (math.random(1, 2) == 2) then
				self:PlaySequenceAndWait("scaredidle")
			else
				self:PlaySequenceAndWait("photo_react_startle")
			end
		end

		self:PlaySequenceAndWait("wave_smg1", 0.9)

	else
		local sPoint = self:GetClosestAvailableRespawnPoint()
		if !sPoint then
			-- Something is wrong remove this zombie
			self:MoveToPos(self:GetPos() + Vector(math.random(-256, 256), math.random(-256, 256), 0), {
				repath = 3,
				maxage = 2
			})
			-- Wander a bit, then check again
			if !self:GetClosestAvailableRespawnPoint() then
				self:Remove()
			end
		else
			self:ChaseTarget( {
				maxage = 20,
				draw = false,
				target = sPoint,
				tolerance = self:GetAttackRange() / 10
			})
			self:RespawnAtRandom( sPoint )
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
	self:EmitSound("physics/flesh/flesh_impact_hard"..math.random(1, 6)..".wav")
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
			local force = -physenv.GetGravity().z * phys:GetMass()/12 * ent:GetFriction()
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
	self:EmitSound( self.PainSounds[ math.random( #self.PainSounds ) ] , 50, math.random(50, 130))
	if self:IsValidTarget( attacker ) then
		self:SetTarget( attacker )
	end
end

function ENT:OnKilled(dmgInfo)
	self:EmitSound(self.DeathSounds[ math.random( #self.DeathSounds ) ], 50, math.random(75, 130))
	self:BecomeRagdoll(dmgInfo)
end

function ENT:OnRemove()
	if (self.Breathing) then
		self.Breathing:Stop()
		self.Breathing = nil
	end
end

function ENT:OnStuck()
	--
	--self.loco:Approach( self:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 2000, 1000 )
	--print("Now I'm stuck", self)
end

--Target and pathfidning
function ENT:GetPriorityTarget()
	local pos = self:GetPos()

	local min_dist, closest_target = -1, nil

	for _, target in pairs(player.GetAll()) do
		if self:IsValidTarget( target ) then
			if !nz.Config.NavGroupTargeting or nz.Nav.Functions.IsInSameNavGroup(target, self) then
				local dist = target:NearestPoint(pos):Distance(pos)
				if ((dist < min_dist||min_dist==-1)) then
					closest_target = target
					min_dist = dist
				end
			end
		end
	end

	return closest_target
end

function ENT:ChaseTarget( options )

	local options = options or {}

	if !options.target then
		options.target = self:GetTarget()
	end

	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( options.lookahead or 300 )
	path:SetGoalTolerance( options.tolerance or 50 )

	--Custom path computer, the same as default but not pathing through locked nav areas.
	path:Compute( self, options.target:GetPos(), function( area, fromArea, ladder, elevator, length )
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
					if !nz.Doors.Data.OpenedLinks[nz.Nav.Data[area:GetID()].link] then
						--print("Door link is not opened")
						return -1
					end
				elseif nz.Nav.Data[area:GetID()].locked then
					--print("Area is locked")
				return -1 end
			end
			--compute distance traveled along path so far
			local dist = 0
			if ( IsValid( ladder ) ) then
				dist = ladder:GetLength()
			elseif ( length > 0 ) then
				--optimization to avoid recomputing length
				dist = length
			else
				dist = ( area:GetCenter() - fromArea:GetCenter() ):GetLength()
			end
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
				local jumpPenalty = 0
				cost = cost + jumpPenalty * dist
			elseif ( deltaZ < -self.loco:GetDeathDropHeight() ) then
				--too far to drop
				return -1
			end
			return cost
		end
	end)
	if ( !path:IsValid() ) then return "failed" end
	while ( path:IsValid() and self:HasTarget() and !self:TargetInAttackRange() ) do
		--Timeout the pathing so it will rerun the entire behaviour (break barricades etc)
		if ( path:GetAge() > options.maxage ) then
			return "timeout"
		end
		path:Update( self )	-- This function moves the bot along the path
		if ( options.draw ) then
			path:Draw()
		end
		--the jumping part simple and buggy
		--local scanDist = (self.loco:GetVelocity():Length()^2)/(2*900) + 15
		local scanDist
		--this will probaly need asjustments to fit the zombies speed
		if self:GetVelocity():Length2D() > 150 then scanDist = 30 else scanDist = 20 end
		--debugoverlay.Line( self:GetPos(),  path:GetClosestPosition(self:EyePos() + self:EyeAngles():Forward() * scanDist), 0.1, Color(255,0,0,0), true )
		--debugoverlay.Line( self:GetPos(),  path:GetPositionOnPath(path:GetCursorPosition() + scanDist), 0.1, Color(0,255,0,0), true )
		--local goal = path:GetCurrentGoal()
		if path:IsValid() and math.abs(self:GetPos().z - path:GetClosestPosition(self:EyePos() + self:EyeAngles():Forward() * scanDist).z) > 22 then
			self:Jump(path:GetClosestPosition(self:EyePos() + self:EyeAngles():Forward() * scanDist), scanDist)
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
			self.loco:SetVelocity( self.loco:GetVelocity() + VectorRand() * 100 )
		end

		coroutine.yield()

	end

	return "ok"

end

function ENT:GetLadderTop( ladder )
	return ladder:GetTopForwardArea() or ladder:GetTopBehindArea() or ladder:GetTopRightArea() or ladder:GetTopLeftArea()
end

function ENT:TargetInAttackRange()
	return self:TargetInRange( self:GetAttackRange() )
end

function ENT:TargetInRange( range )
	return self:GetRangeTo( self:GetTarget():GetPos() ) < range
end

function ENT:CheckForBarricade()
	--we try a line trace first since its more efficient
	local dataL = {}
	dataL.start = self:GetPos() + Vector( 0, 0, self:OBBCenter().z )
	dataL.endpos = self:GetPos() + Vector( 0, 0, self:OBBCenter().z ) + self:GetForward()*64
	dataL.filter = self
	dataL.ignoreworld = true
	local trL = util.TraceLine( dataL )
	if IsValid( trL.Entity ) and trL.Entity:GetClass() == "breakable_entry" then
		return trL.Entity
	end

	--perform a hull trace if line didnt hit just to make sure
	local dataH = {}
	dataH.start = self:GetPos()
	dataH.endpos = self:GetPos() + self:GetForward()*64
	dataH.filter = self
	dataH.mins = self:OBBMins() * 0.65
	dataH.maxs = self:OBBMaxs() * 0.65
	local trH = util.TraceHull(dataH )
	if IsValid( trH.Entity ) and trH.Entity:GetClass() == "breakable_entry" then
		return trH.Entity
	end

	return nil

end

--A standart attack you can use it or create soemthing fancy urself
function ENT:Attack( data )
	data = data or {}
	data.attackseq = data.attackseq or self.AttackSequences[ math.random( #self.AttackSequences ) ] or "swing"
	data.attacksound = data.attacksound or self.AttackSounds[ math.random( #self.AttackSounds) ] or Sound( "npc/vort/claw_swing1.wav" )
	data.hitsound = data.hitsound or self.AttackHitSounds[ math.random( #self.AttackHitSounds ) ]Sound( "npc/zombie/zombie_hit.wav" )
	data.viewpunch = data.viewpunch or VectorRand():Angle() * 0.05
	data.dmglow = data.dmglow or self.DamageLow or 50
	data.dmghigh = data.dmghigh or self.DamageHigh or 70
	data.dmgtype = data.dmgtype or DMG_CLUB
	data.dmgforce = data.dmgforce or self:GetTarget():GetAimVector() * -300 + Vector( 0, 0, 16 )
	local seq, dur = self:LookupSequence( data.attackseq )
	data.attackdur = (seq != - 1 and dur) or 0.6
	data.dmgdelay = ( ( data.attackdur != 0 ) and data.attackdur / 2 ) or 0.3

	self:EmitSound("npc/zombie_poison/pz_throw2.wav", 50, math.random(75, 125)) -- whatever this is!? i will keep it for now

	self:SetAttacking( true )

	self:TimedEvent(0.1, function()
		self:EmitSound( data.attacksound )
	end)

	self:TimedEvent( data.dmgdelay, function()
		if self:IsValidTarget( self:GetTarget() ) and self:TargetInRange( self:GetAttackRange() + 10 ) then
			local dmgInfo = DamageInfo()
				dmgInfo:SetAttacker( self )
				dmgInfo:SetDamage( math.random( data.dmglow, data.dmghigh ) )
				dmgInfo:SetDamageType( data.dmgtype )
				dmgInfo:SetDamageForce( data.dmgforce )
			self:GetTarget():TakeDamageInfo(dmgInfo)
			self:GetTarget():EmitSound( data.hitsound, 50, math.random( 80, 160 ) )
			self:GetTarget():ViewPunch( data.viewpunch )
			self:GetTarget():SetVelocity( data.dmgforce )
		end
	end)

	self:TimedEvent( data.dmgdelay + 0.05, function()
		if (IsValid(target) and !target:Alive()) then
			self:RemoveTarget()
		end
	end)

	self:TimedEvent( data.attackdur, function()
		self:SetAttacking( false )
	end)

	self:PlaySequenceAndWait( data.attackseq, 1)
end

--we do our own jump since the loco one is a bit weird.
function ENT:Jump()
	if CurTime() < self:GetLastJump() + 2 or navmesh.GetNavArea(self:GetPos(), 50):HasAttributes( NAV_MESH_NO_JUMP ) then return end
	if !self:IsOnGround() then return end
	self.loco:SetDesiredSpeed( 450 )
	self.loco:SetAcceleration( 5000 )
	self:SetLastJump( CurTime() )
	self:SetJumping( true )
	--self:SetSolidMask( MASK_NPCSOLID_BRUSHONLY )
	self.loco:Jump()
	--Boost them
	--self.loco:SetVelocity( self:GetForward()*5 )
end

function ENT:Flames( state )
	if state then
		self.FlamesEnt = ents.Create("env_fire")
		if IsValid( self.FlamesEnt ) then
			self.FlamesEnt:SetParent(self, 2)
			self.FlamesEnt:SetOwner(self)
			self.FlamesEnt:SetPos(self:GetPos()-Vector(0,0,-50))
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
					for _, ply in pairs( player.GetAll() ) do
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

	if ( len2d > 150 ) then self.CalcIdeal = ACT_RUN elseif ( len2d > 5 ) then self.CalcIdeal = ACT_WALK end

	if self:IsJumping() && self:WaterLevel() <= 0 then
		self.CalcIdeal = ACT_JUMP
	end

	if self:GetActivity() != self.CalcIdeal && !self:IsAttacking() then self:StartActivity(self.CalcIdeal) end

	if ( self.CalcIdeal == ACT_RUN || self.CalcIdeal == ACT_WALK ) then

		self:BodyMoveXY()

	end

	self:FrameAdvance()

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
		if IsValid(v) and (!nz.Config.NavGroupTargeting or nz.Nav.Functions.IsInSameNavGroup(self, v)) then
			local dist = self:GetRangeTo( v:GetPos() )
			if ((dist < min_dist||min_dist==-1)) then
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
		return true
	end
	return false
end

function ENT:RespawnAtSpawnpoint( ent )
	--if ent:GetClass() != "zed_spawns" then return end
	if nz.Enemies.Functions.CheckIfSuitable( ent:GetPos() ) then
		self:SetPos( ent:GetPos() )
		return true
	end
	return false
end

function ENT:RespawnAtRandom( cur )
	local valids = nz.Enemies.Functions.ValidRespawns( cur )
	if valids[1] == nil then
		print("No valid spawns were found - Couldn't respawn!")
		return
	end
	local spawnpoint = table.Random(valids)
	if nz.Enemies.Functions.CheckIfSuitable(spawnpoint:GetPos()) then
		self:SetPos(spawnpoint:GetPos())
		return true
	end
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

--Targets
function ENT:HasTarget()
	return IsValid( self:GetTarget() ) and self:GetTarget():IsPlayer() and self:GetTarget():Alive() and self:GetTarget():GetNotDowned()
end

function ENT:GetTarget()
	return self.Target
end

function ENT:SetTarget( target )
	self.Target = target
end

function ENT:IsTarget( ent )
	return self.Target == ent
end

function ENT:RemoveTarget()
	self:SetTarget( nil )
end

function ENT:IsValidTarget( ent )
	return IsValid( ent ) and ent:IsPlayer() and ent:Alive() and ent:GetNotDowned() and (!ent.vulturegas or ent.vulturegas < CurTime())
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

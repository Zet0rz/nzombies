AddCSLuaFile()

ENT.Base = "nz_zombiebase"
ENT.PrintName = "Panzersoldat"
ENT.Category = "Brainz"
ENT.Author = "Zet0r"

ENT.Models = { "models/nz_zombie/zombie_panzersoldat.mdl" }

ENT.AttackRange = 80
ENT.DamageLow = 90
ENT.DamageHigh = 180

ENT.RedEyes = true

ENT.AttackSequences = {
	{seq = "nz_melee1"},
	{seq = "nz_melee2"},
}

ENT.DeathSequences = {
	"nz_death",
}

ENT.AttackSounds = {
	"nz/panzer/attack/mech_swing_00.wav",
	"nz/panzer/attack/mech_swing_01.wav",
	"nz/panzer/attack/mech_swing_02.wav",
}

ENT.AttackHitSounds = {
	"nz/panzer/attack/mech_swing_00.wav",
	"nz/panzer/attack/mech_swing_01.wav",
	"nz/panzer/attack/mech_swing_02.wav",
}

ENT.WalkSounds = {
	"nz/panzer/ambient/mech_ambi_00.wav",
	"nz/panzer/ambient/mech_ambi_01.wav",
	"nz/panzer/ambient/mech_ambi_02.wav",
}

ENT.ActStages = {
	[1] = {
		act = ACT_WALK,
		minspeed = 5,
	},
	[2] = {
		act = ACT_WALK_ANGRY,
		minspeed = 50,
	},
	[3] = {
		act = ACT_RUN,
		minspeed = 150,
	},
	[4] = {
		act = ACT_RUN,
		minspeed = 160,
	},
}

-- We overwrite the Init function because we do not change bodygroups randomly!
function ENT:Initialize()

	self:Precache()

	self:SetModel( self.Models[math.random( #self.Models )] )

	self:SetJumping( false )
	self:SetLastLand( CurTime() + 1 ) --prevent jumping after spawn
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

	--target ignore
	self:ResetIgnores()

	self:SetHealth( 75 ) --fallback

	self:SetRunSpeed( self.RunSpeed ) --fallback
	self:SetWalkSpeed( self.WalkSpeed ) --fallback

	self:SetCollisionBounds(Vector(-16,-16, 0), Vector(16, 16, 70))

	self:SetActStage(0)
	self:SetSpecialAnimation(false)

	self:StatsInitialize()
	self:SpecialInit()
	
	-- Fallback for buggy tool
	if !self:GetRunSpeed() then self:SetRunSpeed(150) end

	if SERVER then
		self.loco:SetDeathDropHeight( self.DeathDropHeight )
		self.loco:SetDesiredSpeed( self:GetRunSpeed() )
		self.loco:SetAcceleration( self.Acceleration )
		self.loco:SetJumpHeight( self.JumpHeight )
		if GetConVar("nz_zombie_lagcompensated"):GetBool() then
			self:SetLagCompensated(true)
		end
		
		self.HelmetDamage = 0 -- Used to save how much damage the light has taken
		self:SetUsingClaw(false)
		
		self.NextAction = 0
		self.NextClawTime = 0
		self.NextFlameTime = 0
	end

end

function ENT:StatsInitialize()
	if SERVER then
		self:SetRunSpeed(150)
		self:SetHealth(1000)
		self:SetMaxHealth(1000)
	end
	self:SetCollisionBounds(Vector(-20,-20, 0), Vector(20, 20, 100))

	--PrintTable(self:GetSequenceList())
end

function ENT:SpecialInit()

	if CLIENT then
		--make them invisible for a really short duration to blend the emerge sequences
		self:SetNoDraw(true)
		self:TimedEvent( 0.15, function()
			self:SetNoDraw(false)
		end)

		self:SetRenderClipPlaneEnabled( true )
		self:SetRenderClipPlane(self:GetUp(), self:GetUp():Dot(self:GetPos()))

		self:TimedEvent( 2, function()
			self:SetRenderClipPlaneEnabled(false)
		end)

	end
end

function ENT:InitDataTables()
	self:NetworkVar("Entity", 0, "ClawHook")
	self:NetworkVar("Bool", 1, "UsingClaw")
	self:NetworkVar("Bool", 2, "Flamethrowing")
end

function ENT:OnSpawn()
	local seq = "nz_entry"
	local tr = util.TraceLine({
		start = self:GetPos() + Vector(0,0,500),
		endpos = self:GetPos(),
		filter = self,
		mask = MASK_SOLID_BRUSHONLY,
	})
	if tr.Hit then seq = "nz_entry_instant" end
	local _, dur = self:LookupSequence(seq)

	-- play emerge animation on spawn
	-- if we have a coroutine else just spawn the zombie without emerging for now.
	if coroutine.running() then
		
		local pos = self:GetPos() + (seq == "nz_entry_instant" and Vector(0,0,100) or Vector(0,0,450))
		
		local effectData = EffectData()
		effectData:SetStart( pos )
		effectData:SetOrigin( pos )
		effectData:SetMagnitude(dur)
		util.Effect("panzer_spawn_tp", effectData)
		
		--[[effectData = EffectData()
		effectData:SetStart( pos + Vector(0, 0, 1000) )
		effectData:SetOrigin( pos )
		effectData:SetMagnitude( 0.75 )
		util.Effect("lightning_strike", effectData)]]
		
		self:TimedEvent(dur - 2.1, function()
			--dust cloud
			local effectData = EffectData()
			effectData:SetStart( self:GetPos() )
			effectData:SetOrigin( self:GetPos() )
			effectData:SetMagnitude(dur)
			util.Effect("panzer_land_dust", effectData)
		end)
		self:PlaySequenceAndWait(seq)
	end
end

function ENT:OnZombieDeath(dmgInfo)

	self:ReleasePlayer()
	self:StopFlames()
	self:SetRunSpeed(0)
	self.loco:SetVelocity(Vector(0,0,0))
	self:Stop()
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	local seq, dur = self:LookupSequence(self.DeathSequences[math.random(#self.DeathSequences)])
	self:ResetSequence(seq)
	self:SetCycle(0)

	timer.Simple(dur - 0.5, function()
		if IsValid(self) then
			self:EmitSound("nz/panzer/mech_explode.wav")
		end
	end)
	timer.Simple(dur, function()
		if IsValid(self) then
			self:Remove()
			local effectData = EffectData()
			effectData:SetStart( self:GetPos() )
			effectData:SetOrigin( self:GetPos() )
			effectData:SetMagnitude(2)
			util.Effect("Explosion", effectData)
		end
	end)

end

function ENT:Attack( data )

	self:SetLastAttack(CurTime())

	--if self:Health() <= 0 then coroutine.yield() return end

	data = data or {}
	data.attackseq = data.attackseq or self.AttackSequences[ math.random( #self.AttackSequences ) ].seq or "swing"
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

	self:TimedEvent(0.4, function()
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
			if self:GetTarget().ViewPunch then
				self:GetTarget():ViewPunch( data.viewpunch )
			end
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

function ENT:BodyUpdate()

	self.CalcIdeal = ACT_IDLE

	local velocity = self:GetVelocity()

	local len2d = velocity:Length2D()

	if ( len2d > 60 ) then self.CalcIdeal = ACT_RUN elseif ( len2d > 5 ) then self.CalcIdeal = ACT_WALK end

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

function ENT:OnTargetInAttackRange()
    local atkData = {}
    atkData.dmglow = 90
    atkData.dmghigh = 180
    atkData.dmgforce = Vector( 0, 0, 0 )
	atkData.dmgdelay = 0.6
    self:Attack( atkData )
end

function ENT:IsValidTarget( ent )
	if !ent then return false end
	return IsValid( ent ) and ent:GetTargetPriority() != TARGET_PRIORITY_NONE and ent:GetTargetPriority() != TARGET_PRIORITY_SPECIAL
	-- Won't go for special targets (Monkeys), but still MAX, ALWAYS and so on
end

-- This function is run every time a path times out, once every 1 seconds of pathing
function ENT:OnPathTimeOut()
	local target = self:GetTarget()
	if CurTime() < self.NextAction then return end
	
	if math.random(0,5) == 0 and CurTime() > self.NextClawTime then
		-- Claw
		if self:IsValidTarget(target) then
			local tr = util.TraceLine({
				start = self:GetPos() + Vector(0,50,0),
				endpos = target:GetPos() + Vector(0,0,50),
				filter = self,
			})
			
			if IsValid(tr.Entity) and self:IsValidTarget(tr.Entity) and !IsValid(self.ClawHook) then
				self:Stop()
				self:PlaySequenceAndWait("nz_grapple_aim")
				self.loco:SetDesiredSpeed(0)
				--self:SetSequence(self:LookupSequence("nz_grapple_loop"))
				self:SetBodygroup(2, 1)
				
				local clawpos = self:GetAttachment(self:LookupAttachment("clawlight")).Pos
				self.ClawHook = ents.Create("nz_panzer_claw")
				self.ClawHook:SetPos(clawpos)
				self.ClawHook:Spawn()
				self.ClawHook:Launch(((tr.Entity:GetPos() + Vector(0,0,50)) - self.ClawHook:GetPos()):GetNormalized())
				self:SetClawHook(self.ClawHook)
				self:SetUsingClaw(true)
				self.ClawHook:SetPanzer(self)
				self:SetAngles((target:GetPos() - self:GetPos()):Angle())
				
				self.NextAction = CurTime() + math.random(1, 5)
				self.NextClawTime = CurTime() + math.random(3, 15)
			end
		end
	elseif CurTime() > self.NextFlameTime then
		-- Flamethrower
		if self:IsValidTarget(target) and self:GetPos():DistToSqr(target:GetPos()) <= 75000 then	
			self:Stop()
			self:PlaySequenceAndWait("nz_flamethrower_aim")
			self.loco:SetDesiredSpeed(0)
			local ang = (target:GetPos() - self:GetPos()):Angle()
			self:SetAngles(Angle(ang[1], ang[2] + 10, ang[3]))
			
			self:StartFlames()
			local seq = math.random(0,1) == 0 and "nz_flamethrower_loop" or "nz_flamethrower_sweep"
			local id, dur = self:LookupSequence(seq)
			self:ResetSequence(id)
			self:SetCycle(0)
			self:SetPlaybackRate(1)
			self:SetVelocity(Vector(0,0,0))
			
			self:TimedEvent(dur, function()
				self.loco:SetDesiredSpeed(self:GetRunSpeed())
				self:SetSpecialAnimation(false)
				self:SetBlockAttack(false)
				self:StopFlames()
			end)
			
			self.NextAction = CurTime() + math.random(1, 5)
			self.NextFlameTime = CurTime() + math.random(1, 10)
		end
	end
end

if CLIENT then
	local eyeGlow =  Material( "sprites/redglow1" )
	local white = Color( 255, 255, 255, 255 )
	local lightglow = Material( "sprites/physg_glow1_noz" )
	local lightyellow = Color( 255, 255, 200, 200 )
	local clawglow = Material( "sprites/orangecore1" )
	local clawred = Color( 255, 100, 100, 255 )
	function ENT:Draw()
		self:DrawModel()
		
		local dlight = DynamicLight( self:EntIndex() )
		if ( dlight ) then
			local bone = self:LookupBone("j_spinelower")
			local pos, ang = self:GetBonePosition(bone)
			pos = pos + ang:Right()*-8 + ang:Forward()*25
			dlight.pos = pos
			dlight.r = 255
			dlight.g = 255
			dlight.b = 255
			dlight.brightness = 10
			dlight.Decay = 1000
			dlight.Size = 16
			dlight.DieTime = CurTime() + 1
			dlight.dir = ang:Right() + ang:Forward()
			dlight.innerangle = 1
			dlight.outerangle = 1
			dlight.style = 0
			dlight.noworld = true
		end
		
		if self.RedEyes then
			--local eyes = self:GetAttachment(self:LookupAttachment("eyes")).Pos
			--local leftEye = eyes + self:GetRight() * -1.5 + self:GetForward() * 0.5
			--local rightEye = eyes + self:GetRight() * 1.5 + self:GetForward() * 0.5

			local leftEye = self:GetAttachment(self:LookupAttachment("lefteye")).Pos
			local rightEye = self:GetAttachment(self:LookupAttachment("righteye")).Pos
			cam.Start3D()
				render.SetMaterial( eyeGlow )
				render.DrawSprite( leftEye, 4, 4, white)
				render.DrawSprite( rightEye, 4, 4, white)
			cam.End3D()
		end
		if GetConVar( "nz_zombie_debug" ):GetBool() then
			render.DrawWireframeBox(self:GetPos(), Angle(0,0,0), self:OBBMins(), self:OBBMaxs(), Color(255,0,0), true)
			render.DrawWireframeSphere(self:GetPos(), self:GetAttackRange(), 10, 10, Color(255,165,0), true)
		end
		
		--debugoverlay.Cross(finalpos, 5)
		--debugoverlay.Line(finalpos, finalpos + ang:Forward()*10, 1, Color(0,255,0))
		--debugoverlay.Line(finalpos, finalpos + ang:Right()*5, 1, Color(0,255,0))
		if self:GetBodygroup(1) == 0 then
			local bone = self:LookupBone("j_helmet")
			local pos, ang = self:GetBonePosition(bone)
			local finalpos = pos + ang:Forward()*20 + ang:Up()*10
		
			cam.Start3D2D(finalpos, ang, 1)
				surface.SetMaterial(lightglow)
				surface.SetDrawColor(lightyellow)
				surface.DrawTexturedRect(-50,-10,100,20)
			cam.End3D2D()
			
			ang:RotateAroundAxis(ang:Forward(),90)
			
			--debugoverlay.Line(finalpos, finalpos + ang:Forward()*15, 1, Color(255,0,0))
			--debugoverlay.Line(finalpos, finalpos + ang:Right()*5, 1, Color(255,0,0))
		
			cam.Start3D2D(finalpos, ang, 1)
				surface.SetMaterial(lightglow)
				surface.SetDrawColor(lightyellow)
				surface.DrawTexturedRect(-50,-10,100,20)
			cam.End3D2D()
		end
		
		if self:GetBodygroup(2) == 1 then
			local att = self:GetAttachment(self:LookupAttachment("clawlight"))
			local pos, ang = att.Pos, att.Ang
			ang:RotateAroundAxis(ang:Right(),-90)
			
			--debugoverlay.Line(pos, pos + ang:Forward()*10, 1, Color(0,255,0))
			--debugoverlay.Line(pos, pos + ang:Right()*5, 1, Color(0,255,0))
			
			cam.Start3D2D(pos, ang, 1)
				surface.SetMaterial(clawglow)
				surface.SetDrawColor(clawred)
				surface.DrawTexturedRect(-5,-5,10,10)
			cam.End3D2D()
		end
		
	end
end

function ENT:OnInjured( dmgInfo )
	local hitpos = dmgInfo:GetDamagePosition()
	
	if !self.HelmetLost then
		local bone = self:LookupBone("j_helmet")
		local pos, ang = self:GetBonePosition(bone)
		local finalpos = pos + ang:Forward()*8 + ang:Up()*11
		
		if hitpos:DistToSqr(finalpos) < 50 then
			self.HelmetDamage = self.HelmetDamage + dmgInfo:GetDamage()
			if self.HelmetDamage > (self:GetMaxHealth() * 0.01) then
				self.HelmetLost = true
				self:ManipulateBonePosition(bone, Vector(0,0,-75))
				self:SetBodygroup(1, 1)
				self:SetSpecialAnimation(true)
				self:SetBlockAttack(true)
				self:ReleasePlayer()
				self:StopFlames()
				local id, dur = self:LookupSequence("nz_crit_head")
				self:ResetSequence(id)
				self:SetCycle(0)
				self:SetPlaybackRate(1)
				self.loco:SetDesiredSpeed(0)
				self:SetVelocity(Vector(0,0,0))
				self:TimedEvent(dur, function()
					self.loco:SetDesiredSpeed(self:GetRunSpeed())
					self:SetSpecialAnimation(false)
					self:SetBlockAttack(false)
				end)
			end
		end
		
		dmgInfo:ScaleDamage(0.1) -- When the helmet isn't lost, all damage only deals 10%
	else
		local bone = self:LookupBone("j_head")
		local pos, ang = self:GetBonePosition(bone)
		local finalpos = pos + ang:Up()*4
		
		if hitpos:DistToSqr(finalpos) < 150 then
			-- No damage scaling on headshot, we keep it at 1x
		else
			dmgInfo:ScaleDamage(0.1) -- When the helmet is lost, a non-headshot still only deals 10%
		end
	end
	
	if self:GetUsingClaw() then
		local pos = self:GetAttachment(self:LookupAttachment("clawlight")).Pos
		if hitpos:DistToSqr(pos) <= 25 then
			self:SetSpecialAnimation(true)
			self:SetBlockAttack(true)
			self:ReleasePlayer()
			self:StopFlames()
			local id, dur = self:LookupSequence("nz_crit_grapple")
			self:ResetSequence(id)
			self:SetCycle(0)
			self:SetPlaybackRate(1)
			self.loco:SetDesiredSpeed(0)
			self:SetVelocity(Vector(0,0,0))
			self:TimedEvent(dur, function()
				self.loco:SetDesiredSpeed(self:GetRunSpeed())
				self:SetSpecialAnimation(false)
				self:SetBlockAttack(false)
			end)
		end
	end
end

function ENT:OnRemove()
	if IsValid(self.ClawHook) then self.ClawHook:Remove() end
	if IsValid(self.GrabbedPlayer) then self.GrabbedPlayer:SetMoveType(MOVETYPE_WALK) end
	if self.FireEmitter then self.FireEmitter:Finish() end
end

function ENT:StartFlames(time)
	self:Stop()
	self:SetFlamethrowing(true)
	
	if time then self:TimedEvent(time, function() self:StopFlames() end) end
end

function ENT:StopFlames()
	self:SetFlamethrowing(false)
	self:SetStop(false)
end

function ENT:OnThink()
	if self:GetFlamethrowing() then
		if !self.NextFireParticle or self.NextFireParticle < CurTime() then
			local bone = self:LookupBone("j_elbow_ri")
			local pos, ang = self:GetBonePosition(bone)
			pos = pos - ang:Forward() * 40 - ang:Up()*10
			if CLIENT then
				if !IsValid(self.FireEmitter) then self.FireEmitter = ParticleEmitter(self:GetPos(), false) end
				
				local p = self.FireEmitter:Add("particles/fire1.vmt", pos)
				if p then
					p:SetColor(math.random(30,60), math.random(40,70), math.random(0,50))
					p:SetStartAlpha(255)
					p:SetEndAlpha(0)
					p:SetVelocity(ang:Forward() * -150 + ang:Up()*math.random(-5,5) + ang:Right()*math.random(-5,5))
					p:SetLifeTime(0.25)

					p:SetDieTime(math.Rand(0.75, 1.5))

					p:SetStartSize(math.random(1, 5))
					p:SetEndSize(math.random(20, 30))
					p:SetRoll(math.random(-180, 180))
					p:SetRollDelta(math.Rand(-0.1, 0.1))
					p:SetAirResistance(50)

					p:SetCollide(false)

					p:SetLighting(false)
				end
			else
				if IsValid(self.GrabbedPlayer) then
					if self.GrabbedPlayer:GetPos():DistToSqr(self:GetPos()) > 10000 then
						self:ReleasePlayer()
						self:StopFlames()
						self.loco:SetDesiredSpeed(self:GetRunSpeed())
						self:SetSpecialAnimation(false)
						self:SetBlockAttack(false)
						self:SetStop(false)
					else
						local dmg = DamageInfo()
						dmg:SetAttacker(self)
						dmg:SetInflictor(self)
						dmg:SetDamage(2)
						dmg:SetDamageType(DMG_BURN)
						
						self.GrabbedPlayer:TakeDamageInfo(dmg)
						self.GrabbedPlayer:Ignite(1, 0)
					end
				else
					local tr = util.TraceHull({
						start = pos,
						endpos = pos - ang:Forward()*150,
						filter = self,
						--mask = MASK_SHOT,
						mins = Vector( -5, -5, -10 ),
						maxs = Vector( 5, 5, 10 ),
					})
					
					debugoverlay.Line(pos, pos - ang:Forward()*150)
					
					if self:IsValidTarget(tr.Entity) then
						local dmg = DamageInfo()
						dmg:SetAttacker(self)
						dmg:SetInflictor(self)
						dmg:SetDamage(2)
						dmg:SetDamageType(DMG_BURN)
						
						tr.Entity:TakeDamageInfo(dmg)
						tr.Entity:Ignite(2, 0)
					end
				end
			end
			
			self.NextFireParticle = CurTime() + 0.05
		end
	elseif CLIENT and self.FireEmitter then
		self.FireEmitter:Finish()
		self.FireEmitter = nil
	end
	
	if SERVER and IsValid(self.GrabbedPlayer) and !self:IsValidTarget(self.GrabbedPlayer) then
		self:ReleasePlayer()
		self:StopFlames()
	end
end

function ENT:GrabPlayer(ply)
	if CLIENT then return end
	
	self:SetBodygroup(2,0)
	self:SetUsingClaw(false)
	
	if self:IsValidTarget(ply) then
		self.GrabbedPlayer = ply
		
		self:TimedEvent(0, function()
			local att = self:GetAttachment(self:LookupAttachment("clawlight"))
			local pos = att.Pos + att.Ang:Forward()*10
			
			ply:SetPos(pos - Vector(0,0,50))
			ply:SetMoveType(MOVETYPE_NONE)
		end)
		
		
		self:SetSequence(self:LookupSequence("nz_grapple_flamethrower"))
		self:SetCycle(0)
		self:StartFlames()
	else
		self.loco:SetDesiredSpeed(self:GetRunSpeed())
		self:SetSpecialAnimation(false)
		self:SetBlockAttack(false)
		self:SetStop(false)
	end
end

function ENT:ReleasePlayer()
	if IsValid(self.GrabbedPlayer) then
		self.GrabbedPlayer:SetMoveType(MOVETYPE_WALK)
	end
	if IsValid(self.ClawHook) then
		self.ClawHook:Release()
	end
	if !self:GetFlamethrowing() then
		self:SetStop(false)
	end
	self:SetUsingClaw(false)
end
AddCSLuaFile()

ENT.Base = "nz_zombiebase"
ENT.PrintName = "Walker"
ENT.Category = "Brainz"
ENT.Author = "Lolle"

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "EmergeSequenceIndex")
end

ENT.Models = {
	"models/nz_zombie/zombie_rerig_animated.mdl",
}

ENT.AttackSequences = {
	{seq = "nz_stand_attack1", dmgtimes = {1, 1.5}},
	{seq = "nz_stand_attack2", dmgtimes = {0.4}},
	{seq = "nz_stand_attack3", dmgtimes = {1}},
	{seq = "nz_stand_attack4", dmgtimes = {0.4, 0.8}},
}
ENT.WalkAttackSequences = {
	{seq = "nz_walk_attack1", dmgtimes = {0.3}},
	{seq = "nz_walk_attack2", dmgtimes = {0.4, 1}},
	{seq = "nz_walk_attack3", dmgtimes = {0.6}},
	{seq = "nz_walk_attack4", dmgtimes = {0.4, 0.9}},
}
ENT.RunAttackSequences = {
	{seq = "nz_run_attack1", dmgtimes = {0.4}},
	{seq = "nz_run_attack2", dmgtimes = {0.3, 0.8}},
	{seq = "nz_run_attack3", dmgtimes = {0.3, 0.7}},
	{seq = "nz_run_attack4", dmgtimes = {0.4, 0.9}},
}

ENT.ActStages = {
	[1] = {
		act = ACT_WALK,
		minspeed = 5,
		attackanims = "AttackSequences",
		sounds = "WalkSounds",
		barricadejumps = "JumpSequences",
	},
	[2] = {
		act = ACT_WALK_ANGRY,
		minspeed = 40,
		attackanims = "WalkAttackSequences",
		sounds = "WalkSounds",
		barricadejumps = "JumpSequences",
	},
	[3] = {
		act = ACT_RUN,
		minspeed = 100,
		attackanims = "RunAttackSequences",
		sounds = "RunSounds",
		barricadejumps = "SprintJumpSequences",
	},
	[4] = {
		act = ACT_SPRINT,
		minspeed = 160,
		attackanims = "RunAttackSequences",
		sounds = "RunSounds",
		barricadejumps = "SprintJumpSequences",
	},
}

ENT.RedEyes = true

ENT.ElectrocutionSequences = {
	"nz_electrocuted1",
	"nz_electrocuted2",
	"nz_electrocuted3",
	"nz_electrocuted4",
	"nz_electrocuted5",
}
ENT.EmergeSequences = {
	"nz_emerge1",
	"nz_emerge2",
	"nz_emerge3",
	"nz_emerge4",
	"nz_emerge5",
}
ENT.JumpSequences = {
	{seq = "nz_barricade1", speed = 15, time = 2.7},
	{seq = "nz_barricade2", speed = 15, time = 2.4},
	{seq = "nz_barricade_fast1", speed = 15, time = 1.8},
	{seq = "nz_barricade_fast2", speed = 35, time = 4},
}
ENT.SprintJumpSequences = {
	{seq = "nz_barricade_sprint1", speed = 50, time = 1.9},
	{seq = "nz_barricade_sprint2", speed = 35, time = 1.9},
}

ENT.AttackSounds = {
	"nz/zombies/attack/attack_00.wav",
	"nz/zombies/attack/attack_01.wav",
	"nz/zombies/attack/attack_02.wav",
	"nz/zombies/attack/attack_03.wav",
	"nz/zombies/attack/attack_04.wav",
	"nz/zombies/attack/attack_05.wav",
	"nz/zombies/attack/attack_06.wav",
	"nz/zombies/attack/attack_07.wav",
	"nz/zombies/attack/attack_08.wav",
	"nz/zombies/attack/attack_09.wav",
	"nz/zombies/attack/attack_10.wav",
	"nz/zombies/attack/attack_11.wav",
	"nz/zombies/attack/attack_12.wav",
	"nz/zombies/attack/attack_13.wav",
	"nz/zombies/attack/attack_14.wav",
	"nz/zombies/attack/attack_15.wav",
	"nz/zombies/attack/attack_16.wav",
	"nz/zombies/attack/attack_17.wav",
	"nz/zombies/attack/attack_18.wav",
	"nz/zombies/attack/attack_19.wav",
	"nz/zombies/attack/attack_20.wav",
	"nz/zombies/attack/attack_21.wav",
	"nz/zombies/attack/attack_22.wav",
}
ENT.AttackHitSounds = {
	"npc/zombie/zombie_hit.wav"
}
ENT.PainSounds = {
	"physics/flesh/flesh_impact_bullet1.wav",
	"physics/flesh/flesh_impact_bullet2.wav",
	"physics/flesh/flesh_impact_bullet3.wav",
	"physics/flesh/flesh_impact_bullet4.wav",
	"physics/flesh/flesh_impact_bullet5.wav"
}
ENT.DeathSounds = {
	"nz/zombies/death/death_00.wav",
	"nz/zombies/death/death_01.wav",
	"nz/zombies/death/death_02.wav",
	"nz/zombies/death/death_03.wav",
	"nz/zombies/death/death_04.wav",
	"nz/zombies/death/death_05.wav",
	"nz/zombies/death/death_06.wav",
	"nz/zombies/death/death_07.wav",
	"nz/zombies/death/death_08.wav",
	"nz/zombies/death/death_09.wav",
	"nz/zombies/death/death_10.wav"
}
ENT.WalkSounds = {
	"nz/zombies/ambient/ambient_00.wav",
	"nz/zombies/ambient/ambient_01.wav",
	"nz/zombies/ambient/ambient_02.wav",
	"nz/zombies/ambient/ambient_03.wav",
	"nz/zombies/ambient/ambient_04.wav",
	"nz/zombies/ambient/ambient_05.wav",
	"nz/zombies/ambient/ambient_06.wav",
	"nz/zombies/ambient/ambient_07.wav",
	"nz/zombies/ambient/ambient_08.wav",
	"nz/zombies/ambient/ambient_09.wav",
	"nz/zombies/ambient/ambient_10.wav",
	"nz/zombies/ambient/ambient_11.wav",
	"nz/zombies/ambient/ambient_12.wav",
	"nz/zombies/ambient/ambient_13.wav",
	"nz/zombies/ambient/ambient_14.wav",
	"nz/zombies/ambient/ambient_15.wav",
	"nz/zombies/ambient/ambient_16.wav",
	"nz/zombies/ambient/ambient_17.wav",
	"nz/zombies/ambient/ambient_18.wav",
	"nz/zombies/ambient/ambient_19.wav",
	"nz/zombies/ambient/ambient_20.wav"
}

ENT.RunSounds = {
	"nz/zombies/sprint2/sprint0.wav",
	"nz/zombies/sprint2/sprint1.wav",
	"nz/zombies/sprint2/sprint2.wav",
	"nz/zombies/sprint2/sprint3.wav",
	"nz/zombies/sprint2/sprint4.wav",
	"nz/zombies/sprint2/sprint5.wav",
	"nz/zombies/sprint2/sprint6.wav",
	"nz/zombies/sprint2/sprint7.wav",
	"nz/zombies/sprint2/sprint8.wav"
}

function ENT:StatsInitialize()
	if SERVER then
		local speeds = nzRound:GetZombieSpeeds()
		if speeds then
			self:SetRunSpeed( nzMisc.WeightedRandom(speeds) )
		else
			self:SetRunSpeed( 100 )
		end
		self:SetHealth( nzRound:GetZombieHealth() or 75 )

		--Preselect the emerge sequnces for clientside use
		self:SetEmergeSequenceIndex(math.random(#self.EmergeSequences))
	end
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

		--local _, dur = self:LookupSequence(self.EmergeSequences[self:GetEmergeSequenceIndex()])
		local _, dur = self:LookupSequence(self.EmergeSequences[self:GetEmergeSequenceIndex()])

		self:TimedEvent( dur, function()
			self:SetRenderClipPlaneEnabled(false)
		end)

	end
end

function ENT:SoundThink()
	if CurTime() > self:GetNextMoanSound() and !self:GetStop() then
		--local soundName = self:GetActivity() == ACT_RUN and self.RunSounds[ math.random(#self.RunSounds ) ] or self.WalkSounds[ math.random(#self.WalkSounds ) ]
		local soundtbl = self.ActStages[self:GetActStage()] and self[self.ActStages[self:GetActStage()].sounds] or self.WalkSounds
		local soundName = soundtbl[math.random(#soundtbl)]
		self:EmitSound( soundName, 80 )
		local nextSound = SoundDuration( soundName ) + math.random(0,4) + CurTime()
		self:SetNextMoanSound( nextSound )
	end
end

function ENT:OnSpawn()

	local seq = self.EmergeSequences[self:GetEmergeSequenceIndex()]
	local _, dur = self:LookupSequence(seq)

	--dust cloud
	local effectData = EffectData()
	effectData:SetStart( self:GetPos() )
	effectData:SetOrigin( self:GetPos() )
	effectData:SetMagnitude(dur)
	util.Effect("zombie_spawn_dust", effectData)

	-- play emerge animation on spawn
	-- if we have a coroutine else just spawn the zombie without emerging for now.
	if coroutine.running() then
		self:PlaySequenceAndWait(seq)
	end
end

function ENT:OnZombieDeath(dmgInfo)

	if dmgInfo:GetDamageType() == DMG_SHOCK then
		self:SetRunSpeed(0)
		self.loco:SetVelocity(Vector(0,0,0))
		self:Stop()
		local seq, dur = self:LookupSequence(self.ElectrocutionSequences[math.random(#self.ElectrocutionSequences)])
		self:ResetSequence(seq)
		self:SetCycle(0)
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		-- Emit electrocution scream here when added
		timer.Simple(dur, function()
			if IsValid(self) then
				self:BecomeRagdoll(dmgInfo)
			end
		end)
	else
		self:EmitSound( self.DeathSounds[ math.random( #self.DeathSounds ) ], 100)
		self:BecomeRagdoll(dmgInfo)
	end

end

--A standard attack you can use it or create something fancy yourself
function ENT:Attack( data )

	self:SetLastAttack(CurTime())

	--if self:Health() <= 0 then coroutine.yield() return end

	data = data or {}
	local attacktbl = self.ActStages[self:GetActStage()] and self[self.ActStages[self:GetActStage()].attackanims] or self.AttackSequences
	data.attackseq = data.attackseq or attacktbl[math.random(#attacktbl)] or {seq = "swing", dmgtimes = {1}}
	data.attacksound = data.attacksound or self.AttackSounds[ math.random( #self.AttackSounds) ] or Sound( "npc/vort/claw_swing1.wav" )
	data.hitsound = data.hitsound or self.AttackHitSounds[ math.random( #self.AttackHitSounds ) ] or Sound( "npc/zombie/zombie_hit.wav" )
	data.viewpunch = data.viewpunch or VectorRand():Angle() * 0.05
	data.dmglow = data.dmglow or self.DamageLow or 50
	data.dmghigh = data.dmghigh or self.DamageHigh or 70
	data.dmgtype = data.dmgtype or DMG_CLUB
	data.dmgforce = data.dmgforce or (self:GetTarget():GetPos() - self:GetPos()) * 7 + Vector( 0, 0, 16 )
	data.dmgforce.z = math.Clamp(data.dmgforce.z, 1, 16)
	local seq, dur = self:LookupSequence( data.attackseq.seq )
	data.attackdur = (seq != - 1 and dur) or 0.6
	data.dmgdelay = ( ( data.attackdur != 0 ) and data.attackdur / 2 ) or 0.3

	self:EmitSound("npc/zombie_poison/pz_throw2.wav", 50, math.random(75, 125)) -- whatever this is!? I will keep it for now

	self:SetAttacking( true )

	self:TimedEvent(0.1, function()
		self:EmitSound( data.attacksound )
	end)

	if self:GetTarget():IsPlayer() then
		for k,v in pairs(data.attackseq.dmgtimes) do
			self:TimedEvent( v, function()
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
		end
	end

	self:TimedEvent(data.attackdur, function()
		self:SetAttacking(false)
		self:SetLastAttack(CurTime())
	end)

	self:PlayAttackAndWait(data.attackseq.seq, 1)
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

function ENT:TriggerBarricadeJump()
	if !self:GetSpecialAnimation() and (!self.NextBarricade or CurTime() > self.NextBarricade) then
		self:SetSpecialAnimation(true)
		local seqtbl = self.ActStages[self:GetActStage()] and self[self.ActStages[self:GetActStage()].barricadejumps] or self.JumpSequences
		local seq = seqtbl[math.random(#seqtbl)]
		local id, dur = self:LookupSequence(seq.seq)
		self:SetSolidMask(MASK_SOLID_BRUSHONLY)
		self.loco:SetAcceleration( 5000 )
		self.loco:SetDesiredSpeed(seq.speed)
		self:SetVelocity(self:GetForward()*seq.speed)
		self:SetSequence(id)
		self:SetCycle(0)
		self:SetPlaybackRate(1)
		--self:BodyMoveXY()
		--PrintTable(self:GetSequenceInfo(id))
		self:TimedEvent(dur, function()
			self.NextBarricade = CurTime() + 2
			self:SetSpecialAnimation(false)
			self.loco:SetAcceleration( self.Acceleration )
			self.loco:SetDesiredSpeed(self:GetRunSpeed())
			self:UpdateSequence()
		end)
	end
end

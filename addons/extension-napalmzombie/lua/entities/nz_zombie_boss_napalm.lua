if engine.ActiveGamemode() != "nzombies" then return end

AddCSLuaFile()

ENT.Base = "nz_zombiebase"
ENT.PrintName = "Jihadi Zombie"
ENT.Category = "Brainz"
ENT.Author = "Roach"

ENT.Models = {"models/boz/napalm.mdl"}

ENT.AttackRange = 70
ENT.DamageLow = 0
ENT.DamageHigh = 0
ENT.JumpHeight = 22 -- Napalm zombies can't jump, like, at all.

ENT.RedEyes = false -- To my knowledge napalm zombies don't have glowing eyes not counting the embers that surround them.

ENT.AttackSequences = {
	"ALLAHU_ACKBAR"
}

ENT.AttackSounds = {}
ENT.AttackHitSounds = {}
ENT.WalkSounds = {
	"napalm/step1.mp3",
	"napalm/step2.mp3",
	"napalm/step3.mp3",
}

-- ENT.ActStages = {{
	-- act = ACT_WALK,
	-- minspeed = 40,
-- }}

ENT.ActStages = { -- I have no idea how to only do this once and the above one doesn't seem to work soo.
	[1] = {
		act = ACT_WALK,
		minspeed = 40,
	},
	[2] = {
		act = ACT_WALK,
		minspeed = 40,
	}
}

function ENT:StatsInitialize()
	if SERVER then
		self:SetRunSpeed(40)
		self:SetHealth(nzRound:GetZombieHealth() * 5 or 350)
		self:SetEmergeSequenceIndex(math.random(#self.EmergeSequences))
	end
end

function ENT:SpecialInit() -- Just gonna leave this func alone, shit looks tight.
	if CLIENT then
		self:TimedEvent(0, function()
			if string.find(self:GetSequenceName(self:GetSequence()), "emerge") then
				self:SetNoDraw(true)
				self:TimedEvent( 0.15, function()
					self:SetNoDraw(false)
				end)

				self:SetRenderClipPlaneEnabled( true )
				self:SetRenderClipPlane(self:GetUp(), self:GetUp():Dot(self:GetPos()))
				local _, dur = self:LookupSequence(self.EmergeSequences[self:GetEmergeSequenceIndex()])
				dur = dur - (dur * self:GetCycle())
				self:TimedEvent( dur, function()
					self:SetRenderClipPlaneEnabled(false)
				end)
			end
		end)
	end
end

function ENT:SoundThink()
	if CurTime() > self:GetNextMoanSound() and !self:GetStop() then
		self:EmitSound("napalm/amb"..math.random(1,3)..".mp3")
		local nextSound = CurTime() + math.random(3,7)
		self:SetNextMoanSound(nextSound)
	end
end

function ENT:OnSpawn()
	-- play emerge animation on spawn
	-- if we have a coroutine else just spawn the zombie without emerging for now.
	if coroutine.running() then
		self:EmitSound("nap/spawn.mp3",511,100)
		ParticleEffectAttach("fire_large_01",PATTACH_POINT_FOLLOW,self,0)
		self:PlaySequenceAndWait("emerge",0.65)
		self:StopParticles()
	end
	timer.Simple(0.1,function()ParticleEffectAttach("fire_small_03",PATTACH_POINT_FOLLOW,self,1)end)
end

function ENT:OnZombieDeath(dmgInfo)
	self:Explode()
end

function ENT:Attack(data) -- If this isn't called out of a coroutine func it'll probably demolish itself.
	self:SetLastAttack(CurTime())
	data = data or {}

	data.attackseq = "ALLAHU_ACKBAR"
	data.attacksound = "napalm/charge.mp3" -- I don't see the point in wrapping every sound file with Sound( )... It works fine without.
	data.dmgtype = DMG_BLAST
	data.attackdur = 1.7
	data.dmgdelay = 1.7
	-- We only need the above given the napalm zombies "unique" method of attack.
	-- So we empty out the rest of the table.
	data.hitsound = ""
	data.viewpunch = Angle(0,0,0)
	data.dmglow = 0
	data.dmghigh = 0
	data.dmgforce = Vector(0,0,0)
	data.dmgforce.z = math.Clamp(data.dmgforce.z, 1, 16)
	-----
	self:SetAttacking(true)

	self:TimedEvent(0.1, function()
		self:EmitSound(data.attacksound)
	end)

	if self:GetTarget():IsPlayer() then
		self:TimedEvent(data.attackdur, function() -- I don't see the point in not using what's already given to you (timer.Simple). But I'll roll with it.
			self:CustomExplode()
		end)
	end

	self:PlayAttackAndWait(data.attackseq, 1)
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

	if !self:GetSpecialAnimation() and !self:IsAttacking() then
		if self:GetActivity() != self.CalcIdeal and !self:GetStop() then self:StartActivity(self.CalcIdeal) end

		if self.ActStages[self:GetActStage()] then
			self:BodyMoveXY()
		end
	end

	self:FrameAdvance()
end

function ENT:TriggerBarricadeJump() -- We don't 
	if !self:GetSpecialAnimation() and (!self.NextBarricade or CurTime() > self.NextBarricade) then
		self:SetSpecialAnimation(true)
		self:SetBlockAttack(true)
		local seqtbl = self.ActStages[self:GetActStage()] and self[self.ActStages[self:GetActStage()].barricadejumps] or self.JumpSequences
		local seq = seqtbl[math.random(#seqtbl)]
		local id, dur = self:LookupSequence(seq.seq)
		self:SetSolidMask(MASK_SOLID_BRUSHONLY)
		--self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
		--self.loco:SetAcceleration( 5000 )
		self.loco:SetDesiredSpeed(seq.speed)
		self:SetVelocity(self:GetForward() * seq.speed)
		self:SetSequence(id)
		self:SetCycle(0)
		self:SetPlaybackRate(1)
		--self:BodyMoveXY()
		--PrintTable(self:GetSequenceInfo(id))
		self:TimedEvent(dur, function()
			self.NextBarricade = CurTime() + 2
			self:SetSpecialAnimation(false)
			self:SetBlockAttack(false)
			self.loco:SetAcceleration( self.Acceleration )
			self.loco:SetDesiredSpeed(self:GetRunSpeed())
			self:UpdateSequence()
			self:StartActivity(self.ActStages[self:GetActStage()] and self.ActStages[self:GetActStage()].act or self.CalcIdeal)
		end)
	end
end
function ENT:IsValidTarget( ent )
	if !ent then return false end
	return IsValid( ent ) and ent:GetTargetPriority() != TARGET_PRIORITY_NONE and ent:GetTargetPriority() != TARGET_PRIORITY_SPECIAL
	-- Won't go for special targets (Monkeys), but still MAX, ALWAYS and so on
end

-----
function ENT:CustomExplode()
	self:EmitSound("nap/explode.mp3",511,100)
	ParticleEffect("dusty_explosion_rockets",self:GetPos(),self:GetAngles(),nil)
	local ent = ents.Create("env_explosion")
	ent:SetPos(self:GetPos())
	ent:SetAngles(self:GetAngles())
	ent:Spawn()
	ent:SetKeyValue("imagnitude", "200")
	ent:Fire("explode")
		local entParticle = ents.Create("info_particle_system")
		entParticle:SetKeyValue("start_active", "1")
		entParticle:SetKeyValue("effect_name", "fire_large_01")
		entParticle:SetPos(self:GetPos())
		entParticle:SetAngles(self:GetAngles())
		entParticle:Spawn()
		entParticle:Activate()
		timer.Simple(10, function() if IsValid(entParticle) then entParticle:Remove() end end)
		local vaporizer = ents.Create("point_hurt")
		if !vaporizer:IsValid() then return end
		vaporizer:SetKeyValue("Damage", 15)
		vaporizer:SetKeyValue("DamageRadius", 100)
		vaporizer:SetKeyValue("DamageType",DMG_BURN)
		vaporizer:SetPos(self:GetPos())
		vaporizer:SetOwner(self)
		vaporizer:Spawn()
		vaporizer:Fire("TurnOn","",0)
		vaporizer:Fire("kill","",10)
	SafeRemoveEntity(self)
end
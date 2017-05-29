if !string.find(engine.ActiveGamemode(),"nzombies") then return end -- Since we're in the addons folder, we don't want to run the code unless the user is playing nzombies.


if (SERVER) then
	AddCSLuaFile("shared.lua")
end

ENT.Base     = "nz_extensionbossbase"

nzRound:AddBossType("Napalm Zombie", "nz_zombie_boss_napalm", true, function()
	nzRound:SetNextBossRound(7) -- Always spawn in at round 7.
end, function(zmb, killer, dmginfo, hitgroup) -- No need for health function, the nextbot handles it.
	nzRound:SetNextBossRound(nzRound:GetNumber() + math.random(2,3))
	if IsValid(attacker) and attacker:IsPlayer() and attacker:GetNotDowned() then
		attacker:GivePoints(750) -- Give killer 500 points if not downed
	end
end) -- No onhit function, we don't give points on hit for this guy

ENT.AttackWaitTime = 0
ENT.AttackFinishTime = 0
ENT.NextAttack = 1.3
ENT.AttackRange = 60
ENT.InitialAttackRange = 90
ENT.health = 350
ENT.Damage = 40
ENT.Speed = 40
ENT.UseFootSteps = 1
ENT.FootStepInterval = 0.7
ENT.Model = "models/boz/napalm.mdl"
ENT.AttackAnim = (NONE)
ENT.WalkAnim = "walk"
ENT.FallAnim = (NONE)

function ENT:CustomInit()self:SetModelScale(0.8,0.1)self.NextMoan = CurTime() + 5 end
function ENT:OnSpawn()
	if coroutine.running() then
		self.loco:SetDesiredSpeed(0)
		self:EmitSound("nap/spawn.mp3",511,100)
		ParticleEffectAttach("fire_large_01",PATTACH_POINT_FOLLOW,self,0)
		self:PlaySequenceAndWait("emerge",0.65)
		self:StopParticles()
		timer.Simple(0.1,function()ParticleEffectAttach("fire_small_03",PATTACH_POINT_FOLLOW,self,1)end)
	end
end
function ENT:CustomThink()end
function ENT:FootSteps()
	self:EmitSound("nap/step"..math.random(1,3)..".mp3")
end
function ENT:IdleFunction()
	self:MovementFunctions("idle", 0, 1) -- Sequence, seqname, moving speed, playback rate
end
function ENT:OnIgnite()end
function ENT:CustomKilled(dmginfo)
	self:Explode()
end
function ENT:OnInjured(dmginfo)end
function ENT:CustomChaseEnemy()
	local ent = ents.FindInSphere(self:GetPos(), self.AttackRange)  -- Generic attack function, use as you will.
	for k,v in pairs(ent) do
	
		if ((v:IsNPC() || (v:IsPlayer() && v:Alive() && !self.IgnorePlayer))) then
			if not (v:IsValid() && v:Health() > 0) then return end
		
			coroutine.wait(self.AttackWaitTime)
			if v:IsPlayer() then
				local randattack_close = math.random(1,2)
				self:EmitSound("nap/charge.mp3")
				timer.Simple(1.7,function()
					self:Explode()
				end)
				self.loco:SetDesiredSpeed(0)
				self:PlaySequenceAndWait("ALLAHU_ACKBAR")
				self.loco:SetDesiredSpeed(self.Speed)
				self:ResetSequence(self.WalkAnim)
			end
		end
	end
end

---Custom Funcs---
function ENT:Explode()
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
function ENT:Moan()
	if CurTime() < self.NextMoan then return end
		self:EmitSound("nap/amb"..math.random(1,3)..".mp3")
	self.NextMoan = CurTime() + 5
end
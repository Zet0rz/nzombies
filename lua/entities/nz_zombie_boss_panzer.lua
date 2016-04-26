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
	"nz/hellhound/attack/attack_00.wav",
	"nz/hellhound/attack/attack_01.wav",
	"nz/hellhound/attack/attack_02.wav",
	"nz/hellhound/attack/attack_03.wav",
	"nz/hellhound/attack/attack_04.wav",
	"nz/hellhound/attack/attack_05.wav",
	"nz/hellhound/attack/attack_06.wav"
}

ENT.AttackHitSounds = {
	"nz/hellhound/bite/bite_00.wav",
	"nz/hellhound/bite/bite_01.wav",
	"nz/hellhound/bite/bite_02.wav",
	"nz/hellhound/bite/bite_03.wav",
}

ENT.WalkSounds = {
	"nz/hellhound/dist_vox_a/dist_vox_a_00.wav",
	"nz/hellhound/dist_vox_a/dist_vox_a_01.wav",
	"nz/hellhound/dist_vox_a/dist_vox_a_02.wav",
	"nz/hellhound/dist_vox_a/dist_vox_a_03.wav",
	"nz/hellhound/dist_vox_a/dist_vox_a_04.wav",
	"nz/hellhound/dist_vox_a/dist_vox_a_05.wav",
	"nz/hellhound/dist_vox_a/dist_vox_a_06.wav",
	"nz/hellhound/dist_vox_a/dist_vox_a_07.wav",
	"nz/hellhound/dist_vox_a/dist_vox_a_08.wav",
	"nz/hellhound/dist_vox_a/dist_vox_a_09.wav",
	"nz/hellhound/dist_vox_a/dist_vox_a_10.wav",
	"nz/hellhound/dist_vox_a/dist_vox_a_11.wav"
}

ENT.PainSounds = {
	--"physics/flesh/flesh_impact_bullet1.wav",
	--"physics/flesh/flesh_impact_bullet2.wav",
	--"physics/flesh/flesh_impact_bullet3.wav",
	--"physics/flesh/flesh_impact_bullet4.wav",
	--"physics/flesh/flesh_impact_bullet5.wav"
}

ENT.DeathSounds = {
	"nz/hellhound/death2/death0.wav",
	"nz/hellhound/death2/death1.wav",
	"nz/hellhound/death2/death2.wav",
	"nz/hellhound/death2/death3.wav",
	"nz/hellhound/death2/death4.wav",
	"nz/hellhound/death2/death5.wav",
	"nz/hellhound/death2/death6.wav",
}

ENT.SprintSounds = {
	"nz/hellhound/close/close_00.wav",
	"nz/hellhound/close/close_01.wav",
	"nz/hellhound/close/close_02.wav",
	"nz/hellhound/close/close_03.wav",
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

function ENT:StatsInitialize()
	if SERVER then
		self:SetRunSpeed(150)
		self:SetHealth( 100 )
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

function ENT:OnSpawn()
	local seq = "nz_entry"
	local tr = util.TraceLine({
		start = self:GetPos() + Vector(0,0,500),
		endpos = self:GetPos(),
		filter = self,
		mask = MASK_NPCSOLID,
	})
	if tr.Hit then seq = "nz_entry_instant" end
	local _, dur = self:LookupSequence(seq)

	-- play emerge animation on spawn
	-- if we have a coroutine else just spawn the zombie without emerging for now.
	if coroutine.running() then
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

	self:SetRunSpeed(0)
	self.loco:SetVelocity(Vector(0,0,0))
	self:Stop()
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	local seq, dur = self:LookupSequence(self.DeathSequences[math.random(#self.DeathSequences)])
	self:ResetSequence(seq)
	self:SetCycle(0)

	timer.Simple(dur + 1, function()
		if IsValid(self) then
			self:Remove()
		end
	end)

end

function ENT:BodyUpdate()

	self.CalcIdeal = ACT_IDLE

	local velocity = self:GetVelocity()

	local len2d = velocity:Length2D()

	if ( len2d > 60 ) then self.CalcIdeal = ACT_RUN elseif ( len2d > 5 ) then self.CalcIdeal = ACT_WALK end

	if self:IsJumping() and self:WaterLevel() <= 0 then
		self.CalcIdeal = ACT_JUMP
	end

	if self:GetActivity() != self.CalcIdeal and !self:IsAttacking() and !self:GetStop() then self:StartActivity(self.CalcIdeal) end

	if ( self.CalcIdeal and !self:GetAttacking() ) then

		self:BodyMoveXY()

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

-- Hellhounds target differently
function ENT:GetPriorityTarget()

	if GetConVar( "nz_zombie_debug" ):GetBool() then
		print(self, "Retargeting")
	end

	self:SetLastTargetCheck( CurTime() )

	-- Well if he exists and he is targetable, just target this guy!
	if IsValid(self:GetTarget()) and self:GetTarget():GetTargetPriority() > 0 then
		local dist = self:GetRangeSquaredTo( self:GetTarget():GetPos() )
		if dist < 1000 then
			if !self.sprinting then
				self.sprinting = true
			end
			self:SetRunSpeed(100)
			self.loco:SetDesiredSpeed( self:GetRunSpeed() )
		elseif !self.sprinting then
			self:SetRunSpeed(80)
			self.loco:SetDesiredSpeed( self:GetRunSpeed() )
		end
		return self:GetTarget()
	end

	-- Otherwise, we just loop through all to try and target again
	local allEnts = ents.GetAll()

	local bestTarget = nil
	local lowest

	--local possibleTargets = ents.FindInSphere( self:GetPos(), self:GetTargetCheckRange())

	for _, target in pairs(allEnts) do
		if self:IsValidTarget(target) then
			if target:GetTargetPriority() == TARGET_PRIORITY_ALWAYS then return target end
			if !lowest then
				lowest = target.hellhoundtarget -- Set the lowest variable if not yet
				bestTarget = target -- Also mark this for the best target so he isn't ignored
			end

			if lowest and (!target.hellhoundtarget or target.hellhoundtarget < lowest) then -- If the variable exists and this player is lower than that amount
				bestTarget = target -- Mark him for the potential target
				lowest = target.hellhoundtarget or 0 -- And set the new lowest to continue the loop with
			end

			if !lowest then -- If no players had any target values (lowest was never set, first ever hellhound)
				local players = player.GetAllTargetable()
				bestTarget = players[math.random(#players)] -- Then pick a random player
			end
		end
	end

	if self:IsValidTarget(bestTarget) then -- If we found a valid target
		local targetDist = self:GetRangeSquaredTo( bestTarget:GetPos() )
		if targetDist < 1000 then -- Under this distance, we will break into sprint
			self.sprinting = true -- Once sprinting, you won't stop
			self:SetRunSpeed(100)
		else -- Otherwise we'll just search (towards him)
			self:SetRunSpeed(80)
			self.sprinting = nil
		end
		self.loco:SetDesiredSpeed( self:GetRunSpeed() )
		-- Apply the new target numbers
		bestTarget.hellhoundtarget = bestTarget.hellhoundtarget and bestTarget.hellhoundtarget + 1 or 1
		self:SetTarget(bestTarget) -- Well we found a target, we kinda have to force it

		return bestTarget
	else
		self:TimeOut(0.2)
	end
end

function ENT:IsValidTarget( ent )
	if !ent then return false end
	return IsValid( ent ) and ent:GetTargetPriority() != TARGET_PRIORITY_NONE and ent:GetTargetPriority() != TARGET_PRIORITY_SPECIAL
	-- Won't go for special targets (Monkeys), but still MAX, ALWAYS and so on
end

if CLIENT then
	local eyeGlow =  Material( "sprites/redglow1" )
	local white = Color( 255, 255, 255, 255 )
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
			cam.Start3D(EyePos(),EyeAngles())
				render.SetMaterial( eyeGlow )
				render.DrawSprite( leftEye, 4, 4, white)
				render.DrawSprite( rightEye, 4, 4, white)
			cam.End3D()
		end
		if GetConVar( "nz_zombie_debug" ):GetBool() then
			render.DrawWireframeBox(self:GetPos(), Angle(0,0,0), self:OBBMins(), self:OBBMaxs(), Color(255,0,0), true)
			render.DrawWireframeSphere(self:GetPos(), self:GetAttackRange(), 10, 10, Color(255,165,0), true)
			render.DrawWireframeSphere(pos, 2, 10, 10, Color(0,255,0), false)
		end
	end
end

function ENT:OnInjured( dmgInfo )
	-- No pain sounds
end
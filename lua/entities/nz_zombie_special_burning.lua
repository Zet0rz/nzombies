AddCSLuaFile()

ENT.Base = "nz_zombie_walker"
ENT.PrintName = "Burning Walker"
ENT.Category = "Brainz"
ENT.Author = "Lolle"

function ENT:SpecialInit()
    self:SetSkin(math.random(0, self:SkinCount() - 1))
    if SERVER then
        local speeds = Round:GetZombieData().nz_zombie_special_burning and Round:GetZombieData().nz_zombie_special_burning.speeds or Round:GetZombieSpeeds()
		if speeds then
			self:SetRunSpeed( nz.Misc.Functions.WeightedRandom(speeds) - 20 ) -- A bit slower here
		else
			self:SetRunSpeed( nz.Curves.Data.Speed[ Round:GetNumber() ] )
		end
        self:SetHealth( Round:GetZombieHealth() or 75 )
        self:Flames( true )
    end
end

function ENT:OnTargetInAttackRange()
    local atkData = {}
    atkData.dmglow = 0
    atkData.dmghigh = 0
    atkData.dmgforce = Vector( 0, 0, 0 )
    self:Attack( atkData )
    self:TimedEvent( 0.45, function()
        if self:IsValidTarget( self:GetTarget() ) and self:TargetInRange( self.AttackRange + 10 ) then
            self:Explode( math.random( 50, 100 ) )
        end
    end)
end

function ENT:OnKilled(dmgInfo)
    self:Explode( math.random( 25, 50 ))
	self:EmitSound(self.DeathSounds[ math.random( #self.DeathSounds ) ], 50, math.random(75, 130))
	self:BecomeRagdoll(dmgInfo)
end

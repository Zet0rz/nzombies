AddCSLuaFile()

ENT.Base = "nz_zombiebase"
ENT.PrintName = "Burning Walker"
ENT.Category = "Brainz"
ENT.Author = "Lolle"

ENT.Models = { "models/zed/malezed_04.mdl", "models/zed/malezed_06.mdl", "models/zed/malezed_08.mdl"  }

function ENT:SpecialInit()
    self:SetSkin(math.random(0, self:SkinCount() - 1))
    if SERVER then
        self:SetRunSpeed( nz.Curves.Data.Speed[nz.Rounds.Data.CurrentRound] )
        self:SetHealth( nz.Curves.Data.Health[nz.Rounds.Data.CurrentRound] )
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

AddCSLuaFile()

ENT.Base = "nz_zombiebase"
ENT.PrintName = "Hellhound"
ENT.Category = "Brainz"
ENT.Author = "Lolle"

ENT.Models = { "models/player/slow/amberlyn/re5/dog/slow.mdl" } --Temp model

ENT.AttackRange = 150
ENT.AttackSequences = { "Walk_Shoot_KNIFE" }
ENT.Acceleration = 600

AccessorFunc( ENT, "bAttacked", "Attacked", FORCE_BOOL )

function ENT:SpecialInit()
    if SERVER then
        self:SetRunSpeed( nz.Curves.Data.Speed[nz.Rounds.Data.CurrentRound] * 1.5 )
        self:SetHealth( nz.Curves.Data.Health[nz.Rounds.Data.CurrentRound] * 1.5 )
        self.loco:SetDesiredSpeed( self:GetRunSpeed() )
    end
    self:SetCollisionBounds(Vector(-16,-8, 0), Vector(16, 8, 32)) --DOGE = SMALL
end

function ENT:OnBarricadeBlocking( barricade )
    self:TeleportToTarget()
end

function ENT:OnPathTimeOut()
    if self:HasTarget() and !nz.Nav.Functions.IsInSameNavGroup( self:GetTarget(), self ) then
        self:TeleportToTarget()
    end
end

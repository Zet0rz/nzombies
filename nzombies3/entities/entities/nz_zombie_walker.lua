AddCSLuaFile()

ENT.Base = "nz_zombiebase"
ENT.PrintName = "Walker"
ENT.Category = "Brainz"
ENT.Author = "Lolle"

ENT.Models = { "models/zed/malezed_04.mdl", "models/zed/malezed_06.mdl", "models/zed/malezed_08.mdl"  }

function ENT:SpecialInit()
    self:SetSkin(math.random(0, self:SkinCount() - 1))
    if SERVER then
        --self:SetRunSpeed( nz.Curves.Data.Speed[nz.Rounds.Data.CurrentRound] )
		self:SetRunSpeed( nz.Misc.Functions.WeightedRandom(nz.Rounds.CurrentRoundData.nz_zombie_walker.speeds) )
        self:SetHealth( nz.Curves.Data.Health[nz.Rounds.Data.CurrentRound] )
    end
end

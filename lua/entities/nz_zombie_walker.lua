AddCSLuaFile()

ENT.Base = "nz_zombiebase"
ENT.PrintName = "Walker"
ENT.Category = "Brainz"
ENT.Author = "Lolle"

ENT.Models = {
	"models/half-dead/alcatraz/zombie_01.mdl",
	"models/half-dead/alcatraz/zombie_02.mdl",
	"models/half-dead/alcatraz/zombie_03.mdl",
	"models/half-dead/alcatraz/zombie_04.mdl",
	"models/half-dead/alcatraz/zombie_05.mdl",
}

for _,v in pairs(ENT.Models) do
	util.PrecacheModel( v )
end

function ENT:SpecialInit()
	self:SetSkin(math.random(0, self:SkinCount() - 1))
	if SERVER then
		--self:SetRunSpeed( nz.Curves.Data.Speed[nz.Rounds.Data.CurrentRound] )
		local speeds = Round:GetZombieData().nz_zombie_walker and Round:GetZombieData().nz_zombie_walker.speeds or Round:GetZombieSpeeds()
		if speeds then
			self:SetRunSpeed( nz.Misc.Functions.WeightedRandom(speeds) )
		else
			self:SetRunSpeed( nz.Curves.Data.Speed[ Round:GetNumber() ] )
		end
		self:SetHealth( Round:GetZombieHealth() )
	end
end

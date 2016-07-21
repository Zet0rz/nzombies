function GM:OnZombieKilled(zombie, dmgInfo)
	local attacker = dmgInfo:GetAttacker()
	if IsValid(attacker) and attacker:IsPlayer() then
		attacker:IncrementTotalKills()
	end
end

hook.Add("PlayerRevived", "nzupdateReviveScore", function(ply, revivor)
	if IsValid(revivor) and revivor:IsPlayer() then
		revivor:IncrementTotalRevives()
	end
end )

hook.Add("PlayerDowned", "nzupdateDownedScore", function(ply)
	if IsValid(ply) and ply:IsPlayer() then
		ply:IncrementTotalDowns()
	end
end )

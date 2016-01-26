
function nz.Revive.Functions.DoPlayerDeath(ply, dmg)

	if IsValid(ply) and ply:IsPlayer() and ply:Health() - dmg:GetDamage() <= 0 then
		if ply:GetNotDowned() then
			print(ply:Nick() .. " got downed!")
			ply:DownPlayer()
			ply:SetHealth(100)
			return true
		else
			ply:RevivePlayer()	 //Clear the 'downed' status
		end
	end
	
end

//Hooks
hook.Add("EntityTakeDamage", "DownKilledPlayers", nz.Revive.Functions.DoPlayerDeath)

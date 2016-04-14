
function Revive.DoPlayerDeath(ply, dmg)

	if IsValid(ply) and ply:IsPlayer() and ply:Health() - dmg:GetDamage() <= 0 then
		local allow = hook.Call("PlayerShouldTakeDamage", nil, ply, dmg:GetAttacker())
		print(allow, "Allowed or not")
		if allow != false then -- Only false should prevent it (not nil)
			if ply:GetNotDowned() then
				print(ply:Nick() .. " got downed!")
				ply:DownPlayer()
				ply:SetHealth(100)
				ply:SetMaxHealth(100) -- failsafe for Jugg not resetting
				return true
			else
				ply:KillDownedPlayer() -- Kill them if they are already downed
			end
		end
	end
	
end

//Hooks
hook.Add("EntityTakeDamage", "DownKilledPlayers", Revive.DoPlayerDeath)

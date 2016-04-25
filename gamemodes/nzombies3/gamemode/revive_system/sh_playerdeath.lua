
function Revive.DoPlayerDeath(ply, dmg)

	if IsValid(ply) and ply:IsPlayer() then
		if ply:Health() - dmg:GetDamage() <= 0 then
			local allow = hook.Call("PlayerShouldTakeDamage", nil, ply, dmg:GetAttacker())
			--print(allow, "Allowed or not")
			if allow != false then -- Only false should prevent it (not nil)
				if ply:GetNotDowned() then
					print(ply:Nick() .. " got downed!")
					ply:DownPlayer()
					--ply:SetMaxHealth(100) -- failsafe for Jugg not resetting
					return true
				else
					ply:KillDownedPlayer() -- Kill them if they are already downed
				end
			end
		elseif !ply:GetNotDowned() then 
			return true -- Downed players cannot take non-fatal damage
		end
	end
	
end

function Revive.PostPlayerDeath(ply)
	-- Performs all the resetting functions without actually killing the player
	if !ply:GetNotDowned() then ply:KillDownedPlayer(nil, false, true) end
end

local function HandleKillCommand(ply)
	if ply:GetNotDowned() then
		ply:DownPlayer()
	else
		ply:KillDownedPlayer()
	end
	return false
end

//Hooks
hook.Add("EntityTakeDamage", "nzDownKilledPlayers", Revive.DoPlayerDeath)
hook.Add("PostPlayerDeath", "nzPlayerDeathRevivalReset", Revive.PostPlayerDeath)
hook.Add("CanPlayerSuicide", "nzSuicideDowning", HandleKillCommand)

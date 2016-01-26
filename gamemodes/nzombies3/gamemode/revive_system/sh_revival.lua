//
if SERVER then
	hook.Add("Think", "CheckDownedPlayersTime", function()
		for k,v in pairs(nz.Revive.Data.Players) do
			//The time it takes for a downed player to die - Prevent dying if being revived
			if CurTime() - v.DownTime >= nz.Config.DownTime and !v.ReviveTime then
				k:KillDownedPlayer()
			end
		end
	end)
end

function nz.Revive.Functions.Revive(ply, ent)
	--print(ply, ent)
	
	//Make sure other downed players can't revive other downed players next to them
	if !nz.Revive.Data.Players[ply] then
	
		local tr = util.QuickTrace(ply:EyePos(), ply:GetAimVector()*100, ply)
		local dply = tr.Entity
		--print(dply)
		
		if IsValid(dply) and dply:IsPlayer() then
			if nz.Revive.Data.Players[dply] then 
				if !nz.Revive.Data.Players[dply].ReviveTime then 
					nz.Revive.Data.Players[dply].ReviveTime = CurTime()
					nz.Revive.Data.Players[dply].RevivePlayer = ply
					ply.Reviving = dply
					nz.Revive.Functions.SendSync()
				end
				
				--print(CurTime() - nz.Revive.Data.Players[dply].ReviveTime)
				
				if ply:HasPerk("revive") and CurTime() - nz.Revive.Data.Players[dply].ReviveTime >= 2 //With quick-revive
				or CurTime() - nz.Revive.Data.Players[dply].ReviveTime >= 5 then	//5 is the time it takes to revive
					dply:RevivePlayer()
					ply.Reviving = nil
				end
			end
		else
			if ply.Reviving != dply then
				if nz.Revive.Data.Players[ply.Reviving] then 
					if nz.Revive.Data.Players[ply.Reviving].ReviveTime then 
						nz.Revive.Data.Players[ply.Reviving].ReviveTime = nil
						nz.Revive.Data.Players[ply.Reviving].RevivePlayer = nil
						ply:SetMoveType(MOVETYPE_WALK)
						ply.Reviving = nil
						nz.Revive.Functions.SendSync()
					end
				end
			end
		end
		
		//When a player stops reviving
		if !ply:KeyDown(IN_USE) then 
			if IsValid(dply) and dply:IsPlayer() then
				if nz.Revive.Data.Players[dply] then 
					if nz.Revive.Data.Players[dply].ReviveTime then 
						nz.Revive.Data.Players[dply].ReviveTime = nil
						nz.Revive.Data.Players[dply].RevivePlayer = nil
						ply:SetMoveType(MOVETYPE_WALK)
						ply.Reviving = nil
						nz.Revive.Functions.SendSync()
					end
				end
			end
		end
	
	end
end

//Hooks
hook.Add("FindUseEntity", "CheckRevive", nz.Revive.Functions.Revive)

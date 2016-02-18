local playerMeta = FindMetaTable("Player")
if SERVER then

	function playerMeta:DownPlayer()
		self:AnimRestartGesture(GESTURE_SLOT_GRENADE, ACT_HL2MP_SIT_PISTOL)
		
		nz.Revive.Data.Players[self] = {}
		nz.Revive.Data.Players[self].DownTime = CurTime()
		
		if self:HasPerk("whoswho") then
			self.HasWhosWho = true
			timer.Simple(5, function()
				-- If you choose to use Tombstone within these seconds, you won't make a clone and will get Who's Who back from Tombstone
				if IsValid(self) and !self:GetNotDowned() then
					print("Should've respawned by now")
					nz.Revive.Functions.CreateWhosWhoClone(self)
					nz.Revive.Functions.RespawnWithWhosWho(self)
				end
			end)
		end
		if self:HasPerk("tombstone") then
			nz.Revive.Data.Players[self].tombstone = true
		end
		
		self.OldPerks = nz.Perks.Data.Players[self] or {}
		
		self:RemovePerks()
		
		nz.Revive.Functions.SendSync()
		
		// Equip the first pistol found in inventory - unless a pistol is already equipped
		local wep = self:GetActiveWeapon()
		if IsValid(wep) and wep:GetHoldType() == "pistol" or wep:GetHoldType() == "duel" or wep.HoldType == "pistol" or wep.HoldType == "duel" then
			return
		end
		for k,v in pairs(self:GetWeapons()) do
			if v:GetHoldType() == "pistol" or v:GetHoldType() == "duel" or v.HoldType == "pistol" or v.HoldType == "duel" then
				self:SelectWeapon(v:GetClass())
				--print("Equipped "..v.ClassName.."!")
				return
			end
		end
		
		nz.Revive.Functions.SendSyncHeadsUp(self, 0)
	end
	
	function playerMeta:RevivePlayer(nosync)	 //Also used to clear that someone is downed - like when they die
		if !nz.Revive.Data.Players[self] then return end
		self:AnimResetGestureSlot(GESTURE_SLOT_GRENADE)
		nz.Revive.Data.Players[self] = nil
		if !nosync then 
			nz.Revive.Functions.SendSync()
			nz.Revive.Functions.SendSyncHeadsUp(self, 1)
		end
		self.HasWhosWho = nil
	end
	
	function playerMeta:StartRevive(nosync)
		if !nz.Revive.Data.Players[self] then return end
		if !nosync then nz.Revive.Functions.SendSync() end
	end
	
	function playerMeta:KillDownedPlayer(silent, nosync)
		nz.Revive.Data.Players[self] = nil
		if silent then
			self:KillSilent()
		else
			self:Kill()
		end
		if !nosync then 
			nz.Revive.Functions.SendSync()
			nz.Revive.Functions.SendSyncHeadsUp(self, 2)
		end
		self.HasWhosWho = nil
	end
	
end

function playerMeta:GetNotDowned()
	if nz.Revive.Data.Players[self] then
		return false
	else
		return true
	end
end

function playerMeta:GetDownedWithTombstone()
	if nz.Revive.Data.Players[self] then
		return nz.Revive.Data.Players[self].tombstone or false
	else
		return false
	end
end

//We overwrite the shoot pos function here so we can set it to the lower angle when downed
local oldshootpos = playerMeta.GetShootPos
function playerMeta:GetShootPos()
	if self:GetNotDowned() then return oldshootpos(self) end
	return oldshootpos(self) + Vector(0,0,-30)
end
local playerMeta = FindMetaTable("Player")
if SERVER then

	function playerMeta:DownPlayer()
		local id = self:EntIndex()
		--self:AnimRestartGesture(GESTURE_SLOT_CUSTOM, ACT_HL2MP_SIT_PISTOL)

		nzRevive.Players[id] = {}
		nzRevive.Players[id].DownTime = CurTime()

		-- downed players are not targeted
		self:SetTargetPriority(TARGET_PRIORITY_NONE)
		self:SetHealth(100)

		if self:HasPerk("whoswho") then
			self.HasWhosWho = true
			timer.Simple(5, function()
				-- If you choose to use Tombstone within these seconds, you won't make a clone and will get Who's Who back from Tombstone
				if IsValid(self) and !self:GetNotDowned() then
					--print("Should've respawned by now")
					nzRevive:CreateWhosWhoClone(self)
					nzRevive:RespawnWithWhosWho(self)
				end
			end)
		end
		if self:HasPerk("tombstone") then
			nzRevive.Players[id].tombstone = true
		end
		if #player.GetAllPlaying() <= 1 and self:HasPerk("revive") and (!self.SoloRevive or self.SoloRevive < 3) then
			self.SoloRevive = self.SoloRevive and self.SoloRevive + 1 or 1
			self.DownedWithSoloRevive = true
			self:StartRevive(self)
			timer.Simple(8, function()
				if IsValid(self) and !self:GetNotDowned() then
					self:RevivePlayer(self)
				end
			end)
			--print(self, "Downed with solo revive")
		end

		self.OldPerks = self:GetPerks()

		self:RemovePerks()

		self.DownPoints = math.Round(self:GetPoints()*0.05, -1)
		if self.DownPoints >= self:GetPoints() then
			self:SetPoints(0)
		else
			self:TakePoints(self.DownPoints, true)
		end

		hook.Call("PlayerDowned", nzRevive, self)

		-- Equip the first pistol found in inventory - unless a pistol is already equipped
		local wep = self:GetActiveWeapon()
		if IsValid(wep) and wep.GetHoldType and wep:GetHoldType() == "pistol" or wep:GetHoldType() == "duel" or wep.HoldType == "pistol" or wep.HoldType == "duel" then
			return
		end
		for k,v in pairs(self:GetWeapons()) do
			if v.GetHoldType and v:GetHoldType() == "pistol" or v:GetHoldType() == "duel" or v.HoldType == "pistol" or v.HoldType == "duel" then
				self:SelectWeapon(v:GetClass())
				return
			end
		end
	end

	function playerMeta:RevivePlayer(revivor, nosync)
		local id = self:EntIndex()
		if !nzRevive.Players[id] then return end
		--self:AnimResetGestureSlot(GESTURE_SLOT_CUSTOM)
		nzRevive.Players[id] = nil
		if !nosync then
			hook.Call("PlayerRevived", nzRevive, self, revivor)
		end
		self:SetTargetPriority(TARGET_PRIORITY_PLAYER)
		self.HasWhosWho = nil
		if IsValid(revivor) and revivor:IsPlayer() then
			if self.DownPoints then
				revivor:GivePoints(self.DownPoints)
			end
			revivor:StripWeapon("nz_revive_morphine") -- Remove the viewmodel again
		end
		self.DownPoints = nil
		self.HasWhosWho = nil
		self.DownedWithSoloRevive = nil
		
		self:SetPos(self:GetPos() + Vector(0,0,25))
		self:ResetHull()
	end

	function playerMeta:StartRevive(revivor, nosync)
		local id = self:EntIndex()
		if !nzRevive.Players[id] then return end -- Not even downed
		if nzRevive.Players[id].ReviveTime then return end -- Already being revived

		nzRevive.Players[id].ReviveTime = CurTime()
		nzRevive.Players[id].RevivePlayer = revivor
		revivor.Reviving = self

		print("Started revive", self, revivor)

		if revivor:GetNotDowned() then -- You can revive yourself while downed with Solo Quick Revive
			revivor:Give("nz_revive_morphine") -- Give them the viewmodel
		end

		if !nosync then hook.Call("PlayerBeingRevived", nzRevive, self, revivor) end
	end

	function playerMeta:StopRevive(nosync)
		local id = self:EntIndex()
		if !nzRevive.Players[id] then return end -- Not even downed

		local revivor = nzRevive.Players[id].RevivePlayer
		if IsValid(revivor) then
			revivor:StripWeapon("nz_revive_morphine") -- Remove the revivors viewmodel
		end

		nzRevive.Players[id].ReviveTime = nil
		nzRevive.Players[id].RevivePlayer = nil

		print("Stopped revive", self)

		if !nosync then hook.Call("PlayerNoLongerBeingRevived", nzRevive, self) end
	end

	function playerMeta:KillDownedPlayer(silent, nosync, nokill)
		local id = self:EntIndex()
		if !nzRevive.Players[id] then return end

		local revivor = nzRevive.Players[id].RevivePlayer
		if IsValid(revivor) then -- This shouldn't happen as players can't die if they are currently being revived
			revivor:StripWeapon("nz_revive_morphine") -- Remove the revivors if someone was reviving viewmodel
		end

		nzRevive.Players[id] = nil
		if !nokill then
			if silent then
				self:KillSilent()
			else
				self:Kill()
			end
		end
		if !nosync then hook.Call("PlayerKilled", nzRevive, self) end
		self.HasWhosWho = nil
		self.DownPoints = nil
		self.DownedWithSoloRevive = nil
		for k,v in pairs(player.GetAllPlayingAndAlive()) do
			v:TakePoints(math.Round(v:GetPoints()*0.1, -1), true)
		end
		
		self:RemoveAllPowerUps()
		
		--self:SetPos(self:GetPos() + Vector(0,0,25))
		self:ResetHull()
	end

end

function playerMeta:GetNotDowned()
	local id = self:EntIndex()
	if nzRevive.Players[id] then
		return false
	else
		return true
	end
end

function playerMeta:GetDownedWithTombstone()
	local id = self:EntIndex()
	if nzRevive.Players[id] then
		return nzRevive.Players[id].tombstone or false
	else
		return false
	end
end

function playerMeta:GetPlayerReviving()
	return self.Reviving
end

-- We overwrite the shoot pos function here so we can set it to the lower angle when downed
local oldshootpos = playerMeta.GetShootPos
function playerMeta:GetShootPos()
	if self:GetNotDowned() then return oldshootpos(self) end
	return oldshootpos(self) + Vector(0,0,-15)
end

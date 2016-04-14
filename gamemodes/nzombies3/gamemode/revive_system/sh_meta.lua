local playerMeta = FindMetaTable("Player")
if SERVER then

	function playerMeta:DownPlayer()
		local id = self:EntIndex()
		self:AnimRestartGesture(GESTURE_SLOT_GRENADE, ACT_HL2MP_SIT_PISTOL)

		Revive.Players[id] = {}
		Revive.Players[id].DownTime = CurTime()

		-- downed players are not targeted
		self:SetTargetPriority(TARGET_PRIORITY_NONE)

		if self:HasPerk("whoswho") then
			self.HasWhosWho = true
			timer.Simple(5, function()
				-- If you choose to use Tombstone within these seconds, you won't make a clone and will get Who's Who back from Tombstone
				if IsValid(self) and !self:GetNotDowned() then
					print("Should've respawned by now")
					Revive:CreateWhosWhoClone(self)
					Revive:RespawnWithWhosWho(self)
				end
			end)
		end
		if self:HasPerk("tombstone") then
			Revive.Players[id].tombstone = true
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
			print(self, "Downed with solo revive")
		end

		self.OldPerks = nz.Perks.Data.Players[self] or {}

		self:RemovePerks()

		self.DownPoints = math.Round(self:GetPoints()*0.05, -1)
		if self.DownPoints >= self:GetPoints() then
			self:SetPoints(0)
		else
			self:TakePoints(self.DownPoints, true)
		end

		hook.Call("PlayerDowned", Revive, self)

		-- Equip the first pistol found in inventory - unless a pistol is already equipped
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
	end

	function playerMeta:RevivePlayer(revivor, nosync)
		local id = self:EntIndex()
		if !Revive.Players[id] then return end
		self:AnimResetGestureSlot(GESTURE_SLOT_GRENADE)
		Revive.Players[id] = nil
		if !nosync then
			hook.Call("PlayerRevived", Revive, self, revivor)
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
	end

	function playerMeta:StartRevive(revivor, nosync)
		local id = self:EntIndex()
		if !Revive.Players[id] then return end -- Not even downed
		if Revive.Players[id].ReviveTime then return end -- Already being revived

		Revive.Players[id].ReviveTime = CurTime()
		Revive.Players[id].RevivePlayer = revivor
		revivor.Reviving = self

		print("Started revive", self, revivor)

		if revivor:GetNotDowned() then -- You can revive yourself while downed with Solo Quick Revive
			revivor:Give("nz_revive_morphine") -- Give them the viewmodel
		end

		if !nosync then hook.Call("PlayerBeingRevived", Revive, self, revivor) end
	end

	function playerMeta:StopRevive(nosync)
		local id = self:EntIndex()
		if !Revive.Players[id] then return end -- Not even downed

		local revivor = Revive.Players[id].RevivePlayer
		if IsValid(revivor) then
			revivor:StripWeapon("nz_revive_morphine") -- Remove the revivors viewmodel
		end

		Revive.Players[id].ReviveTime = nil
		Revive.Players[id].RevivePlayer = nil

		print("Stopped revive", self)

		if !nosync then hook.Call("PlayerNoLongerBeingRevived", Revive, self) end
	end

	function playerMeta:KillDownedPlayer(silent, nosync)
		local id = self:EntIndex()
		if !Revive.Players[id] then return end

		local revivor = Revive.Players[id].RevivePlayer
		if IsValid(revivor) then -- This shouldn't happen as players can't die if they are currently being revived
			revivor:StripWeapon("nz_revive_morphine") -- Remove the revivors if someone was reviving viewmodel
		end

		Revive.Players[id] = nil
		if silent then
			self:KillSilent()
		else
			self:Kill()
		end
		if !nosync then hook.Call("PlayerKilled", Revive, self) end
		self.HasWhosWho = nil
		self.DownPoints = nil
		self.DownedWithSoloRevive = nil
		for k,v in pairs(player.GetAllPlayingAndAlive()) do
			v:TakePoints(math.Round(v:GetPoints()*0.1, -1))
		end
	end

end

function playerMeta:GetNotDowned()
	local id = self:EntIndex()
	if Revive.Players[id] then
		return false
	else
		return true
	end
end

function playerMeta:GetDownedWithTombstone()
	local id = self:EntIndex()
	if Revive.Players[id] then
		return Revive.Players[id].tombstone or false
	else
		return false
	end
end

-- We overwrite the shoot pos function here so we can set it to the lower angle when downed
local oldshootpos = playerMeta.GetShootPos
function playerMeta:GetShootPos()
	if self:GetNotDowned() then return oldshootpos(self) end
	return oldshootpos(self) + Vector(0,0,-30)
end

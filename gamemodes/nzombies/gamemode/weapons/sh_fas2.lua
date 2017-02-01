function FAS2_PlayAnim(wep, anim, speed, cyc, time)
	speed = speed and speed or 1
	cyc = cyc and cyc or 0
	time = time or 0

	if type(anim) == "table" then
		anim = table.Random(anim)
	end

	anim = string.lower(anim)
	
	if wep.Owner:HasPerk("speed") then
		if string.find(anim, "reload") != nil or string.find(anim, "insert") != nil then
			speed = speed * 1.33 -- For some reason this fits perfectly to a double reload speed?
		end
	end
	if wep.Owner:HasPerk("dtap") or wep.Owner:HasPerk("dtap2") then
		if string.find(anim, "fire") != nil or string.find(anim, "cock") != nil or string.find(anim, "pump") != nil then
			speed = speed * 1.33
		end
	end

	if game.SinglePlayer() then
		if SERVER then
			if wep.Sounds[anim] then
				wep.CurSoundTable = wep.Sounds[anim]
				wep.CurSoundEntry = 1
				wep.SoundSpeed = speed
				wep.SoundTime = CurTime() + time
			end
		end
			/*if wep.Sounds[anim] then
				for k, v in pairs(wep.Sounds[anim]) do
					timer.Simple(v.time, function()
						if IsValid(ply) and ply:Alive() and IsValid(wep) and wep == ply:GetActiveWeapon() then
							wep:EmitSound(v.sound, 70, 100)
						end
					end)
				end
			end
		end*/
	else
		if wep.Sounds[anim] then
			wep.CurSoundTable = wep.Sounds[anim]
			wep.CurSoundEntry = 1
			wep.SoundSpeed = speed
			wep.SoundTime = CurTime() + time
		end

		/*if wep.Sounds[anim] then
			for k, v in pairs(wep.Sounds[anim]) do
				timer.Simple(v.time, function()
					wep:EmitSound(v.sound, 70, 100)
				end)
			end
		end*/
	end

	if SERVER and game.SinglePlayer() then
		ply = Entity(1)

		umsg.Start("FAS2ANIM", ply)
			umsg.String(anim)
			umsg.Float(speed)
			umsg.Float(cyc)
		umsg.End()
	end

	if CLIENT then
		vm = wep.Wep

		wep.CurAnim = string.lower(anim)

		if vm then
			vm:SetCycle(cyc)
			vm:SetSequence(anim)
			--print(vm:SequenceDuration(vm:LookupSequence(anim))/speed)
			--print(LocalPlayer():GetActiveWeapon():GetNextPrimaryFire() - CurTime())
			vm:SetPlaybackRate(speed)
		end
	end
end

if CLIENT then
	-- A copy using a slightly different usermessage. This one generates the missing tables (which would otherwise require the C-menu)
	local function FAS2_Attach(um)
		local group = um:ReadShort()
		local att = um:ReadString()
		local wep = um:ReadEntity()
		
		ply = LocalPlayer()
		
		if IsValid(wep) and wep.IsFAS2Weapon then
			t = wep.Attachments[group]
			
			t.active = att
			if !t.last then t.last = {} end
			t.last[att] = true
			t2 = FAS2_Attachments[att]
			
			if t2.aimpos then
				wep.AimPos = wep[t2.aimpos]
				wep.AimAng = wep[t2.aimang]
				wep.AimPosName = t2.aimpos
				wep.AimAngName = t2.aimang
			end
			
			if t.lastdeattfunc then
				t.lastdeattfunc(ply, wep)
			end
			
			if t2.clattfunc then
				t2.clattfunc(ply, wep)
			end
			
			t.lastdeattfunc = t2.cldeattfunc
			
			wep:AttachBodygroup(att)
			surface.PlaySound("cstm/attach.wav")
		end
	end
	usermessage.Hook("FAS2_ATTACHPAP", FAS2_Attach)
end

hook.Add("InitPostEntity", "ReplaceCW2BaseFunctions", function()
	local cw2 = weapons.Get("cw_base")
	if cw2 then
		cw2.beginReload = function(self)
			mag = self:Clip1()
			local CT = CurTime()
			
			local hasspeed = self.Owner:HasPerk("speed")
			
			if self.ShotgunReload then
				local time = CT + self.ReloadStartTime / self.ReloadSpeed
				if hasspeed then time = time / 2 end
				
				self.WasEmpty = mag == 0
				self.ReloadDelay = time
				self:SetNextPrimaryFire(time)
				self:SetNextSecondaryFire(time)
				self.GlobalDelay = time
				self.ShotgunReloadState = 1
				
				self:sendWeaponAnim("reload_start", hasspeed and self.ReloadSpeed * 2 or self.ReloadSpeed)
			else	
				local reloadTime = nil
				local reloadHalt = nil
				
				if mag == 0 then
					if self.Chamberable then
						self.Primary.ClipSize = self.Primary.ClipSize_Orig
					end
					
					reloadTime = self.ReloadTime_Empty
					reloadHalt = self.ReloadHalt_Empty
				else
					reloadTime = self.ReloadTime
					reloadHalt = self.ReloadHalt
					
					if self.Chamberable then
						self.Primary.ClipSize = self.Primary.ClipSize_Orig + 1
					end
				end
				
				reloadTime = reloadTime / self.ReloadSpeed
				reloadHalt = reloadHalt / self.ReloadSpeed
				
				if hasspeed then
					reloadTime = reloadTime / 2
					reloadHalt = reloadHalt / 2
				end
				
				self.ReloadDelay = CT + reloadTime
				self:SetNextPrimaryFire(CT + reloadHalt)
				self:SetNextSecondaryFire(CT + reloadHalt)
				self.GlobalDelay = CT + reloadHalt
						
				if self.reloadAnimFunc then
					self:reloadAnimFunc(mag)
				else
					if self.Animations.reload_empty and mag == 0 then
						self:sendWeaponAnim("reload_empty", hasspeed and self.ReloadSpeed * 2 or self.ReloadSpeed)
					else
						self:sendWeaponAnim("reload", hasspeed and self.ReloadSpeed * 2 or self.ReloadSpeed)
					end
				end
			end
			
			CustomizableWeaponry.callbacks.processCategory(self, "beginReload", mag == 0)
			
			self.Owner:SetAnimation(PLAYER_RELOAD)
		end
		
		cw2.playFireAnim = function(self)
			if (self.dt.State == CW_AIMING and not self.ADSFireAnim) or (self.dt.BipodDeployed and not self.BipodFireAnim) then
				return
			end
			
			if self.dt.State ~= CW_AIMING and (not self.LuaViewmodelRecoilOverride and self.LuaViewmodelRecoil) then
				return
			end
			
			if self:Clip1() - self.AmmoPerShot <= 0 and self.Animations.fire_dry then
				if self.Owner:HasPerk("dtap") or self.Owner:HasPerk("dtap2") then
					self:sendWeaponAnim("fire_dry", 1.66)
				else
					self:sendWeaponAnim("fire_dry")
				end
			else
				if self.Owner:HasPerk("dtap") or self.Owner:HasPerk("dtap2") then
					self:sendWeaponAnim("fire", 1.66)
				else
					self:sendWeaponAnim("fire")
				end
			end
		end
		weapons.Register(cw2, "cw_base")
		
		-- We overwrite this slowdown function from CW2 here to take our sprinting system into account
		-- But only if the cw2 weapon is even existant
		local MaxRunSpeed = debug.getregistry().Player.GetMaxRunSpeed
		function CW_Move(ply, m)
			local maxspeed
			if MaxRunSpeed then -- If the GetMaxRunSpeed function exists (server side)
				maxspeed = MaxRunSpeed(ply)
			else
				local class = player_manager.GetPlayerClass(ply) -- Else, get the player class
				if class then -- If it exists, get the class table's RunSpeed value
					maxspeed = baseclass.Get(class).RunSpeed
				else
					maxspeed = ply:GetRunSpeed() -- Otherwise, just set to normal run speed
				end
			end
			if !maxspeed then maxspeed = 300 end -- Fallback
			if ply:Crouching() then
				m:SetMaxSpeed(ply:GetWalkSpeed() * ply:GetCrouchedWalkSpeed())
			else
				wep = ply:GetActiveWeapon()
				
				if IsValid(wep) and wep.CW20Weapon then
					if wep.dt and wep.dt.State == CW_AIMING then
						m:SetMaxSpeed((ply:GetWalkSpeed() - wep.SpeedDec) * 0.75)
					else
						m:SetMaxSpeed(maxspeed - wep.SpeedDec)
					end
				else
					m:SetMaxSpeed(maxspeed)
				end
				--print(m:GetMaxSpeed())
			end
		end
		hook.Add("Move", "CW_Move", CW_Move)
	
	end
	
	local fas2 = weapons.Get("fas2_base")
	if fas2 then
		fas2.PrimaryAttack = function(self) -- Overwrite to prevent up-against-wall-stuff
			if self.FireMode == "safe" then
				if IsFirstTimePredicted() then
					self:CycleFiremodes()
				end
				
				return
			end
			
			if IsFirstTimePredicted() then
				if self.BurstAmount > 0 and self.dt.Shots >= self.BurstAmount then
					return
				end
				
				if self.ReloadState != 0 then
					self.ReloadState = 3
					return
				end
				
				if self.dt.Status == FAS_STAT_CUSTOMIZE then
					return
				end
				
				if self.Cooking or self.FuseTime then
					return
				end
			
				if self.Owner:KeyDown(IN_USE) then
					if self:CanThrowGrenade() then
						self:InitialiseGrenadeThrow()
						return
					end
				end
				
				if self.dt.Status == FAS_STAT_SPRINT or self.dt.Status == FAS_STAT_QUICKGRENADE then
					return
				end
				
				mag = self:Clip1()
				CT = CurTime()
				
				if mag <= 0 or self.Owner:WaterLevel() >= 3 then
					self:EmitSound(self.EmptySound, 60, 100)
					self:SetNextPrimaryFire(CT + 0.2)
					//self:EmitSound("FAS2_DRYFIRE", 70, 100)
					return
				end
			
				if self.CockAfterShot and not self.Cocked then
					if SERVER then
						if SP then
							SendUserMessage("FAS2_COCKREMIND", self.Owner) -- wow okay
						end
					else
						self.CockRemindTime = CurTime() + 1
					end
					
					return
				end
					
				self:FireBullet()
				
				if CLIENT then
					self:CreateMuzzle()
					
					if self.Shell and self.CreateShell then
						self:CreateShell()
					end
				end
				
				ef = EffectData()
				ef:SetEntity(self)
				util.Effect("fas2_ef_muzzleflash", ef)
				
				mod = self.Owner:Crouching() and 0.75 or 1
				
				self:PlayFireAnim(mag)
					
				if self.dt.Status == FAS_STAT_ADS then
					if self.BurstAmount > 0 then
						if self.DelayedBurstRecoil then
							if self.dt.Shots == self.ShotToDelayUntil then
								self:AimRecoil(self.BurstRecoilMod)
							end
						else
							self:AimRecoil(self.BurstRecoilMod)
						end
					else
						self:AimRecoil()
					end
				else
					if self.BurstAmount > 0 then
						if self.DelayedBurstRecoil then
							if self.dt.Shots == self.ShotToDelayUntil then
								self:HipRecoil(self.BurstRecoilMod)
							end
						else
							self:HipRecoil(self.BurstRecoilMod)
						end
					else
						self:HipRecoil()
					end
				end
				
				self.SpreadWait = CT + self.SpreadCooldown
				
				if self.BurstAmount > 0 then
					self.AddSpread = math.Clamp(self.AddSpread + self.SpreadPerShot * mod * 0.5, 0, self.MaxSpreadInc)
					self.AddSpreadSpeed = math.Clamp(self.AddSpreadSpeed - 0.2 * mod * 0.5, 0, 1)
				else
					self.AddSpread = math.Clamp(self.AddSpread + self.SpreadPerShot * mod, 0, self.MaxSpreadInc)
					self.AddSpreadSpeed = math.Clamp(self.AddSpreadSpeed - 0.2 * mod, 0, 1)
				end
				
				if self.CockAfterShot then
					self.Cocked = false
				end
			
				if SERVER and SP then
					SendUserMessage("FAS2SPREAD", self.Owner)
				end
				
				if CLIENT then
					self.CheckTime = 0
				end
				
				if self.dt.Suppressed then
					self:EmitSound(self.FireSound_Suppressed, 75, 100)
				else
					self:EmitSound(self.FireSound, 105, 100)
				end
				
				self.Owner:SetAnimation(PLAYER_ATTACK1)
				
				self.ReloadWait = CT + 0.3
			end
			
			if self.BurstAmount > 0 then
				self.dt.Shots = self.dt.Shots + 1
				self:SetNextPrimaryFire(CT + self.FireDelay * self.BurstFireDelayMod)
			else
				self:SetNextPrimaryFire(CT + self.FireDelay)
			end
			
			self:TakePrimaryAmmo(1)
			
			//self:SetNextSecondaryFire(CT + 0.1)
			
			return
		end
		weapons.Register(fas2, "fas2_base")
	end
	
end)
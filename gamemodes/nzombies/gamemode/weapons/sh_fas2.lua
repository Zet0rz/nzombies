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
	
end)
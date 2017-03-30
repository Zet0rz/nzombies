local WeaponModificationFunctions = {}

-- Defaults are run if no other modifiers were added (or they all allowed the next one to be added)
local WeaponModificationFunctionsDefaults = {
	speed = function(wep)
		local oldreload = wep.Reload
		if !oldreload then return end
		
		--print("Weapon reload modified")
		
		wep.Reload = function( self, ... )
			if self.ReloadFinish and self.ReloadFinish > CurTime() then return end
			local ply = self.Owner
			local cur = self:Clip1()
			if cur >= self:GetMaxClip1() then return end
			local give = self:GetMaxClip1() - cur
			if give > ply:GetAmmoCount(self:GetPrimaryAmmoType()) then
				give = ply:GetAmmoCount(self:GetPrimaryAmmoType())
			end
			if give <= 0 then return end
			
			self:SendWeaponAnim(ACT_VM_RELOAD)
			oldreload(self, ...)
			local rtime = self:SequenceDuration(self:SelectWeightedSequence(ACT_VM_RELOAD))/2
			self:SetPlaybackRate(2)
			ply:GetViewModel():SetPlaybackRate(2)

			local nexttime = CurTime() + rtime

			self:SetNextPrimaryFire(nexttime)
			self:SetNextSecondaryFire(nexttime)
			self.ReloadFinish = nexttime
			
			timer.Simple(rtime, function()
				if IsValid(self) and ply:GetActiveWeapon() == self then
					self:SetPlaybackRate(1)
					ply:GetViewModel():SetPlaybackRate(1)
					self:SendWeaponAnim(ACT_VM_IDLE)
					self:SetClip1(give + cur)
					ply:RemoveAmmo(give, self:GetPrimaryAmmoType())
					self:SetNextPrimaryFire(0)
					self:SetNextSecondaryFire(0)
				end
			end)
		end
	end,
	dtap = function(wep)
		local oldpfire = wep.PrimaryAttack
		if oldpfire then
			wep.PrimaryAttack = function(...)
				oldpfire(wep, ...)
				local delay = (wep:GetNextPrimaryFire() - CurTime())*0.8
				wep:SetNextPrimaryFire(CurTime() + delay)
			end
		end
		
		local oldsfire = wep.SecondaryAttack
		if oldsfire then
			wep.SecondaryAttack = function(...)
				oldsfire(wep, ...)
				local delay = (wep:GetNextSecondaryFire() - CurTime())*0.8
				wep:SetNextSecondaryFire(CurTime() + delay)
			end
		end
	end,
	pap = function(wep)
		if wep.Primary and wep.Primary.ClipSize > 0 then
			local newammo = wep.Primary.ClipSize + (wep.Primary.ClipSize*0.5)
			newammo = math.Round(newammo/5)*5
			if newammo <= 0 then newammo = 2 end
			wep.Primary.ClipSize = newammo
			if SERVER then wep:SetClip1(newammo) end
		end
		
		if CLIENT then
			local bannedmatnames = {"hand", "arm", "accessor", "scope", "sight"}
			local function IsGoodMaterial(str)
				for k,v in pairs(bannedmatnames) do
					if string.find(str, v) then
						return false
					end
				end
				return true
			end
			
			if !wep.PaPMats then -- Only if the weapon doesn't already have
				wep.PaPMats = {} -- Generate PaP mats for this weapon
				local modelstr = wep.VM or wep.ViewModel or wep:GetViewModel()
				if modelstr then
					local model = ClientsideModel(modelstr)
					local mats = model:GetMaterials()
					PrintTable(mats)
					if table.Count(mats) >= 1 then
						local num = 2
						for k,v in pairs(mats) do
							if IsGoodMaterial(v) then
								if num%3 > 0 then
									print("Modified", v)
									wep.PaPMats[k - 1] = true
								end
								num = num + 1
							end
						end
					end
					model:Remove()
				end
			end
		end
	end,
}

local WeaponModificationRevertDefaults = {
	pap = function(wep)
		if CLIENT then wep.PaPMats = nil end
	end
}

-- These work by modifying weapons in a special way - they are called via ApplyWeaponModifier with the event being the type of modification
-- "speed" = Applied to all weapons when Speed Cola is owned
-- "dtap" = Applied to all weapons when Double Tap 1 or 2 is owned
-- "pap" = Applied on Pack-a-Punch
-- "repap" = Applied on Pack-a-Punching again; this is not saved as a modifier, so it can run again and again
-- "equip" = Applied when weapon is equipped; doesn't have any restoration

-- Any other custom event can be used with weapon:ApplyNZModifier(event)

function nzWeps:AddWeaponModification(id, event, condition, apply, revert)
	if !WeaponModificationFunctions[event] then WeaponModificationFunctions[event] = {} end
	
	WeaponModificationFunctions[event][id] = {
		condition = condition, -- Condition is checked on both revert and apply
		apply = apply, -- Applies changes, all changes are restored when reverted automatically
		revert = revert -- If you need some special revert function, this is optional
	}
end

function nzWeps:RemoveWeaponModification(id, event)
	if !WeaponModificationFunctions[event] then return end
	WeaponModificationFunctions[event][id] = nil
end


local wepmeta = FindMetaTable("Weapon")
if !wepmeta then return end

local function RecursiveDifferenceCheck(tbl1, tbl2)
	local diffs = {}
	
	for k,v in pairs(tbl1) do
		if v != tbl2[k] then
			if type(v) == "table" then
				local t = RecursiveDifferenceCheck(v, tbl2[k])
				if table.Count(t) > 0 then
					diffs[k] = t
				end
			else
				diffs[k] = v
			end
		end
	end
	
	return diffs
end

function wepmeta:ApplyDefaultNZModifier(modifier)
	if WeaponModificationFunctionsDefaults[modifier] then
		WeaponModificationFunctionsDefaults[modifier](self)
	end
end

function wepmeta:ApplyNZModifier(modifier, blocknetwork)
	if self:HasNZModifier(modifier) then return end

	if WeaponModificationFunctions and WeaponModificationFunctions[modifier] then
	
		local oldversion = table.Copy(self:GetTable()) -- We'll compare to allow for auto-reversion of any changes
		local modded = false
		
		if self.NZModifierAdd and !self:NZModifierAdd(modifier) then
			modded = true
		end
		
		if !modded then
			if (modifier == "pap" and self.OnPaP and self:OnPaP()) or (modifier == "repap" and self.OnRePaP and self.OnRePaP()) then
				modded = true
			end
		end
		
		if !modded then
			for k,v in pairs(WeaponModificationFunctions[modifier]) do
				if v.condition(self) then -- Apply all modifications that pass the condition
					if !v.apply(self) then -- Return true to allow other modifiers
						modded = true
						break
					end
				end
			end
		end
		
		if !modded then -- If all modifiers passed on, default comes last
			self:ApplyDefaultNZModifier(modifier)
		end
		
		if SERVER and !blocknetwork then
			nzWeps:SendSync(self.Owner, self, modifier, false) -- Sync to let the client do the same
		end
		
		if !self.NZModifiers then self.NZModifiers = {} end
		if modifier != "repap" and modifier != "equip" then self.NZModifiers[modifier] = RecursiveDifferenceCheck(oldversion, self:GetTable()) end -- Store all differences so we can restore them!
	else
		print("Tried to apply invalid modifier "..modifier.." to weapon "..tostring(self))
	end
end

function wepmeta:RevertNZModifier(modifier, blocknetwork)
	if WeaponModificationFunctions and WeaponModificationFunctions[modifier] then
		local olds = self.NZModifiers[modifier]
		
		if olds then
			for k,v in pairs(olds) do -- Restore all old data!
				self[k] = v
			end
		end
		
		for k,v in pairs(WeaponModificationFunctions[modifier]) do
			if v.revert and v.condition(self) then
				v.revert(self) -- Call revert functions if they were added
			end
		end
		if WeaponModificationRevertDefaults[modifier] then WeaponModificationRevertDefaults[modifier](self) end
		
		if SERVER and !blocknetwork then
			nzWeps:SendSync(self.Owner, self, modifier, true) -- Sync to let the client do the same
		end
		
		if !self.NZModifiers then self.NZModifiers = {} end
		self.NZModifiers[modifier] = nil
	else
		print("Tried to revert invalid modifier "..modifier.." to weapon "..tostring(self))
	end
end

function wepmeta:HasNZModifier(id)
	if !self.NZModifiers then return false end
	return self.NZModifiers[id] and true or false
end

nzWeps:AddWeaponModification("speed_fascw2", "speed", function(wep)
	return wep:IsFAS2() or wep:IsCW2()
end, function(wep)
	local data = {}
	-- Normal
	data["ReloadTime"] = 2
	data["ReloadTime_Nomen"] = 2
	data["ReloadTime_Empty"] = 2
	data["ReloadTime_Empty_Nomen"] = 2
	-- BiPod
	data["ReloadTime_Bipod"] = 2
	data["ReloadTime_Bipod_Nomen"] = 2
	data["ReloadTime_Bipod_Empty"] = 2
	data["ReloadTime_Bipod_Empty_Nomen"] = 2
	-- Shotguns
	data["ReloadStartTime"] = 2
	data["ReloadStartTime_Nomen"] = 2
	data["ReloadEndTime"] = 2
	data["ReloadEndTime_Nomen"] = 2
	data["ReloadAbortTime"] = 2
	data["ReloadAdvanceTimeEmpty"] = 2
	data["ReloadAdvanceTimeEmpty_Nomen"] = 2
	data["ReloadAdvanceTimeLast"] = 2
	data["ReloadAdvanceTimeLast_Nomen"] = 2
	data["InsertTime"] = 2
	data["InsertTime_Nomen"] = 2
	data["InsertEmpty"] = 2
	data["InsertEmpty_Nomen"] = 2
	
	for k,v in pairs(data) do
		if wep[k] != nil then
			local val = wep[k] / v
			local old = wep[k]
			-- Save the old so we can remove it later
			--wep["old_"..k] = old
			wep[k] = val
		end
	end
	
	if wep.ReloadTimes then
		--wep.old_ReloadTimes = table.Copy(wep.ReloadTimes)
		for k,v in pairs(wep.ReloadTimes) do
			if type(v) == "table" then
				for k2,v2 in pairs(v) do
					v[k2] = v2/2
				end
			elseif type(v) == "number" then
				v = v/2
			end
		end
	end
end)

nzWeps:AddWeaponModification("dtap_fascw2", "dtap", function(wep)
	return wep:IsFAS2() or wep:IsCW2()
end, function(wep)
	print("Applying Dtap to: " .. wep.ClassName)
	local data = {}
	-- Normal
	data["FireDelay"] = 1.2
	-- Shotgun Cocking and Sniper Bolting
	data["CockTime"] = 1.5
	data["CockTime_Nomen"] = 1.5
	data["CockTime_Bipod"] = 1.5
	data["CockTime_Bipod_Nomen"] = 1.5
	
	for k,v in pairs(data) do
		if wep[k] != nil then
			local val = wep[k] / v
			wep[k] = val
		end
	end
end)


-- A copy of the FAS2 function, slightly modified to not require the costumization menu
-- This is used in the PaP modifier below
local function AttachFAS2Attachment(ply, wep, group, att)
	if not (IsValid(ply) and ply:Alive()) then
		return
	end
	
	if not IsValid(wep) or not wep.IsFAS2Weapon then
		return
	end
	
	ply:FAS2_PickUpAttachment(att, false) -- Silently add the attachment
	
	if not group or not att or not wep.Attachments or wep.NoAttachmentMenu or not table.HasValue(ply.FAS2Attachments, att) then
		return
	end
	
	t = wep.Attachments[group]
	
	if t then
		found = false
		
		for k, v in pairs(t.atts) do
			if v == att then
				found = true
			end
		end
		
		if t.lastdeattfunc then
			t.lastdeattfunc(ply, wep)
			t.lastdeattfunc = nil
		end
		
		if found then
			t.last = att
			
			t2 = FAS2_Attachments[att]
			
			if t2.attfunc then
				t2.attfunc(ply, wep)
			end
				
			if t2.deattfunc then
				t.lastdeattfunc = t2.deattfunc
			end
			
			umsg.Start("FAS2_ATTACHPAP", ply)
				umsg.Short(group)
				umsg.String(att)
				umsg.Entity(wep)
			umsg.End()
		end
	end
end

local cond = function(wep) return SERVER and wep:IsFAS2() and GetConVar("nz_papattachments"):GetBool() end
local atts = function(wep)
	if wep.Attachments then
		for k,v in pairs(wep.Attachments) do
			if string.lower(v.header) != "magazine" and string.lower(v.header) != "mag" then -- Mag can't be edited
				local atts = {}
				for k2,v2 in pairs(v.atts) do -- List all missing attachments
					if !table.HasValue(ply.FAS2Attachments, v2) then
						table.insert(atts, v2)
					end
				end
				if table.Count(atts) > 0 then
					local newatt = atts[math.random(#atts)]
					AttachFAS2Attachment(ply, wep, k, newatt)
					if newatt then
						print(wep.Owner:Nick().." has Pack-a-Punched and gotten attachment "..newatt)
					end
				end
			end
		end
	end
	return true
end
nzWeps:AddWeaponModification("pap_fas_attachments", "pap", cond, atts) -- Add the same to both PaP and Re-PaP
nzWeps:AddWeaponModification("pap_fas_attachments", "repap", cond, atts)

local cond = function(wep) return SERVER and wep:IsCW2() and GetConVar("nz_papattachments"):GetBool() end
local atts = function(wep)
	if wep.Attachments then
		for k,v in pairs(wep.Attachments) do
			if string.lower(v.header) != "magazine" and string.lower(v.header) != "mag" then -- Mag can't be edited
				local atts = {}
				for k2,v2 in pairs(v.atts) do -- List all missing attachments
					if !CustomizableWeaponry:hasAttachment(wep.Owner, v2) then
						table.insert(atts, v2)
					end
				end
				if #atts > 0 then
					local newatt = math.random(#atts)
					CustomizableWeaponry:giveAttachment(wep.Owner, atts[newatt])
					wep:attach(k, newatt - 1)
					if atts[newatt] then
						print(wep.Owner:Nick().." has Pack-a-Punched and gotten attachment "..atts[newatt])
					end
				end
			end
		end
	end
	return true
end
nzWeps:AddWeaponModification("pap_cw2_attachments", "pap", function(wep) return wep:IsCW2() end, function(wep)
	if wep.Primary and wep.Primary.ClipSize_Orig and wep.Primary.ClipSize_Orig > 0 then
		local newammo = wep.Primary.ClipSize_Orig + (wep.Primary.ClipSize_Orig*0.5)
		newammo = math.Round(newammo/5)*5
		if newammo <= 0 then newammo = 2 end
		wep.Primary.ClipSize_Orig = newammo -- CW2 needs special ammo thingies
		wep.Primary.ClipSize_ORIG_REAL = newammo
		if SERVER then wep:SetClip1(newammo) end
	end
	
	if SERVER then
		atts(wep)
	end
	return true
end)
nzWeps:AddWeaponModification("pap_cw2_attachments", "repap", cond, atts) -- Add the same to both PaP and Re-PaP

nzWeps:AddWeaponModification("speed_tfa", "speed", function(wep)
	return wep:IsTFA()
end, function(wep)
	wep.ReloadOld = wep.ReloadOld or wep.Reload
	wep.Reload = function(self, ...)
		local ct = CurTime()
		wep.ReloadOld(self, ...)
		local diff = self:GetNextPrimaryFire() - ct
		diff = diff/2 + ct
		
		print(diff)
		
		if self.SetReloadingEnd then self:SetReloadingEnd(diff) end -- This function handles the ammo refill
		self.ReloadingTime = diff
		self:SetNextPrimaryFire(diff)
		self:SetNextSecondaryFire(diff)
		self:SetNextIdleAnim(diff)
		self:SetPlaybackRate(2)
		self.Owner:GetViewModel():SetPlaybackRate(2)
	end
end)

nzWeps:AddWeaponModification("dtap_tfa", "dtap", function(wep)
	return wep:IsTFA()
end, function(wep)
	wep.PrimaryAttackOld = wep.PrimaryAttackOld or wep.PrimaryAttack
	wep.PrimaryAttack = function(self, ...)
		local npfold = wep:GetNextPrimaryFire()
		wep.PrimaryAttackOld(wep, ...)
		if wep:GetNextPrimaryFire() <= npfold then return end
		
		local dtap1,dtap2 = wep.Owner:HasPerk("dtap"), wep.Owner:HasPerk("dtap2")
		if dtap1 or dtap2 then
			local delay = wep:GetNextPrimaryFire() - CurTime()
			if dtap2 then
				delay = delay * 0.8
			end
			if dtap1 then
				delay = delay * 0.8
			end
			wep:SetNextPrimaryFire(CurTime() + delay)
			if ( wep:GetStatus() == TFA.GetStatus("shooting") or wep:GetStatus()  == TFA.GetStatus("bashing") ) then
				delay = wep:GetStatusEnd() - CurTime()
				if dtap2 then
					delay = delay * 0.8
				end
				if dtap1 then
					delay = delay * 0.8
				end
				wep:SetStatusEnd( CurTime() + delay )
			end
		end
	end
	wep.SecondaryAttackOld = wep.SecondaryAttackOld or wep.SecondaryAttack
	wep.SecondaryAttack = function(self, ...)
		local npfold = wep:GetNextPrimaryFire()
		wep.SecondaryAttackOld(wep, ...)
		if wep:GetNextPrimaryFire() <= npfold then return end

		local dtap1,dtap2 = wep.Owner:HasPerk("dtap"), wep.Owner:HasPerk("dtap2")
		if dtap1 or dtap2 then
			local delay = wep:GetNextPrimaryFire() - CurTime()
			if dtap2 then
				delay = delay * 0.8
			end
			if dtap1 then
				delay = delay * 0.8
			end
			wep:SetNextPrimaryFire(CurTime() + delay)
			if ( wep:GetStatus() == TFA.GetStatus("shooting") or wep:GetStatus()  == TFA.GetStatus("bashing") ) then
				delay = wep:GetStatusEnd() - CurTime()
				if dtap2 then
					delay = delay * 0.8
				end
				if dtap1 then
					delay = delay * 0.8
				end
				wep:SetStatusEnd( CurTime() + delay )
			end
		end
	end
end)

nzWeps:AddWeaponModification("tfa_attachmentmod", "equip", function(wep)
	return wep:IsTFA()
end, function(wep)
	if wep.Attachments then
		wep.CanAttach = function()
			return false
		end
		wep.SetTFAAttachment = function(self, cat, id, nw)
			if ( not self.Attachments[cat] ) then return false end
			if id ~= self.Attachments[cat].sel then
				local att_old = TFA.Attachments[ self.Attachments[cat].atts[ self.Attachments[cat].sel ] or -1 ]
				if att_old then
					att_old:Detach( self )
				end

				local att_neue = TFA.Attachments[ self.Attachments[cat].atts[ id ] or -1 ]
				if att_neue then
					att_neue:Attach( self )
				end
			end
			self:ClearStatCache()
			if id > 0 then
				self.Attachments[cat].sel = id
			else
				self.Attachments[cat].sel = nil
			end
			self:BuildAttachmentCache()
			if nw then
				net.Start("TFA_Attachment_Set")
				net.WriteEntity(self)
				net.WriteInt(cat,8)
				net.WriteInt( id or -1 ,5)
				if SERVER then
					net.Broadcast()
				elseif CLIENT then
					net.SendToServer()
				end
			end
			return true
		end
	end
end)

local cond = function(wep) return SERVER and wep:IsTFA() and GetConVar("nz_papattachments"):GetBool() end
local atts = function(wep)
	if wep.Attachments then
		for k,v in pairs(wep.Attachments) do
			if v.header and string.lower(v.header) != "magazine" and string.lower(v.header) != "mag" then -- Mag can't be edited
				wep:SetTFAAttachment(k, math.random(table.Count(v.atts)), true)
			end
		end
	end
	return true
end
nzWeps:AddWeaponModification("pap_tfa_attachments", "pap", cond, atts) -- Add the same to both PaP and Re-PaP
nzWeps:AddWeaponModification("pap_tfa_attachments", "repap", cond, atts)


if SERVER then
	util.AddNetworkString("nzPaPCamo")
	hook.Add("OnViewModelChanged", "nzPaPCamoUpdate", function(vm, old, new)
		if IsValid(vm) and IsValid(vm:GetOwner()) then
			--print(vm:GetOwner())
			net.Start("nzPaPCamo")
			net.Send(vm:GetOwner())
		end
	end)
end

if CLIENT then
	CreateClientConVar("nz_papcamo", 1, true, false, "Sets whether Pack-a-Punch applies a camo to your viewmodel")

	local function PaPCamoUpdate(vm, old, new)
		if !IsValid(LocalPlayer()) then return end
		local wep = LocalPlayer():GetActiveWeapon()
		--vm:SetSubMaterial()
		if !IsValid(wep) then return end
		local view = wep.CW_VM or wep.Wep or vm or LocalPlayer():GetViewModel()
		if IsValid(view) then
			view:SetSubMaterial()
			if !GetConVar("nz_papcamo"):GetBool() then return end
			if wep.PaPCamo then -- You can also use a function
				wep:PaPCamo(view)
			elseif wep.PaPMats then -- Will be generated if not defined in the weapon file
				timer.Simple(0.01, function()
					for k,v in pairs(wep.PaPMats) do
						view:SetSubMaterial(k, "models/XQM/LightLinesRed_tool.vtf")
					end
				end)
			end
		end
	end
	hook.Add("OnViewModelChanged", "nzPaPCamoUpdate", PaPCamoUpdate)
	net.Receive("nzPaPCamo", function() PaPCamoUpdate() end)
end
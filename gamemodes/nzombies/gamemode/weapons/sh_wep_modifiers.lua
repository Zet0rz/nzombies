local WeaponModificationFunctions = {}

function nzWeps:AddWeaponModifier(modifier, apply, revert)
	if !WeaponModificationFunctions[modifier] then WeaponModificationFunctions[modifier] = {} end
	WeaponModificationFunctions[modifier].apply = apply
	WeaponModificationFunctions[modifier].revert = revert
end

local wepmeta = FindMetaTable("Weapon")
if !wepmeta then return end

function wepmeta:ApplyNZModifier(modifier, blocknetwork)
	if WeaponModificationFunctions and WeaponModificationFunctions[modifier] then
		local nonetwork = WeaponModificationFunctions[modifier].apply(self)
		if !nonetwork and !blocknetwork and SERVER then
			nzWeps:SendSync( self.Owner, self, modifier, false )
		end
		
		if !self.NZModifiers then self.NZModifiers = {} end
		self.NZModifiers[modifier] = true
	else
		print("Tried to apply invalid modifier "..modifier.." to weapon "..tostring(self))
	end
end

function wepmeta:RevertNZModifier(modifier, blocknetwork)
	if WeaponModificationFunctions and WeaponModificationFunctions[modifier] then
		local nonetwork = WeaponModificationFunctions[modifier].revert(self)
		if !nonetwork and !blocknetwork and SERVER then
			nzWeps:SendSync( self.Owner, self, modifier, true )
		end
		
		if !self.NZModifiers then self.NZModifiers = {} end
		self.NZModifiers[modifier] = nil
	else
		print("Tried to revert invalid modifier "..modifier.." to weapon "..tostring(self))
	end
end

function wepmeta:HasNZModifier(id)
	if !self.NZModifiers then return false end
	return self.NZModifiers[id] == true
end

-- Let's add the base perks!
-- Dtap2 applies the same modifier, the extra bullets are handled in the EntityFireBullets hook
nzWeps:AddWeaponModifier("dtap", function(wep)
	if wep:HasNZModifier("dtap") != true  then
		if wep.NZModifierAdd and wep:NZModifierAdd("dtap") then return end
		
		if wep:NZPerkSpecialTreatment() then
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
					local old = wep[k]
					wep["old_"..k] = old
					wep[k] = val
				end
			end
		else
			return true -- Return true to prevent networking; for purely server-sided modifications
			-- In this case it's because we handle it differently via function_override
		end
	end
end, function(wep)
	if wep:HasNZModifier("dtap") then
		if wep.NZModifierRemove and wep:NZModifierRemove("dtap") then return end
		
		if wep:NZPerkSpecialTreatment() then
			print("Removing Dtap from: " .. wep.ClassName)
			local data = {}
			-- Normal
			data["FireDelay"] = true
			-- Shotgun Cocking and Sniper Bolting
			data["CockTime"] = true
			data["CockTime_Nomen"] = true
			data["CockTime_Bipod"] = true
			data["CockTime_Bipod_Nomen"] = true
			for k,v in pairs(data) do
				if wep[k] != nil then
					wep[k] = wep["old_"..k]
					wep["old_"..k] = nil
				end
			end
		else
			return true
		end
	end
end)

-- Speed Cola
nzWeps:AddWeaponModifier("speed", function(wep)
	if wep:HasNZModifier("speed") != true then
		if wep.NZModifierAdd and wep:NZModifierAdd("speed") then return end
		
		if wep:NZPerkSpecialTreatment() then
			print("Applying Speed to: " .. wep.ClassName)
			
			if wep:IsTFA() then
				local oldreload = wep.Reload
				wep.Reload = function( self, ... )
					local ct = CurTime()
					oldreload(self, ...)
					local diff = self:GetNextPrimaryFire() - ct
					diff = diff/2 + ct
					
					self:SetReloadingEnd(diff) -- This function handles the ammo refill
					self.ReloadingTime = diff
					self:SetNextPrimaryFire(diff)
					self:SetNextSecondaryFire(diff)
					self:SetNextIdleAnim(diff)
					self:SetPlaybackRate(2)
					self.Owner:GetViewModel():SetPlaybackRate(2)
				end
				wep.OldReload = oldreload
			else
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
						wep["old_"..k] = old
						wep[k] = val
					end
				end
				
				if wep.ReloadTimes then
					wep.old_ReloadTimes = table.Copy(wep.ReloadTimes)
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
			end
		else return true end
	end
end, function(wep)
	if wep:HasNZModifier("speed") then
		if wep.NZModifierRemove and wep:NZModifierRemove("speed") then return end
		
		if wep:NZPerkSpecialTreatment() then
			print("Removing Speed from: " .. wep.ClassName)
			
			if wep:IsTFA() then
				wep.Reload = wep.OldReload
				wep.OldReload = nil
			else
				local data = {}
				-- Normal
				data["ReloadTime"] = true
				data["ReloadTime_Nomen"] = true
				data["ReloadTime_Empty"] = true
				data["ReloadTime_Empty_Nomen"] = true
				-- BiPod
				data["ReloadTime_Bipod"] = true
				data["ReloadTime_Bipod_Nomen"] = true
				data["ReloadTime_Bipod_Empty"] = true
				data["ReloadTime_Bipod_Empty_Nomen"] = true
				-- Shotguns
				data["ReloadStartTime"] = true
				data["ReloadStartTime_Nomen"] = true
				data["ReloadEndTime"] = true
				data["ReloadEndTime_Nomen"] = true
				data["ReloadAbortTime"] = true
				data["ReloadAdvanceTimeEmpty"] = true
				data["ReloadAdvanceTimeEmpty_Nomen"] = true
				data["ReloadAdvanceTimeLast"] = true
				data["ReloadAdvanceTimeLast_Nomen"] = true
				data["InsertTime"] = true
				data["InsertTime_Nomen"] = true
				data["InsertEmpty"] = true
				data["InsertEmpty_Nomen"] = true
				
				for k,v in pairs(data) do
					if wep[k] != nil then
						wep[k] = wep["old_"..k]
						wep["old_"..k] = nil
					end
				end
				
				if wep.ReloadTimes and wep.old_ReloadTimes then
					wep.ReloadTimes = wep.old_ReloadTimes
					wep.old_ReloadTimes = nil
				end
			end
			
		else return true end
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

-- Pack-a-Punch
-- The attachments are irreversible and will only reset on full death and respawn
nzWeps:AddWeaponModifier("pap", function(wep)
	if !wep:HasNZModifier("pap") then
		print("Applying PaP to: " .. (wep.ClassName or tostring(wep)))
		local ply = wep.Owner
		--wep:SetMaterial("models/XQM/LightLineRed_tool.vtf")

		-- Call OnPaP function for specially coded weapons
		local block
		if wep.OnPaP then 
			block = wep:OnPaP() -- This is instead of NZModifierAdd/NZModifierRemove
		end
		if !block then
			
			if wep.Primary and wep.Primary.ClipSize > 0 then
				local newammo = wep.Primary.ClipSize + (wep.Primary.ClipSize*0.5)
				newammo = math.Round(newammo/5)*5
				if newammo <= 0 then newammo = 2 end
				wep.Primary.old_ClipSize = wep.Primary.ClipSize
				wep.Primary.ClipSize = newammo
				if SERVER then wep:SetClip1(newammo) end
				
				if wep:IsCW2() and SERVER then
					wep.Primary.ClipSize_Orig = newammo
					wep.Primary.ClipSize_ORIG_REAL = newammo
					
					-- Random attachments
					if GetConVar("nz_papattachments"):GetBool() and wep.Attachments then
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
				elseif wep:IsFAS2() and SERVER then
					-- Random attachments
					if GetConVar("nz_papattachments"):GetBool() and wep.Attachments then
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
				end
			end
			
			if CLIENT then
				local bannedmatnames = {"hand", "arm", "accessor"}
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
			
		end
	else
		local block
		if wep.OnRePaP then 
			block = wep:OnRePaP()
		end
		if !block then
			-- Reroll attachments by buying again
			if GetConVar("nz_papattachments"):GetBool() and wep.Attachments then
				if wep:IsCW2() then
					for k,v in pairs(wep.Attachments) do
						if string.lower(v.header) != "magazine" and string.lower(v.header) != "mag" then -- Mag can't be edited
							local atts = table.Copy(v.atts)
							for k,v in pairs(atts) do -- Remove all already owned attachments
								if CustomizableWeaponry:hasAttachment(wep.Owner, v) then
									atts[k] = nil
								end
							end
							if #atts > 0 then
								local newatt = math.random(#atts)
								CustomizableWeaponry:giveAttachment(wep.Owner, atts[newatt])
								wep:attach(k, newatt - 1)
								--print(k, newatt-1, atts[newatt])
								--print("Here's the table:")
								--PrintTable(atts)
								--print("------- End of table --------")
								if atts[newatt] then
									print(wep.Owner:Nick().." has Pack-a-Punched and gotten attachment "..atts[newatt])
								end
							end
						end
					end
				elseif wep:IsFAS2() then
					for k,v in pairs(wep.Attachments) do
						if string.lower(v.header) != "magazine" and string.lower(v.header) != "mag" then -- Mag can't be edited
							local atts = {}
							for k2,v2 in pairs(v.atts) do -- List all missing attachments
								if !table.HasValue(ply.FAS2Attachments, v2) then
									table.insert(atts, v2)
								end
							end
							if #atts > 0 then
								local newatt = atts[math.random(#atts)]
								AttachFAS2Attachment(ply, wep, k, newatt)
								if atts[newatt] then
									print(wep.Owner:Nick().." has Pack-a-Punched and gotten attachment "..atts[newatt])
								end
							end
						end
					end
				end
			end
		end
		return true -- Rerolling attachments will not require networking/being run client-side
	end
end, function(wep)
	if wep:HasNZModifier("pap") then
		print("Removing PaP from: " .. wep.ClassName)
		wep:SetMaterial("")

		-- Call OnUnPaP function for specially coded weapons
		local block
		if wep.OnUnPaP then 
			block = wep:OnUnPaP()
		end
		if !block then			
			if wep.Primary and wep.Primary.ClipSize and wep.Primary.old_ClipSize then
				wep.Primary.ClipSize = wep.Primary.old_ClipSize
				wep.Primary.old_ClipSize = nil
				wep:SetClip1(wep.Primary.ClipSize)
			end
		end
		
		--wep.PaPMats = nil
		-- Since attachments are given to the player and not the weapon, we can't remove them again without removing all :(
	else return true end
end)

if SERVER then
	util.AddNetworkString("nzPaPCamo")
	hook.Add("PlayerSwitchWeapon", "nzPaPCamoUpdate", function(ply, old, new)
		if IsFirstTimePredicted() then
			net.Start("nzPaPCamo")
			net.Send(ply)
		end
	end)
end

if CLIENT then
	CreateClientConVar("nz_papcamo", 1, true, false, "Sets whether Pack-a-Punch applies a camo to your viewmodel")

	local function PaPCamoUpdate(vm, old, new)
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
				for k,v in pairs(wep.PaPMats) do
					view:SetSubMaterial(k, "models/XQM/LightLinesRed_tool.vtf")
				end
			end
		end
	end
	hook.Add("OnViewModelChanged", "nzPaPCamoUpdate", PaPCamoUpdate)
	net.Receive("nzPaPCamo", function() PaPCamoUpdate() end)
end
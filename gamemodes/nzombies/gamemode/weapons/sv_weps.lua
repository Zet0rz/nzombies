function nz.Weps.Functions.ApplySpeed( ply, wep )
	--print(ply, wep, wep.speed)
	if wep:IsFAS2() and wep.speed != true then
		print("Applying Speed to: " .. wep.ClassName)
		local data = {}
		data.wepdata = {}
		//Normal
		data.wepdata["ReloadTime"] = 2
		data.wepdata["ReloadTime_Nomen"] = 2
		data.wepdata["ReloadTime_Empty"] = 2
		data.wepdata["ReloadTime_Empty_Nomen"] = 2
		//BiPod
		data.wepdata["ReloadTime_Bipod"] = 2
		data.wepdata["ReloadTime_Bipod_Nomen"] = 2
		data.wepdata["ReloadTime_Bipod_Empty"] = 2
		data.wepdata["ReloadTime_Bipod_Empty_Nomen"] = 2
		//Shotguns
		data.wepdata["ReloadStartTime"] = 2
		data.wepdata["ReloadStartTime_Nomen"] = 2
		data.wepdata["ReloadEndTime"] = 2
		data.wepdata["ReloadEndTime_Nomen"] = 2
		data.wepdata["ReloadAbortTime"] = 2
		data.wepdata["ReloadAdvanceTimeEmpty"] = 2
		data.wepdata["ReloadAdvanceTimeEmpty_Nomen"] = 2
		data.wepdata["ReloadAdvanceTimeLast"] = 2
		data.wepdata["ReloadAdvanceTimeLast_Nomen"] = 2
		data.wepdata["InsertTime"] = 2
		data.wepdata["InsertTime_Nomen"] = 2
		data.wepdata["InsertEmpty"] = 2
		data.wepdata["InsertEmpty_Nomen"] = 2
		
		local oldtbl = {}
		for k,v in pairs(data.wepdata) do
			if wep[k] != nil then
				local val = wep[k] / v
				local old = wep[k]
				-- Save the old so we can remove it later
				wep["old_"..k] = old
				wep[k] = val
				data.wepdata[k] = val
				oldtbl["old_"..k] = old
				--print(k, wep[k], old)
			else
				data.wepdata[k] = nil
			end
		end
		-- Attach the old values to the data
		for k,v in pairs(oldtbl) do
			data.wepdata[k] = v
		end
		-- Attach the weapon to the data
		data["wep"] = wep
		wep["speed"] = true
		data.wepdata["speed"] = true
		nz.Weps.Functions.SendSync( ply, data )
	end
end

function nz.Weps.Functions.ApplyDTap( ply, wep )
	if wep:IsFAS2() and wep.dtap != true then
		print("Applying Dtap to: " .. wep.ClassName)
		local data = {}
		data.wepdata = {}
		//Normal
		data.wepdata["FireDelay"] = 1.2
		//Shotgun Cocking and Sniper Bolting
		data.wepdata["CockTime"] = 1.5
		data.wepdata["CockTime_Nomen"] = 1.5
		data.wepdata["CockTime_Bipod"] = 1.5
		data.wepdata["CockTime_Bipod_Nomen"] = 1.5
		
		local oldtbl = {}
		for k,v in pairs(data.wepdata) do
			if wep[k] != nil then
				local val = wep[k] / v
				local old = wep[k]
				wep["old_"..k] = old
				wep[k] = val
				data.wepdata[k] = val
				oldtbl["old_"..k] = old
			else
				data.wepdata[k] = nil
			end
		end
		for k,v in pairs(oldtbl) do
			data.wepdata[k] = v
		end
		//Attach the weapon to the data
		data["wep"] = wep
		wep["dtap"] = true
		data.wepdata["dtap"] = true
		nz.Weps.Functions.SendSync( ply, data )
	end
end

function nz.Weps.Functions.RemoveSpeed( ply, wep )
	if wep:IsFAS2() and wep.speed then
		print("Removing Speed from: " .. wep.ClassName)
		local data = {}
		data.wepdata = {}
		//Normal
		data.wepdata["ReloadTime"] = true
		data.wepdata["ReloadTime_Nomen"] = true
		data.wepdata["ReloadTime_Empty"] = true
		data.wepdata["ReloadTime_Empty_Nomen"] = true
		//BiPod
		data.wepdata["ReloadTime_Bipod"] = true
		data.wepdata["ReloadTime_Bipod_Nomen"] = true
		data.wepdata["ReloadTime_Bipod_Empty"] = true
		data.wepdata["ReloadTime_Bipod_Empty_Nomen"] = true
		//Shotguns
		data.wepdata["ReloadStartTime"] = true
		data.wepdata["ReloadStartTime_Nomen"] = true
		data.wepdata["ReloadEndTime"] = true
		data.wepdata["ReloadEndTime_Nomen"] = true
		data.wepdata["ReloadAbortTime"] = true
		data.wepdata["ReloadAdvanceTimeEmpty"] = true
		data.wepdata["ReloadAdvanceTimeEmpty_Nomen"] = true
		data.wepdata["ReloadAdvanceTimeLast"] = true
		data.wepdata["ReloadAdvanceTimeLast_Nomen"] = true
		data.wepdata["InsertTime"] = true
		data.wepdata["InsertTime_Nomen"] = true
		data.wepdata["InsertEmpty"] = true
		data.wepdata["InsertEmpty_Nomen"] = true
		for k,v in pairs(data.wepdata) do
			if wep[k] != nil then
				wep[k] = wep["old_"..k]
				data.wepdata[k] = wep[k]
			else
				data.wepdata[k] = nil
			end
		end
		//Attach the weapon to the data
		data["wep"] = wep
		wep["speed"] = nil
		data.wepdata["speed"] = nil
		nz.Weps.Functions.SendSync( ply, data )
	end
end

function nz.Weps.Functions.RemoveDTap( ply, wep )
	if wep:IsFAS2() and wep.dtap then
		print("Removing Dtap from: " .. wep.ClassName)
		local data = {}
		data.wepdata = {}
		//Normal
		data.wepdata["FireDelay"] = true
		//Shotgun Cocking and Sniper Bolting
		data.wepdata["CockTime"] = true
		data.wepdata["CockTime_Nomen"] = true
		data.wepdata["CockTime_Bipod"] = true
		data.wepdata["CockTime_Bipod_Nomen"] = true
		for k,v in pairs(data.wepdata) do
			if wep[k] != nil then
				wep[k] = wep["old_"..k]
				data.wepdata[k] = wep[k]
			else
				data.wepdata[k] = nil
			end
		end
		//Attach the weapon to the data
		data["wep"] = wep
		wep["dtap"] = nil
		data.wepdata["dtap"] = nil
		nz.Weps.Functions.SendSync( ply, data )
	end
end

-- A copy of the FAS2 function, slightly modified to not require the costumization menu
local function AttachFAS2Attachment(ply, wep, group, att)
	if not (IsValid(ply) and ply:Alive() and ply:IsPlaying()) then
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

function nz.Weps.Functions.ApplyPaP( ply, wep )
	if wep.pap != true then
		print("Applying PaP to: " .. wep.ClassName)
		--wep:SetMaterial("models/XQM/LightLineRed_tool.vtf")

		//Call OnPaP function for specially coded weapons
		if wep.OnPaP then wep:OnPaP() end

		local data = {}
		data.wepdata = {}
		data.primarydata = {}
		//Attach the weapon to the data
		data["wep"] = wep
		wep["pap"] = true
		data.wepdata["pap"] = true
		
		if wep.Primary and wep.Primary.ClipSize > 0 then
			local newammo = wep.Primary.ClipSize + (wep.Primary.ClipSize*0.5)
			newammo = math.Round(newammo/5)*5
			if newammo <= 0 then newammo = 2 end
			wep.Primary.ClipSize = newammo
			data.primarydata = {}
			data.primarydata.ClipSize = newammo
			wep:SetClip1(newammo)
			
			if wep:IsCW2() then
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
			elseif wep:IsFAS2() then
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
		nz.Weps.Functions.SendSync( ply, data )
	else
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
end
if not ConVarExists("nz_papattachments") then CreateConVar("nz_papattachments", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Whether Pack-a-Punching a CW2.0 weapon will attach random attachments for each category. Will also strip players of attachments at the beginning of the game.") end

hook.Add("PlayerSpawn", "RemoveCW2Attachments", function(ply)
	if GetConVar("nz_papattachments"):GetBool() and CustomizableWeaponry then
		for k,v in pairs(ply.CWAttachments) do
			CustomizableWeaponry:removeAttachment(ply, k)
		end
	end
end)

--hook.Add("OnEntityCreated", "nz.Weps.OnEntityCreated", nz.Weps.Functions.OnWepCreated)
function GetPriorityWeaponSlot(ply)
	local lastused = ply.LastUsedSWEP or ply:GetActiveWeapon()
	local ie = 2
	if ply:HasPerk("mulekick") then ie = 3 end
	for i = 1, ie do
		local exists = false
		for k,v in pairs(ply:GetWeapons()) do
			if !exists and v:GetNWInt("SwitchSlot") == i then
				exists = true
			end
		end
		if !exists then return i end
	end
	return lastused:GetNWInt("SwitchSlot") or 1, true, lastused:GetClass()
end

local function OnWeaponAdded( weapon )

	if !weapon:IsSpecial() then
		weapon.Weight = 10000
		-- 0 seconds timer for the next tick, where the weapon's owner will be valid
		timer.Simple(0, function()
			local ply = weapon:GetOwner()
			if !nzRound:InState( ROUND_CREATE ) then

				--[[if ply:HasPerk("mulekick") then
					if GetNumberNonSpecialWeapons(ply) > 3 then
						weapon:SetNWInt( "SwitchSlot", ply:GetActiveWeapon():GetNWInt( "SwitchSlot", 1) )
						print(weapon, 1, "Stage 2")
						ply:StripWeapon( ply:GetActiveWeapon():GetClass() )
					else
						weapon:SetNWInt( "SwitchSlot", GetPriorityWeaponSlot(ply) )
						print(weapon, 1, "Stage 3")
					end
				else
					if GetNumberNonSpecialWeapons(ply) > 2 then
						weapon:SetNWInt( "SwitchSlot", ply:GetActiveWeapon():GetNWInt( "SwitchSlot", 1) )
						print(weapon, 1, "Stage 4")
						ply:StripWeapon( ply:GetActiveWeapon():GetClass() )
					elseif GetNumberNonSpecialWeapons(ply) == 1 then
						weapon:SetNWInt( "SwitchSlot", 1 )
						print(weapon, 1, "Stage 5")
					else
						weapon:SetNWInt( "SwitchSlot", 2 )
						print(weapon, 2, "Stage 6", GetNumberNonSpecialWeapons(ply))
					end
				end]]
				
				local slot, exists, rmSWEP = GetPriorityWeaponSlot(ply)
				if exists then ply:StripWeapon(rmSWEP) end
				weapon:SetNWInt( "SwitchSlot", slot )
				
				weapon.Weight = 10000
				ply:SelectWeapon(weapon:GetClass())
				timer.Simple(0, function()
					if IsValid(ply) then
						if ply:HasPerk("speed") then
							nz.Weps.Functions.ApplySpeed( ply, weapon )
						end
						if ply:HasPerk("dtap") or ply:HasPerk("dtap2") then
							nz.Weps.Functions.ApplyDTap( ply, weapon )
						end
						ply:SelectWeapon(weapon:GetClass())
					end
					weapon.Weight = 0
				end)
			end
		end)
	end
	
end

--Hooks
hook.Add("WeaponEquip", "nzOnWeaponAdded", OnWeaponAdded)

hook.Add("PlayerCanPickupWeapon", "PreventWhosWhoWeapons", function(ply, wep)
	if IsValid(wep:GetOwner()) and wep:GetOwner():GetClass() == "whoswho_downed_clone" then return false end
end)
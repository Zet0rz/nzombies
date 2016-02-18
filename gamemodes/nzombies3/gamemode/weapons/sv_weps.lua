function nz.Weps.Functions.ApplySpeed( ply, wep )
	--print(ply, wep, wep.speed)
	if wep:IsFAS2() and wep.speed != true then
		print("Applying Speed to: " .. wep.ClassName)
		local data = {}
		//Normal
		data["ReloadTime"] = true
		data["ReloadTime_Nomen"] = true
		data["ReloadTime_Empty"] = true
		data["ReloadTime_Empty_Nomen"] = true
		//BiPod
		data["ReloadTime_Bipod"] = true
		data["ReloadTime_Bipod_Nomen"] = true
		data["ReloadTime_Bipod_Empty"] = true
		data["ReloadTime_Bipod_Empty_Nomen"] = true
		local oldtbl = {}
		for k,v in pairs(data) do
			if wep[k] != nil then
				local val = wep[k] / 2
				local old = wep[k]
				-- Save the old so we can remove it later
				wep["old_"..k] = old
				wep[k] = val
				data[k] = val
				oldtbl["old_"..k] = old
				--print(k, wep[k], old)
			else
				data[k] = nil
			end
		end
		-- Attach the old values to the data
		for k,v in pairs(oldtbl) do
			data[k] = v
		end
		-- Attach the weapon to the data
		data["wep"] = wep
		wep["speed"] = true
		data["speed"] = true
		nz.Weps.Functions.SendSync( ply, data )
	end
end

function nz.Weps.Functions.ApplyDTap( ply, wep )
	if wep:IsFAS2() and wep.dtap != true then
		print("Applying Dtap to: " .. wep.ClassName)
		local data = {}
		//Normal
		data["FireDelay"] = true
		local oldtbl = {}
		for k,v in pairs(data) do
			if wep[k] != nil then
				local val = wep[k] * 0.66
				local old = wep[k]
				wep["old_"..k] = old
				wep[k] = val
				data[k] = val
				oldtbl["old_"..k] = old
			else
				data[k] = nil
			end
		end
		for k,v in pairs(oldtbl) do
			data[k] = v
		end
		//Attach the weapon to the data
		data["wep"] = wep
		wep["dtap"] = true
		data["dtap"] = true
		nz.Weps.Functions.SendSync( ply, data )
	end
end

function nz.Weps.Functions.RemoveSpeed( ply, wep )
	if wep:IsFAS2() and wep.speed then
		print("Removing Speed from: " .. wep.ClassName)
		local data = {}
		//Normal
		data["ReloadTime"] = true
		data["ReloadTime_Nomen"] = true
		data["ReloadTime_Empty"] = true
		data["ReloadTime_Empty_Nomen"] = true
		//BiPod
		data["ReloadTime_Bipod"] = true
		data["ReloadTime_Bipod_Nomen"] = true
		data["ReloadTime_Bipod_Empty"] = true
		data["ReloadTime_Bipod_Empty_Nomen"] = true
		for k,v in pairs(data) do
			if wep[k] != nil then
				wep[k] = wep["old_"..k]
				data[k] = wep[k]
			else
				data[k] = nil
			end
		end
		//Attach the weapon to the data
		data["wep"] = wep
		wep["speed"] = nil
		data["speed"] = nil
		nz.Weps.Functions.SendSync( ply, data )
	end
end

function nz.Weps.Functions.RemoveDTap( ply, wep )
	if wep:IsFAS2() and wep.dtap then
		print("Removing Dtap from: " .. wep.ClassName)
		local data = {}
		//Normal
		data["FireDelay"] = true
		for k,v in pairs(data) do
			if wep[k] != nil then
				wep[k] = wep["old_"..k]
				data[k] = wep[k]
			else
				data[k] = nil
			end
		end
		//Attach the weapon to the data
		data["wep"] = wep
		wep["dtap"] = nil
		data["dtap"] = nil
		nz.Weps.Functions.SendSync( ply, data )
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
			wep.Primary.ClipSize = newammo
			data.primarydata = {}
			data.primarydata.ClipSize = newammo
			wep:SetClip1(newammo)
		end
		nz.Weps.Functions.SendSync( ply, data )
	end
end

--[[function nz.Weps.Functions.OnWepCreated( ent )
	if ent:IsWeapon() and (nz.Rounds.Data.CurrentState == ROUND_PREP or nz.Rounds.Data.CurrentState == ROUND_PROG) then
		timer.Simple(1, function()
			local ply = ent.Owner
			if ply:HasPerk("speed") then
				nz.Weps.Functions.ApplySleight( ply, ent )
			end
			if ply:HasPerk("dtap") or ply:HasPerk("dtap2") then
				nz.Weps.Functions.ApplyDTap( ply, ent )
			end
		end)
	end
end]]

--hook.Add("OnEntityCreated", "nz.Weps.OnEntityCreated", nz.Weps.Functions.OnWepCreated)
function GetPriorityWeaponSlot(ply)
	if ply:HasPerk("mulekick") then
		for i = 1, 3 do
			local exists = false
			for k,v in pairs(ply:GetWeapons()) do
				if !exists and v:GetNWInt("SwitchSlot") == i then
					exists = true
				end
			end
			if !exists then return i end
		end
	else
		for i = 1, 2 do
			local exists = false
			for k,v in pairs(ply:GetWeapons()) do
				if !exists and v:GetNWInt("SwitchSlot") == i then
					exists = true
				end
			end
			if !exists then return i end
		end
	end
	return ply:GetActiveWeapon():GetNWInt("SwitchSlot", 1), true
end

local function OnWeaponAdded( weapon )

	if !weapon:IsSpecial() then
		-- 0 seconds timer for the next tick, where the weapon's owner will be valid
		timer.Simple(0, function()
			local ply = weapon:GetOwner()
			if !Round:InState( ROUND_CREATE ) then

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
				
				local slot, exists = GetPriorityWeaponSlot(ply)
				if exists then ply:StripWeapon( ply:GetActiveWeapon():GetClass() ) end
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

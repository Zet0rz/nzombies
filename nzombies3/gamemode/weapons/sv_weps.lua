//

function nz.Weps.Functions.IsFAS2( wep )
	if wep.Category == "FA:S 2 Weapons" then
		return true
	end

	return false
end

function nz.Weps.Functions.ApplySpeed( ply, wep )
	print(ply, wep, wep.speed)
	if nz.Weps.Functions.IsFAS2( wep ) and wep.speed != true then
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
	if nz.Weps.Functions.IsFAS2( wep ) and wep.dtap != true then
		print("Applying Dtap to: " .. wep.ClassName)
		local data = {}
		//Normal
		data["FireDelay"] = true
		local oldtbl = {}
		for k,v in pairs(data) do
			if wep[k] != nil then
				local val = wep[k] / 2
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
	if nz.Weps.Functions.IsFAS2( wep ) and wep.speed then
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
	if nz.Weps.Functions.IsFAS2( wep ) and wep.dtap then
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
		//Attach the weapon to the data
		data["wep"] = wep
		wep["pap"] = true
		data["pap"] = true
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

//We use a seperate function for this, as this for some reason works
function nz.Weps.Functions.OnWeaponAdded( weapon )

	if weapon:GetClass() == "nz_perk_bottle" then return end

	//0 seconds timer for the next tick, where the weapon's owner will be valid
	timer.Simple(0, function()
		local ply = weapon:GetOwner()
		if nz.Rounds.Data.CurrentState != ROUND_CREATE then
				
			if ply:HasPerk("mulekick") then
				if #ply:GetWeapons() > 3 then
					ply:StripWeapon( ply:GetActiveWeapon():GetClass() )
				elseif #ply:GetWeapons() == 3 then
					ply.ThirdWeapon = weapon
				end
			else
				if #ply:GetWeapons() > 2 then
					ply:StripWeapon( ply:GetActiveWeapon():GetClass() )
				end
			end
			ply:SelectWeapon( weapon:GetClass() )
			
		end
	end)
	
end

//Hooks
hook.Add("WeaponEquip", "OnWeaponAdded", nz.Weps.Functions.OnWeaponAdded)

hook.Add("PlayerCanPickupWeapon", "PreventWhosWhoWeapons", function(ply, wep)
	if IsValid(wep:GetOwner()) and wep:GetOwner():GetClass() == "whoswho_downed_clone" then return false end
end)

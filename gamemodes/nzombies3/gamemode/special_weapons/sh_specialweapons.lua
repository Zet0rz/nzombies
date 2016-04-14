
-- Crowbar test melee weapon
SpecialWeapons:CreateCategory("knife", 0)
SpecialWeapons:CreateCategory("specialgrenade", IN_GRENADE2, true)
SpecialWeapons:CreateCategory("grenade", IN_GRENADE1, true)
SpecialWeapons:CreateCategory("display", 0)

SpecialWeapons:AddWeapon( "nz_quickknife_crowbar", "knife", function(ply, wep)
	if SERVER then
		ply:SetUsingSpecialWeapon(true)
		ply:SetActiveWeapon(wep)
		timer.Simple(0.05, function()
			if IsValid(ply) then
				ply:ConCommand("+attack")
				timer.Simple(0.1, function()
					if IsValid(ply) then
						ply:ConCommand("-attack")
					end
				end)
			end
		end)
		timer.Simple(0.5, function()
			if IsValid(ply) then
				ply:SetUsingSpecialWeapon(false)
				ply:EquipPreviousWeapon()
			end
		end)
	end
end, function(ply, wep)
end)

SpecialWeapons:AddWeapon( "nz_grenade", "grenade", function(ply) -- Use function
	if SERVER then
		if ply:GetAmmoCount("nz_grenade") <= 0 then return end
		ply:SetUsingSpecialWeapon(true)
		ply:SelectWeapon("nz_grenade")
		timer.Simple(0.5, function()
			if IsValid(ply) then
				local wep = ply:GetActiveWeapon()
				wep:ThrowGrenade(1000)
				ply:SetAmmo(ply:GetAmmoCount("nz_grenade") - 1, "nz_grenade")
			end
		end)
		timer.Simple(1, function()
			if IsValid(ply) then
				ply:SetUsingSpecialWeapon(false)
				ply:SetActiveWeapon(nil)
				ply:EquipPreviousWeapon()
			end
		end)
	else
		local wep = LocalPlayer():GetWeapon("nz_grenade")
		wep:StartGrenadeModel()
		timer.Simple(0.5, function()
			if IsValid(wep) then
				wep:EndGrenadeModel()
			end
		end)
	end
end, function(ply) -- Equip Function
	--ply:SetAmmo(4, "nz_grenade")
end, function(ply) -- Max Ammo function
	ply:SetAmmo(4, "nz_grenade")
end)

-- Does nothing, just needs to count as special
SpecialWeapons:AddWeapon( "nz_perk_bottle", "display", nil, function(ply, wep)
	if SERVER then
		ply:SetUsingSpecialWeapon(true)
		ply:SelectWeapon("nz_perk_bottle")
	end
end)
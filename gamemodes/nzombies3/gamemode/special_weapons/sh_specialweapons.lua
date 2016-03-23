
-- Crowbar test melee weapon
SpecialWeapons:CreateCategory("knife", 0)
SpecialWeapons:AddWeapon( "nz_quickknife_crowbar", "knife", function(ply, wep)
	if SERVER then
		local prevwep = ply:GetActiveWeapon():GetClass()
		ply.UsingSpecialWep = true
		ply:SetActiveWeapon(wep)
		timer.Simple(0.05, function()
			if IsValid(ply) then
				ply:ConCommand("+attack")
				timer.Simple(0.1, function()
					if IsValid(ply) then
						ply:ConCommand("-attack")
					end
				end)
				--[[local tr = util.TraceLine({
					start = ply:GetShootPos(),
					endpos = ply:GetShootPos() + ply:GetAimVector()*75,
					filter = ply,
				})
				if IsValid(tr.Entity) then
					local d = DamageInfo()
					d:SetDamageType(DMG_CLUB)
					d:SetDamage(50)
					tr.Entity:TakeDamageInfo(d)
				end]]
			end
		end)
		timer.Simple(0.5, function()
			if IsValid(ply) then
				ply.UsingSpecialWep = nil
				ply:SelectWeapon(prevwep)
			end
		end)
	end
end, function(ply, wep)
	if SERVER then
		local prevwep = ply:GetActiveWeapon():GetClass()
		ply.UsingSpecialWep = true
		ply:SelectWeapon("weapon_crowbar")
		timer.Simple(0.5, function()
			if IsValid(ply) then
				ply.UsingSpecialWep = nil
				ply:SelectWeapon(prevwep)
			end
		end)
	end
end)

SpecialWeapons:CreateCategory("specialgrenade", IN_GRENADE2, true)
SpecialWeapons:AddWeapon( "monkey_bomb", "specialgrenade", function(ply)
	if SERVER then
		if ply:GetAmmoCount("nz_specialgrenade") <= 0 then return end
		local prevwep = ply:GetActiveWeapon():GetClass()
		ply.UsingSpecialWep = true
		ply:SelectWeapon("monkey_bomb")
		timer.Simple(0.3, function()
			if IsValid(ply) then
				local wep = ply:GetActiveWeapon()
				wep:Throw()
				ply:DoAttackEvent()
				wep:SendWeaponAnim(ACT_VM_THROW)
				ply:SetAmmo(ply:GetAmmoCount("nz_specialgrenade") - 1, "nz_specialgrenade")
			end
		end)
		timer.Simple(1, function()
			if IsValid(ply) then
				ply.UsingSpecialWep = nil
				ply:SelectWeapon(prevwep)
			end
		end)
	end
end, function(ply)
	ply:SetAmmo(2, "nz_specialgrenade")
end)

SpecialWeapons:CreateCategory("grenade", IN_GRENADE1, true)
SpecialWeapons:AddWeapon( "nz_grenade", "grenade", function(ply) -- Use function
	if SERVER then
		if ply:GetAmmoCount("nz_grenade") <= 0 then return end
		local prevwep = ply:GetActiveWeapon():GetClass()
		ply.UsingSpecialWep = true
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
				ply.UsingSpecialWep = nil
				ply:SelectWeapon(prevwep)
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

SpecialWeapons:CreateCategory("perkbottles", 0)
-- Does nothing, just needs to count as special
SpecialWeapons:AddWeapon( "nz_perk_bottle", "perkbottles", nil, function(ply, wep)
	if SERVER then
		ply.UsingSpecialWep = true
		ply:SelectWeapon("nz_perk_bottle")
	end
end)
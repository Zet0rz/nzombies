//Functions
function nz.Weps.Functions.CalculateMaxAmmo(class)
	local wep = weapons.Get(class)
	local clip = wep.Primary.ClipSize

	return clip * 10
end

function nz.Weps.Functions.GiveMaxAmmoWep(ply, class)

	local wep = weapons.Get(class)
	if wep == nil then return end
	local ammo_type = wep.Primary.Ammo
	local max_ammo = nz.Weps.Functions.CalculateMaxAmmo(class)

	local ply_weps = ply:GetWeapons()
	local multi = 0

	for k,v in pairs(ply_weps) do
		local in_wep = weapons.Get(v:GetClass())
		if in_wep != nil then
			if in_wep.Primary.Ammo == ammo_type then
				multi = multi + 1
			end
		end
	end

	max_ammo = max_ammo * multi

	local curr_ammo = ply:GetAmmoCount( ammo_type )
	local give_ammo = max_ammo - curr_ammo

	//Just for display, since we're setting their ammo anyway
	ply:GiveAmmo(give_ammo, ammo_type)
	ply:SetAmmo(max_ammo, ammo_type)
	
end

function nz.Weps.Functions.GiveMaxAmmo(ply)
	for k,v in pairs(ply:GetWeapons()) do
		if !v:IsSpecial() then
			nz.Weps.Functions.GiveMaxAmmoWep(ply, v:GetClass())
		else
			if SpecialWeapons.Weapons[v:GetClass()].maxammo then
				SpecialWeapons.Weapons[v:GetClass()].maxammo(ply, v)
			end
		end
	end
end

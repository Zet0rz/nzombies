//Functions
function nz.Weps.Functions.CalculateMaxAmmo(class, pap)
	local wep = weapons.Get(class)
	local clip = wep.Primary.ClipSize
	
	if pap then
		return math.Round((clip *1.5)/5)* 5 * 10
	else
		return clip * 10
	end
end

function nz.Weps.Functions.GiveMaxAmmoWep(ply, class, papoverwrite)

	local wep = weapons.Get(class)
	if wep == nil then return end
	local ammo_type = wep.Primary.Ammo
	local max_ammo = nz.Weps.Functions.CalculateMaxAmmo(class, (IsValid(ply:GetWeapon(class)) and ply:GetWeapon(class).pap) or papoverwrite)

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
			if nzSpecialWeapons.Weapons[v:GetClass()].maxammo then
				nzSpecialWeapons.Weapons[v:GetClass()].maxammo(ply, v)
			end
		end
	end
end

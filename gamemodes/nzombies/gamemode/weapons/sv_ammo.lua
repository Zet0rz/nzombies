-- Functions
function nzWeps:CalculateMaxAmmo(class, pap)
	local wep = weapons.Get(class)
	local clip = wep.Primary.ClipSize
	
	if pap then
		clip = math.Round((clip *1.5)/5)* 5
		return clip * 10 <= 500 and clip * 10 or clip * math.ceil(500/clip) -- Cap the ammo to stop at the clip that passes 500 max
	else
		return clip * 10 <= 300 and clip * 10 or clip * math.ceil(300/clip) -- 300 max for non-pap weapons
	end
end

function nzWeps:GiveMaxAmmoWep(ply, class, papoverwrite)

	for k,v in pairs(ply:GetWeapons()) do
		-- If the weapon entity exist, just give ammo on that
		if v:GetClass() == class then v:GiveMaxAmmo(papoverwrite) return end
	end
	
	-- Else we'll have to refer to the old system (for now, this should never happen)
	local wep = weapons.Get(class)
	if !wep then return end
	
	-- Weapons can have their own Max Ammo functions that are run instead
	if wep.NZMaxAmmo then wep:NZMaxAmmo() return end
	
	if !wep.Primary then return end
	
	local ammo_type = wep.Primary.Ammo
	local max_ammo = nzWeps:CalculateMaxAmmo(class, (IsValid(ply:GetWeapon(class)) and ply:GetWeapon(class):HasNZModifier("pap")) or papoverwrite)

	local curr_ammo = ply:GetAmmoCount( ammo_type )
	local give_ammo = max_ammo - curr_ammo
	
	--print(give_ammo)

	-- Just for display, since we're setting their ammo anyway
	ply:GiveAmmo(give_ammo, ammo_type)
	ply:SetAmmo(max_ammo, ammo_type)
	
end

local usesammo = {
	["grenade"] = "nz_grenade",
	["specialgrenade"] = "nz_specialgrenade",
}

local plymeta = FindMetaTable("Player")
function plymeta:GiveMaxAmmo(papoverwrite)
	for k,v in pairs(self:GetWeapons()) do
		if !v:IsSpecial() then
			v:GiveMaxAmmo()
		else
			local wepdata = nzSpecialWeapons.Weapons[v:GetClass()] or v.NZSpecialWeaponData
			if !wepdata then return end
			
			local ammo = usesammo[v:GetSpecialCategory()] or wepdata.ammotype
			local maxammo = wepdata.maxammo
			
			if ammo and maxammo then
				self:SetAmmo(maxammo, GetNZAmmoID(ammo) or ammo) -- Special weapon ammo or just that ammo
			end
			
		end
	end
end

local meta = FindMetaTable("Weapon")

function meta:CalculateMaxAmmo(papoverwrite)
	if !self.Primary then return 0 end
	local clip = self.Primary and self.Primary.ClipSize or self.Primary.ClipSize_Orig
	if !clip then return 0 end
	-- When calculated directly on a weapon entity, its clipsize will already have changed from PaP
	if self:HasNZModifier("pap") or papoverwrite then
		return clip * 10 <= 500 and clip * 10 or clip * math.ceil(500/clip) -- Cap the ammo to stop at the clip that passes 500 max
	else
		return clip * 10 <= 300 and clip * 10 or clip * math.ceil(300/clip) -- 300 max for non-pap weapons
	end
end

function meta:GiveMaxAmmo(papoverwrite)

	if self.NZMaxAmmo then self:NZMaxAmmo(papoverwrite) return end

	local ply = self.Owner
	if !IsValid(ply) then return end
	
	local ammo_type = self:GetPrimaryAmmoType() or self.Primary.Ammo
	local max_ammo = self:CalculateMaxAmmo(papoverwrite)

	local curr_ammo = ply:GetAmmoCount( ammo_type )
	local give_ammo = max_ammo - curr_ammo

	-- Just for display, since we're setting their ammo anyway
	ply:GiveAmmo(give_ammo, ammo_type)
	ply:SetAmmo(max_ammo, ammo_type)
	
end
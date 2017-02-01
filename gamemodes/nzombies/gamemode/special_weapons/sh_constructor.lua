-- Setup Doors module
nzSpecialWeapons = nzSpecialWeapons or AddNZModule("SpecialWeapons")

--nzSpecialWeapons.Categories = nzSpecialWeapons.Categories or {}

nzSpecialWeapons.Keys = nzSpecialWeapons.Keys or {
	["knife"] = KEY_V,
	["grenade"] = KEY_G,
	["specialgrenade"] = KEY_B,
}

function nzSpecialWeapons:RegisterSpecialWeaponCategory(id, defaultkey)
	if !self.Keys[id] then
		if defaultkey and CLIENT then CreateClientConVar("nz_key_"..string.lower(id), defaultkey, true, true, "Sets the key that equips "..id..". Uses numbers from gmod's KEY_ enums: http://wiki.garrysmod.com/page/Enums/KEY") end
		self.Keys[id] = defaultkey -- To use as default
	end		
end
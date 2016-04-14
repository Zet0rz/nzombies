function SpecialWeapons:CreateCategory(id, bind, useammo)
	self.Categories[id] = {
		bind = bind,
		--use = useFunc
	}
	if useammo then
		game.AddAmmoType( {
			name = "nz_"..id,
		} )
	end
	self.Keys[bind] = id
end

function SpecialWeapons:AddWeapon( wepclass, id, use, equip, maxammo )
	self.Weapons[wepclass] = {id = id, use = use, equip = equip, maxammo = maxammo}
end

hook.Add("KeyPress", "SpecialWeaponsUsage", function(ply, key)
	local id = SpecialWeapons.Keys[key]
	if id and ply:GetNotDowned() then -- Can't use grenades and stuff while downed
		local wep = ply:GetSpecialWeaponFromCategory( id )
		if IsValid(wep) and !ply:GetUsingSpecialWeapon() and SpecialWeapons.Weapons[wep:GetClass()].use then
			SpecialWeapons.Weapons[wep:GetClass()].use(ply, wep)
		end
	end
end)
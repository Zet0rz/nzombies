function nzSpecialWeapons:CreateCategory(id, bind, useammo)
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

function nzSpecialWeapons:AddWeapon( wepclass, id, use, equip, maxammo )
	self.Weapons[wepclass] = {id = id, use = use, equip = equip, maxammo = maxammo}
end

hook.Add("KeyPress", "SpecialWeaponsUsage", function(ply, key)
	local id = nzSpecialWeapons.Keys[key]
	if id and ply:GetNotDowned() then -- Can't use grenades and stuff while downed
		local wep = ply:GetSpecialWeaponFromCategory( id )
		if IsValid(wep) and !ply:GetUsingSpecialWeapon() and nzSpecialWeapons.Weapons[wep:GetClass()].use then
			nzSpecialWeapons.Weapons[wep:GetClass()].use(ply, wep)
		end
	end
end)
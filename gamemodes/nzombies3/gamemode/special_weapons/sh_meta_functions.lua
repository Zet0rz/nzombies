local wep = FindMetaTable("Weapon")
local ply = FindMetaTable("Player")

function wep:IsSpecial()
	return SpecialWeapons.Weapons[self:GetClass()] and true or false
end

function wep:GetSpecialCategory()
	return SpecialWeapons.Weapons[self:GetClass()].id
end

function ply:GetSpecialWeaponFromCategory( id )
	if !self.SpecialWeapons then self.SpecialWeapons = {} end
	return self.SpecialWeapons[id] or nil
end

-- Prevent players from manually switching to the weapon if it is special - it is handled by the bind
hook.Add("PlayerSwitchWeapon", "PreventSwitchingToSpecialWeapons", function(ply, oldwep, newwep)
	if IsValid(oldwep) and IsValid(newwep) then
		if (!ply.UsingSpecialWep and newwep:IsSpecial()) or (ply.UsingSpecialWep and oldwep:IsSpecial()) then return true end
	end
end)

if SERVER then
	function ply:AddSpecialWeapon(wep)
		if !self.SpecialWeapons then self.SpecialWeapons = {} end
		local id = wep:GetSpecialCategory()
		self.SpecialWeapons[id] = wep
		SpecialWeapons:SendSpecialWeaponAdded(self, wep, id)
		if SpecialWeapons.Weapons[wep:GetClass()].equip then
			SpecialWeapons.Weapons[wep:GetClass()].equip(self, wep)
		end
	end

	-- This hook only works server-side
	hook.Add("WeaponEquip", "SetSpecialWeapons", function(wep)
		if wep:IsSpecial() then
			-- 0 second timer for the next tick where wep's owner is valid
			timer.Simple(0, function()
				local ply = wep:GetOwner()
				if IsValid(ply) then
					ply:AddSpecialWeapon(wep)
				end		
			end)
		end
	end)
end
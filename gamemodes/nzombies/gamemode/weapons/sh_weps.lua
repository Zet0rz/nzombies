local wepMeta = FindMetaTable("Weapon")

function wepMeta:NZPerkSpecialTreatment( )
	if self:IsFAS2() or self:IsCW2() or self:IsTFA() then
		return true
	end

	return false
end

function wepMeta:IsFAS2()
	if self.Category == "FA:S 2 Weapons" or self.Base == "fas2_base" then
		return true
	else
		local base = weapons.Get(self.Base)
		if base and base.Base == "fas2_base" then
			return true
		end
	end

	return false
end

function wepMeta:IsCW2()
	if self.Category == "CW 2.0" or self.Base == "cw_base" then
		return true
	else
		local base = weapons.Get(self.Base)
		if base and base.Base == "cw_base" then
			return true
		end
	end

	return false
end

function wepMeta:IsTFA()
	if self.Category == "TFA" or self.Base == "tfa_gun_base" then
		return true
	else
		local base = weapons.Get(self.Base)
		if base and base.Base == "tfa_gun_base" then
			return true
		end
	end

	return false
end
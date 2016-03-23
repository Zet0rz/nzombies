local wepMeta = FindMetaTable("Weapon")

function wepMeta:NZPerkSpecialTreatment( )
	if self.Category == "FA:S 2 Weapons" or self.Category == "CW 2.0" then
		return true
	end

	return false
end

function wepMeta:IsFAS2()
	if self.Category == "FA:S 2 Weapons" then
		return true
	end

	return false
end

function wepMeta:IsCW2()
	if self.Category == "CW 2.0" or self.Base == "cw_base" then
		return true
	end

	return false
end
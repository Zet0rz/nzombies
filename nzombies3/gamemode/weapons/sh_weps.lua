local wepMeta = FindMetaTable("Weapon")

function wepMeta:IsFAS2( )
	if self.Category == "FA:S 2 Weapons" then
		return true
	end

	return false
end

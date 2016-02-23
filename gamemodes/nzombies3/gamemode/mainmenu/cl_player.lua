local plyMeta = FindMetaTable( "Player" )

function plyMeta:IsNzMenuOpen()
	return IsValid(g_Settings)
end

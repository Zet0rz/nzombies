local plyMeta = FindMetaTable("Player")

function plyMeta:IsNZMenuOpen()
	return IsValid(g_Settings)
end
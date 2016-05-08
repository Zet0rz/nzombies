-- Setup round module
nzMapping = nzMapping or {}

-- Variables
nzMapping.Settings = nzMapping.Settings or {}
nzMapping.MarkedProps = nzMapping.MarkedProps or {}
nzMapping.ScriptHooks = nzMapping.ScriptHooks or {}

-- Once more gamemode entities are added, add the gamemodes to this list
nzMapping.GamemodeExtensions = nzMapping.GamemodeExtensions or {
	["Zombie Survival"] = false,
}

-- Setup round module
nzMapping = nzMapping or AddNZModule("Mapping")

-- Variables
nzMapping.Settings = nzMapping.Settings or {}
nzMapping.MarkedProps = nzMapping.MarkedProps or {}
nzMapping.ScriptHooks = nzMapping.ScriptHooks or {}

-- Once more gamemode entities are added, add the gamemodes to this list
nzMapping.GamemodeExtensions = nzMapping.GamemodeExtensions or {
	["Zombie Survival"] = false,
}

-- Prevent undo without being in creative
-- This can be circumvented with "alias", but it's more for accidental undos than exploit fixing
if CLIENT then
	hook.Add("PlayerBindPress", "nzUndoHandling", function(ply, bind, pressed)
		if string.find(bind, "undo") then
			if !ply:IsInCreative() then
				return true
			end
		end
	end)
end
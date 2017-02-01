-- Add to this table as more conflicting hook names are found
local hooks = {
	"PlayerUse",
}

-- This rehooks all hooks marked in the above table, making nZ-hooks run first to avoid conflicts
hook.Add("InitPostEntity", "nzReorderHooks", function()
	timer.Simple(3, function()
		local tbl = hook.GetTable()
		for k,v in pairs(hooks) do
			local funcs = tbl[v]
			if funcs then
				local nzfuncs = {}
				local nonfuncs = {}
				
				for k2,v2 in pairs(funcs) do -- Loop through all hooks
					if string.sub(k2, 1, 2) == "nz" then -- Store which ones are nZ and which are not
						nzfuncs[k2] = v2
					else
						nonfuncs[k2] = v2
					end
					hook.Remove(v, k2) -- Unhook
				end
				
				-- Now rehook all hooks so the pairs iterator loops through nZ first
				for k2,v2 in pairs(nzfuncs) do
					hook.Add(v, "_"..k2, v2) -- Prepend _ to make it alphabetically first
				end
				for k2,v2 in pairs(nonfuncs) do
					hook.Add(v, "addon_"..k2, v2) -- Prepend "addon_" to make sure, doesn't actually change anything
				end
			end
		end
	end)
end)
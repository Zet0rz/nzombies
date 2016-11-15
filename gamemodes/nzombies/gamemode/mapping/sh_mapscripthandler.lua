if SERVER then
	util.AddNetworkString("NZMapScript")
	util.AddNetworkString("NZMapScriptUnload")
	function nzMapping:LoadScript( name )
	
		self:UnloadScript() -- For safety

		local filePath = "nzmapscripts/" .. string.StripExtension(name) .. ".lua"

		if !file.Exists( filePath, "LUA") then
			local alternative = string.Explode(";", string.StripExtension(name))
			if alternative[1] and alternative[2] then
				filePath = "nzmapscripts/"..alternative[1]..";"..alternative[2]..".lua"
			end
			
			if !file.Exists( filePath, "LUA") then
				PrintMessage(HUD_PRINTTALK, "Attempted to load non-existant map script: "..filePath)
				return false
			end
		end

		-- To keep track of stuff created in this script
		local create = ents.Create
		ents.Create = function(class)
			local ent = create(class)
			ent.NZMapScriptCreated = true
			return ent
		end
		
		self.ScriptHooks = include( filePath )
		self.ScriptPath = filePath
		

		for k,v in pairs(self.ScriptHooks) do
			if type(v) == "function" then
				hook.Add(k, "nzmapscript"..k, v)
			end
		end
		
		if self.ScriptHooks.ClientSideSend then
			AddCSLuaFile( filePath )
			timer.Simple(1, function()
				net.Start("NZMapScript")
					net.WriteString(filePath)
				net.Broadcast()
			end)
		end
		
		--[[hook.Add("OnRoundInit", "nzmapscriptinit", hooks.RoundInit)
		hook.Add("OnRoundStart", "nzmapscriptstart", hooks.RoundStart)
		hook.Add("OnRoundThink", "nzmapscriptthink", hooks.RoundThink)
		hook.Add("OnRoundEnd", "nzmapscriptend", hooks.RoundEnd)]]
		
		if self.ScriptHooks.ScriptLoad then
			self.ScriptHooks.ScriptLoad()
		end
		
		-- Restore
		ents.Create = create

		PrintMessage(HUD_PRINTTALK, "Successfully loaded map script: "..filePath)
		return true

	end

	function nzMapping:UnloadScript()
		if !self.ScriptHooks then return end

		for k,v in pairs(self.ScriptHooks) do
			if type(v) == "function" then
				hook.Remove(k, "nzmapscript"..k)
			end
		end
		
		if self.ScriptHooks.ClientSideSend then
			net.Start("NZMapScriptUnload")
			net.Broadcast()
		end

		--[[hook.Remove("OnRoundInit", "nzmapscriptinit")
		hook.Remove("OnRoundStart", "nzmapscriptstart")
		hook.Remove("OnRoundThink", "nzmapscriptthink")
		hook.Remove("OnRoundEnd", "nzmapscriptend")]]
		
		if self.ScriptHooks.ScriptUnload then
			self.ScriptHooks.ScriptUnload()
		end

		self.ScriptHooks = nil
		
		-- Remove all created entities that weren't already
		for k,v in pairs(ents.GetAll()) do
			if v.NZMapScriptCreated then v:Remove() end
		end
		
		-- Clean up all items
		nzItemCarry:CleanUp()
		
	end
	
	hook.Add("PlayerInitialSpawn", "SendMapScriptSpawn", function(ply)
		if nzMapping.ScriptHooks and nzMapping.ScriptHooks.ClientSideSend then
			timer.Simple(1, function()
				net.Start("NZMapScript")
					net.WriteString(nzMapping.ScriptPath)
				net.Broadcast()
			end)
		end
	end)
end

if CLIENT then

	net.Receive("NZMapScript", function()
		local path = net.ReadString()
		print(path)
		
		if !file.Exists( path, "LUA") then return end

		nzMapping.ScriptHooks = include( path )
		
		PrintTable(nzMapping.ScriptHooks)

		for k,v in pairs(nzMapping.ScriptHooks) do
			if isfunction(v) then
				hook.Add(k, "nzmapscript"..k, v)
			end
		end
		
		if nzMapping.ScriptHooks.ScriptLoad then
			nzMapping.ScriptHooks.ScriptLoad()
		end
	end)
	
	net.Receive("NZMapScriptUnload", function()	
		if !nzMapping.ScriptHooks then return end

		for k,v in pairs(nzMapping.ScriptHooks) do
			if isfunction(v) then
				hook.Remove(k, "nzmapscript"..k)
			end
		end
		
		if nzMapping.ScriptHooks.ScriptUnload then
			nzMapping.ScriptHooks.ScriptUnload()
		end

		nzMapping.ScriptHooks = nil
		nzMapping.ScriptPath = nil
	end)

end

function nzMapping:GetMapScript()
	return self.ScriptHooks
end
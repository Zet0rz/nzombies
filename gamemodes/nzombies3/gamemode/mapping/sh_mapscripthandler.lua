if SERVER then
	util.AddNetworkString("NZMapScript")
	util.AddNetworkString("NZMapScriptUnload")
	function Mapping:LoadScript( name )
	
		self:UnloadScript() -- For safety

		local filePath = "nzmapscripts/" .. string.StripExtension(name) .. ".lua"

		if !file.Exists( filePath, "LUA") then
			PrintMessage(HUD_PRINTTALK, "Attempted to load non-existant map script: "..filePath)
			return false 
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

		PrintMessage(HUD_PRINTTALK, "Successfully loaded map script: "..filePath)
		return true

	end

	function Mapping:UnloadScript()
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
		
	end
	
	hook.Add("PlayerInitialSpawn", "SendMapScriptSpawn", function(ply)
		if Mapping.ScriptHooks and Mapping.ScriptHooks.ClientSideSend then
			timer.Simple(1, function()
				net.Start("NZMapScript")
					net.WriteString(Mapping.ScriptPath)
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

		Mapping.ScriptHooks = include( path )
		
		PrintTable(Mapping.ScriptHooks)

		for k,v in pairs(Mapping.ScriptHooks) do
			if isfunction(v) then
				hook.Add(k, "nzmapscript"..k, v)
			end
		end
		
		if Mapping.ScriptHooks.ScriptLoad then
			Mapping.ScriptHooks.ScriptLoad()
		end
	end)
	
	net.Receive("NZMapScriptUnload", function()	
		if !Mapping.ScriptHooks then return end

		for k,v in pairs(Mapping.ScriptHooks) do
			if isfunction(v) then
				hook.Remove(k, "nzmapscript"..k)
			end
		end
		
		if Mapping.ScriptHooks.ScriptUnload then
			Mapping.ScriptHooks.ScriptUnload()
		end

		Mapping.ScriptHooks = nil
		Mapping.ScriptPath = nil
	end)

end
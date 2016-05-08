ENT.Type = "point"


function ENT:Initialize()
	-- Remove it as soon as it spawns, if the gamemode hasn't been enabled in Map Settings
	if !nzMapping.Settings.gamemodeentities then
		self:Remove()
	end
end

function ENT:Think()
end

function ENT:AcceptInput(name, activator, caller, args)
	name = string.lower(name)
	if string.sub(name, 1, 2) == "on" then
		self:FireOutput(name, activator, caller, args)
		return true
	elseif name == "win" then
		nzRound:Win("You survived after "..nzRound:GetNumber().." rounds!")
		return true
	elseif name == "lose" then
		nzRound:Lose("You got overwhelmed after "..nzRound:GetNumber().." rounds!")
		return true
	elseif name == "setendslomo" then
		self:SetKeyValue("endslomo", args)
		return true
	elseif name == "setendcamera" then
		self:SetKeyValue("endcamera", args)
		return true
	elseif name == "setendcamerapos" then
		self:SetKeyValue("endcamerapos", args)
		return true
	elseif name == "setwinmusic" then
		self:SetKeyValue("winmusic", args)
		return true
	elseif name == "setlosemusic" then
		self:SetKeyValue("losemusic", args)
		return true
	end
end

function ENT:KeyValue(key, value)
	key = string.lower(key)
	if string.sub(key, 1, 2) == "on" then
		self:AddOnOutput(key, value)
	elseif key == "endslomo" then
		nzRound.OverrideEndSlomo = value == "1"
	elseif key == "endcamera" then
		SetGlobalBool("endcamera", value == "1")
	elseif key == "setendcamerapos" then
		SetGlobalVector("endcamerapos", Vector(value))
	elseif key == "winmusic" then
		if value == "default" then
			SetGlobalString("winmusic", nil)
		else
			SetGlobalString("winmusic", value)
		end
	elseif key == "losemusic" then
		if value == "default" then
			SetGlobalString("losemusic", nil)
		else
			SetGlobalString("losemusic", value)
		end
	end
end

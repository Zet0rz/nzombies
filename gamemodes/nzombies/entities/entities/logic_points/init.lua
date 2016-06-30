ENT.Type = "point"

function ENT:Initialize()
	-- Remove it as soon as it spawns, if the gamemode hasn't been enabled in Map Settings
	if !nzMapping.Settings.gamemodeentities then
		self:Remove()
	end
end

-- We need to scale the point requirements up to what fits nZombies more
local conversionrate = 100

function ENT:Add(pl, amount)
	-- Instead of a player team check, we check if the player is playing
	if pl and pl:IsValid() and pl:IsPlayer() and pl:IsPlaying() then
		amount = math.Round(amount)
		if amount < 0 then
			pl:TakePoints(-amount)
		else
			pl:GivePoints(amount, true) -- We ignore double points for this
		end
	end
end

function ENT:Set(pl, amount)
	-- You CANNOT set the player's points in nZombies!
end

function ENT:GetAmount(pl)
	return pl:GetPoints()
end

function ENT:CallIf(pl, amount)
	if pl and pl:IsValid() and pl:IsPlayer() and pl:IsPlaying() then
		self:Input(pl:IsPlaying() and self:GetAmount(pl) >= amount and "onconditionpassed" or "onconditionfailed", pl, self, amount)
	end
end

function ENT:CallIfNot(pl, amount)
	if pl and pl:IsValid() and pl:IsPlayer() and pl:IsPlaying() then
		self:Input(pl:IsPlaying() and self:GetAmount(pl) >= amount and "onconditionfailed" or "onconditionpassed", pl, self, amount)
	end
end

function ENT:AcceptInput(name, activator, caller, args)
	name = string.lower(name)
	-- We multiply with our conversion rate and round to nearest 10
	local amount = math.Round(tonumber(args) * conversionrate, -1) or 0
	if string.sub(name, 1, 2) == "on" then
		self:FireOutput(name, activator, caller, args)
	elseif name == "addtoactivator" then
		self:Add(activator, amount)
	elseif name == "takefromactivator" then
		self:Add(activator, -amount)
	elseif name == "addtocaller" then
		self:Add(caller, amount)
	elseif name == "takefromcaller" then
		self:Add(caller, -amount)
	elseif name == "callifactivatorhave" then
		self:CallIf(activator, amount)
	elseif name == "callifactivatornothave" then
		self:CallIfNot(activator, amount)
	elseif name == "callifcallerhave" then
		self:CallIf(caller, amount)
	elseif name == "callifcallernothave" then
		self:CallIfNot(caller, amount)
	elseif name == "setactivatoramount" then
		self:Set(activator, amount)
	elseif name == "setcalleramount" then
		self:Set(caller, amount)
	end
end

function ENT:KeyValue(key, value)
	key = string.lower(key)
	if string.sub(key, 1, 2) == "on" then
		self:AddOnOutput(key, value)
	end
end

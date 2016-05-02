
ENT.Type = "point"
ENT.Base = "base_point"

-- An entity to be used in Hammer that can turn the electricity on or off, and will fire outputs when this happens.
-- To use it, grab the nzombies.fgd from the gamemode and import it into Hammer.

function ENT:Initialize()
	-- Calling this when the entity is created so you can turn off the lights only if the gamemode is nZombies.
	if engine.ActiveGamemode() == "nzombies3" then
		self:TriggerOutput("OnInitialized", self)
	end
end

function ENT:KeyValue(k, v)
   
end

function ENT:AcceptInput(name, activator, caller, data)
	if name == "TurnElectricityOn" then
		nzElec:Activate(data == "1")
		return true
	elseif name == "TurnElectricityOff" then
		nzElec:Reset(data == "1")
		return true
	end
end
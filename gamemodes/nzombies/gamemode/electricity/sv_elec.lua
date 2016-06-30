//

function nzElec:Activate(nochat)

	if self.Active then return end -- We don't wanna turn it on twice

	self.Active = true
	self:SendSync()
	
	-- Open all doors with no price and electricity requirement
	for k,v in pairs(ents.GetAll()) do
		if v:IsBuyableEntity() then
			local data = v:GetDoorData()
			if data then
				if tonumber(data.price) == 0 and tobool(data.elec) == true then
					nzDoors:OpenDoor( v )
				end
			end
		end
	end
	
	-- Turn on all perk machines
	for k,v in pairs(ents.FindByClass("perk_machine")) do
		v:TurnOn()
	end
	
	local wund = ents.FindByClass("wunderfizz_machine")
	local machine = wund[math.random(#wund)]
	if IsValid(machine) then machine:TurnOn() end
	
	-- Inform players
	if !nochat then
		PrintMessage(HUD_PRINTTALK, "[NZ] Electricity is on!")
		net.Start("nz.nzElec.Sound")
			net.WriteBool(true)
		net.Broadcast()
	end
	
	for k,v in pairs(ents.FindByClass("nz_electricity")) do
		v:Fire("OnElectricityOn")
	end
	
	hook.Call("ElectricityOn")
	
end

function nzElec:Reset(nochat)

	if !self.Active then return end -- No need to turn it off again
	
	self.Active = false
	-- Reset the button aswell
	local prevs = ents.FindByClass("power_box")
	for k,v in pairs(prevs) do
		v:SetSwitch(false)
	end
	
	self:SendSync()
	
	if !nochat then
		net.Start("nz.nzElec.Sound")
			net.WriteBool(false)
		net.Broadcast()
	end
	
	for k,v in pairs(ents.FindByClass("nz_electricity")) do
		v:Fire("OnElectricityOff")
	end
	
	hook.Call("ElectricityOff")
	
end
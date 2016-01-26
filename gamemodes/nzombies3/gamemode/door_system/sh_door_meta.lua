local meta = FindMetaTable("Entity")

function meta:IsDoor()
	if not IsValid(self) then return false end
	local class = self:GetClass()

	if class == "func_door" or
		class == "func_door_rotating" or
		class == "prop_door_rotating" or
		class == "prop_dynamic" then
		return true
	end
	return false
end

function meta:IsButton()
	if not IsValid(self) then return false end
	local class = self:GetClass()

	if class == "func_button" or (CLIENT and class == "class C_BaseEntity") then
		return true
	end
	return false
end

function meta:IsBuyableProp()
	if not IsValid(self) then return false end
	local class = self:GetClass()

	if class == "prop_buys" then
		return true
	end
	return false
end

function meta:doorIndex()
	if SERVER then
		return self:CreatedByMap() and self:MapCreationID() or nil
	else
		//Check the ED table
		return nz.Doors.Data.EaDI[self:EntIndex()] or 0
	end
end

function meta:DoorUnlock()
	//Delay opening the door by a second to stop the door from accidentally opening then closing forever.
	//timer.Simple(1, function() 
		if self:IsDoor() then
			print("Unlocking ", self)
			self.Locked = false
			self:Fire("unlock", "", 0)
			self:Fire("Unlock", "", 0)
			self:Fire("open", "", 0)	//Seems like some doors wanted it capitalized
			self:Fire("Open", "", 0)
			
			//Doors that can be rebought should not be locked - only use this on doors with buttons that should close again!
			if tobool(self.rebuyable) then return end
			
			self:Fire("lock", "", 0)
			self:Fire("Lock", "", 0)
			self:SetKeyValue("wait",-1)
			self:SetKeyValue("Wait",-1)
			
			//Dem sneaky doors keep closing themselves with their modern triggers - we gotta reopen!
			self:Fire("addoutput", "onclose !self:open::0:-1,0,-1")
			self:Fire("addoutput", "onclose !self:unlock::0:-1,0,-1")
				
		elseif self:IsBuyableProp() then
			self.Locked = false
			self:BlockUnlock()
		end
	//end)
end

function meta:ButtonUnlock(rebuyable)
	if self:IsButton() then
		print("Unlocked button!")
		print(self)
		--self:Fire("unlock")
		self:Fire("Unlock")
		--self:Fire("press")
		self:Fire("Press")
		--self:Fire("pressin")
		self:Fire("PressIn")
		--self:Fire("pressout")
		self:Fire("PressOut")
		
		//Repurchasable buttons don't lock
		if rebuyable then return end
		
		--self:Fire("lock")
		self:Fire("Lock")
		--self:SetKeyValue("wait",-1)
		self:SetKeyValue("Wait",-1)
		
		self.Locked = false
	end
end

function meta:ButtonLock()
	if self:IsButton() then
		self.Locked = true
		--self:Fire("lock", "", 0)
		--self:Fire("Lock", "", 0)
	end
end

function meta:DoorLock()
	if self:IsDoor() then
		print("Locked ", self)
		self.Locked = true
		
		if self.buyable and !tobool(self.buyable) then print("Not locking door", self) return end
		
		self:Fire("close", "", 0)
		self:Fire("Close", "", 0)
		self:Fire("lock", "", 0)
		self:Fire("Lock", "", 0)
	elseif self:IsBuyableProp() then
		self:BlockLock()
	end
end
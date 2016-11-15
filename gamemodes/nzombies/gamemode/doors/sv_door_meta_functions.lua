local meta = FindMetaTable("Entity")

function meta:UnlockDoor()
		if self:IsDoor() then
			local data = self:GetDoorData()
			if data.NextBuy and data.NextBuy > CurTime() then return end
			print("Unlocking door ", self)
			
			self:Fire("unlock", "", 0)
			self:Fire("Unlock", "", 0)
			self:Fire("open", "", 0)	-- Seems like some doors wanted it capitalized
			self:Fire("Open", "", 0)
			
			-- Doors that can be rebought should not be locked - only use this on doors with buttons that should close again!
			if tobool(data.rebuyable) then return end
			
			self:SetLocked(false)
			self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
			
			self:Fire("lock", "", 0)
			self:Fire("Lock", "", 0)
			self:SetKeyValue("wait",-1)
			self:SetKeyValue("Wait",-1)
			
			-- Dem sneaky doors keep closing themselves with their modern triggers - we gotta reopen!
			self:Fire("addoutput", "onclose !self:open::0:-1,0,-1")
			self:Fire("addoutput", "onclose !self:unlock::0:-1,0,-1")
				
		elseif self:IsBuyableProp() then
			self:SetLocked(false)
			self:BlockUnlock()
		end
end

function meta:UnlockButton(rebuyable)
	if self:IsButton() then
		print("Unlocked button", self)
		--print(self)
		--self:Fire("unlock")
		self:Fire("Unlock")
		--self:Fire("press")
		self:Fire("Press")
		--self:Fire("pressin")
		self:Fire("PressIn")
		--self:Fire("pressout")
		self:Fire("PressOut")
		
		-- Repurchasable buttons don't lock
		if rebuyable then return end
		
		--self:Fire("lock")
		self:Fire("Lock")
		--self:SetKeyValue("wait",-1)
		self:SetKeyValue("Wait",-1)
		
		self:SetLocked(false)
	end
end

function meta:LockButton()
	if self:IsButton() then
		self:SetLocked(true)
		--self:Fire("lock", "", 0)
		--self:Fire("Lock", "", 0)
	end
end

function meta:LockDoor()
	if self:IsDoor() then
		local data = self:GetDoorData()
		print("Locked ", self)
		self:SetLocked(true)
		--self:SetCollisionGroup(COLLISION_GROUP_NONE)
		
		if data.buyable and !tobool(data.buyable) then return end
		
		self:Fire("close", "", 0)
		self:Fire("Close", "", 0)
		self:Fire("lock", "", 0)
		self:Fire("Lock", "", 0)
	elseif self:IsBuyableProp() then
		self:BlockLock()
	end
end
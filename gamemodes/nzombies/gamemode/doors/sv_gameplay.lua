function nzDoors:OpenDoor( ent, ply )
	local data = ent:GetDoorData()
	local link = data.link
	local rebuyable = data.rebuyable
	
	-- Open the door and any other door with the same link
	if ent:IsScriptBuyable() then
		ent.BuyFunction(ply)
		if !tobool(rebuyable) then
			ent:SetLocked(false)
		end
	elseif ent:IsButton() then
		ent:UnlockButton(tobool(ent.rebuyable))
	else
		ent:UnlockDoor()
	end
	
	-- Sync
	if link != nil then
		self.OpenedLinks[link] = true
	end
	hook.Call("OnDoorUnlocked", self, ent, link, rebuyable, ply)
end

function nzDoors:OpenLinkedDoors( link, ply )
	-- Go through all the doors
	for k,v in pairs(self.MapDoors) do
		if v.flags then
			local doorlink = v.flags.link
			if doorlink and doorlink == link then
				self:OpenDoor( self:DoorIndexToEnt(k), ply )
			end
		end
	end
	
	for k,v in pairs(self.PropDoors) do
		if v.flags then
			local doorlink = v.flags.link
			if doorlink and doorlink == link then
				self:OpenDoor( Entity(k), ply )
			end
		end
	end
	
	self.OpenedLinks[link] = true
end

function nzDoors:LockAllDoors()
	-- Force all doors to lock and stay open when opened
	for k,v in pairs(ents.GetAll()) do
		if (v:IsDoor() or v:IsBuyableProp()) then
			-- Only lock doors that have been assigned a price - Prop Dynamics may be tied to invisible func_doors
			if self.MapDoors[v:DoorIndex()] or self.PropDoors[v:EntIndex()] then
				v:SetUseType( SIMPLE_USE )
				v:LockDoor()
				v:SetKeyValue("wait",-1)
				print("Locked door ", v)
			else
				//Unlocked doors get an output which forces it to stay open once you open it
				v:Fire("addoutput", "onclose !self:open::0:-1,0,-1")
				v:Fire("addoutput", "onclose !self:unlock::0:-1,0,-1")
				print("Added lock output to", v)
				//They now get that output through OpenDoor too, but for safety
			end
		//Allow locking buttons
		elseif v:IsButton() and self.MapDoors[v:DoorIndex()] then
			v:ButtonLock()
			v:SetUseType( SIMPLE_USE )
		end
	end
	self.OpenedLinks = {}
	hook.Call("OnAllDoorsLocked", self)
end

function nzDoors:BuyDoor( ply, ent )
	if ent.lasttime and ent.lasttime + 2 > CurTime() then return end
	
	local flags = ent:GetDoorData()
	if !flags then return end
	local price = tonumber(flags.price)
	local req_elec = tonumber(flags.elec) or 0
	local link = flags.link
	local buyable = flags.buyable or 1
	--print("Entity info buying ", ent, link, req_elec, price, buyable, ent:IsLocked())
	-- If it has a price and it can be bought
	if price != nil and tonumber(buyable) == 1 then
		if ply:CanAfford(price) and ent:IsLocked() then
			-- If this door doesn't require electricity or if it does, then if the electricity is on at the same time
			if (req_elec == 0 or (req_elec == 1 and IsElec())) then
				ply:TakePoints(price)
				if link == nil then
					self:OpenDoor( ent, ply )
				else
					self:OpenLinkedDoors( link, ply )
				end
			end
		end
	elseif price == nil and buyable == nil and !ent:IsBuyableProp() then
		-- Doors that can be opened because the gamemode doesn't lock them, still need to try and lock upon opening.
		-- Additionally, they get the OnClose output added, in case they can still close
		ent:UnlockDoor()
	end
	
	ent.lasttime = CurTime()
end


//Hooks

function nzDoors.OnUseDoor( ply, ent )
	-- Downed players can't use anything!
	if !ply:GetNotDowned() then return false end
	
	-- Players can't use stuff while using special weapons! (Perk bottles, knives, etc)
	if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():IsSpecial() then return false end
	
	if ent:IsBuyableEntity() then
		if ent.buyable == nil or tobool(ent.buyable) then
			nzDoors:BuyDoor( ply, ent )
		end
	end
end
hook.Add( "PlayerUse", "nzPlayerBuyDoor", nzDoors.OnUseDoor )

function nzDoors.CheckUseDoor(ply, ent)
	--print(ply, ent)

	local tr = util.QuickTrace(ply:EyePos(), ply:GetAimVector()*100, ply)
	local door = tr.Entity
	--print(door)
	
	if IsValid(door) and door:IsDoor() then
		return door
	else
		for k,v in pairs(ents.FindInSphere(ply:EyePos(), 1)) do
			if v:GetClass() == "nz_triggerzone" then
				return v
			end
		end
	end
	
end
hook.Add("FindUseEntity", "nzCheckDoor", nzDoors.CheckUseDoor)
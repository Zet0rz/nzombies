function Doors:DoorToEntIndex(num)
	local ent = ents.GetMapCreatedEntity(num)

	return IsValid(ent) and ent:EntIndex() or nil
end

function Doors:DoorIndexToEnt(num)
	if !num then return nil end
	return ents.GetMapCreatedEntity(num) or NULL
end

function Doors:ParseFlagString( flagsStr )

	local tbl = {}
	
	flagsStr = string.lower(flagsStr)
	
	-- Translate the flags string into a table
	local ex = string.Explode( ",", flagsStr )
	
	for k,v in pairs(ex) do
		local ex2 = string.Explode( "=", v )
		tbl[ex2[1]] = ex2[2]
		-- If buyable is not set on a door, we default to on
		if !tbl["buyable"] and k == #ex then
			tbl["buyable"] = "1"
		end
	end
	
	--PrintTable(tbl)
	return tbl
	
end

function Doors:CreateLink( ent, flagsStr )
	-- First remove all links
	--self:RemoveLink( ent )
	if ent:IsDoor() or ent:IsButton() then
		self:CreateMapDoorLink( ent:DoorIndex(), flagsStr )
	elseif ent:IsBuyableProp() or ent:IsScriptBuyable() then
		self:CreatePropDoorLink( ent, flagsStr )
	end
end

function Doors:RemoveLink( ent, nohook )
	if ent:IsDoor() or ent:IsButton() then
		self:RemoveMapDoorLink( ent:DoorIndex() )
	elseif ent:IsBuyableProp() then
		self:RemovePropDoorLink( ent )
	end
	if !nohook then
		hook.Call("OnDoorUnlocked", self, ent)
	end
end

function Doors:CreateMapDoorLink( doorID, flagsStr )

	local door = self:DoorIndexToEnt(doorID)
	if !flagsStr then ErrorNoHalt("Door "..doorID.." doesn't have a flagsStr saved!") return end
	local flagsTbl = self:ParseFlagString( flagsStr )
	
	if IsValid(door) and (door:IsDoor() or door:IsButton()) then
		-- Assign the flags to the door and the table
		door:SetDoorData(flagsTbl)
		door:SetLocked(true)
		--self.MapDoors[doorID] = flagsTbl
		
		hook.Call("OnMapDoorLinkCreated", self, door, flagsTbl, doorID)
	else
		print("Error: " .. doorID .. " is not a door.")
	end
	
end

function Doors:RemoveMapDoorLink( doorID )

	local door = self:DoorIndexToEnt(doorID)
	
	if door:GetDoorData() then
		if IsValid(door) and (door:IsDoor() or door:IsButton()) then	
			self.MapDoors[doorID] = nil
			
			hook.Call("OnMapDoorLinkRemoved", self, door, doorID)
		else
			print("Error: " .. doorID .. " is not a door. ")
		end
	end
	
end

function Doors:CreatePropDoorLink( ent, flagsStr )

	local flagsTbl = self:ParseFlagString( flagsStr )
	
	if IsValid(ent) and ent:IsBuyableProp() then
		ent:SetDoorData(flagsTbl)
		ent:SetLocked(true)
		--self.PropDoors[ent:EntIndex()] = flagsTbl
		
		hook.Call("OnPropDoorLinkCreated", self, ent, flagsTbl)
	else
		--print("Error: " .. doorID .. " is not a door. ")
	end
	
end

function Doors:RemovePropDoorLink( ent )
	
	if IsValid(ent) and ent:IsBuyableProp() then
		-- Total clear of the table
		self.PropDoors[ent:EntIndex()] = nil
		
		hook.Call("OnPropDoorLinkRemoved", self, ent)
	else
		--print("Error: " .. doorID .. " is not a door. ")
	end
end

function Doors:DisplayDoorLinks( ent )
	if ent.link == nil then self.DisplayLinks[ent] = nil return end
	
	if self.DisplayLinks[ent] == nil then
		self.DisplayLinks[ent] = ent.link
	else
		self.DisplayLinks[ent] = nil
	end
	self:SendSync()
end
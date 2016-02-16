local meta = FindMetaTable("Entity")

Doors.MapDoors = Doors.MapDoors or {}
Doors.PropDoors = Doors.PropDoors or {}
Doors.OpenedLinks = Doors.OpenedLinks or {}

function meta:IsLocked() 
	if self:IsBuyableProp() then
		return Doors.PropDoors[self:EntIndex()].locked
	else
		return Doors.MapDoors[self:DoorIndex()].locked
	end
end

function meta:SetLocked( bool )
	if self:IsBuyableProp() then
		if !Doors.PropDoors[self:EntIndex()] then Doors.PropDoors[self:EntIndex()] = {} end
		Doors.PropDoors[self:EntIndex()].locked = bool
	else
		if !Doors.MapDoors[self:DoorIndex()] then Doors.MapDoors[self:DoorIndex()] = {} end
		Doors.MapDoors[self:DoorIndex()].locked = bool
	end
end

local validdoors = {
	["func_door"] = true,
	["func_door_rotating"] = true,
	["prop_door_rotating"] = true,
	["prop_dynamic"] = true,
}

function meta:IsDoor()
	if not IsValid(self) then return false end
	local class = self:GetClass()

	return validdoors[class] or false
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
	return self:GetClass() == "prop_buys"
end

function meta:IsBuyableMapEntity()
	return self:IsDoor() or self:IsButton() or self:IsBuyableProp()
end

function meta:DoorIndex()
	if SERVER then
		return self:CreatedByMap() and self:MapCreationID() or nil
	else
		-- Check the ED table
		return Doors.MapCreationIndexTable[self:EntIndex()] or 0
	end
end

function meta:GetDoorData()
	if self:IsBuyableProp() then
		if !Doors.PropDoors[self:EntIndex()] then return nil end
		return Doors.PropDoors[self:EntIndex()].flags
	else
		if !Doors.MapDoors[self:DoorIndex()] then return nil end
		return Doors.MapDoors[self:DoorIndex()].flags
	end
end

function meta:SetDoorData( tbl )
	if self:IsBuyableProp() then
		if !Doors.PropDoors[self:EntIndex()] then Doors.PropDoors[self:EntIndex()] = {} end
		Doors.PropDoors[self:EntIndex()].flags = tbl
	else
		if !Doors.MapDoors[self:DoorIndex()] then Doors.MapDoors[self:DoorIndex()] = {} end
		Doors.MapDoors[self:DoorIndex()].flags = tbl
	end
end

function Doors:DoorIndexByID( id )
	if SERVER then
		local ent = Entity(id)
		return ent:CreatedByMap() and ent:MapCreationID() or nil
	else
		-- Check the ED table
		return Doors.MapCreationIndexTable[id] or 0
	end
end

function Doors:SetDoorDataByID( id, prop, tbl )
	if !tbl then return end
	if prop then
		if !self.PropDoors[id] then self.PropDoors[id] = {} end
		self.PropDoors[id].flags = tbl
	else
		if !self.MapDoors[id] then self.MapDoors[id] = {} end
		self.MapDoors[id].flags = tbl
	end
end

function Doors:SetLockedByID( id, prop, bool )
	if prop then
		if !Doors.PropDoors[id] then Doors.PropDoors[id] = {} end
		self.PropDoors[id].locked = bool
	else
		local index = Doors:DoorIndexByID( id )
		if !Doors.MapDoors[index] then Doors.MapDoors[index] = {} end
		self.MapDoors[index].locked = bool
	end
end
local meta = FindMetaTable("Entity")

nzDoors.MapDoors = nzDoors.MapDoors or {}
nzDoors.PropDoors = nzDoors.PropDoors or {}
nzDoors.OpenedLinks = nzDoors.OpenedLinks or {}

function meta:IsLocked() 
	if self:IsBuyableProp() or self:IsScriptBuyable() then
		return nzDoors.PropDoors[self:EntIndex()] and nzDoors.PropDoors[self:EntIndex()].locked or false
	else
		return nzDoors.MapDoors[self:DoorIndex()] and nzDoors.MapDoors[self:DoorIndex()].locked or false
	end
end

function meta:SetLocked( bool )
	if self:IsBuyableProp() or self:IsScriptBuyable() then
		if !nzDoors.PropDoors[self:EntIndex()] then nzDoors.PropDoors[self:EntIndex()] = {} end
		nzDoors.PropDoors[self:EntIndex()].locked = bool
	else
		if !nzDoors.MapDoors[self:DoorIndex()] then nzDoors.MapDoors[self:DoorIndex()] = {} end
		nzDoors.MapDoors[self:DoorIndex()].locked = bool
	end
end

local validdoors = {
	["func_door"] = true,
	["func_door_rotating"] = true,
	["prop_door_rotating"] = true,
	["prop_dynamic"] = true,
}

local scriptbuyables = {
	["nz_script_triggerzone"] = true,
	["nz_triggerbutton"] = true,
}

function meta:IsDoor()
	if not IsValid(self) then return false end
	local class = self:GetClass()

	return validdoors[class] or false
end

function meta:IsScriptBuyable()
	if not IsValid(self) then return false end
	local class = self:GetClass()

	return scriptbuyables[class] or false
end

function meta:IsBuyableEntity()
	return self:IsDoor() or self:IsBuyableProp() or self:IsButton() or self:IsScriptBuyable() or false
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

function meta:IsPropDoorType()
	return self:IsScriptBuyable() or self:IsBuyableProp()
end

function meta:IsBuyableMapEntity()
	return self:IsDoor() or self:IsButton() or self:IsBuyableProp() or self:IsScriptBuyable() or false
end

function meta:DoorIndex()
	if SERVER then
		return self:CreatedByMap() and self:MapCreationID() or nil
	else
		-- Check the ED table
		return nzDoors.MapCreationIndexTable[self:EntIndex()] or 0
	end
end

function meta:GetDoorData()
	if self:IsBuyableProp() or self:IsScriptBuyable() then
		if !nzDoors.PropDoors[self:EntIndex()] then return nil end
		return nzDoors.PropDoors[self:EntIndex()].flags
	else
		if !nzDoors.MapDoors[self:DoorIndex()] then return nil end
		return nzDoors.MapDoors[self:DoorIndex()].flags
	end
end

function meta:SetDoorData( tbl )
	if self:IsBuyableProp() or self:IsScriptBuyable() then
		if !nzDoors.PropDoors[self:EntIndex()] then nzDoors.PropDoors[self:EntIndex()] = {} end
		nzDoors.PropDoors[self:EntIndex()].flags = tbl
	else
		if !nzDoors.MapDoors[self:DoorIndex()] then nzDoors.MapDoors[self:DoorIndex()] = {} end
		nzDoors.MapDoors[self:DoorIndex()].flags = tbl
	end
end

function nzDoors:DoorIndexByID( id )
	if SERVER then
		local ent = Entity(id)
		return ent:CreatedByMap() and ent:MapCreationID() or nil
	else
		-- Check the ED table
		return nzDoors.MapCreationIndexTable[id] or 0
	end
end

function nzDoors:SetDoorDataByID( id, prop, tbl )
	if !tbl then return end
	if prop then
		if !self.PropDoors[id] then self.PropDoors[id] = {} end
		self.PropDoors[id].flags = tbl
	else
		if !self.MapDoors[id] then self.MapDoors[id] = {} end
		self.MapDoors[id].flags = tbl
	end
end

function nzDoors:SetLockedByID( id, prop, bool )
	if prop then
		if !nzDoors.PropDoors[id] then nzDoors.PropDoors[id] = {} end
		self.PropDoors[id].locked = bool
	else
		local index = nzDoors:DoorIndexByID( id )
		if !nzDoors.MapDoors[index] then nzDoors.MapDoors[index] = {} end
		self.MapDoors[index].locked = bool
	end
end
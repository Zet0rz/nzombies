if SERVER then
	util.AddNetworkString( "nzMapDoorCreation" )
	util.AddNetworkString( "nzPropDoorCreation" )
	util.AddNetworkString( "nzAllDoorsLocked" )
	util.AddNetworkString( "nzDoorOpened" )
	util.AddNetworkString( "nzClearDoorData" )

	function nzDoors:SendMapDoorCreation( door, flags, id, ply )
		if IsValid(door) then
			net.Start("nzMapDoorCreation")
				net.WriteBool(true)
				net.WriteInt(door:EntIndex(), 13)
				net.WriteTable(flags or {})
				net.WriteInt(id or 0, 13)
			return ply and net.Send(ply) or net.Broadcast()
		end
	end
	
	function nzDoors:SendPropDoorCreation( ent, flags, ply )
		if IsValid(ent) then
			net.Start("nzPropDoorCreation")
				net.WriteBool(true)
				net.WriteInt(ent:EntIndex(), 13)
				net.WriteTable(flags or {})
			return ply and net.Send(ply) or net.Broadcast()
		end
	end
	
	function nzDoors:SendMapDoorRemoval( door, ply )
		if IsValid(door) then
			net.Start("nzMapDoorCreation")
				net.WriteBool(false)
				net.WriteInt(door:EntIndex(), 13)
			return ply and net.Send(ply) or net.Broadcast()
		end
	end
	
	function nzDoors:SendPropDoorRemoval( ent, ply )
		if IsValid(ent) then
			net.Start("nzPropDoorCreation")
				net.WriteBool(false)
				net.WriteInt(ent:EntIndex(), 13)
			return ply and net.Send(ply) or net.Broadcast()
		end
	end
	
	function nzDoors:SendAllDoorsLocked( ply )
		net.Start("nzAllDoorsLocked")
		return ply and net.Send(ply) or net.Broadcast()
	end
	
	function nzDoors:SendDoorOpened( door, rebuyable, ply )
		net.Start("nzDoorOpened")
			print(door:EntIndex(), door)
			net.WriteBool(IsValid(door) and door:IsPropDoorType())
			net.WriteInt(door:EntIndex(), 13)
			net.WriteBool(rebuyable and tobool(rebuyable) or false)
		return ply and net.Send(ply) or net.Broadcast()
	end
	
	function nzDoors.SendSync( ply )
		-- Clear all data first
		if ply then
			net.Start("nzClearDoorData")
			net.Send(ply)
		else
			net.Start("nzClearDoorData")
			net.Broadcast()
		end
		
		-- Remove old doors
		for k,v in pairs(nzDoors.MapDoors) do
			nzDoors:SendMapDoorCreation( nzDoors:DoorIndexToEnt(k), v.flags, k, ply )
			if !v.locked then
				nzDoors:SendDoorOpened( nzDoors:DoorIndexToEnt(k), ply )
			end
		end
		for k,v in pairs(nzDoors.PropDoors) do
			nzDoors:SendPropDoorCreation( Entity(k), v.flags, ply )
			if !v.locked then
				nzDoors:SendDoorOpened( Entity(k), ply )
			end
		end
	end
	
	FullSyncModules["Doors"] = nzDoors.SendSync

end

if CLIENT then
	nzDoors.MapCreationIndexTable = nzDoors.MapCreationIndexTable or {}
	nzDoors.DisplayLinks = nzDoors.DisplayLinks or {}
	
	local function ReceiveMapDoorCreation()
		local bool = net.ReadBool()
		local index = net.ReadInt(13)
		-- True if door is created, false if removed
		if bool then
			local tbl = net.ReadTable()
			nzDoors.MapCreationIndexTable[index] = net.ReadInt(13)
			nzDoors:SetDoorDataByID( nzDoors.MapCreationIndexTable[index], false, tbl )
			nzDoors:SetLockedByID( index, false, true )
			--ent:SetDoorData(tbl)
			-- We store the map creation ID in a table so we can access it universally
			--ent:SetLocked(true)
		else
			--ent:SetDoorData(nil)
			--nzDoors.MapCreationIndexTable[index] = nil
			--ent:SetLocked(false)
			nzDoors:SetDoorDataByID( nzDoors.MapCreationIndexTable[index], false, nil )
			nzDoors:SetLockedByID( index, false, false )
		end
	end
	net.Receive("nzMapDoorCreation", ReceiveMapDoorCreation)
	
	local function ReceivePropDoorCreation()
		local bool = net.ReadBool()
		local index = net.ReadInt(13)
		--local ent = Entity(index)
		-- True if door is created, false if removed
		if bool then
			local tbl = net.ReadTable()
			nzDoors:SetDoorDataByID( index, true, tbl )
			nzDoors:SetLockedByID( index, true, true )
			--ent:SetDoorData(tbl)
			--ent:SetLocked(true)
		else
			nzDoors:SetDoorDataByID( index, true, nil )
			nzDoors:SetLockedByID( index, true, false )
			--ent:SetDoorData(nil)
			--ent:SetLocked(false)
		end
	end
	net.Receive("nzPropDoorCreation", ReceivePropDoorCreation)
	
	local function ReceiveAllDoorsLocked()
		for k,v in pairs(nzDoors.MapDoors) do
			v.locked = true
		end
		for k,v in pairs(nzDoors.PropDoors) do
			v.locked = true
		end
	end
	net.Receive("nzAllDoorsLocked", ReceiveAllDoorsLocked)
	
	local function ReceiveDoorOpened()
		local prop = net.ReadBool()
		local index = net.ReadInt(13)
		local rebuyable = net.ReadBool()
		nzDoors:SetLockedByID( index, prop, rebuyable )
		--local door = Entity(index)
		--door:SetLocked(false)
	end
	net.Receive("nzDoorOpened", ReceiveDoorOpened)
	
	local function ClearAllDoorData()
		nzDoors.MapDoors = {}
		nzDoors.PropDoors = {}
		nzDoors.MapCreationIndexTable = {}
	end
	net.Receive("nzClearDoorData", ClearAllDoorData)
end
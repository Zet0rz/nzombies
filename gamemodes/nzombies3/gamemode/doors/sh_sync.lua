if SERVER then
	util.AddNetworkString( "nzMapDoorCreation" )
	util.AddNetworkString( "nzPropDoorCreation" )
	util.AddNetworkString( "nzAllDoorsLocked" )
	util.AddNetworkString( "nzDoorOpened" )
	util.AddNetworkString( "nzClearDoorData" )

	function Doors:SendMapDoorCreation( door, flags, id, ply )
		if IsValid(door) then
			net.Start("nzMapDoorCreation")
				net.WriteBool(true)
				net.WriteInt(door:EntIndex(), 13)
				net.WriteTable(flags or {})
				net.WriteInt(id or 0, 13)
			return ply and net.Send(ply) or net.Broadcast()
		end
	end
	
	function Doors:SendPropDoorCreation( ent, flags, ply )
		if IsValid(ent) then
			net.Start("nzPropDoorCreation")
				net.WriteBool(true)
				net.WriteInt(ent:EntIndex(), 13)
				net.WriteTable(flags or {})
			return ply and net.Send(ply) or net.Broadcast()
		end
	end
	
	function Doors:SendMapDoorRemoval( door, ply )
		if IsValid(door) then
			net.Start("nzMapDoorCreation")
				net.WriteBool(false)
				net.WriteInt(door:EntIndex(), 13)
			return ply and net.Send(ply) or net.Broadcast()
		end
	end
	
	function Doors:SendPropDoorRemoval( ent, ply )
		if IsValid(ent) then
			net.Start("nzPropDoorCreation")
				net.WriteBool(false)
				net.WriteInt(ent:EntIndex(), 13)
			return ply and net.Send(ply) or net.Broadcast()
		end
	end
	
	function Doors:SendAllDoorsLocked( ply )
		net.Start("nzAllDoorsLocked")
		return ply and net.Send(ply) or net.Broadcast()
	end
	
	function Doors:SendDoorOpened( door, rebuyable, ply )
		net.Start("nzDoorOpened")
			print(door:EntIndex(), door)
			net.WriteBool(IsValid(door) and door:IsPropDoorType())
			net.WriteInt(door:EntIndex(), 13)
			net.WriteBool(rebuyable and rebuyable or false)
		return ply and net.Send(ply) or net.Broadcast()
	end
	
	function Doors.SendSync( ply )
		-- Clear all data first
		if ply then
			net.Start("nzClearDoorData")
			net.Send(ply)
		else
			net.Start("nzClearDoorData")
			net.Broadcast()
		end
		
		-- Remove old doors
		for k,v in pairs(Doors.MapDoors) do
			Doors:SendMapDoorCreation( Doors:DoorIndexToEnt(k), v.flags, k, ply )
			if !v.locked then
				Doors:SendDoorOpened( Doors:DoorIndexToEnt(k), ply )
			end
		end
		for k,v in pairs(Doors.PropDoors) do
			Doors:SendPropDoorCreation( Entity(k), v.flags, ply )
			if !v.locked then
				Doors:SendDoorOpened( Entity(k), ply )
			end
		end
	end
	
	FullSyncModules["Doors"] = Doors.SendSync

end

if CLIENT then
	Doors.MapCreationIndexTable = Doors.MapCreationIndexTable or {}
	Doors.DisplayLinks = Doors.DisplayLinks or {}
	
	local function ReceiveMapDoorCreation()
		local bool = net.ReadBool()
		local index = net.ReadInt(13)
		-- True if door is created, false if removed
		if bool then
			local tbl = net.ReadTable()
			Doors.MapCreationIndexTable[index] = net.ReadInt(13)
			Doors:SetDoorDataByID( Doors.MapCreationIndexTable[index], false, tbl )
			Doors:SetLockedByID( index, false, true )
			--ent:SetDoorData(tbl)
			-- We store the map creation ID in a table so we can access it universally
			--ent:SetLocked(true)
		else
			--ent:SetDoorData(nil)
			--Doors.MapCreationIndexTable[index] = nil
			--ent:SetLocked(false)
			Doors:SetDoorDataByID( Doors.MapCreationIndexTable[index], false, nil )
			Doors:SetLockedByID( index, false, false )
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
			Doors:SetDoorDataByID( index, true, tbl )
			Doors:SetLockedByID( index, true, true )
			--ent:SetDoorData(tbl)
			--ent:SetLocked(true)
		else
			Doors:SetDoorDataByID( index, true, nil )
			Doors:SetLockedByID( index, true, false )
			--ent:SetDoorData(nil)
			--ent:SetLocked(false)
		end
	end
	net.Receive("nzPropDoorCreation", ReceivePropDoorCreation)
	
	local function ReceiveAllDoorsLocked()
		for k,v in pairs(Doors.MapDoors) do
			v.locked = true
		end
		for k,v in pairs(Doors.PropDoors) do
			v.locked = true
		end
	end
	net.Receive("nzAllDoorsLocked", ReceiveAllDoorsLocked)
	
	local function ReceiveDoorOpened()
		local prop = net.ReadBool()
		local index = net.ReadInt(13)
		Doors:SetLockedByID( index, prop, net.ReadBool() )
		--local door = Entity(index)
		--door:SetLocked(false)
	end
	net.Receive("nzDoorOpened", ReceiveDoorOpened)
	
	local function ClearAllDoorData()
		Doors.MapDoors = {}
		Doors.PropDoors = {}
		Doors.MapCreationIndexTable = {}
	end
	net.Receive("nzClearDoorData", ClearAllDoorData)
end
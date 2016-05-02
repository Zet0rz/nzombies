function nzDoors:OnPlayerBuyDoor( ply, door )
	
end

function nzDoors:OnAllDoorsLocked( )
	self:SendAllDoorsLocked()
end

function nzDoors:OnDoorUnlocked( door, link, rebuyable, ply )
	self:SendDoorOpened( door, rebuyable )
end

function nzDoors:OnMapDoorLinkCreated( door, flags, id )
	self:SendMapDoorCreation(door, flags, id)
end

function nzDoors:OnMapDoorLinkRemoved( door, id )
	self:SendMapDoorRemoval(door)
end

function nzDoors:OnPropDoorLinkCreated( ent, flags )
	self:SendPropDoorCreation( ent, flags )
end

function nzDoors:OnPropDoorLinkRemoved( ent )
	self:SendPropDoorRemoval( ent )
end
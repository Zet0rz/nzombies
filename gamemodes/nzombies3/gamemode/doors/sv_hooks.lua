function Doors:OnPlayerBuyDoor( ply, door )
	
end

function Doors:OnAllDoorsLocked( )
	self:SendAllDoorsLocked()
end

function Doors:OnDoorUnlocked( door, link, rebuyable, ply )
	self:SendDoorOpened( door, rebuyable )
end

function Doors:OnMapDoorLinkCreated( door, flags, id )
	self:SendMapDoorCreation(door, flags, id)
end

function Doors:OnMapDoorLinkRemoved( door, id )
	self:SendMapDoorRemoval(door)
end

function Doors:OnPropDoorLinkCreated( ent, flags )
	self:SendPropDoorCreation( ent, flags )
end

function Doors:OnPropDoorLinkRemoved( ent )
	self:SendPropDoorRemoval( ent )
end
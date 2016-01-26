//Functions

function nz.Doors.Functions.doorToEntIndex(num)
	local ent = ents.GetMapCreatedEntity(num)

	return IsValid(ent) and ent:EntIndex() or nil
end

function nz.Doors.Functions.doorIndexToEnt(num)
	return ents.GetMapCreatedEntity(num) or NULL
end
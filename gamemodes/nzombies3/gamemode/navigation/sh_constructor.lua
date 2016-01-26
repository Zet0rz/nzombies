//Main Tables
nz.Nav = {}
nz.Nav.Functions = {}
nz.Nav.Data = nz.Nav.Data or {}
nz.Nav.NavGroups = {}
nz.Nav.NavGroupIDs = {}

//Reset navmesh attributes so they don't accidentally save
function GM:ShutDown()
	for k,v in pairs(nz.Nav.Data) do
		navmesh.GetNavAreaByID(k):SetAttributes(v.prev)
	end
end

NavFloodSelectedSet = {}
NavFloodAlreadySelected = {}

function FloodSelectNavAreas(area)
	//Clear tables to be ready for a new selection
	NavFloodSelectedSet = {}
	NavFloodAlreadySelected = {}
	
	//Start off on the current area
	AddFloodSelectedToSet(area)
	
	return NavFloodSelectedSet
end

function AddFloodSelectedToSet(area)
	//Prevent locked or door-linked navmeshes from being selected
	if nz.Nav.Data[area:GetID()] then return end

	//Add it to the table and make sure it doesn't get reached again
	NavFloodAlreadySelected[area:GetID()] = true
	table.insert(NavFloodSelectedSet, area)
	
	//Loop through adjacent areas and do the same thing
	for k,v in pairs(area:GetAdjacentAreas()) do
		if !NavFloodAlreadySelected[v:GetID()] and v:IsConnected(area) then
			AddFloodSelectedToSet(v)
		end
	end
end

function nz.Nav.Functions.AddNavGroupIDToArea(area, id)
	local id = string.lower(id)
	
	//Set the areas ID to the given one
	nz.Nav.NavGroups[area:GetID()] = id
	
	//Create the entire group in the index table if it isn't already there
	if !nz.Nav.NavGroupIDs[id] then
		nz.Nav.NavGroupIDs[id] = id
	end
end

function nz.Nav.Functions.RemoveNavGroupArea(area, deletegroup)
	//Remove the entire group from the index table
	if deletegroup and nz.Nav.NavGroupIDs[nz.Nav.NavGroups[area:GetID()]] then
		nz.Nav.NavGroupIDs[nz.Nav.NavGroups[area:GetID()]] = nil
	end
	
	//Remove the group data behind the area itself
	nz.Nav.NavGroups[area:GetID()] = nil
end

function nz.Nav.Functions.MergeNavGroups(id1, id2)
	if !id1 or !nz.Nav.NavGroupIDs[id1] then Error("MergeNavGroups called with invalid id1!") return end
	if !id2 or !nz.Nav.NavGroupIDs[id2] then Error("MergeNavGroups called with invalid id2!") return end
	
	local id1 = string.lower(id1)
	local id2 = string.lower(id2)
	
	//Index all merged part of both area groups
	local tbl1 = string.Explode(";", nz.Nav.NavGroupIDs[id1])
	local tbl2 = string.Explode(";", nz.Nav.NavGroupIDs[id2])
	
	//Create a table in which the keys can only be set once
	local tbl = {}
	for k,v in pairs(tbl1) do
		tbl[v] = true
	end
	for k,v in pairs(tbl2) do
		tbl[v] = true
	end
	
	//Loop through the keys and set their ID to the merged ID of all other keys
	for k,v in pairs(tbl) do
		nz.Nav.NavGroupIDs[k] = string.Implode(";", table.GetKeys(tbl))
	end
end

function nz.Nav.Functions.GetNavGroup(area)
	if type(area) != "CNavArea" then area = navmesh.GetNearestNavArea(area:GetPos()) end
	return nz.Nav.NavGroupIDs[nz.Nav.NavGroups[area:GetID()]]
end

function nz.Nav.Functions.GetNavGroupID(area)
	if type(area) != "CNavArea" then area = navmesh.GetNearestNavArea(area:GetPos()) end
	return nz.Nav.NavGroups[area:GetID()]
end

function nz.Nav.Functions.IsInSameNavGroup(ent1, ent2)
	local area1 = nz.Nav.NavGroups[navmesh.GetNearestNavArea(ent1:GetPos()):GetID()]
	if !area1 then return true end
	
	local area2 = nz.Nav.NavGroups[navmesh.GetNearestNavArea(ent2:GetPos()):GetID()]
	if !area2 then return true end
	
	return nz.Nav.NavGroupIDs[area1] == nz.Nav.NavGroupIDs[area2]
end

function nz.Nav.ResetNavGroupMerges()
	for k,v in pairs(nz.Nav.NavGroupIDs) do
		v = k
	end
end

function nz.Nav.GenerateCleanGroupIDList()
	//Something to use in case everything messes up - loops through all saved navmeshes and adds them to the index list
	for k,v in pairs(nz.Nav.NavGroups) do
		nz.Nav.NavGroupIDs[v] = v
	end
end
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

function IsNavApplicable(ent)
	// All classes that can be linked with navigation
	if !IsValid(ent) then return false end
	if (ent:IsDoor() or ent:IsBuyableProp() or ent:IsButton()) and ent.link then
		return true
	else
		return false
	end
end

local NavFloodSelectedSet = {}
local NavFloodAlreadySelected = {}

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
		nz.Nav.NavGroupIDs[id] = {[id] = true}
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
	
	local tbl = {}
	for k,v in pairs(nz.Nav.NavGroupIDs[id1]) do
		tbl[k] = true
	end
	for k,v in pairs(nz.Nav.NavGroupIDs[id2]) do
		tbl[k] = true
	end
	tbl[id1] = true
	tbl[id2] = true
	
	for k,v in pairs(tbl) do
		nz.Nav.NavGroupIDs[k] = tbl
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
	
	return nz.Nav.NavGroupIDs[area1][area2] or false
end

function nz.Nav.Functions.IsPosInSameNavGroup(pos1, pos2)
	local area1 = nz.Nav.NavGroups[navmesh.GetNearestNavArea(pos1):GetID()]
	if !area1 then return true end
	
	local area2 = nz.Nav.NavGroups[navmesh.GetNearestNavArea(pos2):GetID()]
	if !area2 then return true end
	
	return nz.Nav.NavGroupIDs[area1][area2] or false
end

function nz.Nav.ResetNavGroupMerges()
	local tbl = table.GetKeys(nz.Nav.NavGroupIDs)
	nz.Nav.NavGroupIDs = {}
	for k,v in pairs(tbl) do
		nz.Nav.NavGroupIDs[v] = {[v] = true}
	end
end

function nz.Nav.GenerateCleanGroupIDList()
	//Something to use in case everything messes up - loops through all saved navmeshes and adds them to the index list
	nz.Nav.NavGroupIDs = {}
	for k,v in pairs(nz.Nav.NavGroups) do
		nz.Nav.NavGroupIDs[v] = {[v] = true}
	end
end

function nz.Nav.Functions.CreateAutoMergeLink(door, id)
	if !door:IsDoor() and !door:IsBuyableProp() and !door:IsButton() then return end
	if door.linkedmeshes then
		if !table.HasValue(door.linkedmeshes, id) then
			table.insert(door.linkedmeshes, id)
		end
	else
		door.linkedmeshes = {}
		table.insert(door.linkedmeshes, id)
	end
end

function nz.Nav.Functions.UnlinkAutoMergeLink(door)
	if !door:IsDoor() and !door:IsBuyableProp() and !door:IsButton() then return end
	if door.linkedmeshes then
		door.linkedmeshes = nil
	end
end

function nz.Nav.Functions.AutoGenerateAutoMergeLinks()
	for k,v in pairs(nz.Nav.Data) do
		if v.link then
			for k2,v2 in pairs(ents.GetAll()) do
				if v2:IsDoor() or v2:IsBuyableProp() or v2:IsButton() then
					if v2.link == v.link then
						nz.Nav.Functions.CreateAutoMergeLink(v2, k)
						print("Linked navmesh "..k.." to door", v2)
					end
				end					
			end
		end
	end
end

function nz.Nav.Functions.OnNavMeshUnlocked(areaids)
	local tbl = {}
	
	for k,v in pairs(areaids) do
		local area = navmesh.GetNavAreaByID(v)
		for k2,v2 in pairs(area:GetAdjacentAreas()) do
			local group = nz.Nav.NavGroups[v2:GetID()]
			if group then
				tbl[group] = true
			end
		end
	end

	local prev_group = nil
	for k,v in pairs(tbl) do
		if prev_group then
			nz.Nav.Functions.MergeNavGroups(k, prev_group)
		end
		prev_group = k
	end
end
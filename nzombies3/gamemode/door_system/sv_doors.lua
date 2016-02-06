//

//price=500,elec=0,link=1

function nz.Doors.Functions.ParseFlagString( flagsStr )

	local tbl = {}
	
	flagsStr = string.lower(flagsStr)
	
	//Translate the flags string into a table
	local ex = string.Explode( ",", flagsStr )
	
	for k,v in pairs(ex) do
		local ex2 = string.Explode( "=", v )
		tbl[ex2[1]] = ex2[2]
		//If buyable is not set on a door, we default to on
		if !tbl["buyable"] and k == #ex then
			tbl["buyable"] = "1"
		end
	end
	
	PrintTable(tbl)
	return tbl
	
end

function nz.Doors.Functions.CreateLink( ent, flagsStr )
	//First remove all links
	nz.Doors.Functions.RemoveLink( ent )
	if ent:IsDoor() or ent:IsButton() then
		nz.Doors.Functions.CreateMapDoorLink( ent:doorIndex(), flagsStr )
	elseif ent:IsBuyableProp() then
		nz.Doors.Functions.CreatePropDoorLink( ent, flagsStr )
	end
end

function nz.Doors.Functions.RemoveLink( ent )
	if ent:IsDoor() or ent:IsButton() then
		nz.Doors.Functions.RemoveMapDoorLink( ent:doorIndex(), flagsStr )
	elseif ent:IsBuyableProp() then
		nz.Doors.Functions.RemovePropDoorLink( ent )
	end
end

function nz.Doors.Functions.CreateMapDoorLink( doorID, flagsStr )

	local door = nz.Doors.Functions.doorIndexToEnt(doorID)
	if !flagsStr then ErrorNoHalt("Door "..doorID.." doesn't have a flagsStr saved!") return end
	local flagsTbl = nz.Doors.Functions.ParseFlagString( flagsStr )
	
	if door:IsValid() and (door:IsDoor() or door:IsButton()) then
		//Assign the flags to the door
		for k,v in pairs(flagsTbl) do
			if !string.find(k, "navgroup") then
				door[k] = tonumber(v)
			else
				door[k] = v
			end
		end
		//Save the data into a convenient table for lua refresh
		door.Data = flagsStr
		
		//Set the Door Data
		nz.Doors.Data.LinkFlags[doorID] = flagsTbl
		nz.Doors.Data.EaDI[nz.Doors.Functions.doorToEntIndex(doorID)] = doorID
		
		nz.Doors.Functions.SendSync()
		
	else
		print("Error: " .. doorID .. " is not a door. ")
	end
	
end

function nz.Doors.Functions.RemoveMapDoorLink( doorID )

	local door = nz.Doors.Functions.doorIndexToEnt(doorID)
	
	if door.Data != nil then
		if door:IsValid() and (door:IsDoor() or door:IsButton()) then
			local flagsTbl = nz.Doors.Functions.ParseFlagString( door.Data )
			
			//Remove the flags to the door
			for k,v in pairs(flagsTbl) do
				door[k] = nil
			end
			
			//Remove the data that was used for lua refresh
			door.Data = nil
			
			//Set the Door Data
			nz.Doors.Data.LinkFlags[doorID] = nil
			nz.Doors.Data.EaDI[nz.Doors.Functions.doorToEntIndex(doorID)] = nil
			
			nz.Doors.Functions.SendSync()
		else
			print("Error: " .. doorID .. " is not a door. ")
		end
	end
	
end

function nz.Doors.Functions.CreatePropDoorLink( ent, flagsStr )

	local flagsTbl = nz.Doors.Functions.ParseFlagString( flagsStr )
	
	if ent:IsValid() and ent:IsBuyableProp() then
		//Assign the flags to the door
		for k,v in pairs(flagsTbl) do
			if !string.find(k, "navgroup") then
				ent[k] = tonumber(v)
			else
				ent[k] = v
			end
		end
		//Save the data into a convenient table for lua refresh
		ent.Data = flagsStr
		//Set the Door Data
		nz.Doors.Data.BuyableProps[ent:EntIndex()] = flagsTbl
		nz.Doors.Functions.SendSync()
	else
		//print("Error: " .. doorID .. " is not a door. ")
	end
	
end

function nz.Doors.Functions.RemovePropDoorLink( ent )
	
	if ent:IsValid() and ent:IsBuyableProp() then
	
		//Save the data into a convenient table for lua refresh
		ent.Data = nil
		//Set the Door Data
		nz.Doors.Data.BuyableProps[ent:EntIndex()] = nil
		nz.Doors.Functions.SendSync()
		
	else
		//print("Error: " .. doorID .. " is not a door. ")
	end
end

function nz.Doors.Functions.DisplayDoorLinks( ent )
	if ent.link == nil then nz.Doors.Data.DisplayLinks[ent] = nil return end
	
	if nz.Doors.Data.DisplayLinks[ent] == nil then
		nz.Doors.Data.DisplayLinks[ent] = ent.link
	else
		nz.Doors.Data.DisplayLinks[ent] = nil
	end
	nz.Doors.Functions.SendSync()
end
//Client Server Syncing

if SERVER then

	//Server to client (Server)
	util.AddNetworkString( "nz.Tools.Sync" )
	util.AddNetworkString( "nz.Tools.Update" )
	
	function nz.Tools.Functions.SendSync()
		
	end
	
	function nz.Tools.Functions.ReceiveData(len, ply)
		if !IsValid(ply) then return end
		local id = net.ReadString()
		local wep = ply:GetActiveWeapon()
		
		//Call holster on the old tool
		if nz.Tools.ToolData[wep.ToolMode] then
			nz.Tools.ToolData[wep.ToolMode].OnHolster(wep, ply, ply.NZToolData)
		end
		
		ply:SetActiveNZTool( id )
		//Only read the data if the tool has any - as shown by the bool
		if net.ReadBool() then
			ply:SetNZToolData( net.ReadTable() )
		end
		
		//Then call equip on the new one
		if nz.Tools.ToolData[id] then
			nz.Tools.ToolData[id].OnEquip(wep, ply, ply.NZToolData)
		end
	end
	net.Receive( "nz.Tools.Update", nz.Tools.Functions.ReceiveData )
end

if CLIENT then

	//Client to server
	function nz.Tools.Functions.SendData( data, tool, savedata )
		if data then
			net.Start("nz.Tools.Update")
				net.WriteString(tool)
				//Let the server know we're also sending a table of data
				net.WriteBool(true)
				net.WriteTable(data)
			net.SendToServer()
		else
			//This tool doesn't have any data
			net.Start("nz.Tools.Update")
				net.WriteString(tool)
				net.WriteBool(false)
			net.SendToServer()
		end
		
		//Always save on submit - if a special table of savedata is provided, use that
		if savedata then
			nz.Tools.Functions.SaveData( savedata, tool )
		else
			nz.Tools.Functions.SaveData( data, tool )
		end
	end
	
	function nz.Tools.Functions.SaveData( data, tool )
		nz.Tools.SavedData[tool] = nil
		nz.Tools.SavedData[tool] = data
	end
	
	//Server to client (Client)
	function nz.Tools.Functions.ReceiveSync( length )
	
	end
	
	//Receivers 
	net.Receive( "nz.Tools.Sync", nz.Perks.Functions.ReceiveSync )
end
-- Client Server Syncing

if SERVER then

	-- Server to client (Server)
	--util.AddNetworkString( "nzToolsSync" )
	util.AddNetworkString( "nzToolsUpdate" )
	
	local function ReceiveData(len, ply)
		if !IsValid(ply) then return end
		local id = net.ReadString()
		local wep = ply:GetActiveWeapon()
		
		-- Call holster on the old tool
		if nzTools.ToolData[wep.ToolMode] then
			nzTools.ToolData[wep.ToolMode].OnHolster(wep, ply, ply.NZToolData)
		end
		
		ply:SetActiveNZTool( id )
		-- Only read the data if the tool has any - as shown by the bool
		if net.ReadBool() then
			ply:SetNZToolData( net.ReadTable() )
		end
		
		-- Then call equip on the new one
		if nzTools.ToolData[id] then
			nzTools.ToolData[id].OnEquip(wep, ply, ply.NZToolData)
		end
	end
	net.Receive( "nzToolsUpdate", ReceiveData )
end

if CLIENT then

	-- Client to server
	function nzTools:SendData( data, tool, savedata )
		if data then
			net.Start("nzToolsUpdate")
				net.WriteString(tool)
				-- Let the server know we're also sending a table of data
				net.WriteBool(true)
				net.WriteTable(data)
			net.SendToServer()
		else
			-- This tool doesn't have any data
			net.Start("nzToolsUpdate")
				net.WriteString(tool)
				net.WriteBool(false)
			net.SendToServer()
		end
		
		-- Always save on submit - if a special table of savedata is provided, use that
		if savedata then
			nzTools:SaveData( savedata, tool )
		else
			nzTools:SaveData( data, tool )
		end
	end
	
	function nzTools:SaveData( data, tool )
		self.SavedData[tool] = nil
		self.SavedData[tool] = data
	end
	
end
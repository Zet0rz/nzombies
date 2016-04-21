-- Client Server Syncing

if SERVER then

	-- Server to client (Server)
	util.AddNetworkString( "nzItemCarryUpdate" )
	util.AddNetworkString( "nzItemCarryPlayers" )
	util.AddNetworkString( "nzItemCarryPlayersFull" )
	util.AddNetworkString( "nzItemCarryClean" )
	
	function nzItemCarry:SendObjectCreated(id, receiver)
		if !id then return end
		local data = nzItemCarry.Items[id]
		local tbl = {
			id = data.id,
			text = data.text,
			hastext = data.hastext,
			icon = data.icon,
		}
		
		net.Start( "nzItemCarryUpdate" )
			net.WriteString(id)
			net.WriteTable(tbl)
		return receiver and net.Send(receiver) or net.Broadcast()
	end
	
	function nzItemCarry:SendPlayerItem(ply, receiver)
		if IsValid(ply) then
			local data = nzItemCarry.Players[ply]
			net.Start( "nzItemCarryPlayers" )
				net.WriteEntity(ply)
				net.WriteTable( data )
			return receiver and net.Send(receiver) or net.Broadcast()
		else
			local data = nzItemCarry.Players
			net.Start( "nzItemCarryPlayersFull" )
				net.WriteTable( data )
			return receiver and net.Send(receiver) or net.Broadcast()
		end
	end
	
	function nzItemCarry:CleanUp()
		nzItemCarry.Items = {}
		nzItemCarry.Players = {}
		
		net.Start( "nzItemCarryClean" )
		net.Broadcast()
	end
	
	FullSyncModules["ItemCarry"] = function(ply)
		for k,v in pairs(nzItemCarry.Items) do
			nzItemCarry:SendObjectCreated(k, ply)
		end
		nzItemCarry:SendPlayerItem(nil, ply) -- No specific target, all players
	end

end

if CLIENT then
	
	-- Server to client (Client)
	local function ReceiveItemObject( length )
		local id = net.ReadString()
		local data = net.ReadTable()
		
		-- Precache the material here
		print(data.icon)
		if data.icon and data.icon != "" then data.icon = Material(data.icon) end
		
		nzItemCarry.Items[id] = data
		PrintTable(nzItemCarry.Items[id])
	end
	
	local function ReceiveItemPlayer( length )
		local ply = net.ReadEntity()
		local data = net.ReadTable()
		
		nzItemCarry.Players[ply] = data
		PrintTable(nzItemCarry.Players[ply])
	end
	
	local function ReceiveItemPlayerFull( length )
		local data = net.ReadTable()
		
		nzItemCarry.Players = data
		PrintTable(nzItemCarry.Players)
	end
	
	local function ReceiveItemCleanup( length )
		nzItemCarry.Players = {}
		nzItemCarry.Items = {}
	end
	
	-- Receivers 
	net.Receive( "nzItemCarryUpdate", ReceiveItemObject )
	net.Receive( "nzItemCarryPlayers", ReceiveItemPlayer )
	net.Receive( "nzItemCarryPlayersFull", ReceiveItemPlayerFull )
	net.Receive( "nzItemCarryClean", ReceiveItemCleanup )
end
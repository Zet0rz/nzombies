-- Client Server Syncing

if SERVER then

	-- Server to client (Server)
	util.AddNetworkString( "nzItemCarryUpdate" )
	util.AddNetworkString( "nzItemCarryPlayers" )
	util.AddNetworkString( "nzItemCarryPlayersFull" )
	util.AddNetworkString( "nzItemCarryClean" )
	
	function ItemCarry:SendObjectCreated(id, receiver)
		if !id then return end
		local data = ItemCarry.Items[id]
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
	
	function ItemCarry:SendPlayerItem(ply, receiver)
		if IsValid(ply) then
			local data = ItemCarry.Players[ply]
			net.Start( "nzItemCarryPlayers" )
				net.WriteEntity(ply)
				net.WriteTable( data )
			return receiver and net.Send(receiver) or net.Broadcast()
		else
			local data = ItemCarry.Players
			net.Start( "nzItemCarryPlayersFull" )
				net.WriteTable( data )
			return receiver and net.Send(receiver) or net.Broadcast()
		end
	end
	
	function ItemCarry:CleanUp()
		ItemCarry.Items = {}
		ItemCarry.Players = {}
		
		net.Start( "nzItemCarryClean" )
		net.Broadcast()
	end
	
	FullSyncModules["ItemCarry"] = function(ply)
		for k,v in pairs(ItemCarry.Items) do
			ItemCarry:SendObjectCreated(k, ply)
		end
		ItemCarry:SendPlayerItem(nil, ply) -- No specific target, all players
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
		
		ItemCarry.Items[id] = data
		PrintTable(ItemCarry.Items[id])
	end
	
	local function ReceiveItemPlayer( length )
		local plu = net.ReadEntity()
		local data = net.ReadTable()
		
		ItemCarry.Players[ply] = data
		PrintTable(ItemCarry.Players[ply])
	end
	
	local function ReceiveItemPlayerFull( length )
		local data = net.ReadTable()
		
		ItemCarry.Players = data
		PrintTable(ItemCarry.Players)
	end
	
	local function ReceiveItemCleanup( length )
		ItemCarry.Players = {}
		ItemCarry.Items = {}
	end
	
	-- Receivers 
	net.Receive( "nzItemCarryUpdate", ReceiveItemObject )
	net.Receive( "nzItemCarryPlayers", ReceiveItemPlayer )
	net.Receive( "nzItemCarryPlayersFull", ReceiveItemPlayerFull )
	net.Receive( "nzItemCarryClean", ReceiveItemCleanup )
end
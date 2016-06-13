-- Client Server Syncing

if SERVER then

	-- Server to client (Server)
	util.AddNetworkString( "nz.Perks.Sync" )
	util.AddNetworkString( "nz.Perks.FullSync" )
	
	function nzPerks:SendSync(ply, receiver)
		if !ply then nzPerks:SendFullSync(receiver) return end -- No valid player set, just do a full sync
		if !nzPerks.Players[ply] then nzPerks.Players[ply] = {} end -- Create table should it not exist (for some reason)
		
		local data = table.Copy(nzPerks.Players[ply])
		
		net.Start( "nz.Perks.Sync" )
			net.WriteEntity( ply )
			net.WriteTable( data )
		return receiver and net.Send(receiver) or net.Broadcast()
	end
	
	function nzPerks:SendFullSync(receiver)
		local data = table.Copy(nzPerks.Players)
		
		net.Start( "nz.Perks.FullSync" )
			net.WriteTable( data )
		return receiver and net.Send(receiver) or net.Broadcast()
	end
	
	FullSyncModules["Perks"] = function(ply)
		nzPerks:SendFullSync(ply)
	end

end

if CLIENT then
	
	-- Server to client (Client)
	local function ReceiveSync( length )
		print("Received Player Perks Sync")
		local ply = net.ReadEntity()
		nzPerks.Players[ply] = net.ReadTable()
		--PrintTable(nzPerks.Players)
	end
	
	local function ReceiveFullSync( length )
		print("Received Full Perks Sync")
		nzPerks.Players = net.ReadTable()
		PrintTable(nzPerks.Players)
	end
	
	-- Receivers 
	net.Receive( "nz.Perks.Sync", ReceiveSync )
	net.Receive( "nz.Perks.FullSync", ReceiveFullSync )
end
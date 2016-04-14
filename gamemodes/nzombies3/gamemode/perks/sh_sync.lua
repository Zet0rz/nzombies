//Client Server Syncing

if SERVER then

	//Server to client (Server)
	util.AddNetworkString( "nz.Perks.Sync" )
	
	function nz.Perks.Functions.SendSync()
		local data = table.Copy(nz.Perks.Data.Players)
		
		net.Start( "nz.Perks.Sync" )
			net.WriteTable( data )
		net.Broadcast()
	end

end

if CLIENT then
	
	//Server to client (Client)
	function nz.Perks.Functions.ReceiveSync( length )
		print("Received Player Perks Sync")
		nz.Perks.Data.Players = net.ReadTable()
		PrintTable(nz.Perks.Data.Players)
	end
	
	//Receivers 
	net.Receive( "nz.Perks.Sync", nz.Perks.Functions.ReceiveSync )
end
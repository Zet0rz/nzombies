//Client Server Syncing

if SERVER then

	//Server to client (Server)
	util.AddNetworkString( "nz.PowerUps.Sync" )
	
	function nz.PowerUps.Functions.SendSync()
		local data = table.Copy(nz.PowerUps.Data.ActivePowerUps)
		
		net.Start( "nz.PowerUps.Sync" )
			net.WriteTable( data )
		net.Broadcast()
	end

end

if CLIENT then
	
	//Server to client (Client)
	function nz.PowerUps.Functions.ReceiveSync( length )
		print("Received PowerUps Sync")
		nz.PowerUps.Data.ActivePowerUps = net.ReadTable()
		PrintTable(nz.PowerUps.Data.ActivePowerUps)
	end
	
	//Receivers 
	net.Receive( "nz.PowerUps.Sync", nz.PowerUps.Functions.ReceiveSync )
end
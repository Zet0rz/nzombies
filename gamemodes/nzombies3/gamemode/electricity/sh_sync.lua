//Client Server Syncing

if SERVER then

	//Server to client (Server)
	util.AddNetworkString( "nz.Elec.Sync" )
	
	function nz.Elec.Functions.SendSync()
		net.Start( "nz.Elec.Sync" )
			net.WriteTable(nz.Elec.Data)
		net.Broadcast()
	end

end

if CLIENT then
	
	//Server to client (Client)
	function nz.Elec.Functions.ReceiveSync( length )
		nz.Elec.Data = net.ReadTable()
	end
	
	
	//Receivers 
	net.Receive( "nz.Elec.Sync", nz.Elec.Functions.ReceiveSync )


end
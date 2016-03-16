//Client Server Syncing

if SERVER then

	//Server to client (Server)
	util.AddNetworkString( "nz.Fog.Sync" )

	function nz.Fog.Functions.SendSync()
		local data = table.Copy(nz.Fog.Data)

		net.Start( "nz.Fog.Sync" )
			net.WriteTable( data )
		net.Broadcast()
	end

end

if CLIENT then

	//Server to client (Client)
	function nz.Fog.Functions.ReceiveSync( length )
		print("Received Fog Sync")
		nz.Fog.Data = net.ReadTable()
	end

	//Receivers
	net.Receive( "nz.Fog.Sync", nz.Fog.Functions.ReceiveSync )
end
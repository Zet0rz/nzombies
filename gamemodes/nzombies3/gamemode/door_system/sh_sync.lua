//Client Server Syncing

if SERVER then

	//Server to client (Server)
	util.AddNetworkString( "nz.Doors.Sync" )
	
	function nz.Doors.Functions.SendSync()
		local data = table.Copy(nz.Doors.Data)
		
		net.Start( "nz.Doors.Sync" )
			net.WriteTable( data )
		net.Broadcast()
	end

end

if CLIENT then
	
	//Server to client (Client)
	function nz.Doors.Functions.ReceiveSync( length )
		print("Received Doors Sync")
		nz.Doors.Data = net.ReadTable()
		--PrintTable(nz.Doors.Data)
	end
	
	//Receivers 
	net.Receive( "nz.Doors.Sync", nz.Doors.Functions.ReceiveSync )
end
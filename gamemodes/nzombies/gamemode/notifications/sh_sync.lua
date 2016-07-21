//Client Server Syncing

if SERVER then

	//Server to client (Server)
	util.AddNetworkString( "nz.Notifications.Request" )
	
	function nz.Notifications.Functions.SendRequest(header, data)
		net.Start( "nz.Notifications.Request" )
			net.WriteString( header )
			net.WriteTable( data )
		net.Broadcast()
	end

end

if CLIENT then
	
	//Server to client (Client)
	function nz.Notifications.Functions.ReceiveRequest( length )
		print("Received Notifications Request")
		local header = net.ReadString()
		local data = net.ReadTable()
		
		if header == "sound" then
			nz.Notifications.Functions.AddSoundToQueue(data)
		end
	end
	
	//Receivers 
	net.Receive( "nz.Notifications.Request", nz.Notifications.Functions.ReceiveRequest )
end
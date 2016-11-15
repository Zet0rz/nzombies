-- Client Server Syncing

if SERVER then

	-- Server to client (Server)
	util.AddNetworkString( "nz.Notifications.Request" )
	
	function nzNotifications:SendRequest(header, data)
		net.Start( "nz.Notifications.Request" )
			net.WriteString( header )
			net.WriteTable( data )
		net.Broadcast()
	end

end

if CLIENT then
	
	-- Server to client (Client)
	local function ReceiveRequest( length )
		--print("Received Notifications Request")
		local header = net.ReadString()
		local data = net.ReadTable()
		
		if header == "sound" then
			nzNotifications:AddSoundToQueue(data)
		end
	end
	
	-- Receivers 
	net.Receive( "nz.Notifications.Request", ReceiveRequest )
end
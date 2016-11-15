//Client Server Syncing

if SERVER then

	//Server to client (Server)
	util.AddNetworkString( "nz.Interfaces.Send" )

	function nzInterfaces.SendInterface(ply, interface, data)
		net.Start( "nz.Interfaces.Send" )
			net.WriteString( interface )
			net.WriteTable( data )
		net.Send(ply)
	end

	//Client to Server (Server)
	util.AddNetworkString( "nz.Interfaces.Requests" )

	function nzInterfaces.ReceiveRequests( len, ply )
		local interface = net.ReadString()
		local data = net.ReadTable()

		nzInterfaces[interface.."Handler"](ply, data)
	end

	//Receivers
	net.Receive( "nz.Interfaces.Requests", nzInterfaces.ReceiveRequests )

end

if CLIENT then

	//Server to client (Client)
	function nzInterfaces.ReceiveSync( length )
		local interface = net.ReadString()
		local data = net.ReadTable()

		nzInterfaces[interface](data)
	end

	//Receivers
	net.Receive( "nz.Interfaces.Send", nzInterfaces.ReceiveSync )

	//Client to Server (Client)
	function nzInterfaces.SendRequests( interface, data )
		net.Start( "nz.Interfaces.Requests" )
			net.WriteString( interface )
			net.WriteTable( data )
		net.SendToServer()
	end
end

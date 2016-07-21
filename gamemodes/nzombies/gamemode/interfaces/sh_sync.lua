//Client Server Syncing

if SERVER then

	//Server to client (Server)
	util.AddNetworkString( "nz.Interfaces.Send" )

	function nz.Interfaces.Functions.SendInterface(ply, interface, data)
		net.Start( "nz.Interfaces.Send" )
			net.WriteString( interface )
			net.WriteTable( data )
		net.Send(ply)
	end

	//Client to Server (Server)
	util.AddNetworkString( "nz.Interfaces.Requests" )

	function nz.Interfaces.Functions.ReceiveRequests( len, ply )
		local interface = net.ReadString()
		local data = net.ReadTable()

		nz.Interfaces.Functions[interface.."Handler"](ply, data)
	end

	//Receivers
	net.Receive( "nz.Interfaces.Requests", nz.Interfaces.Functions.ReceiveRequests )

end

if CLIENT then

	//Server to client (Client)
	function nz.Interfaces.Functions.ReceiveSync( length )
		local interface = net.ReadString()
		local data = net.ReadTable()

		nz.Interfaces.Functions[interface](data)
	end

	//Receivers
	net.Receive( "nz.Interfaces.Send", nz.Interfaces.Functions.ReceiveSync )

	//Client to Server (Client)
	function nz.Interfaces.Functions.SendRequests( interface, data )
		net.Start( "nz.Interfaces.Requests" )
			net.WriteString( interface )
			net.WriteTable( data )
		net.SendToServer()
	end
end

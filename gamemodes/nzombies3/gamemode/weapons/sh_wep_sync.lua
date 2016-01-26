//Client Server Syncing

if SERVER then

	//Server to client (Server)
	util.AddNetworkString( "nz.Weps.Sync" )

	function nz.Weps.Functions.SendSync( ply, data )
		net.Start( "nz.Weps.Sync" )
			net.WriteTable( data )
		net.Send( ply )
	end

end

if CLIENT then

	//Server to client (Client)
	function nz.Weps.Functions.ReceiveSync( length )
		print("Received Weps Sync")
		local data = net.ReadTable()
		local wep = data.wep
		data.wep = nil
		if wep != nil then
			if wep:IsValid() then
				print(wep)
				print("Applying data to: " .. wep.ClassName)
				for k,v in pairs(data) do
					wep[k] = v
				end
				PrintTable(data)
			end
		end
	end

	//Receivers
	net.Receive( "nz.Weps.Sync", nz.Weps.Functions.ReceiveSync )
end

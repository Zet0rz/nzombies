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
		print(wep)
		PrintTable(data)
		if wep != nil then
			if IsValid(wep) then
				--print(wep)
				print("Applying data to: " .. wep:GetClass())
				for k,v in pairs(data) do
					wep[k] = v
					--print(wep, wep.pap)
				end
				PrintTable(data)
				if data.pap then timer.Simple(0.1, function() wep.pap = true end) end
			end
		end
	end

	//Receivers
	net.Receive( "nz.Weps.Sync", nz.Weps.Functions.ReceiveSync )
end

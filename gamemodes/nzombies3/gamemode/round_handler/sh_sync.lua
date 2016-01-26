//Client Server Syncing

if SERVER then

	//Server to client (Server)
	util.AddNetworkString( "nz.Round.Sync" )
	
	function nz.Rounds.Functions.SendSync()
		net.Start( "nz.Round.Sync" )
			net.WriteString( nz.Rounds.Data.CurrentState )
			net.WriteString( nz.Rounds.Data.CurrentRound )
		net.Broadcast()
	end

end

if CLIENT then
	
	//Server to client (Client)
	function nz.Rounds.Functions.ReceiveSync( length )
		print("Received Round Sync")
		nz.Rounds.Data.CurrentState = tonumber(net.ReadString())
		nz.Rounds.Data.CurrentRound = tonumber(net.ReadString())
		
		//Quickly reset the electric value
		if !(nz.Rounds.Data.CurrentState == ROUND_PREP or nz.Rounds.Data.CurrentState == ROUND_PROG) or (nz.Rounds.Data.CurrentRound <= 1) then
			nz.Rounds.Data.Elec = false
		end
	end
	
	
	//Receivers 
	net.Receive( "nz.Round.Sync", nz.Rounds.Functions.ReceiveSync )


end
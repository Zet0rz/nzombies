//Client Server Syncing

if SERVER then

	//Server to client (Server)
	util.AddNetworkString( "nz.Elec.Sync" )
	util.AddNetworkString( "nz.Elec.Sound" )
	
	function Elec:SendSync(ply)
		net.Start( "nz.Elec.Sync" )
			net.WriteBool(self.Active)
		return IsValid(ply) and net.Send(ply) or net.Broadcast()
	end
	
	FullSyncModules["Elec"] = function(ply)
		Elec:SendSync(ply)
	end

end

if CLIENT then
	
	//Server to client (Client)
	local function ReceiveSync( length )
		local active = net.ReadBool()
		Elec.Active = active
	end
	
	local function RecievePowerSound()
		local on = net.ReadBool()
		print(on)
		if on then
			surface.PlaySound("nz/machines/power_up.wav")
		else
			surface.PlaySound("nz/machines/power_down.wav")
		end
	end
	
	//Receivers 
	net.Receive( "nz.Elec.Sync", ReceiveSync )
	net.Receive( "nz.Elec.Sound", RecievePowerSound )


end
-- Client Server Syncing


if SERVER then

	-- Server to client (Server)
	util.AddNetworkString( "nzWeps.Sync" )

	function nzWeps:SendSync( ply, weapon, modifier, revert )
		net.Start( "nzWeps.Sync" )
			net.WriteEntity( weapon )
			net.WriteString( modifier )
			net.WriteBool( revert )
		return ply and net.Send( ply ) or net.Broadcast()
	end

end

if CLIENT then

	-- Server to client (Client)
	local function ReceiveSync( length )
		local wep = net.ReadEntity()
		local modifier = net.ReadString()
		local revert = net.ReadBool()
		
		if !IsValid(wep) or !modifier then return end
		
		if revert then
			wep:RevertNZModifier(modifier)
		else
			wep:ApplyNZModifier(modifier)
		end
	end

	-- Receivers
	net.Receive( "nzWeps.Sync", ReceiveSync )
end

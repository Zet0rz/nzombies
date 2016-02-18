//Main Tables
nz.Mapping = nz.Mapping or {}
nz.Mapping.Functions = {}
nz.Mapping.Data = nz.Mapping.Data or {}

//_ Variables
nz.Mapping.MapSettings = nz.Mapping.MapSettings or {}

if SERVER then
	//Server to client (Server)
	util.AddNetworkString( "nz.Mapping.SyncSettings" )
	
	function nz.Mapping.Functions.ReceiveMapData(len, ply)
		local tbl = net.ReadTable()
		PrintTable(tbl)
		
		nz.Mapping.MapSettings.startwep = weapons.Get(tbl.startwep) and tbl.startwep or nz.Config.BaseStartingWeapons[1]
		nz.Mapping.MapSettings.startpoints = tonumber(tbl.startpoints) and tbl.startpoints or 500
		nz.Mapping.MapSettings.numweps = tonumber(tbl.numweps) and tbl.numweps or 2
		nz.Mapping.MapSettings.eeurl = tbl.eeurl and tbl.eeurl or nil
		nz.Mapping.MapSettings.rboxweps = tbl.rboxweps and tbl.rboxweps[1] and tbl.rboxweps or nil
		
		for k,v in pairs(player.GetAll()) do
			nz.Mapping.Functions.SendMapData(ply)
		end
		
		--nz.Mapping.MapSettings = tbl
	end
	net.Receive( "nz.Mapping.SyncSettings", nz.Mapping.Functions.ReceiveMapData )
	
	function nz.Mapping.Functions.SendMapData(ply)
		net.Start("nz.Mapping.SyncSettings")
			net.WriteTable(nz.Mapping.MapSettings)
		net.Send(ply)
	end

else

	//Client to server
	function nz.Mapping.Functions.SendMapData( data )
		if data then
			net.Start("nz.Mapping.SyncSettings")
				net.WriteTable(data)
			net.SendToServer()
		end
	end
	
	function nz.Mapping.Functions.ReceiveMapData()
		local oldeeurl = nz.Mapping.MapSettings.eeurl or ""
		nz.Mapping.MapSettings = net.ReadTable()
		
		print(oldeeurl, nz.Mapping.MapSettings.eeurl)
		
		if !EEAudioChannel or (oldeeurl != nz.Mapping.MapSettings.eeurl and nz.Mapping.MapSettings.eeurl) then
			EasterEggData.ParseSong()
		end
	end
	net.Receive( "nz.Mapping.SyncSettings", nz.Mapping.Functions.ReceiveMapData )
	
end
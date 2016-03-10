if SERVER then
	util.AddNetworkString( "Mapping.SyncSettings" )

	local function receiveMapData(len, ply)
		local tbl = net.ReadTable()
		PrintTable(tbl)

		Mapping.Settings.startwep = weapons.Get(tbl.startwep) and tbl.startwep or nz.Config.BaseStartingWeapons[1]
		Mapping.Settings.startpoints = tonumber(tbl.startpoints) and tbl.startpoints or 500
		Mapping.Settings.numweps = tonumber(tbl.numweps) and tbl.numweps or 2
		Mapping.Settings.eeurl = tbl.eeurl and tbl.eeurl or nil
		Mapping.Settings.script = tbl.script and tbl.script or nil
		Mapping.Settings.scriptinfo = tbl.scriptinfo and tbl.scriptinfo or nil
		Mapping.Settings.rboxweps = tbl.rboxweps and tbl.rboxweps[1] and tbl.rboxweps or nil

		for k,v in pairs(player.GetAll()) do
			Mapping:SendMapData(ply)
		end

		-- Mapping.Settings = tbl
	end
	net.Receive( "Mapping.SyncSettings", receiveMapData )

	function Mapping:SendMapData(ply)
		net.Start("Mapping.SyncSettings")
			net.WriteTable(self.Settings)
		net.Send(ply)
	end
end

if CLIENT then
	local function cleanUpMap()
		game.CleanUpMap()
	end

	net.Receive("nzCleanUp", cleanUpMap )

	local function receiveMapData()
		local oldeeurl = Mapping.Settings.eeurl or ""
		Mapping.Settings = net.ReadTable()

		if !EEAudioChannel or (oldeeurl != Mapping.Settings.eeurl and Mapping.Settings.eeurl) then
			EasterEggData.ParseSong()
		end
	end
	net.Receive( "Mapping.SyncSettings", receiveMapData )

	function Mapping:SendMapData( data )
		if data then
			net.Start("Mapping.SyncSettings")
				net.WriteTable(data)
			net.SendToServer()
		end
	end
end

if SERVER then
	util.AddNetworkString( "nzMapping.SyncSettings" )

	local function receiveMapData(len, ply)
		local tbl = net.ReadTable()
		PrintTable(tbl)

		if tbl.startwep then
			nzMapping.Settings.startwep = weapons.Get(tbl.startwep) and tbl.startwep or nz.Config.BaseStartingWeapons[1]
		end
		if tbl.startpoints then
			nzMapping.Settings.startpoints = tonumber(tbl.startpoints) and tbl.startpoints or 500
		end
		if tbl.numweps then
			nzMapping.Settings.numweps = tonumber(tbl.numweps) and tbl.numweps or 2
		end
		if tbl.eeurl then
			nzMapping.Settings.eeurl = tbl.eeurl and tbl.eeurl or nil
		end
		if tbl.script then
			nzMapping.Settings.script = tbl.script and tbl.script or nil
		end
		if tbl.scriptinfo then
			nzMapping.Settings.scriptinfo = tbl.scriptinfo and tbl.scriptinfo or nil
		end
		if tbl.rboxweps then
			nzMapping.Settings.rboxweps = tbl.rboxweps and tbl.rboxweps[1] and tbl.rboxweps or nil
		end
		if tbl.wunderfizzperks then
			nzMapping.Settings.wunderfizzperks = table.Count(tbl.wunderfizzperks) > 0 and tbl.wunderfizzperks or nil
		end
		if tbl.gamemodeentities then
			nzMapping.Settings.gamemodeentities = tbl.gamemodeentities or nil
		end

		for k,v in pairs(player.GetAll()) do
			nzMapping:SendMapData(ply)
		end

		-- nzMapping.Settings = tbl
	end
	net.Receive( "nzMapping.SyncSettings", receiveMapData )

	function nzMapping:SendMapData(ply)
		if !self.GamemodeExtensions then self.GamemodeExtensions = {} end
		net.Start("nzMapping.SyncSettings")
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
		local oldeeurl = nzMapping.Settings.eeurl or ""
		nzMapping.Settings = net.ReadTable()

		if !EEAudioChannel or (oldeeurl != nzMapping.Settings.eeurl and nzMapping.Settings.eeurl) then
			EasterEggData.ParseSong()
		end
		
		-- Precache all random box weapons in the list
		if nzMapping.Settings.rboxweps then
			local model = ClientsideModel("models/hoff/props/teddy_bear/teddy_bear.mdl")
			for k,v in pairs(nzMapping.Settings.rboxweps) do
				local wep = weapons.Get(v)
				if wep and (wep.WM or wep.WorldModel) then
					util.PrecacheModel(wep.WM or wep.WorldModel)
					model:SetModel(wep.WM or wep.WorldModel)
				end
			end
			model:Remove()
		end
	end
	net.Receive( "nzMapping.SyncSettings", receiveMapData )

	function nzMapping:SendMapData( data )
		if data then
			net.Start("nzMapping.SyncSettings")
				net.WriteTable(data)
			net.SendToServer()
		end
	end
end

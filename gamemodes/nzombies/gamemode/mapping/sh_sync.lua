if SERVER then
	util.AddNetworkString( "nzMapping.SyncSettings" )

	local function receiveMapData(len, ply)
		local tbl = net.ReadTable()
		PrintTable(tbl)
		nzMapping:LoadMapSettings(tbl)
		-- nzMapping.Settings = tbl
	end
	net.Receive( "nzMapping.SyncSettings", receiveMapData )

	function nzMapping:SendMapData(ply)
		if !self.GamemodeExtensions then self.GamemodeExtensions = {} end
		net.Start("nzMapping.SyncSettings")
			net.WriteTable(self.Settings)
		return IsValid(ply) and net.Send(ply) or net.Broadcast()
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
				local wep = weapons.Get(k)
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

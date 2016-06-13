if SERVER then
	util.AddNetworkString("nz_PlayerInit")
	net.Receive("nz_PlayerInit", function(len, ply)
		hook.Call("PlayerFullyInitialized", nil, ply)
	end)
	
	hook.Add("PlayerInitialSpawn", "nzCheckIfInSteamGroup", function(ply)
		-- I ask of you that you do not remove the below part. This part was made as a reward for being part of my Steam Group.
		-- Since this reward is to be used universally on all servers, I ask of you that you do not remove it. Thank you :)
		http.Fetch( "http://steamcommunity.com/groups/the_banter_brigade/memberslistxml/?xml=1",
			function(body) -- On Success
				local playerIDStartIndex = ply:SteamID64() and string.find( tostring(body), "<steamID64>"..ply:SteamID64().."</steamID64>" ) or print("Can't get SteamID64 in single player. Weaponized YTi-L4 is unavailable.")
				if playerIDStartIndex == nil then return else
					ply.nz_InSteamGroup = true
				end
			end,
			function() -- On fail
				print("Couldn't get it the data from the Banter Brigade Steam Group. Weaponized YTi-L4 is unavailable")
			end
		)
	end)
else
	hook.Add("InitPostEntity", "PlayerFullyInitialized", function()
		net.Start("nz_PlayerInit")
		net.SendToServer()
	end)

end

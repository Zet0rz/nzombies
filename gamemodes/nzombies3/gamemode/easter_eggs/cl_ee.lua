if not ConVarExists("nz_eastereggsongs") then CreateClientConVar("nz_eastereggsongs", "1") end

cvars.AddChangeCallback("nz_eastereggsongs", function( convar_name, value_old, value_new )
	local old, new = tobool(value_old), tobool(value_new)
	if old != new then
		if new then
			EasterEggData.ParseSong(play)
		else
			EasterEggData.StopSong()
			EasterEggData.AudioChannel = nil
		end
	end
end)

EasterEggData = EasterEggData or {}
EasterEggData.AudioChannel = EasterEggData.AudioChannel or nil

net.Receive("EasterEggSong", function()
	EasterEggData.PlaySong()
end)
	
net.Receive("EasterEggSongPreload", function()
	timer.Simple(1, function()
		EasterEggData.ParseSong()
	end)
end)
	
net.Receive("EasterEggSongStop", function()
	EasterEggData.StopSong()
end)
	
function EasterEggData.ParseSong(play)
	if !GetConVar("nz_eastereggsongs"):GetBool() then
		print("Prevented loading the Easter Egg song because you have nz_eastereggsongs to 0")
		return
	end

	if !nzMapping.Settings.eeurl then return end
	local url = string.lower(nzMapping.Settings.eeurl)
	if url == nil or url == "" then return end
		
	local soundcloud = string.find(url, "soundcloud.com/")
	if !soundcloud then print("Easter Egg Song currently only supports Soundcloud. Make sure you use the full URL to the song.") return end
	
	http.Fetch( "http://api.soundcloud.com/resolve?url="..url.."&client_id=d8e0407577f7fc8475978904ef89b1f7",
	function( body, len, headers, code )
		if body then
			local _, streamstart = string.find(body, '"stream_url":"')
			if !streamstart then print("This Soundcloud song does not have allow streaming.") return end
			local streamend = string.find(body, '","', streamstart + 1)
			local stream = string.sub(body, streamstart + 1, streamend - 1)
			if stream then
				if play then
					EasterEggData.PlaySong(stream.."?client_id=d8e0407577f7fc8475978904ef89b1f7")
				else
					EasterEggData.PreloadSong(stream.."?client_id=d8e0407577f7fc8475978904ef89b1f7")
				end
			else
				print("This Soundcloud song does not have allow streaming.")
			end
		return end
	end, 
	function( error )
		Error( "Failed to fetch song! Error: " .. error )
	end )
end
	
function EasterEggData.PlaySong(url)
	-- We have a preloaded channel
	if IsValid(EasterEggData.AudioChannel) then
		EasterEggData.AudioChannel:Play()
		print("Playing easter egg song!")
	-- We need to instantly play the given link
	elseif url then
		--print("Playing!")
		sound.PlayURL( url, "", function(channel) EasterEggData.AudioChannel = channel end)
		print("Easter egg song was not preloaded, will play through streaming.")
	-- No link and no preload, parse the link and loopback to above
	else
		EasterEggData.ParseSong(true)
	end
end
	
function EasterEggData.StopSong()
	if IsValid(EasterEggData.AudioChannel) then
		EasterEggData.AudioChannel:Stop()
	end
end
	
function EasterEggData.PreloadSong(song)
	sound.PlayURL( song, "noplay noblock", function(channel) EasterEggData.AudioChannel = channel end)
	print("Successfully preloaded easter egg song")
end
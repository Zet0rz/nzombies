EasterEggData = {}
EasterEggData.AudioChannel = nil

net.Receive("EasterEggSong", function()
	EasterEggData.PlaySong()
end)
	
net.Receive("EasterEggSongPreload", function()
	timer.Simple(1, function()
		ParseSong(false)
	end)
end)
	
net.Receive("EasterEggSongStop", function()
	EasterEggData.StopSong()
end)
	
function EasterEggData.ParseSong(play)
	local url = string.lower(nz.Mapping.MapSettings.eeurl)
	if url == nil or url == "" then return end
		
	local soundcloud = string.find(url, "soundcloud.com/")
	if !soundcloud then print("Easter Egg Song currently only supports Soundcloud. Make sure you use the full URL to the song.") return end
	
	http.Fetch( "http://api.soundcloud.com/resolve?url="..url.."&client_id=d8e0407577f7fc8475978904ef89b1f7",
	function( body, len, headers, code )
		if body then
			local _, streamstart = string.find(body, '"stream_url":"')
			local streamend = string.find(body, '","', streamstart + 1)
			local stream = string.sub(body, streamstart + 1, streamend - 1)
			if stream then
				if play then
					EasterEggData.PlaySong(stream.."?client_id=d8e0407577f7fc8475978904ef89b1f7")
				else
					EasterEggData.PreloadSong(stream.."?client_id=d8e0407577f7fc8475978904ef89b1f7")
				end
			else
				print("This SoundCloud song does not have allow streaming")
			end
		return end
	end, 
	function( error )
		Error( "Failed to fetch song! Error: " .. error )
	end )
end
	
function EasterEggData.PlaySong(url)
	//We have a preloaded channel
	if IsValid(EasterEggData.AudioChannel) then
		EasterEggData.AudioChannel:Play()
	//We need to instantly play the given link
	elseif url then
		--print("Playing!")
		sound.PlayURL( url, "", function(channel) EasterEggData.AudioChannel = channel end)
	//No link and no preload, parse the link and loopback to above
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
end
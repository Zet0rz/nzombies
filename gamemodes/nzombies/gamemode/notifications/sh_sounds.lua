//

if SERVER then

	function nz.Notifications.Functions.PlaySound(path, delay)
		nz.Notifications.Functions.SendRequest("sound", {path = path, delay = delay})
	end
	
end

if CLIENT then
	
	function nz.Notifications.Functions.AddSoundToQueue(data)
		table.insert(nz.Notifications.Data.SoundQueue, data)
	end
	
	function nz.Notifications.Functions.SoundHandler()
		//Check we're allowed to play the next sound
		if CurTime() > nz.Notifications.Data.NextSound then
			//Check the queue
			if nz.Notifications.Data.SoundQueue[1] != nil then
				local data = nz.Notifications.Data.SoundQueue[1]
				table.remove(nz.Notifications.Data.SoundQueue, 1)
				surface.PlaySound( data.path )
				nz.Notifications.Data.NextSound = CurTime() + data.delay
			end
		end
	end
	
	timer.Create("nz.Sound.Handler", 1, 0, nz.Notifications.Functions.SoundHandler)
end




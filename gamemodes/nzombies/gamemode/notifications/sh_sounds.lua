--

if SERVER then

	function nzNotifications:PlaySound(path, delay)
		self:SendRequest("sound", {path = path, delay = delay})
	end
	
end

if CLIENT then
	
	function nzNotifications:AddSoundToQueue(data)
		table.insert(self.Data.SoundQueue, data)
	end
	
	function nzNotifications.SoundHandler()
		-- Check we're allowed to play the next sound
		if CurTime() > nzNotifications.Data.NextSound then
			-- Check the queue
			if nzNotifications.Data.SoundQueue[1] != nil then
				local data = nzNotifications.Data.SoundQueue[1]
				table.remove(nzNotifications.Data.SoundQueue, 1)
				surface.PlaySound( data.path )
				nzNotifications.Data.NextSound = CurTime() + data.delay
			end
		end
	end
	
	timer.Create("nz.Sound.Handler", 1, 0, nzNotifications.SoundHandler)
end




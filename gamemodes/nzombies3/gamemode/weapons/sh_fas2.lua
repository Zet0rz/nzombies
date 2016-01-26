function FAS2_PlayAnim(wep, anim, speed, cyc, time)
	speed = speed and speed or 1
	cyc = cyc and cyc or 0
	time = time or 0

	if type(anim) == "table" then
		anim = table.Random(anim)
	end

	anim = string.lower(anim)
	
	if wep.Owner:HasPerk("sleight") then
		if string.find(anim, "reload") != nil or string.find(anim, "insert") != nil then
			speed = 2
		end
	end
	if wep.Owner:HasPerk("dtap") then
		if string.find(anim, "fire") != nil or string.find(anim, "cock") != nil or string.find(anim, "pump") != nil then
			speed = 1.25
		end
	end

	if game.SinglePlayer() then
		if SERVER then
			if wep.Sounds[anim] then
				wep.CurSoundTable = wep.Sounds[anim]
				wep.CurSoundEntry = 1
				wep.SoundSpeed = speed
				wep.SoundTime = CurTime() + time
			end
		end
			/*if wep.Sounds[anim] then
				for k, v in pairs(wep.Sounds[anim]) do
					timer.Simple(v.time, function()
						if IsValid(ply) and ply:Alive() and IsValid(wep) and wep == ply:GetActiveWeapon() then
							wep:EmitSound(v.sound, 70, 100)
						end
					end)
				end
			end
		end*/
	else
		if wep.Sounds[anim] then
			wep.CurSoundTable = wep.Sounds[anim]
			wep.CurSoundEntry = 1
			wep.SoundSpeed = speed
			wep.SoundTime = CurTime() + time
		end

		/*if wep.Sounds[anim] then
			for k, v in pairs(wep.Sounds[anim]) do
				timer.Simple(v.time, function()
					wep:EmitSound(v.sound, 70, 100)
				end)
			end
		end*/
	end

	if SERVER and game.SinglePlayer() then
		ply = Entity(1)

		umsg.Start("FAS2ANIM", ply)
			umsg.String(anim)
			umsg.Float(speed)
			umsg.Float(cyc)
		umsg.End()
	end

	if CLIENT then
		vm = wep.Wep

		wep.CurAnim = string.lower(anim)

		if vm then
			vm:SetCycle(cyc)
			vm:SetSequence(anim)
			vm:SetPlaybackRate(speed)
		end
	end
end

//

if SERVER then
	function nz.PowerUps.Functions.Activate(id, ply)
		local powerupData = nz.PowerUps.Functions.Get(id)

		if powerupData.duration != 0 then
			//Activate for a certain time
			nz.PowerUps.Data.ActivePowerUps[id] = CurTime() + powerupData.duration
		//else
			//Activate Once

		end

		//Notify
		ply:EmitSound("nz/powerups/power_up_grab.wav")
		powerupData.func(id, ply)

		//Sync
		nz.PowerUps.Functions.SendSync()
	end

	function nz.PowerUps.Functions.SpawnPowerUp(pos, specific)
		local choices = {}
		local total = 0

		//Chance it
		if !specific then
			for k,v in pairs(nz.PowerUps.Data) do
				if k != "ActivePowerUps" then
					choices[k] = v.chance
					total = total + v.chance
				end
			end
		end

		local id = specific and specific or nzMisc.WeightedRandom(choices)
		if !id or id == "null" then return end // Back out

		//Spawn it
		local powerupData = nz.PowerUps.Functions.Get(id)

		local pos = pos+Vector(0,0,50)
		local ent = ents.Create("drop_powerup")
		ent:SetPowerUp(id)
		pos.z = pos.z - ent:OBBMaxs().z
		ent:SetModel(powerupData.model)
		ent:SetPos(pos)
		ent:SetAngles(powerupData.angle)
		ent:Spawn()
		ent:EmitSound("nz/powerups/power_up_spawn.wav")
	end

end

function nz.PowerUps.Functions.IsPowerupActive(id)

	local time = nz.PowerUps.Data.ActivePowerUps[id]

	if time != nil then
		//Check if it is still within the time.
		if CurTime() > time then
			//Expired
			nz.PowerUps.Data.ActivePowerUps[id] = nil
		else
			return true
		end
	end

	return false

end

function nz.PowerUps.Functions.AllActivePowerUps()

	return nz.PowerUps.Data.ActivePowerUps

end

function nz.PowerUps.Functions.NewPowerUp(id, data)
	if SERVER then
		//Sanitise any client data.
	else
		data.Func = nil
	end
	nz.PowerUps.Data[id] = data
end

function nz.PowerUps.Functions.Get(id)
	return nz.PowerUps.Data[id]
end

//Double Points
nz.PowerUps.Functions.NewPowerUp("dp", {
	name = "Double Points",
	model = "models/nzpowerups/x2.mdl",
	angle = Angle(25,0,0),
	scale = 1,
	chance = 5,
	duration = 30,
	func = (function(self, ply)
		nz.Notifications.Functions.PlaySound("nz/powerups/double_points.mp3", 1)
	end),
})

//Max Ammo
nz.PowerUps.Functions.NewPowerUp("maxammo", {
	name = "Max Ammo",
	model = "models/Items/BoxSRounds.mdl",
	angle = Angle(0,0,25),
	scale = 1.5,
	chance = 5,
	duration = 0,
	func = (function(self, ply)
		nz.Notifications.Functions.PlaySound("nz/powerups/max_ammo.mp3", 2)
		//Give everyone ammo
		for k,v in pairs(player.GetAll()) do
			nz.Weps.Functions.GiveMaxAmmo(v)
		end
	end),
})

//Insta Kill
nz.PowerUps.Functions.NewPowerUp("insta", {
	name = "Insta Kill",
	model = "models/nzpowerups/insta.mdl",
	angle = Angle(0,0,0),
	scale = 1,
	chance = 5,
	duration = 30,
	func = (function(self, ply)
		nz.Notifications.Functions.PlaySound("nz/powerups/insta_kill.mp3", 1)
	end),
})

//Nuke
nz.PowerUps.Functions.NewPowerUp("nuke", {
	name = "Nuke",
	model = "models/nzpowerups/nuke.mdl",
	angle = Angle(10,0,0),
	scale = 1,
	chance = 5,
	duration = 0,
	func = (function(self, ply)
		nz.Notifications.Functions.PlaySound("nz/powerups/nuke.mp3", 1)
		nz.PowerUps.Functions.Nuke()
	end),
})

//Fire Sale
nz.PowerUps.Functions.NewPowerUp("firesale", {
	name = "Fire Sale",
	model = "models/nzpowerups/firesale.mdl",
	angle = Angle(45,0,0),
	scale = 0.75,
	chance = 1,
	duration = 30,
	func = (function(self, ply)
		nz.Notifications.Functions.PlaySound("nz/powerups/fire_sale_announcer.wav", 1)
		nz.PowerUps.Functions.FireSale()
	end),
})

//Carpenter
nz.PowerUps.Functions.NewPowerUp("carpenter", {
	name = "Carpenter",
	model = "models/nzpowerups/carpenter.mdl",
	angle = Angle(45,0,0),
	scale = 1,
	chance = 5,
	duration = 0,
	func = (function(self, ply)
		nz.Notifications.Functions.PlaySound("nz/powerups/carpenter.wav", 0)
		nz.Notifications.Functions.PlaySound("nz/powerups/carp_loop.wav", 1)
		nz.PowerUps.Functions.Carpenter()
	end),
})

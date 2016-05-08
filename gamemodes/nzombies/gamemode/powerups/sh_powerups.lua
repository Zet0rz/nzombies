-- 

if SERVER then

	local plyMeta = FindMetaTable("Player")
	
	function plyMeta:GivePowerUp(id, duration)
		if !nzPowerUps.ActivePlayerPowerUps[self] then nzPowerUps.ActivePlayerPowerUps[self] = {} end
		nzPowerUps.ActivePlayerPowerUps[self][id] = CurTime() + duration
	end
	
	function nzPowerUps:Activate(id, ply)
		local powerupData = self:Get(id)

		if !powerupData.global then
			if powerupData.duration != 0 then
				ply:GivePowerUp(id, powerupData.duration)
			end
			self:SendPlayerSync(ply) -- Sync this player's powerups
		else
			if powerupData.duration != 0 then
				-- Activate for a certain time
				self.ActivePowerUps[id] = CurTime() + powerupData.duration
			--else
				-- Activate Once

			end
			-- Sync to everyone
			self:SendSync()
		end

		-- Notify
		ply:EmitSound("nz/powerups/power_up_grab.wav")
		powerupData.func(id, ply)
	end

	function nzPowerUps:SpawnPowerUp(pos, specific)
		local choices = {}
		local total = 0

		-- Chance it
		if !specific then
			for k,v in pairs(self.Data) do
				if k != "ActivePowerUps" then
					choices[k] = v.chance
					total = total + v.chance
				end
			end
		end

		local id = specific and specific or nzMisc.WeightedRandom(choices)
		if !id or id == "null" then return end --  Back out

		-- Spawn it
		local powerupData = self:Get(id)

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

function nzPowerUps:IsPowerupActive(id)

	local time = self.ActivePowerUps[id]

	if time != nil then
		-- Check if it is still within the time.
		if CurTime() > time then
			-- Expired
			self.ActivePowerUps[id] = nil
		else
			return true
		end
	end

	return false

end

function nzPowerUps:IsPlayerPowerupActive(ply, id)

	local time = self.ActivePlayerPowerUps[ply][id]

	if time then
		-- Check if it is still within the time.
		if CurTime() > time then
			-- Expired
			self.ActivePlayerPowerUps[ply][id] = nil
		else
			return true
		end
	end

	return false

end

function nzPowerUps:AllActivePowerUps()

	return self.ActivePowerUps

end

function nzPowerUps:NewPowerUp(id, data)
	if SERVER then
		-- Sanitise any client data.
	else
		data.Func = nil
	end
	self.Data[id] = data
end

function nzPowerUps:Get(id)
	return self.Data[id]
end

-- Double Points
nzPowerUps:NewPowerUp("dp", {
	name = "Double Points",
	model = "models/nzpowerups/x2.mdl",
	global = true, -- Global means it will appear for any player and will refresh its own time if more
	angle = Angle(25,0,0),
	scale = 1,
	chance = 5,
	duration = 30,
	func = (function(self, ply)
		nz.Notifications.Functions.PlaySound("nz/powerups/double_points.mp3", 1)
	end),
})

-- Max Ammo
nzPowerUps:NewPowerUp("maxammo", {
	name = "Max Ammo",
	model = "models/Items/BoxSRounds.mdl",
	global = true,
	angle = Angle(0,0,25),
	scale = 1.5,
	chance = 5,
	duration = 0,
	func = (function(self, ply)
		nz.Notifications.Functions.PlaySound("nz/powerups/max_ammo.mp3", 2)
		-- Give everyone ammo
		for k,v in pairs(player.GetAll()) do
			nz.Weps.Functions.GiveMaxAmmo(v)
		end
	end),
})

-- Insta Kill
nzPowerUps:NewPowerUp("insta", {
	name = "Insta Kill",
	model = "models/nzpowerups/insta.mdl",
	global = true,
	angle = Angle(0,0,0),
	scale = 1,
	chance = 5,
	duration = 30,
	func = (function(self, ply)
		nz.Notifications.Functions.PlaySound("nz/powerups/insta_kill.mp3", 1)
	end),
})

-- Nuke
nzPowerUps:NewPowerUp("nuke", {
	name = "Nuke",
	model = "models/nzpowerups/nuke.mdl",
	global = true,
	angle = Angle(10,0,0),
	scale = 1,
	chance = 5,
	duration = 0,
	func = (function(self, ply)
		nz.Notifications.Functions.PlaySound("nz/powerups/nuke.wav", 1)
		nzPowerUps:Nuke(ply:GetPos())
	end),
})

-- Fire Sale
nzPowerUps:NewPowerUp("firesale", {
	name = "Fire Sale",
	model = "models/nzpowerups/firesale.mdl",
	global = true,
	angle = Angle(45,0,0),
	scale = 0.75,
	chance = 1,
	duration = 30,
	func = (function(self, ply)
		nz.Notifications.Functions.PlaySound("nz/powerups/fire_sale_announcer.wav", 1)
		nzPowerUps:FireSale()
	end),
	expirefunc = function()
		local tbl = ents.FindByClass("random_box_spawns")
		for k,v in pairs(tbl) do
			if IsValid(v.FireSaleBox) then
				v.FireSaleBox:MarkForRemoval()
			end
		end
	end,
})

-- Carpenter
nzPowerUps:NewPowerUp("carpenter", {
	name = "Carpenter",
	model = "models/nzpowerups/carpenter.mdl",
	global = true,
	angle = Angle(45,0,0),
	scale = 1,
	chance = 5,
	duration = 0,
	func = (function(self, ply)
		nz.Notifications.Functions.PlaySound("nz/powerups/carpenter.wav", 0)
		nz.Notifications.Functions.PlaySound("nz/powerups/carp_loop.wav", 1)
		nzPowerUps:Carpenter()
	end),
})

-- Zombie Blood
nzPowerUps:NewPowerUp("zombieblood", {
	name = "Zombie Blood",
	model = "models/nzpowerups/zombieblood.mdl",
	global = false, -- Only applies to the player picking it up and time is handled individually per player
	angle = Angle(0,0,0),
	scale = 1,
	chance = 2,
	duration = 30,
	func = (function(self, ply)
		nz.Notifications.Functions.PlaySound("nz/powerups/zombie_blood.wav", 1)
		ply:SetTargetPriority(TARGET_PRIORITY_NONE)
	end),
	expirefunc = function(self, ply) -- ply is only passed if the powerup is non-global
		ply:SetTargetPriority(TARGET_PRIORITY_PLAYER)
	end,
})
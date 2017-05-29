-- 

if SERVER then

	local plyMeta = FindMetaTable("Player")
	
	function plyMeta:GivePowerUp(id, duration)
		if duration > 0 then
			if !nzPowerUps.ActivePlayerPowerUps[self] then nzPowerUps.ActivePlayerPowerUps[self] = {} end
			
			nzPowerUps.ActivePlayerPowerUps[self][id] = CurTime() + duration
			nzPowerUps:SendPlayerSync(self) -- Sync this player's powerups
		end
	end
	
	function plyMeta:RemovePowerUp(id, nosync)
		local PowerupData = nzPowerUps:Get(id)
		if PowerupData and PowerupData.expirefunc then
			PowerupData.expirefunc(id, self) -- Call expirefunc when manually removed
		end
	
		if !nzPowerUps.ActivePlayerPowerUps[self] then nzPowerUps.ActivePlayerPowerUps[self] = {} end
		nzPowerUps.ActivePlayerPowerUps[self][id] = nil
		if !nosync then nzPowerUps:SendPlayerSync(self) end -- Sync this player's powerups
	end
	
	function plyMeta:RemoveAllPowerUps()
		if !nzPowerUps.ActivePlayerPowerUps[self] then nzPowerUps.ActivePlayerPowerUps[self] = {} return end
		
		for k,v in pairs(nzPowerUps.ActivePlayerPowerUps[self]) do
			self:RemovePowerUp(k, true)
		end
		nzPowerUps:SendPlayerSync(self)
	end
	
	function nzPowerUps:Activate(id, ply, ent)
		if hook.Call("OnPlayerPickupPowerUp", nil, ply, id, ent) then return end
		
		local PowerupData = self:Get(id)

		if !PowerupData.global then
			if IsValid(ply) then
				if not nzPowerUps.ActivePlayerPowerUps[ply] or not nzPowerUps.ActivePlayerPowerUps[ply][id] then -- If you don't have the powerup
					PowerupData.func(id, ply)
				end
				ply:GivePowerUp(id, PowerupData.duration)
			end
		else
			if PowerupData.duration != 0 then
				-- Activate for a certain time
				if not self.ActivePowerUps[id] then
					PowerupData.func(id, ply)
				end
				self.ActivePowerUps[id] = CurTime() + PowerupData.duration
			else
				-- Activate Once
				PowerupData.func(id, ply)
			end
			-- Sync to everyone
			self:SendSync()
			
		end

		-- Notify
		if IsValid(ply) then ply:EmitSound("nz/powerups/power_up_grab.wav") end
		if PowerupData.announcement then
			nzNotifications:PlaySound(PowerupData.announcement, 1)
		end
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
		
		local ent = ents.Create("drop_powerup")
		id = hook.Call("OnPowerUpSpawned", nil, id, ent) or id
		if !IsValid(ent) then return end -- If a hook removed the powerup

		-- Spawn it
		local PowerupData = self:Get(id)

		local pos = pos+Vector(0,0,50)
		
		ent:SetPowerUp(id)
		pos.z = pos.z - ent:OBBMaxs().z
		ent:SetModel(PowerupData.model)
		ent:SetPos(pos)
		ent:SetAngles(PowerupData.angle)
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
	announcement = "nz/powerups/double_points.mp3",
	func = function(self, ply)
	end,
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
		nzNotifications:PlaySound("nz/powerups/max_ammo.mp3", 2)
		-- Give everyone ammo
		for k,v in pairs(player.GetAll()) do
			v:GiveMaxAmmo()
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
	announcement = "nz/powerups/insta_kill.mp3",
	func = function(self, ply)
		print("Called")
	end,
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
	announcement = "nz/powerups/nuke.wav",
	func = (function(self, ply)
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
	announcement = "nz/powerups/fire_sale_announcer.wav",
	func = (function(self, ply)
		nzPowerUps:FireSale()
		
		-- Adding sound code so that you can turn it off
		-- Putting it here because you need to be able to turn it off too.
		FSaleLoopSound = CreateSound("random_box","nz/randombox/fire_sale.wav")				-- Creates CSoundPatch
		FSaleLoopSound:SetSoundLevel(SNDLVL_NONE) 											-- Makes it play everywhere
		if !FSaleLoopSound:IsPlaying() then 												-- Are we currently playing?
			FSaleLoopSound:PlayEx(1,100) 													-- If not then play the sound with max (1) volume and normal (100) pitch.
		end
		
	end),
	expirefunc = function()
		local tbl = ents.FindByClass("random_box_spawns")
		for k,v in pairs(tbl) do
			local box = v.FireSaleBox
			if IsValid(box) then
				box:StopSound("nz_firesale_jingle")
				if box.MarkForRemoval then
					box:MarkForRemoval()
					box.FireSaling = false
				else
					box:Remove()
				end
			end
		end
		
		-- FSaleLoopSound:Stop()																-- Then we turn it off.
		FSaleLoopSound:FadeOut()															-- Then we make it fade out.
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
		nzNotifications:PlaySound("nz/powerups/carpenter.wav", 0)
		nzNotifications:PlaySound("nz/powerups/carp_loop.wav", 1)
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
	announcement = "nz/powerups/zombie_blood.wav",
	func = (function(self, ply)
		ply:SetTargetPriority(TARGET_PRIORITY_NONE)
	end),
	expirefunc = function(self, ply) -- ply is only passed if the powerup is non-global
		ply:SetTargetPriority(TARGET_PRIORITY_PLAYER)
	end,
})

-- Death Machine
nzPowerUps:NewPowerUp("deathmachine", {
	name = "Death Machine",
	model = "models/nzpowerups/deathmachine.mdl",
	global = false, -- Only applies to the player picking it up and time is handled individually per player
	angle = Angle(0,0,0),
	scale = 1,
	chance = 2,
	duration = 30,
	announcement = "nz/powerups/deathmachine.mp3",
	func = (function(self, ply)
		ply:SetUsingSpecialWeapon(true)
		ply:Give("nz_death_machine")
		ply:SelectWeapon("nz_death_machine")
	end),
	expirefunc = function(self, ply) -- ply is only passed if the powerup is non-global
		ply:SetUsingSpecialWeapon(false)
		ply:StripWeapon("nz_death_machine")
		ply:EquipPreviousWeapon()
	end,
})
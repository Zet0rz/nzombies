-- 

hook.Add("Think", "CheckActivePowerups", function()
	for k,v in pairs(nzPowerUps.ActivePowerUps) do
		if CurTime() >= v then
			local func = nzPowerUps:Get(k).expirefunc
			if func then func(id) end
			nzPowerUps.ActivePowerUps[k] = nil
			nzPowerUps:SendSync()
		end
	end
	for k,v in pairs(nzPowerUps.ActivePlayerPowerUps) do
		for id, time in pairs(v) do
			if CurTime() >= time then
				local func = nzPowerUps:Get(id).expirefunc
				if func then func(id, k) end
				nzPowerUps.ActivePlayerPowerUps[k][id] = nil
				nzPowerUps:SendPlayerSync(k)
			end
		end
	end
end)

function nzPowerUps:Nuke(pos, nopoints, noeffect)
	-- Kill them all
	local highesttime = 0
	if pos and type(pos) == "Vector" then
		for k,v in pairs(ents.GetAll()) do
			if nzConfig.ValidEnemies[v:GetClass()] then
				if IsValid(v) then
					v:SetBlockAttack(true) -- They cannot attack now!
					local insta = DamageInfo()
					insta:SetDamage(v:Health())
					insta:SetAttacker(Entity(0))
					insta:SetDamageType(DMG_BLAST_SURFACE)
					-- Delay the death by the distance from the position in milliseconds
					local time = v:GetPos():Distance(pos)/1000
					if time > highesttime then highesttime = time end
					timer.Simple(time, function() if IsValid(v) then v:TakeDamageInfo( insta ) end end)
				end
			end
		end
	else
		for k,v in pairs(ents.GetAll()) do
			if nzConfig.ValidEnemies[v:GetClass()] then
				if IsValid(v) then
					local insta = DamageInfo()
					insta:SetDamage(v:Health())
					insta:SetAttacker(Entity(0))
					insta:SetDamageType(DMG_BLAST_SURFACE)
					timer.Simple(0.1, function() if IsValid(v) then v:TakeDamageInfo( insta ) end end)
				end
			end
		end
	end
	
	-- Give the players a set amount of points
	if !nopoints then
		timer.Simple(highesttime, function()
			if nzRound:InProgress() then -- Only if the game is still going!
				for k,v in pairs(player.GetAll()) do
					if v:IsPlayer() then
						v:GivePoints(400)
					end
				end
			end
		end)
	end
	
	if !noeffect then
		net.Start("nzPowerUps.Nuke")
		net.Broadcast()
	end
end

-- Add the sound so we can stop it again
sound.Add( {
	name = "nz_firesale_jingle",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 75,
	pitch = { 100, 100 },
	sound = "nz/randombox/fire_sale.wav"
} )

function nzPowerUps:FireSale()
	--print("Running")
	-- Get all spawns
	local all = ents.FindByClass("random_box_spawns")
	
	for k,v in pairs(all) do
		if !v.HasBox then
			if v != nil and !v.HasBox then
				local box = ents.Create( "random_box" )
				box:SetPos( v:GetPos() )
				box:SetAngles( v:GetAngles() )
				box:Spawn()
				--box:PhysicsInit( SOLID_VPHYSICS )
				box.SpawnPoint = v
				v.FireSaleBox = box

				local phys = box:GetPhysicsObject()
				if phys:IsValid() then
					phys:EnableMotion(false)
				end
			else
				print("No random box spawns have been set.")
			end
		end
	end
	
	for k,v in pairs(ents.FindByClass("random_box")) do
		v:EmitSound("nz_firesale_jingle")
	end
end

function nzPowerUps:CleanUp()
	-- Clear all powerups
	for k,v in pairs(ents.FindByClass("drop_powerup")) do
		v:Remove()
	end
	
	-- Turn off all modifiers
	table.Empty(self.ActivePowerUps)
	-- Sync
	self:SendSync()
end

function nzPowerUps:Carpenter(nopoints)
	-- Repair them all
	for k,v in pairs(ents.FindByClass("breakable_entry")) do
		if v:IsValid() then
			for i=1, GetConVar("nz_difficulty_barricade_planks_max"):GetInt() do
				if i > #v.Planks then
					v:AddPlank()
				end
			end
		end	
	end
	
	-- Give the players a set amount of points
	if !nopoints then
		for k,v in pairs(player.GetAll()) do
			if v:IsPlayer() then
				v:GivePoints(200)
			end
		end
	end
end
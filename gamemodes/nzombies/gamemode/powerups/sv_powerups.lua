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
		if !IsValid(k) then
			nzPowerUps.ActivePlayerPowerUps[k] = nil
			nzPowerUps:SendPlayerSyncFull()
		else
			for id, time in pairs(v) do
				if CurTime() >= time then
					local func = nzPowerUps:Get(id).expirefunc
					if func then func(id, k) end
					nzPowerUps.ActivePlayerPowerUps[k][id] = nil
					nzPowerUps:SendPlayerSync(k)
				end
			end
		end
	end
end)

function nzPowerUps:Nuke(pos, nopoints, noeffect)
	-- Kill them all
	local highesttime = 0
	if pos and type(pos) == "Vector" then
		for k,v in pairs(ents.GetAll()) do
			if v:IsValidZombie() then
				if IsValid(v) then
					v:SetBlockAttack(true) -- They cannot attack now!
					local insta = DamageInfo()
					insta:SetAttacker(Entity(0))
					insta:SetDamageType(DMG_BLAST_SURFACE)
					-- Delay the death by the distance from the position in milliseconds
					local time = v:GetPos():Distance(pos)/1000
					if time > highesttime then highesttime = time end
					timer.Simple(time, function()
						if IsValid(v) then
							insta:SetDamage(v:Health())
							v:TakeDamageInfo( insta )
						end
					end)
				end
			end
		end
	else
		for k,v in pairs(ents.GetAll()) do
			if v:IsValidZombie() then
				print(v, IsValid(v))
				if IsValid(v) then
					local insta = DamageInfo()
					insta:SetAttacker(Entity(0))
					insta:SetInflictor(Entity(0))
					insta:SetDamageType(DMG_BLAST_SURFACE)
					timer.Simple(0.1, function()
						if IsValid(v) then
							insta:SetDamage(v:Health())
							v:TakeDamageInfo( insta )
						end
					end)
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

function nzPowerUps:FireSale()
	--print("Running")
	-- Get all spawns
	local all = ents.FindByClass("random_box_spawns")
	
	for k,v in pairs(all) do
		if !IsValid(v.Box) then
			local box = ents.Create( "random_box" )
			local pos = v:GetPos()
			local ang = v:GetAngles()
			
			box:SetPos( pos + ang:Up()*10 + ang:Right()*7 )
			box:SetAngles( ang )
			box:Spawn()
			--box:PhysicsInit( SOLID_VPHYSICS )
			box.SpawnPoint = v
			v.FireSaleBox = box
			
			v:SetBodygroup(1,1)

			local phys = box:GetPhysicsObject()
			if phys:IsValid() then
				phys:EnableMotion(false)
			end
			
			box:EmitSound("nz_firesale_jingle")
		else
			local sound = ents.Create("nz_prop_effect_attachment")
			sound:SetNoDraw(true)
			sound:SetPos(v:GetPos())
			sound:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
			sound:Spawn()
			sound:EmitSound("nz_firesale_jingle")
			v.FireSaleBox = sound
		end
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
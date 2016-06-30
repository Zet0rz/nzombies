function nzEnemies:OnEnemyKilled(enemy, attacker, dmginfo, hitgroup)
	--  Prevent multiple "dyings" by making sure the zombie has not already been "killed"
	if enemy.MarkedForDeath then return end

	if attacker:IsPlayer() then
		--attacker:GivePoints(90)
		attacker:AddFrags(1)
		if attacker:HasPerk("vulture") then
			if math.random(10) == 1 then
				local drop = ents.Create("drop_vulture")
				drop:SetPos(enemy:GetPos() + Vector(0,0,50))
				drop:Spawn()
			end
		end
	end

	-- Run special on-killed function if it has any
	nzConfig.ValidEnemies[enemy:GetClass()].OnKilled(enemy, dmginfo, hitgroup)

	if nzRound:InProgress() then
		nzRound:SetZombiesKilled( nzRound:GetZombiesKilled() + 1 )

		-- Chance a powerup spawning
		if !nzPowerUps:IsPowerupActive("insta") and IsValid(enemy) then -- Don't spawn powerups during instakill
			if !nzPowerUps:GetPowerUpChance() then nzPowerUps:ResetPowerUpChance() end
			if math.Rand(0, 100) < nzPowerUps:GetPowerUpChance() then
				nzPowerUps:SpawnPowerUp(enemy:GetPos())
				nzPowerUps:ResetPowerUpChance()
			else
				nzPowerUps:IncreasePowerUpChance()
			end
		end

		print("Killed Enemy: " .. nzRound:GetZombiesKilled() .. "/" .. nzRound:GetZombiesMax() )
		if nzRound:IsSpecial() and nzRound:GetZombiesKilled() >= nzRound:GetZombiesMax() then
			nzPowerUps:SpawnPowerUp(enemy:GetPos(), "maxammo")
			--reset chance here?
		end
	end
	-- Prevent this function from running on this zombie again
	enemy.MarkedForDeath = true
end

function GM:EntityTakeDamage(zombie, dmginfo)

	-- Who's Who clones can't take damage!
	if zombie:GetClass() == "whoswho_downed_clone" then return true end
	
	if zombie.Alive and zombie:Alive() and zombie:Health() < 0 then zombie:SetHealth(1) end

	if !dmginfo:GetAttacker():IsPlayer() then return end
	if IsValid(zombie) and nzConfig.ValidEnemies[zombie:GetClass()] and nzConfig.ValidEnemies[zombie:GetClass()].Valid then
		local hitgroup = util.QuickTrace( dmginfo:GetDamagePosition( ), dmginfo:GetDamagePosition( ) ).HitGroup

		if nzPowerUps:IsPowerupActive("insta") then
			dmginfo:SetDamage(zombie:Health())
			nzEnemies:OnEnemyKilled(zombie, dmginfo:GetAttacker(), dmginfo, hitgroup)
		return end


		nzConfig.ValidEnemies[zombie:GetClass()].ScaleDMG(zombie, hitgroup, dmginfo)

		--  Pack-a-Punch doubles damage
		if dmginfo:GetAttacker():GetActiveWeapon().pap then dmginfo:ScaleDamage(2) end

		if zombie:Health() > dmginfo:GetDamage() then
			if zombie.HasTakenDamageThisTick then return end
			nzConfig.ValidEnemies[zombie:GetClass()].OnHit(zombie, dmginfo, hitgroup)
			zombie.HasTakenDamageThisTick = true
			--  Prevent multiple damages in one tick (FA:S 2 Bullet penetration makes them hit 1 zombie 2-3 times per bullet)
			timer.Simple(0, function() if IsValid(zombie) then zombie.HasTakenDamageThisTick = false end end)
		else
			nzEnemies:OnEnemyKilled(zombie, dmginfo:GetAttacker(), dmginfo, hitgroup)
		end
	end
end

local function OnRagdollCreated( ent )
	if ( ent:GetClass() == "prop_ragdoll" ) then
		ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	end
end
hook.Add("OnEntityCreated", "nz.Enemies.OnEntityCreated", OnRagdollCreated)

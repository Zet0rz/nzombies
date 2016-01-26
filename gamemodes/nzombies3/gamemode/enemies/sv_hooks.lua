//


function nz.Enemies.Functions.OnEnemyKilled(enemy, attacker, dmginfo)
	//Prevent multiple "dyings" by making sure the zombie has not already been "killed"
	if enemy.MarkedForDeath then return end

	if attacker:IsPlayer() then
		--attacker:GivePoints(90)
		attacker:AddFrags(1)
	end
	
	//Run special on-killed function if it has any
	nz.Config.ValidEnemies[enemy:GetClass()].OnKilled(enemy, dmginfo:GetAttacker(), hitgroup)

	nz.Rounds.Data.KilledZombies = nz.Rounds.Data.KilledZombies + 1
	//nz.Rounds.Data.ZombiesSpawned = nz.Rounds.Data.ZombiesSpawned - 1

	//Chance a powerup spawning
	if nz.PowerUps.Functions.IsPowerupActive("insta") == false and enemy:IsValid() then //Don't spawn powerups during instakill
		if math.random(1, nz.Config.PowerUpChance) == 1 then // 1 in 100 chance - you can change this in config
			nz.PowerUps.Functions.SpawnPowerUp(enemy:GetPos())
		end
	end

	print("Killed Enemy: " .. nz.Rounds.Data.KilledZombies .. "/" .. nz.Rounds.Data.MaxZombies )
	//Prevent this function from running on this zombie again
	enemy.MarkedForDeath = true
end

function GM:EntityTakeDamage(zombie, dmginfo)
	if IsValid(zombie) and nz.Config.ValidEnemies[zombie:GetClass()] and nz.Config.ValidEnemies[zombie:GetClass()].Valid then
		local hitgroup = util.QuickTrace( dmginfo:GetDamagePosition( ), dmginfo:GetDamagePosition( ) ).HitGroup
		
		if nz.PowerUps.Functions.IsPowerupActive("insta") then
			dmginfo:SetDamage(zombie:Health())
			nz.Enemies.Functions.OnEnemyKilled(zombie, dmginfo:GetAttacker(), dmginfo)
		return end
		
		
		nz.Config.ValidEnemies[zombie:GetClass()].ScaleDMG(zombie, hitgroup, dmginfo)
		
		//Pack-a-Punch doubles damage
		if dmginfo:GetAttacker():GetActiveWeapon().pap then dmginfo:ScaleDamage(2) end
		
		if zombie:Health() > dmginfo:GetDamage() then
			if zombie.HasTakenDamageThisTick then return end
			nz.Config.ValidEnemies[zombie:GetClass()].OnHit(zombie, dmginfo:GetAttacker(), hitgroup)
			zombie.HasTakenDamageThisTick = true
			//Prevent multiple damages in one tick (FA:S 2 Bullet penetration makes them hit 1 zombie 2-3 times per bullet)
			timer.Simple(0, function() if IsValid(zombie) then zombie.HasTakenDamageThisTick = false end end)
		else
			nz.Enemies.Functions.OnEnemyKilled(zombie, dmginfo:GetAttacker(), dmginfo)
		end
	end
end

function nz.Enemies.Functions.OnEntityCreated( ent )
	if ( ent:GetClass() == "prop_ragdoll" ) then
		ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	end
end
hook.Add("OnEntityCreated", "nz.Enemies.OnEntityCreated", nz.Enemies.Functions.OnEntityCreated)

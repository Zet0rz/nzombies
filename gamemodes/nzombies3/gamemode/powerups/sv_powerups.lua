//

function nz.PowerUps.Functions.Nuke()
	//Kill them all
	for k,v in pairs(nz.Config.ValidEnemies) do
		for k2,enemy in pairs(ents.FindByClass(k)) do
			if enemy:IsValid() then
				local insta = DamageInfo()
				insta:SetDamage(enemy:Health())
				insta:SetAttacker(Entity(0))
				insta:SetDamageType(DMG_BLAST_SURFACE)
				//Delay so it doesn't "die" twice
				timer.Simple(0.1, function() if enemy:IsValid() then enemy:TakeDamageInfo( insta ) end end)
			end
		end	
	end
	
	//Give the players a set amount of points
	for k,v in pairs(player.GetAll()) do
		if v:IsPlayer() then
			v:GivePoints(400)
		end
	end
end

//Add the sound so we can stop it again
sound.Add( {
	name = "nz_firesale_jingle",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 75,
	pitch = { 100, 100 },
	sound = "nz/randombox/fire_sale.wav"
} )

function nz.PowerUps.Functions.FireSale()
	--print("Running")
	//Get all spawns
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
	
	hook.Add("Tick", "FireSaleActive", function()
		if !nz.PowerUps.Functions.IsPowerupActive("firesale") then
			for k,v in pairs(ents.FindByClass("random_box_spawns")) do
				if IsValid(v.FireSaleBox) then
					v.FireSaleBox:StopSound("nz_firesale_jingle")
					v.FireSaleBox:MarkForRemoval()
				end
			end
			hook.Remove("Tick", "FireSaleActive")
		end
	end)
end

function nz.PowerUps.Functions.CleanUp()
	//Clear all powerups
	for k,v in pairs(ents.FindByClass("drop_powerup")) do
		v:Remove()
	end
	
	//Turn off all modifiers
	table.Empty(nz.PowerUps.Data.ActivePowerUps)
	//Sync
	nz.PowerUps.Functions.SendSync()
end

function nz.PowerUps.Functions.Carpenter()
	//Kill them all
	for k,v in pairs(ents.FindByClass("breakable_entry")) do
		if v:IsValid() then
			for i=1, nz.Config.MaxPlanks do
				if i > #v.Planks then
					v:AddPlank()
				end
			end
		end	
	end
	
	//Give the players a set amount of points
	for k,v in pairs(player.GetAll()) do
		if v:IsPlayer() then
			v:GivePoints(200)
		end
	end
end
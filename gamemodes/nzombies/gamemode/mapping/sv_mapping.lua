--

function nzMapping:ZedSpawn(pos, link, ply)

	local ent = ents.Create("nz_spawn_zombie_normal")
	pos.z = pos.z - ent:OBBMaxs().z
	ent:SetPos( pos )
	ent:Spawn()
	-- For the link displayer
	if link != nil then
		ent:SetLink(tostring(link))
		ent.link = tostring(link)
	end

	if ply then
		undo.Create( "Zombie Spawnpoint" )
			undo.SetPlayer( ply )
			undo.AddEntity( ent )
		undo.Finish( "Effect (" .. tostring( model ) .. ")" )
	end
	return ent
end

function nzMapping:ZedSpecialSpawn(pos, link, ply)

	local ent = ents.Create("nz_spawn_zombie_special")
	pos.z = pos.z - ent:OBBMaxs().z
	ent:SetPos( pos )
	ent:Spawn()
	-- For the link displayer
	if link != nil then
		ent:SetLink(tostring(link))
		ent.link = tostring(link)
	end

	if ply then
		undo.Create( "Special Zombie Spawnpoint" )
			undo.SetPlayer( ply )
			undo.AddEntity( ent )
		undo.Finish( "Effect (" .. tostring( model ) .. ")" )
	end
	return ent
end

function nzMapping:PlayerSpawn(pos, ply)

	local ent = ents.Create("player_spawns")
	pos.z = pos.z - ent:OBBMaxs().z
	ent:SetPos( pos )
	ent:Spawn()

	if ply then
		undo.Create( "Player Spawnpoint" )
			undo.SetPlayer( ply )
			undo.AddEntity( ent )
		undo.Finish( "Effect (" .. tostring( model ) .. ")" )
	end
	return ent

end

function nzMapping:EasterEgg(pos, ang, model, ply)
	local egg = ents.Create( "easter_egg" )
	egg:SetModel( model )
	egg:SetPos( pos )
	egg:SetAngles( ang )
	egg:Spawn()

	local phys = egg:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end

	if ply then
		undo.Create( "Easter Egg" )
			undo.SetPlayer( ply )
			undo.AddEntity( egg )
		undo.Finish( "Effect (" .. tostring( model ) .. ")" )
	end
	return egg
end

function nzMapping:WallBuy(pos, gun, price, angle, oldent, ply, flipped)

	if IsValid(oldent) then oldent:Remove() end

	local ent = ents.Create("wall_buys")
	ent:SetAngles(angle)
	pos.z = pos.z - ent:OBBMaxs().z
	ent:SetPos( pos )
	ent:SetWeapon(gun, price)
	ent:Spawn()
	--ent:PhysicsInit( SOLID_VPHYSICS )

	local phys = ent:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end

	if flipped != nil then
		ent:SetFlipped(flipped)
	end

	if ply then
		undo.Create( "Wall Gun" )
			undo.SetPlayer( ply )
			undo.AddEntity( ent )
		undo.Finish( "Effect (" .. tostring( model ) .. ")" )
	end
	return ent

end

function nzMapping:PropBuy(pos, ang, model, flags, ply)
	local prop = ents.Create( "prop_buys" )
	prop:SetModel( model )
	prop:SetPos( pos )
	prop:SetAngles( ang )
	prop:Spawn()
	prop:PhysicsInit( SOLID_VPHYSICS )

	-- REMINDER APPY FLAGS
	if flags != nil then
		nzDoors:CreateLink( prop, flags )
	end

	local phys = prop:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end

	if ply then
		undo.Create( "Prop" )
			undo.SetPlayer( ply )
			undo.AddEntity( prop )
		undo.Finish( "Effect (" .. tostring( model ) .. ")" )
	end
	return prop
end

function nzMapping:Electric(pos, ang, model, ply)
	--THERE CAN ONLY BE ONE TRUE HERO
	local prevs = ents.FindByClass("power_box")
	if prevs[1] != nil then
		prevs[1]:Remove()
	end

	local ent = ents.Create( "power_box" )
	ent:SetPos( pos )
	ent:SetAngles( ang )
	ent:Spawn()
	ent:PhysicsInit( SOLID_VPHYSICS )

	local phys = ent:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end

	if ply then
		undo.Create( "Power Switch" )
			undo.SetPlayer( ply )
			undo.AddEntity( ent )
		undo.Finish( "Effect (" .. tostring( model ) .. ")" )
	end
	return ent
end

function nzMapping:BlockSpawn(pos, ang, model, ply)
	local block = ents.Create( "wall_block" )
	block:SetModel( model )
	block:SetPos( pos )
	block:SetAngles( ang )
	block:Spawn()
	block:PhysicsInit( SOLID_VPHYSICS )

	local phys = block:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end

	if ply then
		undo.Create( "Invisible Block" )
			undo.SetPlayer( ply )
			undo.AddEntity( block )
		undo.Finish( "Effect (" .. tostring( model ) .. ")" )
	end
	return block
end

function nzMapping:BoxSpawn(pos, ang, spawn, ply)
	local box = ents.Create( "random_box_spawns" )
	box:SetPos( pos )
	box:SetAngles( ang )
	box:Spawn()
	box:PhysicsInit( SOLID_VPHYSICS )
	box:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )
	box.PossibleSpawn = spawn

	if ply then
		undo.Create( "Random Box Spawnpoint" )
			undo.SetPlayer( ply )
			undo.AddEntity( box )
		undo.Finish( "Effect (" .. tostring( model ) .. ")" )
	end
	return box
end

function nzMapping:PerkMachine(pos, ang, id, ply)
	if id == "wunderfizz" then
		local perk = ents.Create("wunderfizz_machine")
		perk:SetPos(pos)
		perk:SetAngles(ang)
		perk:Spawn()
		perk:Activate()
		perk:PhysicsInit( SOLID_VPHYSICS )
		perk:TurnOff()

		local phys = perk:GetPhysicsObject()
		if phys:IsValid() then
			phys:EnableMotion(false)
		end

		if ply then
			undo.Create( "Der Wunderfizz" )
				undo.SetPlayer( ply )
				undo.AddEntity( perk )
			undo.Finish( "Effect (" .. tostring( model ) .. ")" )
		end
		return perk
	else
		local perkData = nzPerks:Get(id)

		local perk = ents.Create("perk_machine")
		perk:SetPerkID(id)
		perk:TurnOff()
		perk:SetPos(pos)
		perk:SetAngles(ang)
		perk:Spawn()
		perk:Activate()
		perk:PhysicsInit( SOLID_VPHYSICS )

		local phys = perk:GetPhysicsObject()
		if phys:IsValid() then
			phys:EnableMotion(false)
		end

		if ply then
			undo.Create( "Perk Machine" )
				undo.SetPlayer( ply )
				undo.AddEntity( perk )
			undo.Finish( "Effect (" .. tostring( model ) .. ")" )
		end
		return perk
	end
end

function nzMapping:BreakEntry(pos, ang, planks, jump, ply)
	local planks = planks
	if planks == nil then planks = true else planks = tobool(planks) end
	local jump = jump
	if jump == nil then jump = false else jump = tobool(jump) end

	local entry = ents.Create( "breakable_entry" )
	entry:SetPos( pos )
	entry:SetAngles( ang )
	entry:SetHasPlanks(planks)
	entry:SetTriggerJumps(jump)
	entry:Spawn()
	entry:PhysicsInit( SOLID_VPHYSICS )

	local phys = entry:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end

	if ply then
		undo.Create( "Barricade" )
			undo.SetPlayer( ply )
			undo.AddEntity( entry )
		undo.Finish( "Effect (" .. tostring( model ) .. ")" )
	end
	return entry
end

function nzMapping:SpawnEffect( pos, ang, model, ply )

	local e = ents.Create("nz_prop_effect")
	e:SetModel(model)
	e:SetPos(pos)
	e:SetAngles( ang )
	e:Spawn()
	e:Activate()
	if ( !IsValid( e ) ) then return end

	if ply then
		undo.Create( "Effect" )
			undo.SetPlayer( ply )
			undo.AddEntity( e )
		undo.Finish( "Effect (" .. tostring( model ) .. ")" )
	end
	return e

end

function nzMapping:SpawnEntity(pos, ang, ent, ply)
	local entity = ents.Create( ent )
	entity:SetPos( pos )
	entity:SetAngles( ang )
	entity:Spawn()
	entity:PhysicsInit( SOLID_VPHYSICS )

	table.insert(nzQMenu.Data.SpawnedEntities, entity)

	entity:CallOnRemove("nzSpawnedEntityClean", function(ent)
		table.RemoveByValue(nzQMenu.Data.SpawnedEntities, ent)
	end)

	if ply then
		undo.Create( "Entity" )
			undo.SetPlayer( ply )
			undo.AddEntity( entity )
		undo.Finish( "Effect (" .. tostring( model ) .. ")" )
	end
	return entity
end

function nzMapping:CreateInvisibleWall(vec1, vec2, ply)
	local wall = ents.Create( "invis_wall" )
	wall:SetPos( vec1 ) -- Later we might make the position the center
	--wall:SetAngles( ang )
	--wall:SetMinBound(vec1) -- Just the position for now
	wall:SetMaxBound(vec2)
	wall:Spawn()
	wall:PhysicsInitBox( Vector(0,0,0), vec2 )

	local phys = wall:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
	end

	if ply then
		undo.Create( "Invis Wall" )
			undo.SetPlayer( ply )
			undo.AddEntity( wall )
		undo.Finish( "Effect (" .. tostring( model ) .. ")" )
	end
	return wall
end

function nzMapping:CreateInvisibleDamageWall(vec1, vec2, ply, dmg, delay, radiation, poison, tesla)
	local wall = ents.Create( "invis_damage_wall" )
	wall:SetPos( vec1 )
	wall:SetMaxBound(vec2)
	wall:Spawn()
	wall:PhysicsInitBox( Vector(0,0,0), vec2 )
	wall:SetNotSolid(true)
	wall:SetTrigger(true)
	wall:SetDamage(dmg)
	wall:SetDelay(delay)

	wall:SetRadiation(radiation)
	wall:SetPoison(poison)
	wall:SetTesla(tesla)

	local phys = wall:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
	end

	if ply then
		undo.Create( "Damage Wall" )
			undo.SetPlayer( ply )
			undo.AddEntity( wall )
		undo.Finish( "Effect (" .. tostring( model ) .. ")" )
	end
	return wall
end

-- Physgun Hooks
local ghostentities = {
	["prop_buys"] = true,
	["wall_block"] = true,
	["breakable_entry"] = true,
	["invis_wall"] = true,
	--["wall_buys"] = true,
}
local function onPhysgunPickup( ply, ent )
	local class = ent:GetClass()
	if ghostentities[class] or ent:ShouldPhysgunNoCollide() then
		-- Ghost the entity so we can put them in walls.
		local phys = ent:GetPhysicsObject()
		phys:EnableCollisions(false)
		phys:Wake()
	end

end

local function onPhysgunDrop( ply, ent )
	local class = ent:GetClass()
	if ghostentities[class] or ent:ShouldPhysgunNoCollide() then
		-- Unghost the entity so we can put them in walls.
		local phys = ent:GetPhysicsObject()
		phys:EnableCollisions(true)
		phys:EnableMotion(false)
		phys:Sleep()
	end

end

hook.Add( "PhysgunPickup", "nz.OnPhysPick", onPhysgunPickup )
hook.Add( "PhysgunDrop", "nz.OnDrop", onPhysgunDrop )

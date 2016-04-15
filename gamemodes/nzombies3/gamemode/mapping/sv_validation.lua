function Mapping:CheckSpawns()

	--Check Player spawns
	if #ents.FindByClass("player_spawns") == 0 then
		return false
	end

	--Check Zombie Spawns
	if #ents.FindByClass("nz_spawn_zombie_*") == 0 then
		return false
	end

	return true
end

function Mapping:CheckEnoughPlayerSpawns()

	//Check Player spawns
	if #ents.FindByClass("player_spawns") < #player.GetAll() then
		return false
	end

	return true
end

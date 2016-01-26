//

function nz.Mapping.Functions.CheckSpawns()

	//Check Player spawns
	if #ents.FindByClass("player_spawns") == 0 then
		for k,v in pairs(player.GetAll()) do
			nz.Rounds.Functions.UnReady(v, "You have been set to un-ready since the map does not have enough player spawns placed.")
		end
		return false
	end
	
	//Check Zombie Spawns
	if #ents.FindByClass("zed_spawns") == 0 then
		for k,v in pairs(player.GetAll()) do
			nz.Rounds.Functions.UnReady(v, "You have been set to un-ready since the map does not have enough zombie spawns placed.")
		end
		return false
	end
	
	return true
end

function nz.Mapping.Functions.CheckEnoughPlayerSpawns()

	//Check Player spawns
	if #ents.FindByClass("player_spawns") < #player.GetAll() then
		for k,v in pairs(player.GetAll()) do
			nz.Rounds.Functions.UnReady(v, "You have been set to un-ready since the map does not have enough player spawns placed.")
		end
		return false
	end
	
	return true
end
function player.GetByName(name)
	name = string.lower(name)
	for _,v in ipairs(player.GetHumans()) do
		if string.find(string.lower(v:Nick()), name, 1, true) != nil then
			return v
		end
	end

	return nil
end

//http://snippets.luacode.org/snippets/Weighted_random_choice_104

local function weighted_total(choices)
	local total = 0
	for choice, weight in pairs(choices) do
		total = total + weight
	end
	return total
end
							
local function weighted_random_choice( choices )
	local threshold = math.random(0, weighted_total(choices))
	local last_choice
	for choice, weight in pairs(choices) do
		threshold = threshold - weight
		if threshold <= 0 then return choice end
		last_choice = choice
	end
	return last_choice
end

function nz.Misc.Functions.WeightedRandom(choices)
	return weighted_random_choice(choices)
end
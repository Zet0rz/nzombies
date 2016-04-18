-- http://snippets.luacode.org/snippets/Weighted_random_choice_104

-- Modified to allow special weight keys

local function weighted_total( choices, weightkey )
	local total = 0
	if weightkey then
		for choice, weight in pairs(choices) do
			total = total + weight[weightkey]
		end
	else
		for choice, weight in pairs(choices) do
			total = total + weight
		end
	end
	return total
end

local function weighted_random_choice( choices, weightkey )
	local threshold = math.random(0, weighted_total( choices, weightkey ))
	local last_choice
	if weightkey then
		for choice, weight in pairs(choices) do
			threshold = threshold - weight[weightkey]
			if threshold <= 0 then return choice end
			last_choice = choice
		end
	else
		for choice, weight in pairs(choices) do
			threshold = threshold - weight
			if threshold <= 0 then return choice end
			last_choice = choice
		end
	end
	return last_choice
end

function nzMisc.WeightedRandom( choices, weightkey )
	return weighted_random_choice( choices, weightkey )
end

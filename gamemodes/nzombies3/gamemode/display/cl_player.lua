local playerColors = {
	Color(239,154,154),
	Color(244,143,177),
	Color(159,168,218),
	Color(129,212,250),
	Color(128,203,196),
	Color(165,214,167),
	Color(230,238,156),
	Color(255,241,118),
	Color(255,224,130),
	Color(255,171,145),
	Color(161,136,127),
	Color(224,224,224),
	Color(144,164,174),
	nil
}

local blooddecals = {
	Material("bloodline_score1.png", "unlitgeneric smooth"),
	Material("bloodline_score2.png", "unlitgeneric smooth"),
	Material("bloodline_score3.png", "unlitgeneric smooth"),
	Material("bloodline_score4.png", "unlitgeneric smooth"),
	nil
}

--shuffle the colors on map start
local rand = math.random
local n = #playerColors

while n > 2 do

	local k = rand(n) -- 1 <= k <= n

	playerColors[n], playerColors[k] = playerColors[k], playerColors[n]
	n = n - 1
end

n = #blooddecals

while n > 2 do

	local k = rand(n) -- 1 <= k <= n

	blooddecals[n], blooddecals[k] = blooddecals[k], blooddecals[n]
	n = n - 1
end

function player.GetColorByIndex(index)
	return playerColors[((index - 1) % #playerColors) + 1]
end

function player.GetBloodByIndex(index)
	return blooddecals[((index - 1) % #blooddecals) + 1]
end

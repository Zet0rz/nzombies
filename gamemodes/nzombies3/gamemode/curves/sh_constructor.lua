//We only need this on the server
if SERVER then
	//Main Tables
	nz.Curves = {}
	nz.Curves.Functions = {}
	nz.Curves.Data = {}

	//Difficulty Curves
	nz.Curves.Data.SpawnRate = {}
	nz.Curves.Data.Health = {}
	nz.Curves.Data.Speed = {}

	//Generate Curve
	function nz.Curves.Functions.GenerateCurve()
		for i=1, nz.Config.MaxRounds do
			nz.Curves.Data.SpawnRate[i-1] = math.Round(nz.Config.BaseDifficultySpawnRateCurve*math.pow(i-1,nz.Config.DifficultySpawnRateCurve))
			nz.Curves.Data.Health[i-1] = math.Round(nz.Config.BaseDifficultyHealthCurve*math.pow(i-1,nz.Config.DifficultyHealthCurve))
			nz.Curves.Data.Speed[i-1] = math.Round(nz.Config.BaseDifficultySpeedCurve*math.pow(i-1,nz.Config.DifficultySpeedCurve))
		end
		//PrintTable(nz.Curves.Data)
	end
	
	function nz.Curves.Functions.GenerateHealthCurve(round)
		return math.Round(nz.Config.BaseDifficultyHealthCurve*math.pow(round,nz.Config.DifficultyHealthCurve))
	end
	
	function nz.Curves.Functions.GenerateMaxZombies(round)
		return math.Round(nz.Config.BaseDifficultySpawnRateCurve*math.pow(round,nz.Config.DifficultySpawnRateCurve))
	end

	function nz.Curves.Functions.GenerateSpeedTable(round)
		if !round then return {[50] = 100} end -- Default speed for any invalid round (Say, creative mode test zombies)
		local tbl = {}
		local range = 3 -- The range on either side of the tip (current round) of speeds in steps of "steps"
		local min = 50 -- Minimum speed (Round 1)
		local max = 300 -- Maximum speed
		local maxround = 25 -- The round at which the 300 speed has its tip
		local steps = ((max-min)/maxround) -- The different speed steps speed can exist in
		
		print("Generating round speeds with steps of "..steps.."...")
		for i = -range, range do
			local speed = (min - steps + steps*round) + (steps*i)
			if speed >= min and speed <= max then
				local chance = 100 - 10*math.abs(i)^2
				--print("Speed is "..speed..", with a chance of "..chance)
				tbl[speed] = chance
			elseif speed >= max then
				tbl[max] = 100
			end
		end
		return tbl
	end


	nz.Curves.Functions.GenerateCurve()

end
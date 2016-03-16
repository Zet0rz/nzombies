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


	nz.Curves.Functions.GenerateCurve()

end
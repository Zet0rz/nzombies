hook.Add("nz.Round.Prog", "nz.Special.Zombies", function()
	if nz.Rounds.Data.CurrentRound == 6 or nz.Rounds.Data.CurrentRound >= 18 then
		nz.Fog.Functions.Enable( true )
	elseif nz.Rounds.Data.CurrentRound >= 18 then
		nz.Fog.Functions.SetColor( Color(190, 60, 40) )
		nz.Fog.Functions.Enable( true )
	else
		nz.Fog.Functions.Enable( false )
	end
end)
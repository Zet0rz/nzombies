chatcommand.Add("/cheats", function(ply, text)
	if CLIENT then
		if !IsValid(g_nz_cheats) then
			g_nz_cheats = vgui.Create("NZCheatFrame")
		else
			g_nz_cheats:Remove()
		end
	end
end, false, "Opens the cheat panel.")

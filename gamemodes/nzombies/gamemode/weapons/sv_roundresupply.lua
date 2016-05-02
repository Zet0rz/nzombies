nz.Weps.RoundResupply = {}

function nz.Weps.AddAmmoToRoundResupply(ammo, count, max)
	nz.Weps.RoundResupply[ammo] = {count = count, max = max}
end

function nz.Weps.DoRoundResupply()
	for k,v in pairs(player.GetAllPlaying()) do
		for k2,v2 in pairs(nz.Weps.RoundResupply) do
			local give = math.Clamp(v2.max - v:GetAmmoCount(k2), 0, v2.count)
			v:GiveAmmo(give, k2, true)
		end
	end
end

-- Standard grenades
nz.Weps.AddAmmoToRoundResupply("nz_grenade", 2, 4)
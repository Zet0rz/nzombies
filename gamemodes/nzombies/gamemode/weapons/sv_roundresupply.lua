nzWeps.RoundResupply = {}

function nzWeps:AddAmmoToRoundResupply(ammo, count, max)
	nzWeps.RoundResupply[ammo] = {count = count, max = max}
end

function nzWeps:DoRoundResupply()
	for k,v in pairs(player.GetAllPlaying()) do
		for k2,v2 in pairs(nzWeps.RoundResupply) do
			local give = math.Clamp(v2.max - v:GetAmmoCount(k2), 0, v2.count)
			v:GiveAmmo(give, k2, true)
		end
	end
end

-- Standard grenades
nzWeps:AddAmmoToRoundResupply("nz_grenade", 2, 4)
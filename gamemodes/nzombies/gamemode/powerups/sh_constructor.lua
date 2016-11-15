-- Main Tables
nzPowerUps = nzPowerUps or AddNZModule("PowerUps")
nzPowerUps.Data = nzPowerUps.Data or {}

-- Tables storing the active powerups and their expiration time
nzPowerUps.ActivePowerUps = nzPowerUps.ActivePowerUps or {}
nzPowerUps.ActivePlayerPowerUps = nzPowerUps.ActivePlayerPowerUps or {}

AccessorFunc(nzPowerUps, "fPowerUpChance", "PowerUpChance", FORCE_NUMBER)


function nzPowerUps:ResetPowerUpChance()
	-- pseudo random so we start a bit lower than the actual chance
	self:SetPowerUpChance(GetConVar("nz_difficulty_powerup_chance"):GetFloat() / 10)
end

function nzPowerUps:IncreasePowerUpChance()
	-- function:
	-- 	f(0) = initialchance, f(n) = f(n-1) + initialchance

	-- % = chance of powerup spawning per zombie.
	-- for default 2% this would be 0.2% on reset
	-- after one kill it would be 0.04%
	-- after 10 kills 2.2%
	-- ...
	-- after 50 kills 10.2%
	-- ..
	-- after 100 kills 20.2%
	-- ...
	-- after 499 kills a powerup drop is guaranteed
	-- for default 2%: f(n) = n+1/5
	self:SetPowerUpChance(self:GetPowerUpChance() + (GetConVar("nz_difficulty_powerup_chance"):GetFloat() / 10))
end
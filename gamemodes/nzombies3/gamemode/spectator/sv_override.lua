//Get the meta Table
playerMeta = FindMetaTable( "Player" )

//Meta Functions
function playerMeta:IsSpec()
	return nz.Spectator.Functions.IsSpec(self)
end

function playerMeta:SetAsSpec()
	nz.Spectator.Functions.SetAsSpec(self) 
end

function playerMeta:IsPermSpec()
	return nz.Spectator.Functions.IsPermSpec(self)
end

function playerMeta:PermSpec()
	nz.Spectator.Functions.PermSpec(self)
end

function playerMeta:SetAsPlayer()
	nz.Spectator.Functions.SetAsPlayer(self)
end

//Gamemode Overrides

function GM:PlayerInitialSpawn( ply )
	nz.Spectator.Functions.InitialSpawn(ply)
end

function GM:PlayerDeath( victim, weapon, killer )
	nz.Spectator.Functions.OnDeath(victim)
end

function GM:PlayerDeathThink( ply )
	nz.Spectator.Functions.DeathThink(ply)
end



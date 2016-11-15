--pool network strings
util.AddNetworkString( ", nzRoundNumber" )
util.AddNetworkString( ", nzRoundState" )
util.AddNetworkString( ", nzRoundSpecial" )
util.AddNetworkString( "nzPlayerReadyState" )
util.AddNetworkString( "nzPlayerPlayingState" )

nzRound.Number = nzRound.Number or 0 -- Default for reloaded scenarios

function nzRound:GetZombiesKilled()
	return self.ZombiesKilled
end
function nzRound:SetZombiesKilled( num )
	self.ZombiesKilled = num
end

function nzRound:GetZombiesMax()
	return self.ZombiesMax
end
function nzRound:SetZombiesMax( num )
	self.ZombiesMax = num
end

function nzRound:GetZombiesToSpawn()
	return self.ZombiesToSpawn
end
function nzRound:SetZombiesToSpawn( num )
	self.ZombiesToSpawn = num
end
function nzRound:GetZombiesSpawned()
	return self.ZombiesMax - self.ZombiesToSpawn
end

function nzRound:GetZombieHealth()
	return self.ZombieHealth
end
function nzRound:SetZombieHealth( num )
	self.ZombieHealth = num
end

function nzRound:GetNormalSpawner()
	return self.hNormalSpawner
end

function nzRound:SetNormalSpawner(spawner)
	self.hNormalSpawner = spawner
end

function nzRound:GetSpecialSpawner()
	return self.hSpecialSpawner
end

function nzRound:SetSpecialSpawner(spawner)
	self.hSpecialSpawner = spawner
end

function nzRound:GetZombieSpeeds()
	return self.ZombieSpeeds
end
function nzRound:SetZombieSpeeds( tbl )
	self.ZombieSpeeds = tbl
end

function nzRound:SetGlobalZombieData( tbl )
	self:SetZombiesMax(tbl.maxzombies or 5)
	self:SetZombieHealth(tbl.health or 75)
	self:SetSpecial(tbl.special or false)
end

function nzRound:InState( state )
	return self:GetState() == state
end

function nzRound:IsSpecial()
	return self.SpecialRound or false
end

function nzRound:SetSpecial( bool )
	self.SpecialRound = bool or false
	self:SendSpecialRound( self.SpecialRound )
end

function nzRound:InProgress()
	return self:GetState() == ROUND_PREP or self:GetState() == ROUND_PROG
end

function nzRound:SetState( state )
	
	local oldstate = self.RoundState
	self.RoundState = state

	self:SendState( state )
	
	hook.Call("OnRoundChangeState", nzRound, state, oldstate)

end

function nzRound:GetState()

	return self.RoundState

end

function nzRound:SetNumber( number )
	self.Number = number

	self:SendNumber( number )

end

function nzRound:IncrementNumber()

	self:SetNumber( self:GetNumber() + 1 )

end

function nzRound:GetNumber()

	return self.Number

end

function nzRound:SetEndTime( time )

	SetGlobalFloat( "nzEndTime", time )

end

function nzRound:GetEndTime( time )

	GetGlobalFloat( "nzEndTime" )

end

function nzRound:GetNextSpawnTime()
	return self.NextSpawnTime or 0
end
function nzRound:SetNextSpawnTime( time )
	self.NextSpawnTime = time
end

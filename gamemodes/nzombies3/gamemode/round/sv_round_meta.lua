--pool network strings
util.AddNetworkString( "nzRoundNumber" )
util.AddNetworkString( "nzRoundState" )
util.AddNetworkString( "nzRoundSpecial" )
util.AddNetworkString( "nzPlayerReadyState" )
util.AddNetworkString( "nzPlayerPlayingState" )

function Round:GetZombiesKilled()
	return self.ZombiesKilled
end
function Round:SetZombiesKilled( num )
	self.ZombiesKilled = num
end

function Round:GetZombiesSpawned()
	return self.ZombiesSpawned
end
function Round:SetZombiesSpawned( num )
	self.ZombiesSpawned = num
end
function Round:IncrementZombiesSpawned()
	self:SetZombiesSpawned( self:GetZombiesSpawned() + 1 )
end

function Round:GetZombiesMax()
	return self.ZombiesMax
end
function Round:SetZombiesMax( num )
	self.ZombiesMax = num
end

function Round:GetZombieHealth()
	return self.ZombieHealth
end
function Round:SetZombieHealth( num )
	self.ZombieHealth = num
end

function Round:GetZombieData()
	if Round:IsSpecial() then
		return self.SpecialZombieData
	else
		return self.ZombieData
	end
end
function Round:SetZombieData( tbl )
	self.ZombieData = tbl
end
function Round:SetSpecialZombieData( tbl )
	self.SpecialZombieData = tbl
end

function Round:GetZombieSpeeds()
	return self.ZombieSpeeds
end
function Round:SetZombieSpeeds( tbl )
	self.ZombieSpeeds = tbl
end

function Round:SetGlobalZombieData( tbl )
	self:SetZombiesMax(tbl.maxzombies or 5)
	self:SetZombieHealth(tbl.health or 75)
	self:SetSpecial(tbl.special or false)
end

function Round:InState( state )
	return self:GetState() == state
end

function Round:IsSpecial()
	return self.SpecialRound or false
end

function Round:SetSpecial( bool )
	self.SpecialRound = bool or false
	self:SendSpecialRound( self.SpecialRound )
end

function Round:InProgress()
	return self:GetState() == ROUND_PREP or self:GetState() == ROUND_PROG
end

function Round:SetState( state )

	self.RoundState = state

	self:SendState( state )

end

function Round:GetState()

	return self.RoundState

end

function Round:SetNumber( number )
	self.Number = number

	self:SendNumber( number )

end

function Round:IncrementNumber()

	self:SetNumber( self:GetNumber() + 1 )

end

function Round:GetNumber()

	return self.Number

end

function Round:SetEndTime( time )

	SetGlobalFloat( "nzEndTime", time )

end

function Round:GetEndTime( time )

	GetGlobalFloat( "nzEndTime" )

end

function Round:GetNextSpawnTime()
	return self.NextSpawnTime or 0
end
function Round:SetNextSpawnTime( time )
	self.NextSpawnTime = time
end
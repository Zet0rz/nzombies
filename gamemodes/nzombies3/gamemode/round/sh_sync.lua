if SERVER then
	util.AddNetworkString( "nzRoundNumber" )
	util.AddNetworkString( "nzRoundState" )
	util.AddNetworkString( "nzRoundSpecial" )
	util.AddNetworkString( "nzPlayerReadyState" )
	util.AddNetworkString( "nzPlayerPlayingState" )

	function Round:SendNumber( number, ply )

		net.Start( "nzRoundNumber" )
			net.WriteUInt( number or 0, 16 )
		return ply and net.Send( ply ) or net.Broadcast()

	end

	function Round:SendState( state, ply )

		net.Start( "nzRoundState" )
			net.WriteUInt( state or ROUND_WAITING, 3 )
		return ply and net.Send( ply ) or net.Broadcast()

	end

	function Round:SendSpecialRound( bool, ply )

		net.Start( "nzRoundSpecial" )
			net.WriteBool( bool or false )
		return ply and net.Send( ply ) or net.Broadcast()

	end

	function Round:SendReadyState( ply, state, recieverPly )

		net.Start( "nzPlayerReadyState" )
			net.WriteEntity( ply )
			net.WriteBool( state )
		return recieverPly and net.Send( recieverPly ) or net.Broadcast()

	end

	function Round:SendPlayingState( ply, state, recieverPly )

		net.Start( "nzPlayerPlayingState" )
			net.WriteEntity( ply )
			net.WriteBool( state )
		return recieverPly and net.Send( recieverPly ) or net.Broadcast()

	end

	function Round:SendSync(ply)
		self:SendNumber( self:GetNumber(), ply )
		self:SendSpecialRound( self:IsSpecial(), ply)
		self:SendState(self:GetState(), ply)

		for _, v in pairs(player.GetAll()) do
			self:SendReadyState(v, v:GetReady(), ply)
			self:SendPlayingState(v, v:GetPlaying(), ply)
		end

		self:SetEndTime( self:GetEndTime() )

	end

	FullSyncModules["Round"] = function(ply)
		Round:SendSync(ply)
	end
end

if CLIENT then
	local function receiveRoundState()
		local old = Round:GetState()
		new = net.ReadUInt( 3 )

		Round:SetState( new )

		if old != new then
			Round:StateChange( old, new )
		end
	end
	net.Receive( "nzRoundState", receiveRoundState )


	local function receiveRoundNumber()
		Round:SetNumber( net.ReadUInt( 16 ) )
	end
	net.Receive( "nzRoundNumber", receiveRoundNumber)

	local function receiveSpecialRound()
		Round:SetSpecial( net.ReadBool() )
	end
	net.Receive( "nzRoundSpecial", receiveSpecialRound )


	local function receivePlayerReadyState()
		local ply = net.ReadEntity()
		if IsValid(ply) then
			ply:SetReady( net.ReadBool() )
		end
	end
	net.Receive( "nzPlayerReadyState", receivePlayerReadyState )

	local function receivePlayerPlayingState()
		local ply = net.ReadEntity()
		if IsValid(ply) then
			ply:SetPlaying( net.ReadBool() )
		end
	end
	net.Receive( "nzPlayerPlayingState", receivePlayerPlayingState )
end

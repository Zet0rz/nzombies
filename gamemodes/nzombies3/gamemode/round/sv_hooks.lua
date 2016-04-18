function nzRound:OnPlayerReady( ply )

	self:SendReadyState( ply, true )

	--Start Round if we have enough players
	if self:InState( ROUND_WAITING ) and #player.GetAllReady() > #player.GetAllNonSpecs() / 3 then
		self:Init()
	end

end

function nzRound:OnPlayerUnReady( ply )

	self:SendReadyState( ply, false )

end

function nzRound:OnPlayerDropIn( ply )

	self:SendPlayingState( ply, true )
	self:SendReadyState( ply, true )

end

function nzRound:OnPlayerDropOut( ply )

	self:SendPlayingState( ply, false )
	self:SendReadyState( ply, false )

end

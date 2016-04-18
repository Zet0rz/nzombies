function nzRound:SetNextSpecialRound( num )
	self.NextSpecialRound = num
end

function nzRound:GetNextSpecialRound()
	return self.NextSpecialRound
end

function nzRound:MarkedForSpecial( num )
	return (self.NextSpecialRound == num or (nzConfig.RoundData[ num ] and nzConfig.RoundData[ num ].special)) or false
end

util.AddNetworkString("nz_hellhoundround")
function nzRound:CallHellhoundRound()
	net.Start("nz_hellhoundround")
		net.WriteBool(true)
	net.Broadcast()
end
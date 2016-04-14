function Round:SetNextSpecialRound( num )
	self.NextSpecialRound = num
end

function Round:GetNextSpecialRound()
	return self.NextSpecialRound
end

function Round:MarkedForSpecial( num )
	return (self.NextSpecialRound == num or (nz.Config.EnemyTypes[ num ] and nz.Config.EnemyTypes[ num ].special)) or false
end

util.AddNetworkString("nz_hellhoundround")
function Round:CallHellhoundRound()
	net.Start("nz_hellhoundround")
		net.WriteBool(true)
	net.Broadcast()
end
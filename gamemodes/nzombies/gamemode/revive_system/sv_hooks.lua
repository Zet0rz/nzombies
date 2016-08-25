local defaultdata = {
	DownTime = true,
	ReviveTime = true,
	RevivePlayer = true,
}

function Revive:PlayerDowned( ply )
	local attdata = {}
	-- Attach whatever other data was attached to the table, other than the default ones
	for k,v in pairs(Revive.Players[ply:EntIndex()]) do
		if !defaultdata[k] then attdata[k] = v end
	end
	self:SendPlayerDowned( ply, nil, attdata )
	hook.Call( "nzPlayerDowned", nil, ply)
end

function Revive:PlayerRevived( ply )
	self:SendPlayerRevived( ply )
	hook.Call( "nzPlayerRevived", nil, ply)
end

function Revive:PlayerBeingRevived( ply, revivor )
	self:SendPlayerBeingRevived( ply, revivor )
end

function Revive:PlayerNoLongerBeingRevived( ply )
	self:SendPlayerBeingRevived( ply ) -- No second argument means no revivor
end


function Revive:PlayerKilled( ply )
	self:SendPlayerKilled( ply )
end

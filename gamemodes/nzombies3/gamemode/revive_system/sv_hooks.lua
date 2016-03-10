function Revive:PlayerDowned( ply )
	self:SendPlayerDowned( ply )
end

function Revive:PlayerRevived( ply )
	self:SendPlayerRevived( ply )
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
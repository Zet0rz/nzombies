local plyMeta = FindMetaTable("Player")
FullSyncModules = {}

function plyMeta:SendFullSync()
	-- Modules add their own fullsync functions into this table
	for k,v in pairs(FullSyncModules) do
		v(self)
	end
end

include( "shared.lua" )
include( "loader.lua" )

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "loader.lua" )
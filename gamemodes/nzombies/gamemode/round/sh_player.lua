local plyMeta = FindMetaTable( "Player" )

AccessorFunc( plyMeta, "bReady", "Ready", FORCE_BOOL )
function plyMeta:IsReady() return self:GetReady() end

AccessorFunc( plyMeta, "bPlaying", "Playing", FORCE_BOOL )
function plyMeta:IsPlaying() return self:GetPlaying() end

function plyMeta:IsSpectating() return self:Team() == TEAM_SPECTATOR end

function plyMeta:IsInCreative() return player_manager.GetPlayerClass( self ) == "player_create" end

local player = player

--player.utils
function player.GetAllReady()
	local result = {}
	for _, ply in pairs( player.GetAll() ) do
		if ply:IsReady() then
			table.insert( result, ply )
		end
	end

	return result
end

function player.GetAllPlaying()
	local result = {}
	for _, ply in pairs( player.GetAll() ) do
		if ply:IsPlaying() then
			table.insert( result, ply )
		end
	end

	return result
end

function player.GetAllPlayingAndAlive()
	local result = {}
	for _, ply in pairs( player.GetAllPlaying() ) do
		if ply:Alive() and (ply:GetNotDowned() or ply.HasWhosWho or ply.DownedWithSoloRevive) then -- Who's Who will respawn the player, don't end yet
			table.insert( result, ply )
		end
	end

	return result
end

function player.GetAllNonSpecs()
	local result = {}
	for _, ply in pairs( player.GetAll() ) do
		if ply:Team() != TEAM_SPECTATOR then
			table.insert( result, ply )
		end
	end

	return result
end

function player.GetAllTargetable()
	local result = {}
	for _, ply in pairs(player.GetAll()) do
		if ply:GetTargetPriority() > 0 then
			table.insert( result, ply )
		end
	end
	
	return result
end
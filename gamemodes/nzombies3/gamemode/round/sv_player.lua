local plyMeta = FindMetaTable( "Player" )

function plyMeta:ReadyUp()

	if !navmesh.IsLoaded() then
		PrintMessage( HUD_PRINTTALK, "Can't ready you up, because the map has not Navmesh loaded. Use the settings menu to generate a rough Navmesh or use tools in sandbox to make a proper one.")
		return false
	end

	if Mapping:CheckSpawns() == false then
		PrintMessage( HUD_PRINTTALK, "Can't ready you up, because no Zombie/Player spawns have been set.")
		return false
	end

	--Check if we have enough player spawns
	if Mapping:CheckEnoughPlayerSpawns() == false then
		PrintMessage( HUD_PRINTTALK, "Can't ready you up, because not enough player spawns have been set. We need " .. #player.GetAll() .. " but only have " .. #ents.FindByClass("player_spawns") .. "." )
		return false
	end

	if Round:InState( ROUND_WAITING ) or Round:InState( ROUND_INIT ) then
		if !self:IsReady() then
			PrintMessage( HUD_PRINTTALK, self:Nick().." is ready!" )
			self:SetReady( true )
			self:SetTeam(TEAM_PLAYERS)
			hook.Call( "OnPlayerReady", Round, self )
		else
			self:PrintMessage( HUD_PRINTTALK, "You are already ready!" )
		end
	elseif Round:InProgress() then
		if self:IsPlaying() then
			self:PrintMessage( HUD_PRINTTALK, "You are already playing!" )
		else
			self:PrintMessage( HUD_PRINTTALK, "Round in progress you will be dropped into next round if possible." )
			self:DropIn()
		end
	end

	return true

end

function plyMeta:UnReady()
	if Round:InState( ROUND_WAITING ) then
		if self:IsReady() then
			PrintMessage( HUD_PRINTTALK, self:Nick() .. " is no longer ready!" )
			self:SetReady( false )
			hook.Call( "OnPlayerUnReady", Round, self )
		end
	end
	if Round:InProgress() then
		self:DropOut()
	end
end

function plyMeta:DropIn()
	if nz.Config.AllowDropins == true and !self:IsPlaying() then
		PrintMessage( HUD_PRINTTALK, self:Nick().." will be dropping in next round!" )
		self:SetPlaying( true )
		self:SetTeam( TEAM_PLAYERS )
		hook.Call( "OnPlayerDropIn", Round, self )
	else
		self:PrintMessage( HUD_PRINTTALK, "You are already in queue or dropins are not allowed on this Server." )
	end
end

function plyMeta:DropOut()
	if self:IsPlaying() then
		PrintMessage( HUD_PRINTTALK, self:Nick().." has dropped out of the game!" )
		self:SetReady( false )
		self:SetPlaying( false )
		self:RevivePlayer()
		self:KillSilent()
		hook.Call( "OnPlayerDropOut", Round, self )
	end
end

function plyMeta:ReSpawn()

	--Setup a player
	player_manager.SetPlayerClass( self, "player_ingame" )
	if !self:Alive() then
		self:Spawn()
	end

end

function plyMeta:GiveCreativeMode()

	player_manager.SetPlayerClass( self, "player_create" )
	if !self:Alive() then
		self:Spawn()
	end

end

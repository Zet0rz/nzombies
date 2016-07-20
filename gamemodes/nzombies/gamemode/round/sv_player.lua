local plyMeta = FindMetaTable( "Player" )

function plyMeta:ReadyUp()

	if !navmesh.IsLoaded() then
		PrintMessage( HUD_PRINTTALK, "Can't ready you up, because the map has not Navmesh loaded. Use the settings menu to generate a rough Navmesh or use tools in sandbox to make a proper one.")
		return false
	end

	if nzMapping:CheckSpawns() == false then
		PrintMessage( HUD_PRINTTALK, "Can't ready you up, because no Zombie/Player spawns have been set.")
		return false
	end

	--Check if we have enough player spawns
	if nzMapping:CheckEnoughPlayerSpawns() == false then
		PrintMessage( HUD_PRINTTALK, "Can't ready you up, because not enough player spawns have been set. We need " .. #player.GetAll() .. " but only have " .. #ents.FindByClass("player_spawns") .. "." )
		return false
	end

	if nzRound:InState( ROUND_WAITING ) or nzRound:InState( ROUND_INIT ) then
		if !self:IsReady() then
			PrintMessage( HUD_PRINTTALK, self:Nick() .. " is ready!" )
			self:SetReady( true )
			self:SetTeam(TEAM_PLAYERS)
			hook.Call( "OnPlayerReady", nzRound, self )
		else
			self:PrintMessage( HUD_PRINTTALK, "You are already ready!" )
		end
	elseif nzRound:InProgress() then
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
	if nzRound:InState( ROUND_WAITING ) then
		if self:IsReady() then
			PrintMessage( HUD_PRINTTALK, self:Nick() .. " is no longer ready!" )
			self:SetReady( false )
			hook.Call( "OnPlayerUnReady", nzRound, self )
		end
	end
	if nzRound:InProgress() then
		self:DropOut()
	end
end

function plyMeta:DropIn()
	if GetConVar("nz_round_dropins_allow"):GetBool() and !self:IsPlaying() then
		self:SetReady( true )
		self:SetPlaying( true )
		self:SetTeam( TEAM_PLAYERS )
		self:RevivePlayer()
		hook.Call( "OnPlayerDropIn", nzRound, self )
		if nzRound:GetNumber() == 1 and nzRound:InState(ROUND_PREP) then
			PrintMessage( HUD_PRINTTALK, self:Nick() .. " is dropping in!" )
			self:ReSpawn()
		else
			PrintMessage( HUD_PRINTTALK, self:Nick() .. " will be dropping in next round!" )
		end
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
		self:SetTargetPriority(TARGET_PRIORITY_NONE)
		hook.Call( "OnPlayerDropOut", nzRound, self )
	end
end

function plyMeta:ReSpawn()

	--Setup a player
	player_manager.SetPlayerClass( self, "player_ingame" )
	if !self:Alive() then
		self:Spawn()
		self:SetTeam( TEAM_PLAYERS )
	end

end

function plyMeta:GiveCreativeMode()

	player_manager.SetPlayerClass( self, "player_create" )
	if !self:Alive() then
		self:Spawn()
	end

end

function plyMeta:RemoveCreativeMode()

	player_manager.SetPlayerClass( self, "player_ingame" ) -- Defaults to ingame
	self:SetSpectator()

end

function plyMeta:ToggleCreativeMode()
	if self:IsInCreative() then
		self:RemoveCreativeMode()
		
		if nzRound:InState(ROUND_CREATE) then
			local creative = false
			for k,v in pairs(player.GetAll()) do
				if v:IsInCreative() then
					creative = true
					break
				end
			end
			
			-- If there are no other players left in creative, return to survival
			if !creative then
				nzRound:Create(false)
			end
		end
	else
		if !nzRound:InState(ROUND_CREATE) then
			nzRound:Create(true)
		end
		if nzRound:InState(ROUND_CREATE) then -- Only if we already are or we successfully switched to it
			self:GiveCreativeMode()
		else
			self:ChatPrint("Can't go in Creative right now.")
		end
	end
end
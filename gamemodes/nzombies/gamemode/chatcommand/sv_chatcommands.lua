-- Chat Commands

chatcommand.Add("/help", function(ply, text)
	ply:PrintMessage( HUD_PRINTTALK, "-----" )
	ply:PrintMessage( HUD_PRINTTALK, "NZ Available commands:" )
	ply:PrintMessage( HUD_PRINTTALK, "Arguments in [] are optional." )
	for _, cmd in pairs(chatcommand.commands) do
		local cmdText = cmd[1]
		if cmd[4] then
			cmdText = cmdText .. " " .. cmd[4]
		end
		if cmd[3]  or (!cmd[3] and ply:IsSuperAdmin()) then
			ply:PrintMessage( HUD_PRINTTALK, cmdText )
		end
	end
	ply:PrintMessage( HUD_PRINTTALK, "-----" )
	ply:PrintMessage( HUD_PRINTTALK, "" )
end, true, "   Print this list.")

chatcommand.Add("/ready", function(ply, text)
	ply:ReadyUp()
end, true, "   Mark yourself as ready.")

chatcommand.Add("/unready", function(ply, text)
	ply:UnReady()
end, true, "   Mark yourself as unready.")

chatcommand.Add("/dropin", function(ply, text)
	ply:DropIn()
end, true, "   Drop into the next round.")

chatcommand.Add("/dropout", function(ply, text)
	ply:DropOut()
end, true, "   Drop out of the current round.")

chatcommand.Add("/create", function(ply, text)
	nzRound:Create()
end, false, "   Respawn in creative mode.")

chatcommand.Add("/generate", function(ply, text)
	if navmesh.IsLoaded() then
		ply:PrintMessage( HUD_PRINTTALK, "NZ Navmesh already exists, couldn't generate." )
	else
		ply:PrintMessage( HUD_PRINTTALK, "NZ Starting Navmesh Generation, this may take a while." )
		navmesh.BeginGeneration()
		--force generate
		if !navmesh.IsGenerating() then
			ply:PrintMessage( HUD_PRINTTALK, "NZ No walkable seeds found, forcing generation..." )
			local sPoint = GAMEMODE.SpawnPoints[ math.random( #GAMEMODE.SpawnPoints ) ]
			local tr = util.TraceLine( {
				start = sPoint:GetPos(),
				endpos = sPoint:GetPos() - Vector( 0, 0, 100),
				filter = sPoint
			} )

			local ent = ents.Create("info_player_start")
			ent:SetPos( tr.HitPos )
			ent:Spawn()
			navmesh.BeginGeneration()
		end

		if !navmesh.IsGenerating() then
			--Will not happen but jsut in case
			ply:PrintMessage( HUD_PRINTTALK, "NZ Navmesh Generation failed! Please try this command again or generate the navmesh manually." )
		end
	end
end, false, "   Generate a new naviagtion mesh.")

util.AddNetworkString("nz_SaveConfig")
chatcommand.Add("/save", function(ply, text)
	if nzRound:InState( ROUND_CREATE ) then
		-- nzMapping:SaveConfig()
		net.Start("nz_SaveConfig")
		net.Send(ply)
	else
		ply:PrintMessage( HUD_PRINTTALK, "NZ You can't save outside of create mode." )
	end
end, false, "   Save your cahnges to a config.")

chatcommand.Add("/load", function(ply, text)
	if nzRound:InState( ROUND_CREATE) or nzRound:InState( ROUND_WAITING ) then
		nz.Interfaces.Functions.SendInterface(ply, "ConfigLoader", {configs = file.Find( "nz/nz_*", "DATA" ), workshopconfigs = file.Find( "nz/nz_*", "LUA" ), officialconfigs = file.Find("gamemodes/nzombies/officialconfigs/*", "GAME")})
	else
		ply:PrintMessage( HUD_PRINTTALK, "NZ You can't load while playing!" )
	end
end, false, "   Open the map config load dialog.")

chatcommand.Add("/clean", function(ply, text)
	if nzRound:InState( ROUND_CREATE) or nzRound:InState( ROUND_WAITING ) then
		nzMapping:ClearConfig()
	else
		ply:PrintMessage( HUD_PRINTTALK, "NZ You can't clean while playing!" )
	end
end)

-- Tests

chatcommand.Add("/spectate", function(ply, text)
	if !nzRound:InProgress() or nzRound:InState( ROUND_INIT ) then
		ply:PrintMessage( HUD_PRINTTALK, "No round in progress, couldnt set you to spectator!" )
	elseif ply:IsReady() then
		ply:UnReady()
		ply:SetSpectator()
	else
		ply:SetSpectator()
	end
end, true)

chatcommand.Add("/soundcheck", function(ply, text)
	if ply:IsSuperAdmin() then
		nz.Notifications.Functions.PlaySound("nz/powerups/double_points.mp3", 1)
		nz.Notifications.Functions.PlaySound("nz/powerups/insta_kill.mp3", 2)
		nz.Notifications.Functions.PlaySound("nz/powerups/max_ammo.mp3", 2)
		nz.Notifications.Functions.PlaySound("nz/powerups/nuke.mp3", 2)

		nz.Notifications.Functions.PlaySound("nz/round/round_start.mp3", 14)
		nz.Notifications.Functions.PlaySound("nz/round/round_end.mp3", 9)
		nz.Notifications.Functions.PlaySound("nz/round/game_over_4.mp3", 21)
	end
end, true)

--cheats
chatcommand.Add("/revive", function(ply, text)
	local plyToRev = player.GetByName(text[1]) or ply
	if IsValid(plyToRev) and !ply:GetNotDowned() then
		plyToRev:RevivePlayer()
	else
		ply:ChatPrint("Player could not have been revived, are you sure he is downed?")
	end
end, false, "[playerName]   Revive yourself or another player.")

chatcommand.Add("/givepoints", function(ply, text)
	local plyToGiv = player.GetByName(text[1])
	local points

	if !plyToGiv then
		points = tonumber(text[1])
		plyToGiv = ply
	else
		points = tonumber(text[2])
	end

	if IsValid(plyToGiv) and plyToGiv:Alive() and (plyToGiv:IsPlaying() or nzRound:InState(ROUND_CREATE)) then
		if points then
			plyToGiv:GivePoints(points)
		else
			ply:ChatPrint("No valid number provided.")
		end
	else
		ply:ChatPrint("The player you have selected is either not valid or not alive.")
	end
end, false, "[playerName] pointAmount   Give points to yourself or another player.")

chatcommand.Add("/giveweapon", function(ply, text)
	local plyToGiv = player.GetByName(text[1])

	local wep

	if !plyToGiv then
		wep = weapons.Get(text[1])
		plyToGiv = ply
	else
		wep = weapons.Get(text[2])
	end
	if IsValid(plyToGiv) and plyToGiv:Alive() and (plyToGiv:IsPlaying() or nzRound:InState(ROUND_CREATE)) then
		if wep then
			plyToGiv:Give(wep.ClassName)
		else
			ply:ChatPrint("No valid weapon provided.")
		end
	else
		ply:ChatPrint("The player you have selected is either not valid or not alive.")
	end
end, false, "[playerName] weaponName   Give a weapon to yourself or another player.")

chatcommand.Add("/giveperk", function(ply, text)
	local plyToGiv = player.GetByName(text[1])

	local perk

	if !plyToGiv then
		perk = text[1]
		plyToGiv = ply
	else
		perk = text[2]
	end
	if IsValid(plyToGiv) and plyToGiv:Alive() and (plyToGiv:IsPlaying() or nzRound:InState(ROUND_CREATE)) then
		if nz.Perks.Functions.Get(perk) then
			plyToGiv:GivePerk(perk)
		else
			ply:ChatPrint("No valid perk provided.")
		end
	else
		ply:ChatPrint("They player you have selected is either not valid or not alive.")
	end
end, false, "[playerName] perkID   Give a perk to yourself or another player.")

chatcommand.Add("/targetpriority", function(ply, text)
	local plyToGiv
	local strstart, strend = string.find(text[1], "entity(", 1, true)
	if strstart then
		local _, strstop = string.find(text[1], ")", strend, true)
		local ent = string.sub(text[1], strend + 1, strstop - 1)
		if ent and IsValid(Entity(ent)) then
			plyToGiv = Entity(ent)
		end
	else
		plyToGiv = player.GetByName(text[1])
	end

	local priority

	if !plyToGiv then
		priority = tonumber(text[1])
		plyToGiv = ply
	else
		priority = tonumber(text[2])
	end
	if IsValid(plyToGiv) and (!plyToGiv:IsPlayer() or (plyToGiv:Alive() and (plyToGiv:IsPlaying() or nzRound:InState(ROUND_CREATE)))) then
		if priority then
			plyToGiv:SetTargetPriority(priority)
		else
			ply:ChatPrint("No valid priority provided.")
		end
	else
		ply:ChatPrint("They player you have selected is either not valid or not alive.")
	end
end)

chatcommand.Add("/activateelec", function(ply, text)
	nzElec:Activate()
end)

chatcommand.Add("/navflush", function(ply, text)
	nz.Nav.Functions.FlushAllNavModifications()
	PrintMessage(HUD_PRINTTALK, "Navlocks and Navgroups successfully flushed. Remember to redo them for best playing experience.")
end)

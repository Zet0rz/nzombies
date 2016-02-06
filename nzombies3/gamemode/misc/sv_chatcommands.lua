//Chat Commands

//Setup
nz.Misc.Data.ChatCommands = {}

//Functions
function nz.Misc.Functions.NewChatCommand(text, func)
	table.insert(nz.Misc.Data.ChatCommands, {text, func})
end

//Hooks
hook.Add( "PlayerSay", "chatCommand", function( ply, text, public )
	local text = string.lower(text)
	for k,v in pairs(nz.Misc.Data.ChatCommands) do
		if (string.sub(text, 1, string.len(v[1])) == v[1]) then
			v[2](ply, text)
			return false
		end
	end
end )

//Quick Function
NewChatCommand = nz.Misc.Functions.NewChatCommand

// Actual Chat Commands

NewChatCommand("/ready", function(ply, text)
	nz.Rounds.Functions.ReadyUp(ply)
end)

NewChatCommand("/unready", function(ply, text)
	nz.Rounds.Functions.UnReady(ply)
end)

NewChatCommand("/dropin", function(ply, text)
	nz.Rounds.Functions.DropIn(ply)
end)

NewChatCommand("/dropout", function(ply, text)
	nz.Rounds.Functions.DropOut(ply)
end)

NewChatCommand("/create", function(ply, text)
	if ply:IsSuperAdmin() then
		nz.Rounds.Functions.CreateMode()
	end
end)

NewChatCommand("/generate", function(ply, text)
	if ply:IsSuperAdmin() then
		if navmesh.IsLoaded() then
			ply:PrintMessage( HUD_PRINTTALK, "[NZ] Navmesh already exists, couldn't generate." )
		else
			ply:PrintMessage( HUD_PRINTTALK, "[NZ] Starting Navmesh Generation, this may take a while." )
			navmesh.BeginGeneration()
			--force generate
			if !navmesh.IsGenerating() then
				ply:PrintMessage( HUD_PRINTTALK, "[NZ] No walkable seeds found, forcing generation..." )
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
				ply:PrintMessage( HUD_PRINTTALK, "[NZ] Navmesh Generation failed! Please try this command again or generate the navmesh manually." )
			end
		end
	end
end)

NewChatCommand("/save", function(ply, text)
	if ply:IsSuperAdmin() then
		if nz.Rounds.Data.CurrentState == ROUND_CREATE then
			nz.Mapping.Functions.SaveConfig()
		else
			ply:PrintMessage( HUD_PRINTTALK, "[NZ] You can't save outside of create mode." )
		end
	end
end)

--decrepit
NewChatCommand("/forcegenerate", function(ply, text)
	if ply:IsSuperAdmin() then
		local ent = ents.Create("info_player_start")
		ent:SetPos(ply:GetPos())
		ent:Spawn()
		navmesh.BeginGeneration( )
	end
end)

NewChatCommand("/load", function(ply, text)
	if ply:IsSuperAdmin() then
		if nz.Rounds.Data.CurrentState == ROUND_CREATE or nz.Rounds.Data.CurrentState == ROUND_INIT then
			nz.Interfaces.Functions.SendInterface(ply, "ConfigLoader", {configs = file.Find( "nz/nz_"..game.GetMap( ).."*", "DATA" )})
		else
			ply:PrintMessage( HUD_PRINTTALK, "[NZ] You can't load while playing!" )
		end
	end
end)

//Tests

NewChatCommand("/spec", function(ply, text)
	ply:PermSpec()
end)

NewChatCommand("/soundcheck", function(ply, text)
	if ply:IsSuperAdmin() then
		nz.Notifications.Functions.PlaySound("nz/powerups/double_points.mp3", 1)
		nz.Notifications.Functions.PlaySound("nz/powerups/insta_kill.mp3", 2)
		nz.Notifications.Functions.PlaySound("nz/powerups/max_ammo.mp3", 2)
		nz.Notifications.Functions.PlaySound("nz/powerups/nuke.mp3", 2)

		nz.Notifications.Functions.PlaySound("nz/round/round_start.mp3", 14)
		nz.Notifications.Functions.PlaySound("nz/round/round_end.mp3", 9)
		nz.Notifications.Functions.PlaySound("nz/round/game_over_4.mp3", 21)
	end
end)

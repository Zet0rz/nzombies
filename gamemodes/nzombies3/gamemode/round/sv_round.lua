function GM:InitPostEntity()

	Round:Waiting()

end

function Round:Waiting()

	self:SetState( ROUND_WAITING )
	hook.Call( "OnRoundWating", Round )

end

function Round:Init()

	timer.Simple( 5, function() self:SetupGame() self:Prepare() end )
	self:SetState( ROUND_INIT )
	self:SetEndTime( CurTime() + 5 )
	PrintMessage( HUD_PRINTTALK, "5 seconds till start time." )
	hook.Call( "OnRoundInit", Round )

end

function Round:Prepare()

	-- Set special for the upcoming round during prep, that way clients have time to fade the fog in
	self:SetSpecial( self:MarkedForSpecial( self:GetNumber() + 1 ) )
	self:SetState( ROUND_PREP )
	self:IncrementNumber()

	self:SetZombieHealth( nz.Curves.Functions.GenerateHealthCurve(self:GetNumber()) )
	self:SetZombiesMax( nz.Curves.Functions.GenerateMaxZombies(self:GetNumber()) )

	-- Quickly make sure that a special round with the convar on does not use the config (temporarily)
	if nz.Config.EnemyTypes[ self:GetNumber() ] and !(self:IsSpecial() and GetConVar("nz_test_hellhounds"):GetBool()) then
		self:SetZombieData( nz.Config.EnemyTypes[ self:GetNumber() ].types )
		if nz.Config.EnemyTypes[ self:GetNumber() ].count then
			self:SetZombiesMax( nz.Config.EnemyTypes[ self:GetNumber() ].count )
		end
	elseif self:IsSpecial() then -- The config always takes priority, however if nothing has been set for this round, assume special round settings
		if GetConVar("nz_test_hellhounds"):GetBool() then
			self:SetSpecialZombieData( {["nz_zombie_special_dog"] = {chance = 100}} )
			self:SetZombiesMax( self:GetZombiesMax() * 0.5 )
		else
			self:SetSpecialZombieData( nz.Config.SpecialRoundData.types )
			self:SetZombiesMax( nz.Config.SpecialRoundData.modifycount(self:GetZombiesMax()) )
		end
	end
	self:SetZombieSpeeds( nz.Curves.Functions.GenerateSpeedTable(self:GetNumber()) )

	self:SetZombiesKilled( 0 )
	self:SetZombiesSpawned( 0 )

	--Notify
	PrintMessage( HUD_PRINTTALK, "ROUND: " .. self:GetNumber() .. " preparing" )
	hook.Call( "OnRoundPreperation", Round, self:GetNumber() )
	--Play the sound

	--Spawn all players
	--Check config for dropins
	--For now, only allow the players who started the game to spawn
	for _, ply in pairs( player.GetAllPlaying() ) do
		ply:ReSpawn()
	end

	--Heal
	--[[for _, ply in pairs( player.GetAllPlaying() ) do
		ply:SetHealth( ply:GetMaxHealth() )
	end]]

	--Set this to reset the overspawn debug message status
	CurRoundOverSpawned = false

	--Start the next round
	timer.Simple(GetConVar("nz_round_prep_time"):GetFloat(), function() self:Start() end )

	if self:IsSpecial() then
		self:SetNextSpecialRound( self:GetNumber() + GetConVar("nz_round_special_interval"):GetInt() )
	end

end

local CurRoundOverSpawned = false

function Round:Start()

	self:SetState( ROUND_PROG )
	self:SetNextSpawnTime( CurTime() + 3 ) -- Delay zombie spawning by 3 seconds
	
	if self:IsSpecial() and GetConVar("nz_test_hellhounds"):GetBool() then -- The config always takes priority, however if nothing has been set for this round, assume special round settings
		self:SetNextSpawnTime( CurTime() + 5 )
		timer.Simple(3, function()
			Round:CallHellhoundRound()
		end)
	end
	
	--Notify
	PrintMessage( HUD_PRINTTALK, "ROUND: " .. self:GetNumber() .. " started" )
	hook.Call("OnRoundStart", Round, self:GetNumber() )
	--nz.Notifications.Functions.PlaySound("nz/round/round_start.mp3", 1)

	timer.Create( "NZRoundThink", 0.1, 0, function() self:Think() end )

	nz.Weps.DoRoundResupply()
end

function Round:Think()
	hook.Call( "OnRoundThink", self )
	--If all players are dead, then end the game.
	if #player.GetAllPlayingAndAlive() < 1 then
		self:End()
		timer.Remove( "NZRoundThink" )
	end

	local numzombies = nz.Enemies.Functions.TotalCurrentEnemies()

	--If we've killed all the zombies, then progress to the next level.
	if ( self:GetZombiesKilled() >= self:GetZombiesMax() ) then
		if numzombies <= 0 then
			self:Prepare()
			timer.Remove( "NZRoundThink" )
		elseif !CurRoundOverSpawned then --To not spam it every second upon overspawning - only once per round (reset on Prepare)
			print("The wave was overspawning by "..numzombies.."! Kill the remaining zombies to progress.")
			CurRoundOverSpawned = true
		end
	end

	--Uh-oh! Looks like all zombies have spawned, yet they aren't enough to satisfy the round limit!
	if ( self:GetZombiesSpawned() >= self:GetZombiesMax() ) and numzombies < ( self:GetZombiesMax() - self:GetZombiesKilled() ) then
		local diff = ( self:GetZombiesMax() - self:GetZombiesKilled() ) - numzombies
		--Apparently not?
		if diff <= 0 then return end

		self:SetZombiesSpawned( self:GetZombiesSpawned() - diff )
		print("The wave was underspawning by "..diff.."! Spawning more zombies ...")
	end
end

function Round:ResetGame()
	--Main Behaviour
	Doors:LockAllDoors()
	self:SetState( ROUND_WAITING )
	--Notify
	PrintMessage( HUD_PRINTTALK, "GAME READY!" )
	--Reset variables
	self:SetNumber( 0 )

	self:SetZombiesKilled( 0 )
	self:SetZombiesSpawned( 0 )
	self:SetZombiesMax( 0 )

	--Reset all player ready states
	for _, ply in pairs( player.GetAllReady() ) do
		ply:UnReady()
	end

	--Reset all downed players' downed status
	for k,v in pairs( player.GetAll() ) do
		v:KillDownedPlayer( true )
		v.SoloRevive = nil -- Reset Solo Revive counter
	end

	--Remove all enemies
	for k,v in pairs( nz.Config.ValidEnemies ) do
		for k2, v2 in pairs( ents.FindByClass( k ) ) do
			v2:Remove()
		end
	end

	--Resets all active palyers playing state
	for _, ply in pairs( player.GetAllPlaying() ) do
		ply:SetPlaying( false )
	end

	--Reset the electricity
	Elec:Reset(true)

	--Remove the random box
	RandomBox:Remove()

	--Reset all perk machines
	for k,v in pairs(ents.FindByClass("perk_machine")) do
		v:TurnOff()
	end

	for _, ply in pairs(player.GetAll()) do
		ply:SetPoints(0) --Reset all player points
		ply:RemovePerks() --Remove all players perks
	end

	--Clean up powerups
	nz.PowerUps.Functions.CleanUp()

	--Reset easter eggs
	nzEE:Reset()

	--Reset merged navigation groups
	nz.Nav.ResetNavGroupMerges()

end

function Round:End()
	--Main Behaviour
	self:SetState( ROUND_GO )
	--Notify
	PrintMessage( HUD_PRINTTALK, "GAME OVER!" )
	PrintMessage( HUD_PRINTTALK, "Restarting in 10 seconds!" )
	nz.Notifications.Functions.PlaySound("nz/round/game_over_4.mp3", 21)
	timer.Simple(10, function()
		self:ResetGame()
	end)

	hook.Call( "OnRoundEnd", Round )
end

function Round:Create()

	if self:InState( ROUND_WAITING ) then
		PrintMessage( HUD_PRINTTALK, "The mode has been set to creative mode!" )
		self:SetState( ROUND_CREATE )
		--We are in create
		for _, ply in pairs( player.GetAll() ) do
			if ply:IsSuperAdmin() then
				ply:GiveCreativeMode()
			end
			if ply:IsReady() then
				ply:SetReady( false )
			end
		end

		Mapping:CleanUpMap()

		--Re-enable navmesh visualization
		for k,v in pairs(nz.Nav.Data) do
			local navarea = navmesh.GetNavAreaByID(k)
			if v.link then
				navarea:SetAttributes(NAV_MESH_STOP)
			else
				navarea:SetAttributes(NAV_MESH_AVOID)
			end
		end

	elseif self:InState( ROUND_CREATE ) then
		PrintMessage( HUD_PRINTTALK, "The mode has been set to play mode!" )
		self:SetState( ROUND_WAITING )
		--We are in play mode
		for k,v in pairs(player.GetAll()) do
			v:SetSpectator()
		end
	end
end

function Round:SetupGame()

	self:SetNumber( 0 )

	-- Store a session of all our players
	for _, ply in pairs(player.GetAll()) do
		if ply:IsValid() and ply:IsReady() then
			ply:SetPlaying( true )
		end
		ply:SetFrags( 0 ) --Reset all player kills
	end

	Mapping:CleanUpMap()
	Doors:LockAllDoors()

	-- Reset navigation attributes so they don't save into the actual .nav file.
	for k,v in pairs(nz.Nav.Data) do
		navmesh.GetNavAreaByID(k):SetAttributes(v.prev)
	end

	-- Open all doors with no price and electricity requirement
	for k,v in pairs(ents.GetAll()) do
		if v:IsBuyableEntity() then
			local data = v:GetDoorData()
			if data then
				if tonumber(data.price) == 0 and tobool(data.elec) == false then
					Doors:OpenDoor( v )
				end
			end
		end
		-- Setup barricades
		if v:GetClass() == "breakable_entry" then
			v:ResetPlanks()
		end
	end

	-- Empty the link table
	table.Empty(Doors.OpenedLinks)

	-- All doors with Link 0 (No Link)
	Doors.OpenedLinks[0] = true
	--nz.Doors.Functions.SendSync()

	-- Spawn a random box
	RandomBox:Spawn()

	local power = ents.FindByClass("power_box")
	if !IsValid(power[1]) then -- No power switch D:
		Elec:Activate(true) -- Silently turn on the power
	else
		Elec:Reset() -- Reset with no value to play the power down sound
	end
	
	nz.Perks.Functions.UpdateQuickRevive()
	
	Round:SetNextSpecialRound( GetConVar("nz_round_special_interval"):GetInt() )
	
	hook.Call( "OnGameBegin", Round )

end

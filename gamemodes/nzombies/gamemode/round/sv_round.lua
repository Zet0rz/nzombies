function GM:InitPostEntity()

	nzRound:Waiting()

end

function nzRound:Waiting()

	self:SetState( ROUND_WAITING )
	hook.Call( "OnRoundWaiting", nzRound )

end

function nzRound:Init()

	timer.Simple( 5, function() self:SetupGame() self:Prepare() end )
	self:SetState( ROUND_INIT )
	self:SetEndTime( CurTime() + 5 )
	PrintMessage( HUD_PRINTTALK, "5 seconds till start time." )
	hook.Call( "OnRoundInit", nzRound )

end

function nzRound:Prepare( time )

	if self:IsSpecial() then -- From previous round
		local data = self:GetSpecialRoundData()
		if data and data.endfunc then data.endfunc() end
	end
	
	-- Update special round type every round, before special state is set
	local roundtype = nzMapping.Settings.specialroundtype
	self:SetSpecialRoundType(roundtype)

	-- Set special for the upcoming round during prep, that way clients have time to fade the fog in
	self:SetSpecial( self:MarkedForSpecial( self:GetNumber() + 1 ) )
	self:SetState( ROUND_PREP )
	self:IncrementNumber()

	self:SetZombieHealth( nzCurves.GenerateHealthCurve(self:GetNumber()) )
	self:SetZombiesMax( nzCurves.GenerateMaxZombies(self:GetNumber()) )

	self:SetZombieSpeeds( nzCurves.GenerateSpeedTable(self:GetNumber()) )

	self:SetZombiesKilled( 0 )

	--Notify
	--PrintMessage( HUD_PRINTTALK, "ROUND: " .. self:GetNumber() .. " preparing" )
	hook.Call( "OnRoundPreparation", nzRound, self:GetNumber() )
	--Play the sound

	--Spawn all players
	--Check config for dropins
	--For now, only allow the players who started the game to spawn
	for _, ply in pairs( player.GetAllPlaying() ) do
		ply:ReSpawn()
	end

	-- Setup the spawners after all players have been spawned

	-- Reset and remove the old spawners
	if self:GetSpecialSpawner() then
		self:GetSpecialSpawner():Remove()
		self:SetSpecialSpawner(nil)
	end

	if self:GetNormalSpawner() then
		self:GetNormalSpawner():Remove()
		self:SetNormalSpawner(nil)
	end

	-- Prioritize any configs (useful for mapscripts)
	if nzConfig.RoundData[ self:GetNumber() ] or (self:IsSpecial() and self:GetSpecialRoundData()) then
		local roundData = self:IsSpecial() and self:GetSpecialRoundData().data or nzConfig.RoundData[ self:GetNumber() ]

		--normal spawner
		local normalCount = 0

		-- only setup a spawner if we have zombie data
		if roundData.normalTypes then
			if roundData.normalCountMod then
				local mod = roundData.normalCountMod
				normalCount = mod(self:GetZombiesMax())
			elseif roundData.normalCount then
				normalCount = roundData.normalCount
			else
				normalCount = self:GetZombiesMax()
			end
			
			local normalDelay
			if roundData.normalDelayMod then
				local mod = roundData.normalDelayMod
				normalDelay = mod(self:GetZombiesMax())
			elseif roundData.normalDelay then
				normalDelay = roundData.normalDelay
			else
				normalDelay = 0.25
			end

			local normalData = roundData.normalTypes
			local normalSpawner = Spawner("nz_spawn_zombie_normal", normalData, normalCount, normalDelay or 0.25)

			-- save the spawner to access data
			self:SetNormalSpawner(normalSpawner)
		end

		-- special spawner
		local specialCount = 0

		-- only setup a spawner if we have zombie data
		if roundData.specialTypes then
			if roundData.specialCountMod then
				local mod = roundData.specialCountMod
				specialCount = mod(self:GetZombiesMax())
			elseif roundData.specialCount then
				specialCount = roundData.specialCount
			else
				specialCount = self:GetZombiesMax()
			end
			
			local specialDelay
			if roundData.specialDelayMod then
				local mod = roundData.specialDelayMod
				specialDelay = mod(self:GetZombiesMax())
			elseif roundData.specialDelay then
				specialDelay = roundData.specialDelay
			else
				specialDelay = 0.5
			end

			local specialData = roundData.specialTypes
			local specialSpawner = Spawner("nz_spawn_zombie_special", specialData, specialCount, specialDelay or 0.25)

			-- save the spawner to access data
			self:SetSpecialSpawner(specialSpawner)
		end

		-- update the zombiesmax (for win detection)
		self:SetZombiesMax(normalCount + specialCount)
		
	-- Woah ... spooky round O_o
	elseif self:GetNumber() == -1 then
		
		local normalrounddata = {["nz_zombie_walker"] = {chance = 100}}
		local specialrounddata = {}
		
		for k,v in pairs(nzRound.SpecialData) do
			if v.data then
				if v.data.normalTypes then
					for k3,v3 in pairs(v.data.normalTypes) do
						local chance = v3.chance
						normalrounddata[k3] = {["chance"] = chance/10}
					end
				end
				if v.data.specialTypes then
					for k3,v3 in pairs(v.data.specialTypes) do
						local chance = v3.chance
						specialrounddata[k3] = {["chance"] = chance/10}
					end
				end
			end
		end
		
		local normalSpawner = Spawner("nz_spawn_zombie_normal", normalrounddata, 1)
		self:SetNormalSpawner(normalSpawner)
		
		if table.Count(specialrounddata) > 0 then
			local specialSpawner = Spawner("nz_spawn_zombie_special", specialrounddata, 1, 4)
			self:SetSpecialSpawner(specialSpawner)
		end
			

	-- else if no data was set continue with the gamemodes default spawning
	-- if the round is special use the gamemodes default special round (Hellhounds)
	elseif self:IsSpecial() then
		-- only setup a special spawner
		self:SetZombiesMax(math.floor(self:GetZombiesMax() / 2)) -- Half the amount of special zombies
		local specialSpawner = Spawner("nz_spawn_zombie_special", {["nz_zombie_special_dog"] = {chance = 100}}, self:GetZombiesMax(), 2)

		-- save the spawner to access data
		self:SetSpecialSpawner(specialSpawner)

	-- else just do regular walker spawning
	else
		local normalSpawner = Spawner("nz_spawn_zombie_normal", {["nz_zombie_walker"] = {chance = 100}}, self:GetZombiesMax())

		-- after round 20 spawn some hellhounds aswell (half of the round number 21: 10, 22: 11, 23: 11, 24: 12 ...)
		if self:GetNumber() > 20 then
			local amount = math.floor(self:GetNumber() / 2)
			local specialSpawner = Spawner("nz_spawn_zombie_special", {["nz_zombie_special_dog"] = {chance = 100}}, amount, 2)

			self:SetSpecialSpawner(specialSpawner)
			self:SetZombiesMax(self:GetZombiesMax() + amount)
		end

		-- save the spawner to access data
		self:SetNormalSpawner(normalSpawner)
	end

	--Heal
	--[[for _, ply in pairs( player.GetAllPlaying() ) do
		ply:SetHealth( ply:GetMaxHealth() )
	end]]

	--Set this to reset the overspawn debug message status
	CurRoundOverSpawned = false

	--Start the next round
	local time = time or GetConVar("nz_round_prep_time"):GetFloat()
	if self:GetNumber() == -1 then time = 20 end
	--timer.Simple(time, function() if self:InProgress() then self:Start() end end )
	
	local starttime = CurTime() + time
	hook.Add("Think", "nzRoundPreparing", function()
		if CurTime() > starttime then
			if self:InProgress() then self:Start() end
			hook.Remove("Think", "nzRoundPreparing")
		end
	end)

	if self:IsSpecial() then
		self:SetNextSpecialRound( self:GetNumber() + GetConVar("nz_round_special_interval"):GetInt() )
	end

end

local CurRoundOverSpawned = false

function nzRound:Start()

	self:SetState( ROUND_PROG )
	local spawner = self:GetNormalSpawner()
	if spawner then
		spawner:SetNextSpawn( CurTime() + 3 ) -- Delay zombie spawning by 3 seconds
	end

	local specialspawner = self:GetSpecialSpawner()
	if self:IsSpecial() then
		if specialspawner and specialspawner:GetData()["nz_zombie_special_dog"] then -- If we got a dog special round
			specialspawner:SetNextSpawn( CurTime() + 6 ) -- Delay spawning even furhter
			timer.Simple(3, function()
				nzRound:CallHellhoundRound() -- Play the sound
			end)
		end
		
		local data = self:GetSpecialRoundData()
		if data and data.roundfunc then data.roundfunc() end
	end

	--Notify
	--PrintMessage( HUD_PRINTTALK, "ROUND: " .. self:GetNumber() .. " started" )
	hook.Call("OnRoundStart", nzRound, self:GetNumber() )
	--nzNotifications:PlaySound("nz/round/round_start.mp3", 1)

	timer.Create( "NZRoundThink", 0.1, 0, function() self:Think() end )

	nzWeps:DoRoundResupply()
	
	if self:GetNumber() == -1 then
		self.InfinityStart = CurTime()
	end
end

function nzRound:Think()
	if self.Frozen then return end
	hook.Call( "OnRoundThink", self )
	--If all players are dead, then end the game.
	if #player.GetAllPlayingAndAlive() < 1 then
		self:End()
		timer.Remove( "NZRoundThink" )
		return -- bail
	end

	--If we've killed all the spawned zombies, then progress to the next level.
	local numzombies = nzEnemies:TotalAlive()

	-- failsafe temporary until i can identify the issue (why are not all zombies spawned and registered)
	local zombiesToSpawn
	if self:GetNormalSpawner() then
		zombiesToSpawn = self:GetNormalSpawner():GetZombiesToSpawn()
	end

	if self:GetSpecialSpawner() then
		if zombiesToSpawn then
			zombiesToSpawn = zombiesToSpawn + self:GetSpecialSpawner():GetZombiesToSpawn()
		else
			zombiesToSpawn = self:GetSpecialSpawner():GetZombiesToSpawn()
		end
	end

	-- this will trigger if no more zombies will spawn, but more are required to end a round
	if zombiesToSpawn == 0 and self:GetZombiesKilled() + numzombies < self:GetZombiesMax() then
		if self:GetNormalSpawner() then
			self:GetNormalSpawner():SetZombiesToSpawn(self:GetZombiesMax() - (self:GetZombiesKilled() + numzombies))
			DebugPrint(2, "Spawned additional normal zombies because the wave was underspawning.")
		elseif self:GetSpecialSpawner() then
			self:GetSpecialSpawner():SetZombiesToSpawn(self:GetZombiesMax() - (self:GetZombiesKilled() + numzombies))
			DebugPrint(2, "Spawned additional special zombies because the wave was underspawning.")
		end
	end
	
	self:SetZombiesToSpawn(zombiesToSpawn)

	if ( self:GetZombiesKilled() >= self:GetZombiesMax() and self:GetNumber() != -1 ) then
		if numzombies <= 0 then
			self:Prepare()
			timer.Remove( "NZRoundThink" )
		end
	end
end

function nzRound:ResetGame()
	--Main Behaviour
	nzDoors:LockAllDoors()
	self:Waiting()
	--Notify
	PrintMessage( HUD_PRINTTALK, "GAME READY!" )
	--Reset variables
	self:SetNumber( 0 )

	self:SetZombiesKilled( 0 )
	self:SetZombiesMax( 0 )

	--Reset all player ready states
	for _, ply in pairs( player.GetAllReady() ) do
		ply:UnReady()
	end

	--Reset all downed players' downed status
	for k,v in pairs( player.GetAll() ) do
		v:KillDownedPlayer( true )
		v.SoloRevive = nil -- Reset Solo Revive counter
		v:SetPreventPerkLoss(false)
		v:RemovePerks()
	end

	--Remove all enemies
	for k,v in pairs( nzConfig.ValidEnemies ) do
		for k2, v2 in pairs( ents.FindByClass( k ) ) do
			v2:Remove()
		end
	end

	--Resets all active palyers playing state
	for _, ply in pairs( player.GetAllPlaying() ) do
		ply:SetPlaying( false )
	end

	--Reset the electricity
	nzElec:Reset(true)

	--Remove the random box
	nzRandomBox.Remove()

	--Reset all perk machines
	for k,v in pairs(ents.FindByClass("perk_machine")) do
		v:TurnOff()
	end

	for _, ply in pairs(player.GetAll()) do
		ply:SetPoints(0) --Reset all player points
		ply:RemovePerks() --Remove all players perks
	end

	--Clean up powerups
	nzPowerUps:CleanUp()

	--Reset easter eggs
	nzEE:Reset()
	nzEE.Major:Reset()
	
	-- Load queued config if any
	if nzMapping.QueuedConfig then
		nzMapping:LoadConfig(nzMapping.QueuedConfig.config, nzMapping.QueuedConfig.loader)
	end

end

function nzRound:End()
	--Main Behaviour
	self:SetState( ROUND_GO )
	--Notify
	PrintMessage( HUD_PRINTTALK, "GAME OVER!" )
	PrintMessage( HUD_PRINTTALK, "Restarting in 10 seconds!" )
	if self:GetNumber() == -1 then
		if self.InfinityStart then
			local time = string.FormattedTime(CurTime() - self.InfinityStart)
			local timestr = string.format("%02i:%02i:%02i", time.h, time.m, time.s)
			net.Start("nzMajorEEEndScreen")
				net.WriteBool(false)
				net.WriteBool(false)
				net.WriteString("You survived for "..timestr.." in Round Infinity")
				net.WriteFloat(10)
				net.WriteBool(false)
			net.Broadcast()
		end
		nzNotifications:PlaySound("nz/round/game_over_-1.mp3", 21)
	elseif nzMapping.OfficialConfig then
		nzNotifications:PlaySound("nz/round/game_over_5.mp3", 21)
	else
		nzNotifications:PlaySound("nz/round/game_over_4.mp3", 21)
	end
	
	timer.Simple(10, function()
		self:ResetGame()
	end)

	hook.Call( "OnRoundEnd", nzRound )
end

function nzRound:Win(message, keepplaying, time, noautocam, camstart, camend)
	if !message then message = "You survived after " .. self:GetNumber() .. " rounds!" end
	local time = time or 10
	
	if not noautocam then
		net.Start("nzMajorEEEndScreen")
			net.WriteBool(false)
			net.WriteBool(true)
			net.WriteString(message)
			net.WriteFloat(time)
			if camstart and camend then
				net.WriteBool(true)
				net.WriteVector(camstart)
				net.WriteVector(camend)
			else
				net.WriteBool(false)
			end
		net.Broadcast()
	end
	
	-- Set round state to Game Over
	if !keepplaying then
		nzRound:SetState( ROUND_GO )
		--Notify with chat message
		PrintMessage( HUD_PRINTTALK, "GAME OVER!" )
		PrintMessage( HUD_PRINTTALK, "Restarting in 10 seconds!" )
		
		if self.OverrideEndSlomo then
			game.SetTimeScale(0.25)
			timer.Simple(2, function() game.SetTimeScale(1) end)
		end
		
		timer.Simple(time, function()
			nzRound:ResetGame()
		end)
		
		hook.Call( "OnRoundEnd", nzRound )
	else
		for k,v in pairs(player.GetAllPlaying()) do
			v:SetTargetPriority(TARGET_PRIORITY_NONE)
		end
		if self.OverrideEndSlomo then
			game.SetTimeScale(0.25)
			timer.Simple(2, function() game.SetTimeScale(1) end)
		end
		timer.Simple(time, function()
			for k,v in pairs(player.GetAllPlaying()) do
				v:SetTargetPriority(TARGET_PRIORITY_PLAYER)
				--v:GivePermaPerks()
			end
		end)
	end

end

function nzRound:Lose(message, time, noautocam, camstart, camend)
	if !message then message = "You got overwhelmed after " .. self:GetNumber() .. " rounds!" end
	local time = time or 10
	
	if not noautocam then
		net.Start("nzMajorEEEndScreen")
			net.WriteBool(false)
			net.WriteBool(true)
			net.WriteString(message)
			net.WriteFloat(time)
			if camstart and camend then
				net.WriteBool(true)
				net.WriteVector(camstart)
				net.WriteVector(camend)
			else
				net.WriteBool(false)
			end
		net.Broadcast()
	end
	
	-- Set round state to Game Over
	nzRound:SetState( ROUND_GO )
	--Notify with chat message
	PrintMessage( HUD_PRINTTALK, "GAME OVER!" )
	PrintMessage( HUD_PRINTTALK, "Restarting in 10 seconds!" )
	
	if self.OverrideEndSlomo then
		game.SetTimeScale(0.25)
		timer.Simple(2, function() game.SetTimeScale(1) end)
	end
	
	timer.Simple(time, function()
		nzRound:ResetGame()
	end)

	hook.Call( "OnRoundEnd", nzRound )
end

function nzRound:Create(on)
	if on then
		if self:InState( ROUND_WAITING ) then
			PrintMessage( HUD_PRINTTALK, "The mode has been set to creative mode!" )
			self:SetState( ROUND_CREATE )
			hook.Call("OnRoundCreative", nzRound)
			--We are in create
			for _, ply in pairs( player.GetAll() ) do
				if ply:IsSuperAdmin() then
					ply:GiveCreativeMode()
				end
				if ply:IsReady() then
					ply:SetReady( false )
				end
			end

			nzMapping:CleanUpMap()
			nzDoors:LockAllDoors()
			
			for k,v in pairs(ents.GetAll()) do
				if v.NZOnlyVisibleInCreative then
					v:SetNoDraw(false)
				end
			end
			
			self:SetZombieHealth(100)
		else
			PrintMessage( HUD_PRINTTALK, "Can only go in Creative Mode from Waiting state." )
		end
	elseif self:InState( ROUND_CREATE ) then
		PrintMessage( HUD_PRINTTALK, "The mode has been set to play mode!" )
		self:SetState( ROUND_WAITING )
		--We are in play mode
		for k,v in pairs(player.GetAll()) do
			v:SetSpectator()
		end
		
		for k,v in pairs(ents.GetAll()) do
			if v.NZOnlyVisibleInCreative then -- This is set in each entity's file
				v:SetNoDraw(true) -- Yes this improves FPS by ~50% over a client-side convar and round state check
			end
		end
	else
		PrintMessage( HUD_PRINTTALK, "Not in Creative Mode." )
	end
end

function nzRound:SetupGame()

	self:SetNumber( 0 )

	-- Store a session of all our players
	for _, ply in pairs(player.GetAll()) do
		if ply:IsValid() and ply:IsReady() then
			ply:SetPlaying( true )
		end
		ply:SetFrags( 0 ) --Reset all player kills
	end

	nzMapping:CleanUpMap()
	nzDoors:LockAllDoors()

	-- Open all doors with no price and electricity requirement
	for k,v in pairs(ents.GetAll()) do
		if v:IsBuyableEntity() then
			local data = v:GetDoorData()
			if data then
				if tonumber(data.price) == 0 and tobool(data.elec) == false then
					nzDoors:OpenDoor( v )
				end
			end
		end
		-- Setup barricades
		if v:GetClass() == "breakable_entry" then
			v:ResetPlanks()
		end
	end

	-- Empty the link table
	table.Empty(nzDoors.OpenedLinks)

	-- All doors with Link 0 (No Link)
	nzDoors.OpenedLinks[0] = true
	--nz.nzDoors.Functions.SendSync()

	-- Spawn a random box at a possible starting position
	nzRandomBox.Spawn(nil, true)

	local power = ents.FindByClass("power_box")
	if !IsValid(power[1]) then -- No power switch D:
		nzElec:Activate(true) -- Silently turn on the power
	else
		nzElec:Reset() -- Reset with no value to play the power down sound
	end

	nzPerks:UpdateQuickRevive()

	nzRound:SetNextSpecialRound( GetConVar("nz_round_special_interval"):GetInt() )

	nzEE.Major:Reset()

	hook.Call( "OnGameBegin", nzRound )

end

function nzRound:Freeze(bool)
	self.Frozen = bool
end

function nzRound:RoundInfinity(nokill)
	if !nokill then
		nzPowerUps:Nuke(nil, true) -- Nuke kills them all, no points, no position delay
	end

	nzRound:SetNumber( -2 )
	nzRound:SetState(ROUND_PROG)
	nzRound:Prepare()
end
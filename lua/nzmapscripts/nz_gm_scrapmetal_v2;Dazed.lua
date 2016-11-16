--//Made by Logan - written for Zet0r to (hopefully) be included in the official gamemode
--[[
	Things I need:
	- Way to retrieve invisible walls on an indivdual basis - try prop remover tool?
	- Way to immediately enable or disable electricity (on game start what would normally be done if the power lever WAS spawned?)
	- Way to disable parts of the nav mesh? For when enabling the first EE ending with the control panel, there will be floating nav areas
	- What are the specifics of round infinity?

	Idea(s):
	- Create a system of links, where starting a generator allows the link in each respective room to be activated,
		after all are finished, players can do final EE run (such props: models/props_lab/reciever_cart.mdl, models/props_lab/reciever01a.mdl, models/props_lab/reciever01b.mdl )
		- Maybe allow for players to fall straight to the bottom in the elevator shafts? First fall platform (from spawn) can be
			changed into wood from the elevator, and players can run from the elevator console area to underneath the bridges
			but not back
	- Players must activate the 5 console props in a specific order maybe randomized
		- Set specific to generator order? Starting a generator allows for one of the console props to be pushed
	- Console gets the lights above each button/prop to indicate on/off/unpowered state?
	- Incorporate a way to fail? Final way to escape are the two garage doors, blocked by some panzers and shitton of zombies,
		doors open after 30 seconds or so after activating them
		- Failing primary EE will perma-disable power, have all the generators and power switch being zapped with the electricity effect
	- At some point in the EE steps, the power should turn back off
		- Maybe on a randomized per-round basis AFTER power has been initially restored?
		- Every round it turns off, could disable flashlights / use the electricity damage effect as well
]]
local mapscript = {}

--//Positions of generators and gas cans
local generators = {
	{ pos = Vector( -324.481293, 985.716675, 27.194300 ), ang = Angle( -0.008, -1.304, 0.013 ) },
	{ pos = Vector( -2503.098877, -637.548645, 146.832428 ), ang = Angle( -0.000, 180.000, 0.000 ) },
	{ pos = Vector( -530.526611, -1575.066895, -121.032532 ), ang = Angle( -0.000, -180.000, -0.000 ) },
	{ pos = Vector( -2768.641113, -1372.191284, -369.08517 ), ang = Angle( -0.000, -180.000, -0.000 ) },
	{ pos = Vector( -2061.307373, 1403.317261, -157.157211 ), ang = Angle( -0.000, 180.000, 0.000 ) }
}

local gascanspawns = {
	{ pos = Vector( 281.657257, -1538.109131, 122.891541 ), ang = Angle( 0.000, 90.000, 0.000 ) }, --Power Switch room corner
	{ pos = Vector( -2614.193604, -792.145874, 6.813320 ), ang = Angle( -30.955, 92.504, -0.018 ) }, --Bathroom (PaP level)
	{ pos = Vector( -1882.064575, -2003.087524, -384.468384 ), ang = Angle( 23.955, -0.368, 0.070 ) }, --Warehouse corner
	{ pos = Vector( -663.979797, -1431.645508, -385.301178 ), ang = Angle( -0.000, -0.000, 0.000 ) }, --Creepy room off the garage - Hide it better?
	{ pos = Vector( -730.634888, -2468.336182, -5.215676 ), ang = Angle( -35.735, -90.746, 0.077 ) } --Double Tap room
}

local links = {
	{ pos = Vector( -485.073120, 714.775635, 37.296597 ), ang = Angle( -2.823, -7.083, 0.082 ) }, --On desk
	{ pos = Vector( -2060.613037, -2014.947021, 175.752914 ), ang = Angle( -8.780, 97.645, -1.173 ) }, --Steam room
	{ pos = Vector( 190.453674, -1582.523315, -110.206749 ), ang = Angle( -0.665, -134.111, -0.199 ) }, --Warden
	{ pos = Vector( -2342.335205, -239.686722, -386.362579 ), ang = Angle( -0.300, 42.795, 0.052 ) }, --Jugg
	{ pos = Vector( -568.757507, 1237.885498, -180.267487 ), ang = Angle( -2.201, 122.529, 2.652 ) } --Elevator
}

local lights1 = {
	{ pos = Vector( -575, -1467, 220.0 ), ang = Angle( 0.000, -90.000, -0.000 ) },
	{ pos = Vector( -555, -1467, 220.0 ), ang = Angle( 0.000, -90.000, -0.000 ) },
	{ pos = Vector( -535, -1467, 220.0 ), ang = Angle( 0.000, -90.000, -0.000 ) },
	{ pos = Vector( -595, -1467, 220.0 ), ang = Angle( 0.000, -90.000, -0.000 ) },
	{ pos = Vector( -615, -1467, 220.0 ), ang = Angle( 0.000, -90.000, -0.000 ) },
}

local lights2 = {
	{ pos = Vector( -912.5, -130, -263 ), ang = Angle( 0, 0, 0 ) },
	{ pos = Vector( -912.5, -80, -263 ), ang = Angle( 0, 0, 0 ) },
	{ pos = Vector( -912.5, -30, -263 ), ang = Angle( 0, 0, 0 ) },
	{ pos = Vector( -912.5, 20, -263 ), ang = Angle( 0, 0, 0 ) },
	{ pos = Vector( -912.5, 70, -263 ), ang = Angle( 0, 0, 0 ) },
}

--//From left to right
local consolebuttons = { 2335, 2337, 2338, 2339, 2340 }

local poweredgenerators, establishedlinks = { }, { }

--//Creates all of the gas cans
local gascans = nzItemCarry:CreateCategory( "gascan" )
gascans:SetIcon( "spawnicons/models/props_junk/metalgascan.png" ) --spawnicons/models/props_junk/gascan001a.png
gascans:SetText( "Press E to pick up the gas can." )
gascans:SetDropOnDowned( true )
gascans:SetShowNotification( true )

gascans:SetResetFunction( function( self )
	for k, v in pairs( gascanspawns ) do
		if !v.used and !v.held then --Only spawn those that are not being carried
			local ent = ents.Create( "nz_script_prop" )
			ent:SetModel( "models/props_junk/metalgascan.mdl" )
			ent:SetPos( v.pos )
			ent:SetAngles( v.ang )
			ent:Spawn()
			v.ent = ent --Sets each gascan in gascanspawns as a unique entity
			self:RegisterEntity( ent )
		end
	end
end )

gascans:SetDropFunction( function( self, ply )
	for k, v in pairs( gascanspawns ) do -- Loop through all gascans
		if v.held == ply then -- If this is the one we're carrying
			local ent = ents.Create( "nz_script_prop" )
			ent:SetModel( "models/props_junk/metalgascan.mdl" )
			ent:SetPos( ply:GetPos() )
			ent:SetAngles( Angle( 0, 0, 0 ) )
			ent:Spawn()
			ent:DropToFloor()
			ply:RemoveCarryItem( "gascan" )
			v.held = nil
			ply.ent = nil
			self:RegisterEntity( ent )
			break
		end
	end
end )

gascans:SetPickupFunction( function( self, ply, ent )
	for k, v in pairs( gascanspawns ) do
		if v.ent == ent then --If this is the correct gas can
			ply:GiveCarryItem( self.id )
			ent:Remove()
			v.held = ply --Save the player who's holding the can
			ply.ent = ent --Because for some reason there's no included way to retrieve a held object
			break
		end
	end
end )
gascans:SetCondition( function( self, ply )
	return !ply:HasCarryItem( "gascan" )
end )

gascans:Update()

--//Creates the power switch lever
local lever = nzItemCarry:CreateCategory( "lever" )
lever:SetIcon( "spawnicons/models/nzprops/zombies_power_lever_handle.png" )
lever:SetText( "Press E to pick up the power switch lever." )
lever:SetDropOnDowned( true )
lever:SetShowNotification( true )

lever:SetDropFunction( function( self, ply )
	--if IsValid(scriptgascan) then scriptgascan:Remove() end
	local lvr = ents.Create("nz_script_prop")
	lvr:SetModel( "models/nzprops/zombies_power_lever_handle.mdl" )
	lvr:SetPos( ply:GetPos() )
	lvr:SetAngles( Angle( 0, 0, 0 ) )
	lvr:Spawn()
	lvr:DropToFloor()
	ply:RemoveCarryItem( "lever" )
	self:RegisterEntity( lvr )
end )

lever:SetResetFunction( function( self )
	--if IsValid(scriptgascan) then scriptgascan:Remove() end
	local lvr = ents.Create("nz_script_prop")
	lvr:SetModel( "models/nzprops/zombies_power_lever_handle.mdl" )
	lvr:SetPos( Vector( 13.191984, -1872.725342, -116.208336 ) )
	lvr:SetAngles( Angle( -6.148, 33.658, 0.388 ) )
	lvr:Spawn()
	self:RegisterEntity( lvr )
end )

lever:SetPickupFunction( function(self, ply, ent)
	ply:GiveCarryItem( self.id )
	ent:Remove()
end )

lever:Update()

--//To be used to check for establishedlinks' or poweredgenerators' validity
function CheckTable( tbl )
	if #tbl == 0 then return false end
	for k, v in pairs( tbl ) do
		if not v then
			return false
		end
	end
	return true
end

function mapscript.OnGameBegin()
	local linkstarted = false
    --nzElec:Reset()
    --EE option 2 door IDs: 5238, 5243

	--//Creates the broken power switch
	local powerswitch = ents.Create( "nz_script_prop" )
	powerswitch:SetPos( Vector( 109.952400, -1472.475220, 107.462799 ) )
	powerswitch:SetAngles( Angle( -0.000, -90.000, 0.000 ) )
	powerswitch:SetModel( "models/nzprops/zombies_power_lever.mdl" ) 
	powerswitch:SetNWString( "NZText", "You must fix the power switch before turning on the power." )
	powerswitch:SetNWString( "NZRequiredItem", "lever" )
	powerswitch:SetNWString( "NZHasText", "Press E to place the lever back on the power switch." )
	powerswitch:Spawn()
	powerswitch:Activate()
	powerswitch.OnUsed = function( self, ply )
		if not ply:HasCarryItem( "lever" ) then return end
		local actualpowerswitch = ents.Create( "power_box" )
		actualpowerswitch:SetPos( self:GetPos() )
		actualpowerswitch:SetAngles( self:GetAngles() )
		timer.Simple( 0.1, function()
			actualpowerswitch:Spawn()
			actualpowerswitch:SetNWString( "NZText", "There's no certainty power will remain on..." )
			powerswitch:Remove()
			ply:RemoveCarryItem( "lever" )
		end )
	end

	baselink = ents.Create( "nz_script_prop" )
	baselink:SetPos( Vector( -580.019531, -1488.002930, 143.345886 ) )
	baselink:SetAngles( Angle( 0.008, -85.925, -0.133 ) )
	baselink:SetModel( "models/props_lab/reciever_cart.mdl" )
	baselink:SetNWString( "NZText", "The power must be turned on before starting the linking." )
	baselink:Spawn()
	baselink:Activate()
	baselink.OnUsed = function( self, ply )
		print( "BaseLink OnUse called, debug: ", nzElec.IsOn(), linkstarted, CheckTable( establishedlinks ) )
		if not nzElec.IsOn() or linkstarted or CheckTable( establishedlinks ) then return end --//If electricity is on, linkstarted is true, and not all of the links are established
		PrintMessage( HUD_PRINTTALK, "BaseLink has been activated." )
		baselink:SetNWString( "NZText", "" )
		linkstarted = true
		for k, v in pairs( links ) do
			if not establishedlinks[ k ] and poweredgenerators[ k ] then
				v.ent:SetNWString( "Press E to establish a link with the home receiver." )
			end
		end
	end
	local effecttimer = 0
	baselink.Think = function()
		if linkstarted and CurTime() > effecttimer then
			local effect = EffectData()
			effect:SetScale( 1 )
			effect:SetEntity( baselink )
			util.Effect( "lightning_aura", effect )
			effecttimer = CurTime() + 0.5
		end
		if CheckTable( poweredgenerators ) and nzElec:IsOn() and not stop then
			baselink:SetNWString( "NZText", "Press E to begin linking." )
			stop = true
		end
	end

	extra1 = ents.Create( "nz_script_prop" )
	extra1:SetPos( Vector( -574.423828, -1495.917358, 129.057999 ) )
	extra1:SetAngles( Angle( -0.294, -88.05,5 -0.171 ) )
	extra1:SetModel( "models/props_lab/reciever01b.mdl" )
	extra1:Spawn()

	extra2 = ents.Create( "nz_script_prop" )
	extra2:SetPos( Vector( -573.884705, -1496.818726, 134.691925 ) )
	extra2:SetAngles( Angle( -1.788, -92.981, 0.029 ) )
	extra2:SetModel( "models/props_lab/reciever01d.mdl" )
	extra2:Spawn()

	extra3 = ents.Create( "nz_script_prop" )
	extra3:SetPos( Vector( -574.466370, -1495.319702, 121.456146 ) )
	extra3:SetAngles( Angle( -0.769, -86.667, -0.191 ) )
	extra3:SetModel( "models/props_lab/reciever01c.mdl" )
	extra3:Spawn()

	--//Creates all of the generators
	for k, v in pairs( generators ) do
		poweredgenerators[ k ] = false
		local gen = ents.Create( "nz_script_prop" )
		gen:SetPos( v.pos )
		gen:SetAngles( v.ang )
		gen:SetModel( "models/props_wasteland/laundry_washer003.mdl" ) --It doesn't look anything like a washing machine?!
		gen:SetNWString( "NZText", "You must fill this generator with gasoline to power it." )
		gen:SetNWString( "NZRequiredItem", "gascan" )
		gen:SetNWString( "NZHasText", "Press E to fuel this generator with gasoline." )
		gen:Spawn()
		gen:Activate()
		gen.OnUsed = function( self, ply )
			if ply:HasCarryItem( "gascan" ) and not poweredgenerators[ k ] then --If ply has gas can and generator is unpowered
				for k, v in pairs( gascanspawns ) do
					if v == ply.ent then
						v.used = true
						v.held = false
						continue
					end
				end
				PrintMessage( HUD_PRINTTALK, "Generator " .. k .. " has been fueled." )
				ply:RemoveCarryItem( "gascan" )
				poweredgenerators[ k ] = true
				gen:SetNWString( "NZText", "This generator is powered on." )
				gen:SetNWString( "NZHasText", "This generator has already been fueled." )
				gen:EmitSound( "l4d2/gas_pour.wav" )
				timer.Simple( 4, function()
					gen:EmitSound( "l4d2/generator_start.wav" )
					timer.Simple( 9, function()
						timer.Create( "Gen" .. k, 3, 0, function()
							gen:EmitSound( "l4d2/generator_humm.ogg" )
						end )
					end )
				end )
				links[ k ].ent:SetNWString( "NZText", "Press E to establish a link with the home receiver.")
			end
		end
		gen.Think = function()
			if not poweredgenerators[ k ] and timer.Exists( "Gen" .. k ) then
				timer.Destroy( "Gen" .. k )
			end
		end
	end

	for k, v in pairs( links ) do
		establishedlinks[ k ] = false
		local link = ents.Create( "nz_script_prop" )
		v.ent = link
		link:SetPos( v.pos )
		link:SetAngles( v.ang )
		link:SetModel( "models/props_lab/reciever01b.mdl" ) 
		link:SetNWString( "NZText", "You must activate the base link first." )
		link:Spawn()
		link:Activate()
		link.OnUsed = function( self, ply )
			print( "Link debug: ", linkstarted, establishedlinks[ k ], poweredgenerators[ k ], "Link #" .. k )
			if not linkstarted or establishedlinks[ k ] or not poweredgenerators[ k ] then return end --If linkstarted is true, the link hasn't yet been established, and it's respective generator is on
			PrintMessage( HUD_PRINTTALK, "Link " .. k .. " has been activated." )
			linkstarted = false
			establishedlinks[ k ] = true --I think I'll use this for the thinking...?
			link:EmitSound( "ambient/machines/teleport1.wav" )
			link:SetNWString( "NZText", "" )
			lights1[ k ].ent:SetModel( "models/props_c17/light_cagelight02_on.mdl" )
			lights2[ k ].ent:SetModel( "models/props_c17/light_cagelight02_on.mdl" )
			if not CheckTable( establishedlinks ) then
				baselink:SetNWString( "NZText", "Press E to begin linking." )
			end
		end
	end

	for k, v in pairs( lights1 ) do
		local light = ents.Create( "nz_script_prop" )
		v.ent = light
		light:SetPos( v.pos )
		light:SetAngles( v.ang )
		light:SetModel( "models/props_c17/light_cagelight02_off.mdl" )
		--[[light.Think = funciont()
			if CurTime() > thinkskip and nzElec:IsOn() then
				if linkstarted then
					light:SetModel( "" )

				end
				thinkskip = CurTime() + 0.75
			end
		end]]
	end

	for k, v in pairs( lights2 ) do
		local light = ents.Create( "nz_script_prop" )
		v.ent = light
		light:SetPos( v.pos )
		light:SetAngles( v.ang )
		light:SetModel( "models/props_c17/light_cagelight02_off.mdl" )
	end

	gascans:Reset()
	lever:Reset()

	--//Fixes the bugged doorways
    local shittodelete = { 2169, 1858, 2959, 2465, 1921, 1918, 1939, 2209, 1976, 1973, 2373 } --, 2518 } the culprit
	for k, v in pairs( shittodelete ) do
		ents.GetMapCreatedEntity( v ):Fire( "Open" )
		timer.Simple( 0.2, function()
			ents.GetMapCreatedEntity( v ):Remove()
		end )
	end
end

--[[
lua_run print( player.GetAll()[1]:GetEyeTrace().Entity:GetPos() )
lua_run print( player.GetAll()[1]:GetEyeTrace().Entity:GetAngles() )

Build station pos: -1375.442627 985.563049 -164.028244
Build station ang: -0.000 -90.000 -0.000

models/props_c17/light_cagelight02_off.mdl - White
models/props_c17/light_cagelight02_on.mdl
models/props_c17/light_cagelight01_off.mdl - Red
models/props_c17/light_cagelight01_on.mdl
]]

local initialactivation = false
hook.Add( "ElectricityOn", "fuckoff", function() --What's the function I should be using...? mapscript.ElectricityOn() maybe did nothing?
	initialactivation = true
	baselink:SetNWString( "NZText", "Press E to begin linking." )
	print( "ElectricityOn has been called..." )
	for k, v in pairs( lights1 ) do
		v.ent:SetModel( "models/props_c17/light_cagelight01_on.mdl" )
	end
	for k, v in pairs( lights2 ) do
		v.ent:SetModel( "models/props_c17/light_cagelight01_on.mdl" )
	end
end )

local chance, turnoff = math.Clamp( 1, 1, 5 ), { }
function mapscript.OnRoundBegin()
	print( "mapscript.OnRoundBegin() has been called" )
	if initialactivation then
		print( "electricity has been turned on by the player" )
		for i = 1, 5 - chance do
			turnoff[ i ] = false
		end
		for i = 5 - chance, 10 do
			turnoff[ i ] = true
		end
		print( "should we turn off power this round?" )
		if turnoff[ math.random( 1, #turnoff ) ] then
			if not nzElec.IsOn() then
				nzElec:Reset()
			end
			chance = 1
			print( "turning off power" )
		else
			if not nzElec.IsOn() then
				nzElec:Active()
			end
			chance = chance + 1
			print( "turning power back on" )
		end
	end
end

function mapscript.RoundThink()

end

function mapscript.RoundEnd()

end

return mapscript
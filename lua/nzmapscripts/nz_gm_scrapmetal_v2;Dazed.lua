--//Made by Logan - written for Zet0r to (hopefully) be included in the official gamemode
--//This of course may be edited to work better, I ain't no great coder

--[[
TO-DO:	- Disallow returning power after failing the EE
		- Raise the invisible wall over the Soul Catcher
		- Randomize the power switch lever spawning
		- Get Counter Strike: Source C4 stuff, such as spawnicons
		- Add final step in EE steps where player builds bomb to destroy fence to escape, 
			can be created before console buttons, but only used after
			- In-game C-4 materials: timed detonator (remote or controller), blasting cap, 
				explosive (a nitroamine, nitrogen and amino acid mix, compound, gunpowder prop?), & rubber (any tire)
			- Have mini EE for the materials
				- Blasting Caps are found by destroying the door to the warden's office (lock model found in map de_cherno)
				- Tire found lying around
				- Nitroamine powder is rewarded by shooting something with a PaP weapon
		- Finalize navmesh (and fix that one zombie spawn after first door buy)

lua_run print( player.GetAll()[1]:GetEyeTrace().Entity:GetPos() )
lua_run print( player.GetAll()[1]:GetEyeTrace().Entity:GetAngles() )

Tire pos: -1889.828125 -1512.047974 -384.140137
Tire ang: 17.772 -19.848 -49.948

Nitroamine pos: -1817.329224 1417.655273 -177.375412
Nitroamine ang: -0.696 -45.993 -0.042
Nitroamine model: models/props_lab/jar01a.mdl

Possible Blasting Cap model: models/Items/grenadeAmmo.mdl --HL2 grenade
Possible Blasting Cap model: models/Items/AR2_Grenade.mdl --HL2 SMG grenade - this is probably the best of the two

EE failure door IDs: 5238, 5243

Train horn sound: ambient/alarms/train_horn2.wav
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
	{ { pos = Vector( 281.657257, -1538.109131, 122.891541 ), ang = Angle( 0.000, 90.000, 0.000 ) }, --Power Switch Room
		{ pos = Vector( -956.488892, -1478.487671, 123.242821 ), ang = Angle( -0.000, -180.000, 0.000 ) }, 
		{ pos = Vector( -501.245422, -1974.201050, 123.098961 ), ang = Angle( -0.000, -90.000, 0.000 ) } },
	{ { pos = Vector( -2614.193604, -792.145874, 6.813320 ), ang = Angle( -30.955, 92.504, -0.018 ) }, --PaP Floor
		{ pos = Vector( -2678.300049, -1757.024292, 49.664085 ), ang = Angle( 22.865, -164.534, 0.364 ) }, 
		{ pos = Vector( -2209.789795, -816.475830, 7.266649 ), ang = Angle( 0.000, 90.000, -0.000 ) } },
	{ { pos = Vector( -1882.064575, -2003.087524, -384.468384 ), ang = Angle( 23.955, -0.368, 0.070 ) }, --Warehouse
		{ pos = Vector( -2674.887939, -740.855103, -416.867920 ), ang = Angle( 31.790, -93.012, 0.072 ) }, 
		{ pos = Vector( -1876.407104, -618.244568, -128.735123 ), ang = Angle( -0.000, 0.000, -0.000 ) } },
	{ { pos = Vector( -663.979797, -1431.645508, -385.301178 ), ang = Angle( -0.000, -0.000, 0.000 ) }, --Garage
		{ pos = Vector( -817.737732, -1425.805420, -387.532410 ), ang = Angle( 89.700, -67.723, -111.667 ) }, 
		{ pos = Vector( -1334.050049, -2262.879395, -357.792572 ), ang = Angle( 62.510, -101.852, 12.076 ) } },
	{ { pos = Vector( -730.634888, -2468.336182, -5.215676 ), ang = Angle( -35.735, -90.746, 0.077 ) }, --Prison Cell Block
		{ pos = Vector( -60.586754, -2005.164673, -132.757187 ), ang = Angle( 0.000, -180.000, -0.000 ) }, 
		{ pos = Vector( 300.146576, -1618.740967, -132.940964 ), ang = Angle( 33.083, 5.192, -0.155 ) } },
}
local gascanlist = { }

local links = {
	{ pos = Vector( -485.073120, 714.775635, 37.296597 ), ang = Angle( -2.823, -7.083, 0.082 ) }, --On desk
	{ pos = Vector( -2060.613037, -2014.947021, 175.752914 ), ang = Angle( -8.780, 97.645, -1.173 ) }, --Steam room
	{ pos = Vector( 190.453674, -1582.523315, -110.206749 ), ang = Angle( -0.665, -134.111, -0.199 ) }, --Warden
	{ pos = Vector( -2342.335205, -239.686722, -386.362579 ), ang = Angle( -0.300, 42.795, 0.052 ) }, --Jugg
	{ pos = Vector( -1885.892090, 1419.159180, -420.200226 ), ang = Angle( -0.446, -46.191, 0.104 ) } --Under radiation
}

--//The lights above the Link Base
local lights1 = {
	{ pos = Vector( -575, -1467, 220.0 ), ang = Angle( 0.000, -90.000, -0.000 ) },
	{ pos = Vector( -555, -1467, 220.0 ), ang = Angle( 0.000, -90.000, -0.000 ) },
	{ pos = Vector( -535, -1467, 220.0 ), ang = Angle( 0.000, -90.000, -0.000 ) },
	{ pos = Vector( -595, -1467, 220.0 ), ang = Angle( 0.000, -90.000, -0.000 ) },
	{ pos = Vector( -615, -1467, 220.0 ), ang = Angle( 0.000, -90.000, -0.000 ) },
}

--//The lights above the console buttons (by trains)
local lights2 = {
	{ pos = Vector( -912.5, -130, -263 ), ang = Angle( 0, 0, 0 ) },
	{ pos = Vector( -912.5, -82, -263 ), ang = Angle( 0, 0, 0 ) },
	{ pos = Vector( -912.5, -35, -263 ), ang = Angle( 0, 0, 0 ) },
	{ pos = Vector( -912.5, 13, -263 ), ang = Angle( 0, 0, 0 ) },
	{ pos = Vector( -912.5, 60, -263 ), ang = Angle( 0, 0, 0 ) },
}

--//The detonator to be charged can spawn in any of the 3 places randomly
local detonatorspawn = {
	{ pos = Vector( -2002.968750, -553.781860, -394.328888 ), ang = Angle( -0.025, 99.925, 0.077 ) },
	{ pos = Vector( 187.443161, 1128.233643, 54.083485 ), ang = Angle( -0.233, 89.339, 0.178 ) },
	{ pos = Vector( -724.184204, -237.450592, -354.308746 ), ang = Angle( -2.876, 169.066, -0.773 ) },
}

	--//These are the props used for the EE hinting with console buttons. Hint#a is the outlying prop w/ hint text, 
	--//hint#b is the prop above the console buttons, hint#a will electrocute when the respective button needs pushing
	--//This could have been one giant for statement with outlying tables... buuuuuuuuuuuuuut...
local prophints = { }
	local hint1a = ents.Create( "nz_script_prop" )
	hint1a:SetPos( Vector( -281.893066, -1002.959473, 9.120822 ) ) --By the rubble where the crashed helicopter normally lies
	hint1a:SetAngles( Angle( -0.000, -12.150, 0.168 ) )
	hint1a:SetModel( "models/props_c17/BriefCase001a.mdl" )
	hint1a:Spawn()
	hint1a:SetNWString( "NZText", "It seems strange for this to just be lying here..." )
	prophints[ 1 ] = hint1a

	local hint1b = ents.Create( "nz_script_prop" )
	hint1b:SetPos( Vector( -885.444214, -128.211121, -346.147583 ) )
	hint1b:SetAngles( Angle( 0.000, -98.560, -93.304 ) )
	hint1b:SetModel( "models/props_c17/BriefCase001a.mdl" )
	hint1b:Spawn()

	--//--

	local hint2a = ents.Create( "nz_script_prop" )
	hint2a:SetPos( Vector( -1983.612427, -2021.229980, -102.058907 ) ) --In the Warehouse, on the rafters above
	hint2a:SetAngles( Angle( -48.433, 87.870, 90.805 ) )
	hint2a:SetModel( "models/props_c17/doll01.mdl" )
	hint2a:Spawn()
	hint2a:SetNWString( "NZText", "It seems strange for this to just be lying here..." )
	prophints[ 2 ] = hint2a

	local hint2b = ents.Create( "nz_script_prop" )
	hint2b:SetPos( Vector( -913.857971, -79.409180, -334.235504 ) )
	hint2b:SetAngles( Angle( 58.459, 179.829, -91.969 ) )
	hint2b:SetModel( "models/props_c17/doll01.mdl" )
	hint2b:Spawn()

	--//--

	local hint3a = ents.Create( "nz_script_prop" )
	hint3a:SetPos( Vector( -718.101379, 907.215454, -380.273407 ) ) --By the accessible elevator shafts near the bottom-most entrance
	hint3a:SetAngles( Angle( 4.376, 100.548, -13.520 ) )
	hint3a:SetModel( "models/props_junk/watermelon01.mdl" )
	hint3a:Spawn()
	hint3a:SetNWString( "NZText", "It seems strange for this to just be lying here..." )
	prophints[ 3 ] = hint3a

	local hint3b = ents.Create( "nz_script_prop" )
	hint3b:SetPos( Vector( -888.274048, -36.890865, -342.155243 ) )
	hint3b:SetAngles( Angle( 4.749, -112.861, 172.102 ) )
	hint3b:SetModel( "models/props_junk/watermelon01.mdl" )
	hint3b:Spawn()

	--//--

	local hint4a = ents.Create( "nz_script_prop" )
	hint4a:SetPos( Vector( -2556.203369, -2012.717529, 125.299492 ) ) --Next to the second computer in Steam room
	hint4a:SetAngles( Angle( -0.159, -149.331, 1.211 ) )
	hint4a:SetModel( "models/props_junk/Shoe001a.mdl" )
	hint4a:Spawn()
	hint4a:SetNWString( "NZText", "It seems strange for this to just be lying here..." )
	prophints[ 4 ] = hint4a

	local hint4b = ents.Create( "nz_script_prop" )
	hint4b:SetPos( Vector( -874.233643, 13.012714, -382.704803 ) )
	hint4b:SetAngles( Angle( -0.132, 123.661, 1.303 ) )
	hint4b:SetModel( "models/props_junk/Shoe001a.mdl" )
	hint4b:Spawn()

	--//--

	local hint5a = ents.Create( "nz_script_prop" )
	hint5a:SetPos( Vector( -1313.937622, -2223.339844, -367.152771 ) ) --In one of the cars outside
	hint5a:SetAngles( Angle( -5.747, -14.542, -26.477 ) )
	hint5a:SetModel( "models/props_lab/binderblue.mdl" )
	hint5a:Spawn()
	hint5a:SetNWString( "NZText", "It seems strange for this to just be lying here..." )
	prophints[ 5 ] = hint5a

	local hint5b = ents.Create( "nz_script_prop" )
	hint5b:SetPos( Vector( -894.307007, 78.609192, -344.923279 ) )
	hint5b:SetAngles( Angle( 37.427, -26.780, 75.820 ) )
	hint5b:SetModel( "models/props_lab/binderblue.mdl" )
	hint5b:Spawn()

	--//--

--//Build Table Information
local buildabletbl = {
	model = "", --insert C4 world model here
	pos = Vector(  ), --C4 Position relative to the table
	ang = Angle(  ), --C4 Angles
	parts = {
		[ "charged_detonator" ] = { 0, 1 },
		[ "tire" ] = { 2 },
		[ "nitroamine" ] = { 3 }, --Nitroamine
		[ "blastcap" ] = { 4 } --Blasting Caps
	},
	usefunc = function( self, ply ) -- When it's completed and a player presses E
		if !ply:HasWeapon("nz_zombieshield") then
			ply:GiveCarryItem( "" )
		end
	end,
	text = "Press E to pick up the plastic explosive."
}

--//Console buttons, from left to right
local consolebuttons = { 2335, 2337, 2338, 2339, 2340 }

local poweredgenerators, establishedlinks, buttonorder = { }, { }, { }

--//Creates all of the gas cans
local gascans = nzItemCarry:CreateCategory( "gascan" )
gascans:SetIcon( "spawnicons/models/props_junk/metalgascan.png" ) --spawnicons/models/props_junk/gascan001a.png
gascans:SetText( "Press E to pick up the gas can." )
gascans:SetDropOnDowned( true )
gascans:SetShowNotification( true )
gascans:SetResetFunction( function( self )
    for k, v in pairs( gascanspawns ) do --Resets the spawn point for all gas cans
        gascanlist[ k ] = v[ math.random( 3 ) ]
    end
	for k, v in pairs( gascanlist ) do
		local ent = ents.Create( "nz_script_prop" )
		ent:SetModel( "models/props_junk/metalgascan.mdl" )
		ent:SetPos( v.pos )
		ent:SetAngles( v.ang )
		ent:Spawn()
		v.ent = ent --Sets each gascan in gascanlist as a unique entity
		self:RegisterEntity( ent )
	end
end )
gascans:SetDropFunction( function( self, ply )
	for k, v in pairs( gascanlist ) do -- Loop through all gascans
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
	for k, v in pairs( gascanlist ) do
		if v.ent == ent then --If this is the correct gas can
			ply:GiveCarryItem( self.id )
			ent:Remove()
			v.held = ply --Save the player who's holding the can
			ply.ent = ent --Because I didn't know how to access player held objects and I'm too lazy now to change it
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

local detonator = nzItemCarry:CreateCategory( "detonator" )
detonator:SetIcon( "spawnicons/models/props_c17/consolebox05a.png" )
detonator:SetText( "Press E to pick up the console box." )
detonator:SetDropOnDowned( true )
detonator:SetShowNotification( true )
detonator:SetDropFunction( function( self, ply )
	local dtntr = ents.Create("nz_script_prop")
	dtntr:SetModel( "models/props_c17/consolebox05a.mdl" )
	dtntr:SetPos( ply:GetPos() )
	dtntr:SetAngles( Angle( 0, 0, 0 ) )
	dtntr:Spawn()
	dtntr:DropToFloor()
	ply:RemoveCarryItem( "detonator" )
	self:RegisterEntity( dtntr )
end )
detonator:SetResetFunction( function( self )
	local dtntr, randomnumber = ents.Create("nz_script_prop"), math.random( 3 )
	dtntr:SetModel( "models/props_c17/consolebox05a.mdl" )
	dtntr:SetPos( detonatorspawn[ randomnumber ].pos )
	dtntr:SetAngles( detonatorspawn[ randomnumber ].ang )
	dtntr:Spawn()
	self:RegisterEntity( dtntr )
end )
detonator:SetPickupFunction( function(self, ply, ent)
	ply:GiveCarryItem( self.id )
	ent:Remove()
end )
detonator:Update()

local chargeddetonator = nzItemCarry:CreateCategory( "charged_detonator" )
chargeddetonator:SetIcon( "spawnicons/models/props_c17/consolebox05a.png" )
chargeddetonator:SetText( "Press E to pick up the charged console box." )
chargeddetonator:SetDropOnDowned( true )
chargeddetonator:SetShowNotification( true )
chargeddetonator:SetDropFunction( function( self, ply )
	local chrgddtntr = ents.Create( "nz_script_prop" )
	chrgddtntr:SetModel( "models/props_c17/consolebox05a.mdl" )
	chrgddtntr:SetPos( ply:GetPos() )
	chrgddtntr:SetAngles( Angle( 0, 0, 0 ) )
	chrgddtntr:Spawn()
	chrgddtntr:DropToFloor()
	ply:RemoveCarryItem( "charged_detonator" )
	self:RegisterEntity( chrgddtntr )
end )
chargeddetonator:SetResetFunction( function( self )
	--//I'm not gonna have this be local
	chrgddtntr = ents.Create( "nz_script_prop" )
	chrgddtntr:SetModel( "models/props_c17/consolebox05a.mdl" )
	chrgddtntr:SetPos( Vector( -1018.099365, -1729.259888, -334.313202 ) )
	chrgddtntr:SetAngles( Angle( -90.000, 90.000, 180.000 ) )
	chrgddtntr:Spawn()
	chrgddtntr:SetNoDraw( true )
	self:RegisterEntity( chrgddtntr )
end )
chargeddetonator:SetPickupFunction( function(self, ply, ent)
	if not ent.CanPickup then return end
	ply:GiveCarryItem( self.id )
	ent:Remove()
end )
chargeddetonator:Update()

local rubber = nzItemCarry:CreateCategory( "tire" )
rubber:SetIcon( "spawnicons/.png" )
rubber:SetText( "Press E to pick up the tire." )
rubber:SetDropOnDowned( true )
rubber:SetShowNotification( true )
rubber:SetDropFunction( function( self, ply )
	local rbr = ents.Create( "nz_script_prop" )
	rbr:SetModel( "" )
	rbr:SetPos( ply:GetPos() )
	rbr:SetAngles( Angle( 0, 0, 0 ) )
	rbr:Spawn()
	rbr:DropToFloor()
	ply:RemoveCarryItem( "tire" )
	self:RegisterEntity( rbr )
end )
rubber:SetResetFunction( function( self )
	local rbr = ents.Create( "nz_script_prop" )
	rbr:SetModel( "" )
	rbr:SetPos( Vector( -1889.828125, -1512.047974, -384.140137 ) )
	rbr:SetAngles( Angle( 17.772, -19.848, -49.948 ) )
	rbr:Spawn()
	rbr:SetNoDraw( true )
	self:RegisterEntity( rbr )
end )
rubber:SetPickupFunction( function(self, ply, ent)
	if not ent.CanPickup then return end
	ply:GiveCarryItem( self.id )
	ent:Remove()
end )
rubber:Update()

local powder = nzItemCarry:CreateCategory( "nitroamine" )
powder:SetIcon( "" )
powder:SetText( "" )
powder:SetDropOnDowned( true )
powder:SetShowNotification( true )
powder:SetDropFunction( function( self, ply )

end )
powder:SetResetFunction( function( self )

end )
powder:SetPickupFunction( function( self, ply, ent )

end )
powder:Update()

local blast = nzItemCarry:CreateCategory( "blastcap" )
blast:SetIcon( "" )
blast:SetText( "" )
blast:SetDropOnDowned( true )
blast:SetShowNotification( true )
blast:SetDropFunction( function( self, ply )

end )
blast:SetResetFunction( function( self )

end )
blast:SetPickupFunction( function( self, ply, ent )

end )
blast:Update()

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

--//I use this to check and set text for the base link and the outlying links. Not super efficient, but it should be 100% consistent, whereas it wasn't before
function SetTexts()
	print( "function SetTexts called")
	if nzElec:IsOn() then
		print( "Electricity is on.")
		for k, v in pairs( links ) do
			print( "For k, v in pairs( links ), ", k, v )
			if not poweredgenerators[ k ] then
				print( "Link's room generator is not on." )
				v.ent:SetNWString( "NZText", "You must turn on the room's generator first." )
			elseif not establishedlinks[ k ] then
				print( "Link's room generator is on, outlier link has not been connected to base link." )
				if linkstarted then
					print( "Linking has been started on base link." )
					v.ent:SetNWString( "NZText", "Press E to establish a link with the home receiver." )
				else
					print( "Linking has not been started on base link." )
					v.ent:SetNWString( "NZText", "You must activate the home link first." )
				end
			else
				print( "Link's room generator is on, and the outlier link has been connect to the base link." )
				v.ent:SetNWString( "" )
			end 
		end
		print( "End of For k, v in pairs( links )" )
		if not CheckTable( establishedlinks ) then
			print( "All links have not yet been established." )
			if linkstarted then
				print( "Linking has already been started." )
				baselink:SetNWString( "" )
			else
				print( "Linking has not yet been started." )
				baselink:SetNWString( "NZText", "Press E to begin linking." )
			end
		else
			print( "All receivers have been linked." )
			baselink:SetNWString( "NZText", "All receivers have been linked." )
		end
	else
		print( "Electricity is off.")
		for k, v in pairs( links ) do
			print( "For k, v in pairs( links ), ", k, v )
			if not poweredgenerators[ k ] then
				print( "Link's room generator is not on." )
				v.ent:SetNWString( "NZText", "You must turn on the room's generator first." )
			elseif not establishedlinks[ k ] then
				print( "Link's room generator is on, but the power is off." )
				v.ent:SetNWString( "NZText", "The power must be turned on before linking." )
			else
				print( "The link has already been established." )
				v.ent:SetNWString( "" )
			end 
		end
		if not CheckTable( establishedlinks ) then
			print( "All outlier links have not been established." )
			baselink:SetNWString( "NZText", "The power must be turned on before beginning linking." )
		else
			print( "All outlier links have been established." )
			baselink:SetNWString( "NZText", "All receivers have been linked." )
		end
	end
end

--[[Nextpush is used as the logic for the the next button to be pushed, an integer seperate from buttonorder, 
	activehint is the hint entity to be electrocuted when it's respective button is to be pushed.]]
local nextpush = 1
--[[The button order will be random every time the script loads. Button order is set after all links have been activated, but hint items remains the same
	between button re-order. The hint giveaway will currently spawn on top of the link base, but can, and probably should, be randomized.
	On EE failure, ALL EE items (beside generators and music EE) will get randomized text, power is permanenetly disabled, and the game is on round infinity
	until the players "escape" via opening the garage doors after a 30 second timer upon garage door activation. This should be DIFFICULT. Should the 
	players successfully complete the buttons, they will eventually escape by running through the train tunnel (screen will fade to black and players who 
	have faded to black	will be lose zombie aggro). The quest that remains is to figure out if there should be, or what should be the step between console and escaping.]] 
function StartPuzzle()
	print( "StartPuzzle has been called" )
	print( "consolebuttons table:" )
	PrintTable( consolebuttons )
	print( "buttonorder table:" )
	PrintTable( buttonorder )
	print( "Start of \"for k, v in pairs( buttonorder ) do\"" )
	for k, v in pairs( buttonorder ) do --At this point, buttonorder is a randomized table version of consolebuttons
		print( k, v, v[ 1 ], v[ 2 ], nextpush )
		local consolebutton = ents.GetMapCreatedEntity( v[ 1 ] )
		consolebutton:SetNWString( "NZText", "Press E to activate button " .. v[ 1 ] ) -- consolebuttons[ table.KeyFromValue( buttonorder, v[ 1 ] ) ] )
		consolebutton.OnUsed = function()
			print( "console button " .. v[ 1 ] .. " pushed" )
			if not nzElec:IsOn() then return end
			consolebutton:EmitSound( "buttons/button9.wav" )--TO DO: find a button pushing sound in gmod/hl2
			--//You can push a button more than once, and it can fail the EE. This is a "feature," not a bug.
			if k == nextpush then
				print( "The correct button was pushed. Debug: ", k, nextpush )
				nextpush = nextpush + 1
			else
				print( "The wrong button was pushed. Debug: ", k, nextpush )
				FailPrimaryEE()
				nextpush = 0
			end
		end
		local effecttimer = 0
		v[ 2 ].Think = function()
			if k == nextpush and effecttimer < CurTime() then
				local effect = EffectData()
				effect:SetScale( 1 )
				effect:SetEntity( v[ 2 ] )
				util.Effect( "lightning_aura", effect )
				effecttimer = CurTime() + 0.5
			end
		end
	end
end

local availabletext = { "A", "a", "B", "b", "C", "c", "D", "d", "E", "e", "F", "f", "G", "g", "H", "h", "I", "i", "J", "j", "K", "k", "L", "l", "M", "m",
						"N", "n", "O", "o", "P", "p", "Q", "q", "R", "r", "S", "s", "T", "t", "U", "u", "V", "v", "W", "w", "X", "x", "Y", "y", "Z", "z",
						"!", "%", "ERROR", "*", "&", "SELF-DESTRUCT", "ESCAPE", "#", "SYSTEM", "POWER", "OFF", "ON", "HUMANOID", "METRO", " ", "ENTER", "EXIT",
						"ASCEND_FROM_DARKNESS", "SAMANTHA", "FAILURE", "EVACUATE", "115", "ELEMENT", "CRITICAL", "-", "_" } --Can we add more Nazi Zombie easter egg sayings?
local PermaOff
function FailPrimaryEE()
	nzElec:Reset()
	PermaOff = true
	local mixedtext = ""
	for k, v in pairs( player.GetAll() ) do
		v:SendLua( "surface.PlaySound( \"ambient/levels/labs/electric_explosion4.wav\" ) " )
	end
	--//All link outliers
	for k, v in pairs( links ) do
		for i = 1, 6 do
			mixedtext = mixedtext .. table.Random( availabletext )
		end
		v.ent:EmitSound( "ambient/energy/zap5.wav" )
		v.ent:SetNWString( "NZText", mixedtext )
		mixedtext = ""
		v.ent.OnUsed = function()
			return false
		end
	end
	--//All console buttons
	for k, v in pairs( consolebuttons ) do
		local consolebutton = ents.GetMapCreatedEntity( v )
		for i = 1, 6 do
			mixedtext = mixedtext .. table.Random( availabletext )
		end
		consolebutton:EmitSound( "ambient/energy/zap5.wav" )
		consolebutton:SetNWString( "NZText", mixedtext )
		mixedtext = ""
		consolebutton.OnUsed = function()
			return false
		end
	end
	for i = 1, 6 do
	mixedtext = mixedtext .. table.Random( availabletext )
	end
	baselink:EmitSound( "ambient/energy/zap5.wav" )
	baselink:SetNWString( "NZText", mixedtext )
	mixedtext = ""
	baselink.OnUsed = function()
		return false
	end
end

function mapscript.OnGameBegin()
	--//Generates the random list of console buttons and their prop hint entity
	local fakelist = table.Copy( consolebuttons )
	for i = 1, #fakelist do
		local choice = table.Random( fakelist )
		table.insert( buttonorder, { choice, prophints[ table.KeyFromValue( consolebuttons, choice ) ] } )
		table.RemoveByValue( fakelist, choice )
	end
	
	--//Build Table Info Continued
	local tbl = ents.Create( "buildable_table" )
	tbl:AddValidCraft( "Plastic Explosive", buildabletbl )
	tbl:SetPos( Vector( -1384.457886, 971.894897, -184.897278 ) )
	tbl:SetAngles( Angle( 0.000, -90.000, 0.000 ) )
	tbl:Spawn()

	--//Creates the broken power switch
	powerswitch = ents.Create( "nz_script_prop" )
	powerswitch:SetPos( Vector( 109.952400, -1472.475220, 107.462799 ) )
	powerswitch:SetAngles( Angle( -0.000, -90.000, 0.000 ) )
	powerswitch:SetModel( "models/nzprops/zombies_power_lever.mdl" ) 
	powerswitch:SetNWString( "NZText", "You must fix the power switch before turning on the power." )
	powerswitch:SetNWString( "NZRequiredItem", "lever" )
	powerswitch:SetNWString( "NZHasText", "Press E to attach the lever onto the power switch." )
	powerswitch:Spawn()
	powerswitch:Activate()
	powerswitch.OnUsed = function( self, ply )
		if not ply:HasCarryItem( "lever" ) then return end
		local actualpowerswitch, initialstart, effecttimer2 = ents.Create( "power_box" ), false, 0
		actualpowerswitch:SetPos( self:GetPos() )
		actualpowerswitch:SetAngles( self:GetAngles() )
		actualpowerswitch.OnUsed = function( self, ply )
			if initialstart then
				return false
			end
			initialstart = true
			--The power switch should only be used once, and un-reactivatable, so power remains off during rounds it turns off
		end
		--//If the power is off after being turned on, play the lightning aura effect to indicate power shortaging
		actualpowerswitch.Think = function( )
			if initialstart and CurTime() > effecttimer2 and not nzElec.IsOn() then
				local effect = EffectData()
				effect:SetScale( 1 )
				effect:SetEntity( actualpowerswitch )
				util.Effect( "lightning_aura", effect )
				effecttimer2 = CurTime() + 0.5
			end
		end
		timer.Simple( 0.1, function()
			actualpowerswitch:Spawn()
			actualpowerswitch:SetNWString( "NZText", "There's no certainty power will remain on..." )
			powerswitch:Remove()
			ply:RemoveCarryItem( "lever" )
		end )
	end

	--//The base link the must be pushed before pushing an outlying link
	baselink = ents.Create( "nz_script_prop" )
	baselink:SetPos( Vector( -580.019531, -1488.002930, 143.345886 ) )
	baselink:SetAngles( Angle( 0.008, -85.925, -0.133 ) )
	baselink:SetModel( "models/props_lab/reciever_cart.mdl" )
	baselink:SetNWString( "NZText", "The power must be turned on before starting the linking." )
	baselink:Spawn()
	baselink:Activate()
	baselink.OnUsed = function( self, ply )
		--//If electricity is on, link isn't currently activated, and not all of the links are established, then...
		if not nzElec.IsOn() or linkstarted or CheckTable( establishedlinks ) then return end 
		linkstarted = true
		SetTexts()
	end
	local effecttimer, stop = 0, false
	baselink.Think = function()
		if linkstarted and CurTime() > effecttimer and nzElec.IsOn() or CheckTable( establishedlinks ) and nzElec.IsOn() then
			local effect = EffectData()
			effect:SetScale( 1 )
			effect:SetEntity( baselink )
			util.Effect( "lightning_aura", effect )
			effecttimer = CurTime() + 0.5
		end
	end

	--//These are just extra entities placed inside the link base to make it more aestheticly pleasing
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
				gen:EmitSound( "player/items/gas_can_fill_pour_01.wav" ) --gen:EmitSound( "l4d2/gas_pour.wav" )
				--Plays the generator fueling and generator humming sounds
				timer.Simple( 4, function()
					if not gen then return end
					gen:EmitSound( "level/generator_start_loop.wav" ) --gen:EmitSound( "l4d2/generator_start.wav" )
					timer.Simple( 9, function()
						timer.Create( "Gen" .. k, 3, 0, function()
							if not gen then return end
							gen:EmitSound( "l4d2/generator_humm.ogg" )
						end )
					end )
				end )
				SetTexts()
			end
		end
		gen.Think = function()
			--If a new script is loaded, destory the generator humming sounds
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
		link:SetNWString( "NZText", "The room's generator must be powered on first." )
		link:Spawn()
		link:Activate()
		link.OnUsed = function( self, ply )
			if not linkstarted or establishedlinks[ k ] or not poweredgenerators[ k ] or not nzElec.IsOn() then return end --If linkstarted is true, the link hasn't yet been established, and it's respective generator is on
			PrintMessage( HUD_PRINTTALK, "Link " .. k .. " has been activated." )
			linkstarted = false
			establishedlinks[ k ] = true
			link:EmitSound( "ambient/machines/teleport1.wav" )
			lights1[ k ].ent:SetModel( "models/props_c17/light_cagelight02_on.mdl" )
			lights2[ k ].ent:SetModel( "models/props_c17/light_cagelight02_on.mdl" )
			SetTexts()
			if CheckTable( establishedlinks ) then
				StartPuzzle() --Should this be an EE step function? - Probably
			end
		end
		local effecttimer2 = 0
	end

	for k, v in pairs( lights1 ) do
		local light = ents.Create( "nz_script_prop" )
		v.ent = light
		light:SetPos( v.pos )
		light:SetAngles( v.ang )
		light:SetModel( "models/props_c17/light_cagelight02_off.mdl" )
	end

	for k, v in pairs( lights2 ) do
		local light = ents.Create( "nz_script_prop" )
		v.ent = light
		light:SetPos( v.pos )
		light:SetAngles( v.ang )
		light:SetModel( "models/props_c17/light_cagelight02_off.mdl" )
	end

	soulcatcher = ents.Create( "nz_script_soulcatcher" )
	soulcatcher:SetPos( Vector( -1013.565002, -1750.850830, -392.342163 ) )
	soulcatcher:SetAngles( Angle( -0.000, -0.000, 0.000 ) )
	soulcatcher:SetModel( "models/props_vehicles/generatortrailer01.mdl" )
	soulcatcher:SetNWString( "NZText", "Use this generator to charge something." )
	soulcatcher:SetNWString( "NZRequiredItem", "detonator" )
	soulcatcher:SetNWString( "NZHasText", "Press E to place and charge the console box battery." )
	soulcatcher:Spawn()
	soulcatcher:Activate()
	soulcatcher:SetRange( 500 )
	soulcatcher:SetTargetAmount( 30 )
	soulcatcher:SetCondition( function( self, z, dmg )
    	return soulcatcher.AllowSouls
	end)
	soulcatcher:Reset()
	chrgddtntr:SetNWString( "NZText", "" )
	soulcatcher.OnUsed = function( self, ply )
		if ply:HasCarryItem( "detonator" ) then
			soulcatcher.AllowSouls = true
			ply:RemoveCarryItem( "detonator" )
			chrgddtntr:SetNoDraw( false )
			chrgddtntr:SetNWString( "NZText", "" )
			soulcatcher:SetNWString( "NZText", "Kill zombies near this generator to charge the console box battery." )
			soulcatcher:SetNWString( "NZHasText", "Kill zombies near this generator to charge the console box battery." )
		end
	end
	soulcatcher:SetCompleteFunction( function( self )
		soulcatcher.AllowSouls = false
		chrgddtntr.CanPickup = true
		chrgddtntr:SetNWString( "NZText", "Press E to pick up the charged console box." )
	end )

	gascans:Reset()
	lever:Reset()
	detonator:Reset()
	chargeddetonator:Reset()

	--//Fixes the bugged doorways
    local shittodelete = { 2169, 1858, 2959, 2465, 1921, 1918, 1939, 2209, 1976, 1973, 2373 } --, 2518 } the culprit
	for k, v in pairs( shittodelete ) do
		ents.GetMapCreatedEntity( v ):Fire( "Open" )
		timer.Simple( 0.2, function()
			ents.GetMapCreatedEntity( v ):Remove()
		end )
	end
end

local initialactivation = false
function mapscript.ElectricityOn()
	--//Because this function will run whenever the power is turned back on, we have to run checks
	SetTexts()
	--//Only run this the first time; logic for 2nd activation and onward is done below
	if initialactivation then return end
	for k, v in pairs( lights1 ) do
		v.ent:SetModel( "models/props_c17/light_cagelight01_on.mdl" )
	end
	for k, v in pairs( lights2 ) do
		v.ent:SetModel( "models/props_c17/light_cagelight01_on.mdl" )
	end
	initialactivation = true
end

function mapscript.ElectricityOff()
	--//Of course, when the electricity turns off, the lights must turn off
	for k, v in pairs( lights1 ) do
		v.ent:SetModel( "models/props_c17/light_cagelight02_off.mdl" )
	end
	for k, v in pairs( lights2 ) do
		v.ent:SetModel( "models/props_c17/light_cagelight02_off.mdl" )
	end
end

local chance, turnoff, propinfo = math.Clamp( 1, 1, 5 ), { }, { }
function mapscript.OnRoundStart()
	if PermaOff then
		if nzElec:IsOn() then
			nzElec:Reset()
			return
		end
	end
	if initialactivation then --Only if power has been activated once, and the EE hasn't failed, should we check to turn power on or off
		--[[By default, there is a 1 and 5 chance (20%) the power will turn off (or stay off) for any given round AFTER the electricity has been turn on. For every round the power DOESN'T
		turn off, the chance increases by an additional 20% until the power WILL turn off. This is some form of pseudo-randomness. I might make the chance smaller if it's too obtrusive.]]
		for i = 1, 5 - chance do 
			turnoff[ i ] = false
		end
		for i = 6 - chance, 5 do
			turnoff[ i ] = true
		end
		--//Power on/off logic ahead
		if turnoff[ math.random( 1, #turnoff ) ] then
			--//If the electricity is on, save the light colors, turn the power off, check link text, then reset power failure chance
			if nzElec.IsOn() then
				for k, v in pairs( lights1 ) do
					table.insert( propinfo, v.ent:GetModel() )
				end
				for k, v in pairs( lights2 ) do
					table.insert( propinfo, v.ent:GetModel() )
				end
				nzElec:Reset()
				SetTexts()
			end
			chance = 1
		else
			--//If the electricity is off, turn it on, set the light colors, then increase power failure chance
			if not nzElec.IsOn() then
				nzElec:Activate()
				for k, v in pairs( lights1 ) do
					v.ent:SetModel( propinfo[ k ] )
				end
				for k, v in pairs( lights2 ) do
					v.ent:SetModel( propinfo[ 5 + k ] )
				end
				propinfo = { }
			end
			chance = chance + 1
		end
	end
end

return mapscript
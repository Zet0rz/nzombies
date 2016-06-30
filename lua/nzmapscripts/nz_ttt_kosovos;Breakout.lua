local mapscript = {}

local scriptgascanpositions = {
	{pos = Vector(4275, -1381, 39), ang = Angle(0, 0, 0)},
	{pos = Vector(3507, -1311, 38), ang = Angle(0, 0, 0)},
	{pos = Vector(4274, -697, 39), ang = Angle(0, -2, 0)},
	{pos = Vector(4041, -515, 167), ang = Angle(0, 2, 0)},
	{pos = Vector(4244, -1278, 165), ang = Angle(0, 2, 0)},
	{pos = Vector(4311, -477, 172), ang = Angle(0, 1, 0)},
	{pos = Vector(4887, -249, 172), ang = Angle(0, -2, 0)},
	{pos = Vector(4955, 87, 171), ang = Angle(0, -1, 0)},
	{pos = Vector(4485, -4, 173), ang = Angle(0, 13, 0)},
	{pos = Vector(4203, 231, 175), ang = Angle(0, -91, 0)},
	{pos = Vector(4024, 669, 173), ang = Angle(0, 3, 0)},
	{pos = Vector(3978, 707, 175), ang = Angle(0, -91, 0)},
	{pos = Vector(3527, 983, 173), ang = Angle(0, 42, 0)},
	{pos = Vector(3278, 635, 245), ang = Angle(90, -150, 180)},
	{pos = Vector(3820, 159, 214), ang = Angle(0, -40, 0)},
	{pos = Vector(3618, 308, 174), ang = Angle(90, -132, 180)},
	{pos = Vector(3413, -199, 15), ang = Angle(0, 3, 0)},
	{pos = Vector(3636, 93, 150), ang = Angle(0, -86, 0)},
}

local scriptscriptgenerator
local scriptscriptgascan
local hasscriptgascan = false
local scripthasusedelev = false
local scriptnextexpltime

local ee_cabinet
local ee_lock
local ee_bat_place
local ee_bat_charging

local gascanobject = nzItemCarry:CreateCategory("gascan")
gascanobject:SetIcon("spawnicons/models/props_junk/gascan001a.png")
gascanobject:SetText("Press E to pick up the Gas Can.")
gascanobject:SetDropOnDowned(true)

gascanobject:SetDropFunction( function(self, ply)
	if IsValid(scriptgascan) then scriptgascan:Remove() end
	scriptgascan = ents.Create("nz_script_prop")
	scriptgascan:SetModel("models/props_junk/gascan001a.mdl")
	scriptgascan:SetPos(ply:GetPos())
	scriptgascan:SetAngles(Angle(0,0,0))
	scriptgascan:Spawn()
	self:RegisterEntity( scriptgascan )
end)

gascanobject:SetResetFunction( function(self)
	hasscriptgascan = false
	if IsValid(scriptgascan) then scriptgascan:Remove() end
	local ran = scriptgascanpositions[math.random(table.Count(scriptgascanpositions))]
	if ran and ran.pos and ran.ang then
		scriptgascan = ents.Create("nz_script_prop")
		scriptgascan:SetModel("models/props_junk/gascan001a.mdl")
		scriptgascan:SetPos(ran.pos)
		scriptgascan:SetAngles(ran.ang)
		scriptgascan:Spawn()
		self:RegisterEntity( scriptgascan )
	end
end)

gascanobject:SetPickupFunction( function(self, ply, ent)
	hasscriptgascan = true
	ply:GiveCarryItem(self.id)
	ent:Remove()
end)

-- Call this to update the info to clients!
gascanobject:Update()

-- Time to create the Easter Egg! Warning: This may spoil the steps!

local keyobject = nzItemCarry:CreateCategory("ee_key")
keyobject:SetIcon("icon16/key.png")
keyobject:SetText("Press E to pick up the Key.")
keyobject:SetDropOnDowned(false)
keyobject:SetResetFunction( function(self)
	local key = ents.Create("nz_prop_effect")
	key:SetModel("models/lostcoast/fisherman/keys.mdl")
	key:SetPos(Vector(2330, 1432, -1646))
	key:SetAngles(Angle(0, 52, 90))
	--key:PhysicsInitSphere(5, "metal")
	--key:SetSolid(SOLID_OBB)
	key:Spawn()
	self:RegisterEntity(key)
end)
keyobject:Update()

local batteryobject = nzItemCarry:CreateCategory("ee_battery")
batteryobject:SetIcon("spawnicons/models/items/car_battery01.png")
batteryobject:SetText("Press E to pick up the Battery.")
batteryobject:SetDropOnDowned(true)
batteryobject:SetResetFunction( function(self)
	local bat = ents.Create("nz_script_prop")
	bat:SetModel("models/items/car_battery01.mdl")
	bat:SetPos(Vector(4162, 674, 167))
	bat:SetAngles(Angle(0, 90, 0))
	bat:Spawn()
	self:RegisterEntity(bat)
end)
batteryobject:SetDropFunction( function(self, ply)
	local bat = ents.Create("nz_script_prop")
	bat:SetModel("models/items/car_battery01.mdl")
	bat:SetPos(ply:GetPos() + Vector(0,0,5))
	bat:SetAngles(Angle(0, 90, 0))
	bat:Spawn()
	self:RegisterEntity(bat)
end)
batteryobject:SetPickupFunction( function(self, ply, ent)
	ply:GiveCarryItem(self.id)
	nzEE.Major:CompleteStep(2)
	ent:Remove()
end)
batteryobject:SetCondition( function()
	return nzEE.Major.CurrentStep >= 1 -- Can only be picked up during at Step 1 or higher
end)
batteryobject:Update()

local chargedbatteryobject = nzItemCarry:CreateCategory("ee_chargedbattery")
chargedbatteryobject:SetIcon("spawnicons/models/items/car_battery01.png")
chargedbatteryobject:SetText("Press E to pick up the Charged Battery.")
chargedbatteryobject:SetDropOnDowned(true)
chargedbatteryobject:SetResetFunction( function(self)
	local bat = ents.Create("nz_script_prop")
	bat:SetModel("models/items/car_battery01.mdl")
	bat:SetPos(Vector(4162, 674, 167))
	bat:SetAngles(Angle(0, 90, 0))
	bat:Spawn()
	batteryobject:RegisterEntity(bat) -- Reset it to non-charged
end)
chargedbatteryobject:SetDropFunction( function(self, ply)
	local bat = ents.Create("nz_script_prop")
	bat:SetModel("models/items/car_battery01.mdl")
	bat:SetPos(ply:GetPos() + Vector(0,0,5))
	bat:SetAngles(Angle(0, 90, 0))
	bat:Spawn()
	self:RegisterEntity(bat) -- Dropping it is still charged
end)
chargedbatteryobject:SetCondition( function()
	return nzEE.Major.CurrentStep >= 2 -- Can only be picked up during at Step 2 or higher
end)
chargedbatteryobject:Update()


nzEE.Major:AddStep( function()
	-- Add unlock sound here
end)

nzEE.Major:AddStep( function() -- Creates ghost charger that can charge the battery and return ee_chargedbattery
	ee_bat_place = ents.Create("nz_script_prop")
	ee_bat_place:SetModel("models/items/car_battery01.mdl")
	ee_bat_place:SetPos(Vector(5386, -1079, -58))
	ee_bat_place:SetAngles(Angle(-10, 0, 0))
	ee_bat_place.OnUsed = function(self, ply)
		if ply:HasCarryItem("ee_battery") then
			ply:RemoveCarryItem("ee_battery")
			ee_bat_charging = ents.Create("nz_script_soulcatcher")
			ee_bat_charging:SetModel(self:GetModel())
			ee_bat_charging:SetPos(self:GetPos())
			ee_bat_charging:SetAngles(self:GetAngles())
			ee_bat_charging:Spawn() -- Spawn before setting variables or they'll become the default
			ee_bat_charging:SetTargetAmount(10)
			ee_bat_charging:SetRange(200)
			ee_bat_charging:SetReleaseOverride( function(self2, z)
				--print(self2.CurrentAmount)
				if self2.CurrentAmount >= self2.TargetAmount then return end
				--print("Passing")
				local e = EffectData()
				e:SetOrigin(self2:GetPos())
				e:SetStart(z:GetPos())
				e:SetMagnitude(0.3)
				util.Effect("lightning_strike", e)
				self2.CurrentAmount = self2.CurrentAmount + 1
				--print(self2.CurrentAmount)
				self2:CollectSoul() -- Updates and triggers when to complete it
				-- CollectSoul is normally called in the standard effect when the soul gets to the collector
			end)
			ee_bat_charging:SetCompleteFunction( function(self3)
				local chgbat = ents.Create("nz_script_prop")
				chgbat:SetModel(self3:GetModel())
				chgbat:SetPos(self3:GetPos())
				chgbat:SetAngles(self3:GetAngles())
				chgbat:Spawn()
				chargedbatteryobject:RegisterEntity(chgbat)
				self3:Remove()
				--print("Done!")
			end)
			ee_bat_charging:SetCondition( function(self4, z, dmg)
				--print(dmg:GetDamageType(), z, self4, dmg)
				return dmg:GetDamageType() == DMG_SHOCK -- Only allow electric kills
			end)
			self:Remove()
		end
	end
	ee_bat_place:Spawn()
	ee_bat_place:SetColor(Color(255,255,255,30))
	ee_bat_place:SetRenderMode(RENDERMODE_TRANSCOLOR)
end)

local propcolors = {
	[1] = "models/props_lab/tpplug.mdl", -- Blue plug
	[2] = "models/weapons/w_ammobox_thrown.mdl", -- Green ammo case
	[3] = "models/props_mining/freightelevatorbutton02.mdl", -- Yellow button
	[4] = "models/props_c17/light_cagelight01_off.mdl", -- Red light
}
local colorprops = { -- Table indexes all possible random locations for props
	[1] = { -- Key indicates the color
		[1] = { -- This key indicates what row these positions are on
			{pos = Vector(2391, -1727, -142), ang = Angle(19, 70, 42)},
			{pos = Vector(2385, -1926, -185), ang = Angle(19, 48, -44)},
			{pos = Vector(2383, -2040, -142), ang = Angle(19, 52, -44)},
		},
		[2] = {
			{pos = Vector(2233, -1771, -142), ang = Angle(19, -29, 45)},
			{pos = Vector(2236, -2045, -185), ang = Angle(19, -37, -45)},
		},
		[3] = {
			{pos = Vector(2033, -2094, -144), ang = Angle(0, 34, -2)},
			{pos = Vector(2027, -2085, -186), ang = Angle(0, -35, -2)},
			{pos = Vector(2044, -1714, -185), ang = Angle(19, -30, -45)},
		},
		[4] = {
			{pos = Vector(1874, -2081, -144), ang = Angle(0, -43, -3)},
			{pos = Vector(1873, -1884, -144), ang = Angle(0, 54, -1)},
			{pos = Vector(1884, -1775, -187), ang = Angle(0, 56, 1)},
		},
	},
	[2] = {
		[1] = {
			{pos = Vector(2397, -1713, -185), ang = Angle(0, 48, 0)},
			{pos = Vector(2383, -1727, -142), ang = Angle(0, 101, 1)},
			{pos = Vector(2381, -1921, -185), ang = Angle(0, 57, 0)},
			{pos = Vector(2379, -2068, -100), ang = Angle(0, 57, -1)},
		},
		[2] = {
			{pos = Vector(2257, -2087, -185), ang = Angle(0, 103, 0)},
			{pos = Vector(2244, -1746, -99), ang = Angle(0, 137, 0)},
		},
		[3] = {
			{pos = Vector(2034, -1723, -185), ang = Angle(0, 123, -1)},
			{pos = Vector(2047, -2091, -142), ang = Angle(0, -158, 0)},
			{pos = Vector(2048, -2097, -185), ang = Angle(0, -152, -1)},
			{pos = Vector(2045, -2024, -185), ang = Angle(0, -173, 0)},
		},
		[4] = {
			{pos = Vector(1873, -1774, -185), ang = Angle(0, -126, 0)},
			{pos = Vector(1894, -1901, -100), ang = Angle(0, -81, 0)},
			{pos = Vector(1886, -2089, -142), ang = Angle(0, -94, 0)},
		},
	},
	[3] = {
		[1] = {
			{pos = Vector(2386, -1719, -147), ang = Angle(-89, -47, -80)},
			{pos = Vector(2388, -2036, -148), ang = Angle(-89, 150, 89)},
		},
		[2] = {
			{pos = Vector(2245, -2040, -191), ang = Angle(-89, -43, 90)},
			{pos = Vector(2226, -1766, -148), ang = Angle(-90, -58, -1)},
		},
		[3] = {
			{pos = Vector(2058, -2088, -147), ang = Angle(-90, -159, 180)},
			{pos = Vector(2050, -1727, -191), ang = Angle(-90, -38, 0)},
		},
		[4] = {
			{pos = Vector(1904, -2081, -148), ang = Angle(-89, -18, 68)},
			{pos = Vector(1880, -1892, -147), ang = Angle(-89, 85, -135)},
			{pos = Vector(1892, -1768, -190), ang = Angle(-90, 133, 180)},
		},
	},
	[4] = {
		[1] = {
			{pos = Vector(2385, -1716, -146), ang = Angle(0, -38, -90)},
			{pos = Vector(2378, -1896, -101), ang = Angle(0, -85, -90)},
			{pos = Vector(2385, -2039, -145), ang = Angle(0, 2, -90)},
		},
		[2] = {
			{pos = Vector(2264, -2137, -190), ang = Angle(0, 166, -90)},
			{pos = Vector(2247, -2022, -146), ang = Angle(0, 70, -90)},
			{pos = Vector(2245, -1789, -145), ang = Angle(0, 131, -90)},
		},
		[3] = {
			{pos = Vector(2042, -2083, -145), ang = Angle(0, 30, -88)},
			{pos = Vector(2039, -1709, -187), ang = Angle(0, 47, 88)},
		},
		[4] = {
			{pos = Vector(1875, -2094, -144), ang = Angle(0, 9, 93)},
			{pos = Vector(1879, -1879, -146), ang = Angle(0, -71, 93)},
			{pos = Vector(1873, -1769, -190), ang = Angle(0, -18, 93)},
		},
	},
}
local countprops = {
	[1] = { -- This shows the row
		[1] = { -- This is the number of prop
			model = "models/items/boxmrounds.mdl",
			pos = Vector(2370, -1315, -196),
			ang = Angle(-1, 26, 0),
		},
		[2] = {
			model = "models/items/boxsrounds.mdl",
			pos = Vector(2361, -1324, -196), 
			ang = Angle(1, 28, 0),
		},
		[3] = {
			model = "models/items/boxmrounds.mdl",
			pos = Vector(2346, -1312, -196), 
			ang = Angle(0, -14, -1),
		},
		[4] = {
			model = "models/items/357ammobox.mdl",
			pos = Vector(2380, -1329, -196),
			ang = Angle(2, -43, 0)
		},
	},
	[2] = {
		[1] = {
			model = "models/items/ammocrate_ar2.mdl",
			pos = Vector(2137, -1290, -180),
			ang = Angle(0, -84, 0),
		},
		[2] = {
			model = "models/items/boxmrounds.mdl",
			pos = Vector(2122, -1320, -196),
			ang = Angle(0, -25, 0),
		},
		[3] = {
			model = "models/items/boxsrounds.mdl",
			pos = Vector(2141, -1310, -196),
			ang = Angle(1, 88, 1),
		},
		[4] = {
			model = "models/items/boxbuckshot.mdl",
			pos = Vector(2137, -1322, -196), 
			ang = Angle(0, -68, 0)
		},
	},
	[3] = {
		[1] = {
			model = "models/items/boxmrounds.mdl",
			pos = Vector(1917, -1288, -196),
			ang = Angle(0, -69, 0)
		},
		[2] = {
			model = "models/items/boxmrounds.mdl",
			pos = Vector(1897, -1288, -196),
			ang = Angle(0, -31, 0)
		},
		[3] = {
			model = "models/items/boxmrounds.mdl",
			pos = Vector(1937, -1282, -196),
			ang = Angle(0, 49, 0)
		},
		[4] = {
			model = "models/items/boxsrounds.mdl",
			pos = Vector(1905, -1302, -196),
			ang = Angle(0, -87, 0)
		},
	},
	[4] = {
		[1] = {
			model = "models/items/boxmrounds.mdl",
			pos = Vector(1930, -1582, -164),
			ang = Angle(0, 59, 0)
		},
		[2] = {
			model = "models/items/boxsrounds.mdl",
			pos = Vector(1902, -1580, -164),
			ang = Angle(-1, 124, 0)
		},
		[3] = {
			model = "models/items/357ammobox.mdl",
			pos = Vector(1930, -1572, -189),
			ang = Angle(0, 114, 0)
		},
		[4] = {
			model = "models/items/boxbuckshot.mdl",
			pos = Vector(1910, -1581, -139),
			ang = Angle(0, 68, 0)
		},
	}
}

function mapscript.ScriptLoad()
end

local ee_buttons = {
	{pos = Vector(3776, -1482, 83), ang = Angle(9, 92, 0)},
	{pos = Vector(4913, -2115, 22), ang = Angle(0, 90, 0)},
	{pos = Vector(3102, 216, 62), ang = Angle(0, 90, 0)},
	{pos = Vector(3248, 697, 213), ang = Angle(0, 0, 0)},
	{pos = Vector(4232, 682, 218), ang = Angle(0, -90, 0)},
	{pos = Vector(4448, -720, 215), ang = Angle(0, 90, 0)},
}
local ee_actualbuttons = {}
local curbuttoncount = 0

local function RandomizeButtonOrders()
	
end

-- Remove props and stuff on spawn
local function CleanUpMapScriptStuff()
	if IsValid(scriptgenerator) then scriptgenerator:Remove() end
	if IsValid(scriptgascan) then scriptgascan:Remove() end
	scriptgenerator = nil
	scriptgaspositions = nil
	scriptgascan = nil
	hasscriptgascan = nil
	for k,v in pairs(ee_actualbuttons) do
		if IsValid(v) then
			v:Remove()
		end
		ee_actualbuttons[k] = nil
	end
end

function mapscript.OnGameBegin()
	CleanUpMapScriptStuff() -- Clean up the entities from previous games if they exist
	local button = ents.FindByName("ele_call_down")[1]
	button:Fire("Press") -- Call the elevator down to begin with
	
	local button2 = ents.FindByName("ele_button_1")[1]
	button2.OnUsed = function(self)
		if !scripthasusedelev then
			scripthasusedelev = true
			scriptgenerator:SetNWString("NZText", "The Elevator is currently on a lower floor.")
			local ent = ents.FindByName("alarm_obj")[1]
			timer.Simple(50, function()
				ent:Fire("PlaySound")
			end)
			timer.Simple(60, function()
				ent:Fire("StopSound")
				scripthasusedelev = false
				scriptgenerator:SetNWString("NZText", "You need a Gas Can to power the Elevator.")
				for k,v in pairs(player.GetAllPlaying()) do
					local pos = v:GetPos()
					if pos.z < -1000 then
						local e = EffectData()
						e:SetOrigin(v:GetPos())
						e:SetEntity(v)
						e:SetMagnitude(2)
						util.Effect("lightning_prespawn", e)
						local spawn = ents.FindByClass("player_spawns")[v:EntIndex()]
						e = EffectData()
						e:SetOrigin(spawn:GetPos())
						e:SetEntity(nil)
						util.Effect("lightning_prespawn", e)
					end
				end
				timer.Simple(2, function()
					for k,v in pairs(player.GetAllPlaying()) do
						local pos = v:GetPos()
						if pos.z < -1000 then
							local e = EffectData()
							e:SetOrigin(pos)
							e:SetMagnitude(0.75)
							util.Effect("lightning_strike", e)
							local spawnpos = ents.FindByClass("player_spawns")[v:EntIndex()]:GetPos()
							e = EffectData()
							e:SetOrigin(spawnpos)
							e:SetMagnitude(0.75)
							util.Effect("lightning_strike", e)
							v:SetPos(spawnpos)
						end
					end
				end)
			end)
		end
	end
	
	local button3 = ents.FindByName("ele_button_7")[1]
	
	scriptgenerator = ents.Create("nz_script_prop")
	scriptgenerator:SetPos(Vector(3275, -254, -275))
	scriptgenerator:SetAngles(Angle(0, 90, 0))
	scriptgenerator:SetModel("models/props_vehicles/generatortrailer01.mdl")
	scriptgenerator:SetNWString("NZText", "You need a Gas Can to power the Elevator.")
	scriptgenerator:SetNWString("NZRequiredItem", "gascan")
	scriptgenerator:SetNWString("NZHasText", "Press E to fuel the Generator with a Gas Can.")
	scriptgenerator:Spawn()
	scriptgenerator:Activate()
	-- Function when it is used (E)
	scriptgenerator.OnUsed = function( self, ply )
		if ply:HasCarryItem("gascan") then -- Only if we picked up the gascan
			hasscriptgascan = false -- Reset gascan status
			ply:RemoveCarryItem("gascan")
			if button3:GetPos().z < -1000 then
				button3:Fire("Unlock") -- Call the elevator up
				button3:Fire("Press")
				scriptgenerator:SetNWString("NZText", "The Elevator is on its way up.") -- Update text
			end
		end
	end
	
	local door = ents.GetMapCreatedEntity(1836)
	if IsValid(door) then door:SetNWString("NZText", "You need to disable the security system.") end
	
	for k,v in pairs(ents.FindInSphere(Vector(3315, -1280, 55), 10)) do
		if v:GetClass() == "prop_buys" then v:BlockUnlock() end
	end
	
	keyobject:Reset()
	
	ee_cabinet = ents.Create("nz_script_prop")
	ee_cabinet:SetModel("models/props_c17/fence01b.mdl")
	ee_cabinet:SetPos(Vector(4163, 661, 135))
	ee_cabinet:SetAngles(Angle(0,90,0))
	ee_cabinet:Spawn()
	
	ee_lock = ents.Create("nz_script_prop")
	ee_lock:SetModel("models/props_wasteland/prison_padlock001a.mdl")
	ee_lock:SetPos(Vector(4126, 659, 171))
	ee_lock:SetAngles(Angle(0,-90,0))
	ee_lock:SetNWString("NZText", "You need a Key.")
	ee_lock:SetNWString("NZRequiredItem", "ee_key")
	ee_lock:SetNWString("NZHasText", "Press E to unlock.")
	ee_lock.OnUsed = function(self, ply)
		if ply:HasCarryItem("ee_key") then
			ply:RemoveCarryItem("ee_key")
			ee_cabinet:Remove()
			ee_lock:Remove()
			nzEE.Major:CompleteStep(1)
		end
	end
	ee_lock:Spawn()
	
	batteryobject:Reset()
	
	for k,v in pairs(ee_buttons) do
		local button = ents.Create("nz_script_prop")
		button:SetModel("models/props_lab/keypad.mdl")
		button:SetPos(v.pos)
		button:SetAngles(v.ang)
		table.insert(ee_actualbuttons, button)
	end
end

function mapscript.PostCleanupMap()
	--print("Things")
end

-- This one will be called at the start of each round
function mapscript.OnRoundStart()
	if !IsValid(scriptgascan) and !hasscriptgascan and !scripthasusedelev then
		gascanobject:Reset() -- Makes it respawn
	end
end

-- Will be called every second if a round is in progress (zombies are alive)
function mapscript.RoundThink()

end

-- Will be called after each round
function mapscript.RoundEnd()

end

-- Cleanup
function mapscript.ScriptUnload()
	CleanUpMapScriptStuff()
	
end

-- Only functions will be hooked, meaning you can safely store data as well
mapscript.TestPrint = "v0.0"
local testprint2 = "This is cool" -- You can also store the data locally

-- Always return the mapscript table. This gives it on to the gamemode so it can use it.
return mapscript

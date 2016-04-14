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

local gascanobject = ItemCarry:CreateCategory("gascan")
gascanobject:SetIcon("spawnicons/models/props_junk/gascan001a.png")
gascanobject:SetText("Press E to pick up Gas Can.")
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

function mapscript.ScriptLoad()
end


function mapscript.OnGameBegin()
	mapscript.ScriptUnload() -- Clean up the entities from previous games if they exist
	local button = ents.FindByName("ele_call_down")[1]
	button:Fire("Press") -- Call the elevator down to begin with
	
	local button2 = ents.FindByName("ele_button_1")[1]
	button2.OnUsed = function(self)
		if !scripthasusedelev then
			scripthasusedelev = true
			scriptgenerator:SetNWString("NZText", "Elevator is currently on the lower floor.")
			local ent = ents.FindByName("alarm_obj")[1]
			timer.Simple(50, function()
				ent:Fire("PlaySound")
			end)
			timer.Simple(60, function()
				ent:Fire("StopSound")
				scripthasusedelev = false
				scriptgenerator:SetNWString("NZText", "You need a gas can to power the elevator.")
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
	scriptgenerator:SetNWString("NZText", "You need a gas can to power the elevator.")
	scriptgenerator:SetNWString("NZRequiredItem", "gascan")
	scriptgenerator:SetNWString("NZHasText", "Press E to fuel generator with Gas Can.")
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
				scriptgenerator:SetNWString("NZText", "Elevator is on its way up.") -- Update text
			end
		end
	end
	
	local door = ents.GetMapCreatedEntity(1836)
	if IsValid(door) then door:SetNWString("NZText", "You need to disable security.") end
	
	for k,v in pairs(ents.FindInSphere(Vector(3315, -1280, 55), 10)) do
		if v:GetClass() == "prop_buys" then v:BlockUnlock() end
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
	if IsValid(scriptgenerator) then scriptgenerator:Remove() end
	if IsValid(scriptgascan) then scriptgascan:Remove() end
	scriptgenerator = nil
	scriptgaspositions = nil
	scriptgascan = nil
	hasscriptgascan = nil
end

-- Only functions will be hooked, meaning you can safely store data as well
mapscript.TestPrint = "v0.0"
local testprint2 = "This is cool" -- You can also store the data locally

-- Always return the mapscript table. This gives it on to the gamemode so it can use it.
return mapscript

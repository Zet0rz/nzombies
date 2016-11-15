local mapscript = {}

local gens = {
	{pos = Vector(475, -845, 213), ang = Angle(0,-105,90)},
	{pos = Vector(1860, -365, 225), ang = Angle(0,-87,90)},
	{pos = Vector(1557, 889, 193), ang = Angle(0,-8,90)}
}
local gen_ents = {}

local shieldparts = {
	[1] = { -- Fence
		{pos = Vector(324, 348, 205), ang = Angle(15,-45,0)},
		{pos = Vector(16, 523, 180), ang = Angle(-8, 0, 0)},
		{pos = Vector(602, 741, 332), ang = Angle(5, 0, 0)},
		{pos = Vector(-205, 377, 132), ang = Angle(-90, -90, 180)},
		{pos = Vector(575, 887, 186), ang = Angle(45, 90, 90)},
	},
	[2] = { -- Radiator
		{pos = Vector(1200, -669, 274), ang = Angle(0,43,0)},
		{pos = Vector(935, -349, 379), ang = Angle(-90, -133, 180)},
		{pos = Vector(1116, -250, 274), ang = Angle(0,0,0)},
		{pos = Vector(1130, -1058, 269), ang = Angle(45,-90,0)},
		{pos = Vector(803, -1775, 338), ang = Angle(0,0,0)},
	},
	[3] = { -- Posts
		{pos = Vector(336, 570, 16), ang = Angle(0,0,0)},
		{pos = Vector(338, 120, 37), ang = Angle(-10, 18, 45)},
		{pos = Vector(560, 960, 134), ang = Angle(-90, -90, 180)},
		{pos = Vector(1059, 906, 0), ang = Angle(0,75,0)},
		{pos = Vector(1615, 953, -4), ang = Angle(0,90,0)},
	}
}

local shield1 = nzItemCarry:CreateCategory("shield1")
shield1:SetIcon("spawnicons/models/props_c17/fence01b.png")
shield1:SetText("Press E to pick up part.")
shield1:SetDropOnDowned(false)
shield1:SetShared(false)

shield1:SetResetFunction( function(self)
	local poss = shieldparts[1]
	local ran = poss[math.random(table.Count(poss))]
	if ran and ran.pos and ran.ang then
		local part = ents.Create("nz_script_prop")
		part:SetModel("models/props_c17/fence01b.mdl")
		part:SetPos(ran.pos)
		part:SetAngles(ran.ang)
		part:Spawn()
		self:RegisterEntity( part )
	end
end)
shield1:Update()

local shield2 = nzItemCarry:CreateCategory("shield2")
shield2:SetIcon("spawnicons/models/props_c17/furnitureradiator001a.png")
shield2:SetText("Press E to pick up part.")
shield2:SetDropOnDowned(false)
shield2:SetShared(false)

shield2:SetResetFunction( function(self)
	local poss = shieldparts[2]
	local ran = poss[math.random(table.Count(poss))]
	if ran and ran.pos and ran.ang then
		local part = ents.Create("nz_script_prop")
		part:SetModel("models/props_c17/furnitureradiator001a.mdl")
		part:SetPos(ran.pos)
		part:SetAngles(ran.ang)
		part:Spawn()
		self:RegisterEntity( part )
	end
end)
shield2:Update()

local shield3 = nzItemCarry:CreateCategory("shield3")
shield3:SetIcon("spawnicons/models/props_c17/playgroundtick-tack-toe_post01.png")
shield3:SetText("Press E to pick up part.")
shield3:SetDropOnDowned(false)
shield3:SetShared(false)

shield3:SetResetFunction( function(self)
	local poss = shieldparts[3]
	local ran = poss[math.random(table.Count(poss))]
	if ran and ran.pos and ran.ang then
		local part = ents.Create("nz_script_prop")
		part:SetModel("models/props_c17/playgroundtick-tack-toe_post01.mdl")
		part:SetPos(ran.pos)
		part:SetAngles(ran.ang)
		part:Spawn()
		self:RegisterEntity( part )
	end
end)
shield3:Update()

local buildabletbl = {
	model = "models/weapons/w_zombieshield.mdl",
	pos = Vector(0,0,60), -- (Relative to tables own pos)
	ang = Angle(0,180,90), -- (Relative too)
	parts = {
		["shield1"] = {0,1}, -- Submaterials to "unhide" when this part is added
		["shield2"] = {2}, -- id's are ItemCarry object IDs
		["shield3"] = {3},
		-- You can have as many as you want
	},
	usefunc = function(self, ply) -- When it's completed and a player presses E (optional)
		if !ply:HasWeapon("nz_zombieshield") then
			ply:Give("nz_zombieshield")
		end
	end,
	text = "Press E to pick up Zombie Shield"
}

local validfuses = {
	[1] = {pos = Vector(587, -467, 236), finishpos = Vector(-370, 948, 40), ent = NULL, done = false},
	[2] = {pos = Vector(587, -467, 230), finishpos = Vector(-370, 948, 34), ent = NULL, done = false},
	[3] = {pos = Vector(587, -467, 224), finishpos = Vector(-370, 948, 28), ent = NULL, done = false}
}

local fuses = nzItemCarry:CreateCategory("fuses")
fuses:SetIcon("spawnicons/models/healthvial.png")
fuses:SetText("Press E to pick up fuse.")
fuses:SetDropOnDowned(true)

fuses:SetResetFunction( function(self)
	for k,v in pairs(validfuses) do
		if !v.done and (!IsValid(v.ent) or (v.ent:IsPlayer() and (!v.ent:IsPlaying() or !v.ent:HasCarryItem("fuses")))) then -- Only spawn those that are not being carried
			local ent = ents.Create("nz_script_prop")
			ent:SetModel("models/healthvial.mdl")
			ent:SetPos(v.pos)
			ent:SetAngles(Angle(0,-90,-90))
			ent:Spawn()
			v.done = false
			v.ent = ent
			self:RegisterEntity(ent)
		end
	end
end)

fuses:SetDropFunction( function(self, ply)
	for k,v in pairs(validfuses) do -- Loop through all fuses
		if v.ent == ply then -- If this is the one we're carrying
			local ent = ents.Create("nz_script_prop")
			ent:SetModel("models/healthvial.mdl")
			ent:SetPos(ply:GetPos() + Vector(0,0,10))
			ent:SetAngles(Angle(0,0,0))
			ent:Spawn()
			ent:DropToFloor()
			v.ent = ent -- Drop the fuse and set the entity to this fuse
			self:RegisterEntity( ent )
			break
		end
	end
end)

fuses:SetPickupFunction( function(self, ply, ent)
	for k,v in pairs(validfuses) do -- Loop through all fuses
		if v.ent == ent then -- If this is the one
			ply:GiveCarryItem(self.id)
			ent:Remove()
			v.ent = ply -- Mark the new entity to be that of the player
			break
		end
	end
end)
fuses:SetCondition( function(self, ply)
	return !ply:HasCarryItem("fuses") and !ply:HasCarryItem("chargedfuses")
end)

fuses:Update()

local chargedfuses = nzItemCarry:CreateCategory("chargedfuses")
chargedfuses:SetIcon("spawnicons/models/healthvial.png")
chargedfuses:SetText("Press E to pick up charged fuse.")
chargedfuses:SetDropOnDowned(true)

chargedfuses:SetResetFunction( function(self)
	for k,v in pairs(validfuses) do -- They share the table
		if v.done and (!IsValid(v.ent) or (v.ent:IsPlayer() and (!v.ent:IsPlaying() or !v.ent:HasCarryItem("chargedfuses")))) then -- Reset the finished ones not being carried
			local ent = ents.Create("nz_script_prop")
			ent:SetModel("models/healthvial.mdl")
			ent:SetPos(v.pos)
			ent:SetAngles(Angle(0,-90,-90))
			ent:Spawn()
			v.done = true -- These are already charged, although they will respawn in the start point (if reset)
			v.ent = ent
			self:RegisterEntity(ent)
		end
	end
end)

chargedfuses:SetDropFunction( function(self, ply)
	for k,v in pairs(validfuses) do -- Loop through all fuses
		if v.ent == ply then -- If this is the one we're carrying
			local ent = ents.Create("nz_script_prop")
			ent:SetModel("models/healthvial.mdl")
			ent:SetPos(ply:GetPos() + Vector(0,0,10))
			ent:SetAngles(Angle(0,0,0))
			ent:Spawn()
			ent:DropToFloor()
			v.ent = ent -- Drop the fuse and set the entity to this fuse
			self:RegisterEntity( ent )
			break
		end
	end
end)

chargedfuses:SetPickupFunction( function(self, ply, ent)
	for k,v in pairs(validfuses) do -- Loop through all fuses
		if v.ent == ent then -- If this is the one
			ply:GiveCarryItem(self.id)
			ent:Remove()
			v.ent = ply -- Mark the new entity to be that of the player
			break
		end
	end
end)
chargedfuses:SetCondition( function(self, ply)
	return !ply:HasCarryItem("fuses") and !ply:HasCarryItem("chargedfuses")
end)

chargedfuses:Update()

local elecbuttonpos = {
	Vector(1922, -872, 223),
	Vector(1342, 1048, 192),
	Vector(460, -32, 252),
	Vector(975, -1048, 181),
	Vector(808, -985, 180),
	Vector(935, -150, 180),
	Vector(24, -1452, 194),
	Vector(-344, -1200, 186),
	Vector(133, -1717, 185),
	Vector(892, 785, 189)
}
local elecent
local elechit
local function electrify()
	local rand = math.random(#elecbuttonpos)
	local pos = elecbuttonpos[rand]
	
	elechit = false
	
	if !IsValid(elecent) then
		elecent = ents.Create("nz_script_prop")
		function elecent:UpdateTransmitState()
			return TRANSMIT_ALWAYS -- Then our effect will work no matter where it is
		end
		elecent:SetModel("models/hunter/blocks/cube025x025x025.mdl")
		elecent:SetNoDraw(true)
		elecent:Spawn()
		elecent.HitPlayer = NULL
		elecent.OnTakeDamage = function(self, dmginfo)
			if nzEE.Major.CurrentStep == 2 then
				local att = dmginfo:GetAttacker()
				local wep = att:GetActiveWeapon()
				if IsValid(wep) and wep:GetClass() == "nz_zombieshield" then
					if IsValid(self.HitPlayer) then
						local wep2 = self.HitPlayer:GetWeapon("nz_zombieshield")
						if IsValid(wep2) then wep2:SetElectrified(false) end
					end
					self.HitPlayer = att
					wep:SetElectrified(true)
					elechit = true
				end
			end
		end
	end
	elecent:SetPos(pos)
	timer.Simple(0.5, function()
		local e = EffectData()
		e:SetScale(-1)
		e:SetEntity(elecent)
		util.Effect("lightning_aura", e)
	end)
end
local elecgatebuttonshit = 0
local function finalelectric()
	if !IsValid(elecent) then
		elecent = ents.Create("nz_script_prop")
		function elecent:UpdateTransmitState()
			return TRANSMIT_ALWAYS
		end
		elecent:SetModel("models/hunter/blocks/cube025x025x025.mdl")
		elecent:SetNoDraw(true)
		elecent:Spawn()
		
	end
	elecent.OnTakeDamage = function(self, dmginfo)
		local att = dmginfo:GetAttacker()
		local wep = att:GetActiveWeapon()
		if IsValid(wep) and wep:GetClass() == "nz_zombieshield" then
			wep:SetElectrified(true)
		end
		elecgatebuttonshit = elecgatebuttonshit + 1
		if elecgatebuttonshit == 2 then
			nzEE.Major:CompleteStep(2)
		end
	end
	elecent:SetPos(Vector(2217, -862, 232))
	timer.Simple(0.5, function()
		local e = EffectData()
		e:SetScale(-1)
		e:SetEntity(elecent)
		util.Effect("lightning_aura", e)
	end)
	
	local ent2 = ents.Create("nz_script_prop")
	function ent2:UpdateTransmitState()
		return TRANSMIT_ALWAYS -- Then our effect will work no matter where it is
	end
	ent2:SetModel("models/hunter/blocks/cube025x025x025.mdl")
	ent2:SetNoDraw(true)
	ent2:SetPos(Vector(1966, -862, 232))
	ent2:Spawn()
	ent2.OnTakeDamage = function(self, dmginfo)
		local att = dmginfo:GetAttacker()
		local wep = att:GetActiveWeapon()
		if IsValid(wep) and wep:GetClass() == "nz_zombieshield" then
			wep:SetElectrified(true)
		end
		elecgatebuttonshit = elecgatebuttonshit + 1
		if elecgatebuttonshit == 2 then
			nzEE.Major:CompleteStep(2)
		end
	end

	timer.Simple(0.5, function()
		if IsValid(ent2) then
			local e = EffectData()
			e:SetScale(-1)
			e:SetEntity(ent2)
			util.Effect("lightning_aura", e)
		end
	end)
end

nzEE.Major:AddStep( function() -- Step 1, get to the key (fairly long step)
	nzDoors:OpenLinkedDoors("ee_door")
	nzNotifications:PlaySound("nz/easteregg/motd_round-01.wav", 0)
	local ent
	for k,v in pairs(ents.FindByName("door_key_5")) do
		if IsValid(v) then
			ent = v
			break
		end
	end
	if !IsValid(ent) then
		for k,v in pairs(ents.FindByName("key_template5")) do
			v:Fire("ForceSpawn") -- Spawn the key if it doesn't exist
		end
	end
	
end)

local forcefieldgens = {}
nzEE.Major:AddStep( function() -- Step 2, Open control room gate (fairly long step too)
	nzNotifications:PlaySound("nz/easteregg/motd_round-04.wav", 5)
	nzNotifications:PlaySound("ambient/machines/thumper_startup1.wav", 2)
	nzNotifications:PlaySound("ambient/machines/thumper_hit.wav", 0)
	for k,v in pairs(forcefieldgens) do -- This enables the next step
		if IsValid(v) then
			v:SetSubMaterial(1, "")
		end
	end	
	for k,v in pairs(ents.FindByName("gate")) do
		if IsValid(v) then
			v:Fire("Open") -- Opens the gate
		end
	end
	local ent = ents.FindByName("gate_opening_sound")[1]
	ent:Fire("StopSound")
	ent:Fire("PlaySound")
	timer.Simple(10, function()
		if IsValid(ent) then
			ent:Fire("StopSound")
		end
	end)
end)

nzEE.Major:AddStep( function() -- Step 3, Shut down forcefield
	for k,v in pairs(ents.FindByName("energy_shield_2")) do
		if IsValid(v) then
			v:Remove() -- Closes the forcefield
		end
	end
	for k,v in pairs(ents.FindByName("panel1")) do
		v:SetSubMaterial(1, "color")
	end
	for k,v in pairs(ents.FindByName("panel2")) do
		v:SetSubMaterial(0, "color")
	end
	local corekillstart = ents.FindByName("shield_button1")[1]
	corekillstart:CallOnRemove("nzee_core", function()
		nzEE.Major:CompleteStep(4) -- Triggers the final step
	end)
end)

local roundwegotto
nzEE.Major:AddStep( function() -- Step 4, trigger the core's destruction
	roundwegotto = nzRound:GetNumber()
	nzRound:RoundInfinity()
	local corekilled = ents.FindByName("corekill_button2")[1]
	corekilled:CallOnRemove("nzee_win", function(self)
		nzEE.Major:CompleteStep(5)
	end)
end)

nzEE.Major:AddStep( function() -- Step 5, You win :D
	nzEE.Cam:QueueView(5, nil, nil, nil, true)
	nzEE.Cam:Text("You blew up the core after "..roundwegotto.." rounds!")
	nzEE.Cam:Function( function()
		game.SetTimeScale(0.2)
		nzRound:Freeze(true) -- Prevents switching and spawning
	end)
	nzEE.Cam:Music("nz/easteregg/motd_standard.wav")
	nzEE.Cam:QueueView(15, Vector(1623, -1257, 187), Vector(1623, -1382, 227), nil, true)
	nzEE.Cam:Text("You blew up the core after "..roundwegotto.." rounds!")
	nzEE.Cam:Function( function()
		nzRound.Number = roundwegotto or 0
		game.SetTimeScale(1)
		for k,v in pairs(player.GetAll()) do
			v:SetTargetPriority(TARGET_PRIORITY_NONE)
			v:Freeze(true)
		end
	end)
	nzEE.Cam:QueueView(1)
	nzEE.Cam:Function( function()
		nzPowerUps:Nuke(nil, true, false)
		nzRound:Freeze(false)
		nzRound:Prepare() -- We continue now with perma perks :D
		for k,v in pairs(player.GetAll()) do
			v:GivePermaPerks()
			v:SetTargetPriority(TARGET_PRIORITY_PLAYER)
			v:Freeze(false)
		end
	end)
	nzEE.Cam:Begin()
end)

function mapscript.OnGameBegin()
	local completed = 1
	for k,v in pairs(gens) do
		local gen
		if IsValid(gen_ents[k]) then
			gen = gen_ents[k]
		else
			gen = ents.Create("nz_script_soulcatcher")
		end
		gen:SetNoDraw(true)
		gen:SetPos(v.pos)
		gen:SetAngles(v.ang)
		gen:SetModel("models/hunter/blocks/cube025x025x025.mdl")
		gen:Spawn() -- Spawn before setting variables or they'll become the default
		gen:SetTargetAmount(20)
		gen:SetRange(500)
		gen:SetReleaseOverride( function(self, z)
			if self.CurrentAmount >= self.TargetAmount then return end
			
			local e = EffectData()
			e:SetOrigin(self:GetPos())
			e:SetStart(z:GetPos())
			e:SetMagnitude(0.3)
			util.Effect("lightning_strike", e)
			self.CurrentAmount = self.CurrentAmount + 1
			self:CollectSoul()
		end)
		gen:SetCompleteFunction( function(self)
			if validfuses[self.fuse] and IsValid(validfuses[self.fuse].ent) then
				validfuses[self.fuse].done = true
				chargedfuses:RegisterEntity(validfuses[self.fuse].ent) -- Can now be picked up charged
			end
			nzDoors:OpenLinkedDoors("gen"..completed)
			if completed == 3 then
				nzDoors:OpenLinkedDoors("10") -- Enables the spawnpoints by PaP
			end
			completed = completed + 1
			self:Remove() -- Disappear!
		end)
		gen:SetCondition( function(self, z, dmg)
			return nzElec.Active
		end)
		gen_ents[k] = gen
		
		gen:SetEnabled(false)
		gen:SetNWString("NZText", "You need a fuse to charge the generator.")
		gen:SetNWString("NZRequiredItem", "fuses")
		gen:SetNWString("NZHasText", "Press E to insert fuse.")
		gen.OnUsed = function(self, ply)
			if ply:HasCarryItem("fuses") then
				for k,v in pairs(validfuses) do
					if v.ent == ply then
						local ent = ents.Create("nz_script_prop")
						ent:SetModel("models/healthvial.mdl")
						ent:SetPos(self:GetPos())
						ent:SetAngles(self:GetAngles())
						ent:Spawn()
						v.ent = ent -- Drop the fuse and set the entity to this fuse
						self.fuse = k -- ID of this fuse
						self:SetEnabled(true) -- Start charging!
						gen:SetNWString("NZText", "")
						gen:SetNWString("NZHasText", "")
						break
					end
				end
				ply:RemoveCarryItem("fuses")
			end
		end
	end
	
	local tbl = ents.Create("buildable_table")
	tbl:AddValidCraft("Zombie Shield", buildabletbl)
	tbl:SetPos(Vector(-771, -880, -2))
	tbl:SetAngles(Angle(0,-90,0))
	tbl:Spawn()
	
	shield1:Reset()
	shield2:Reset()
	shield3:Reset()
	
	local fuseholder = ents.Create("nz_script_prop")
	fuseholder:SetPos(Vector(592, -478, 230))
	fuseholder:SetAngles(Angle(0,180,0))
	fuseholder:SetModel("models/props_lab/reciever_cart.mdl")
	fuseholder:Spawn()
	fuseholder.OnUsed = function(self, ply) -- You can temporarily place fuses back here for storage
		if ply:HasCarryItem("fuses") or ply:HasCarryItem("chargedfuses") then
			for k,v in pairs(validfuses) do
				if v.ent == ply then
					local ent = ents.Create("nz_script_prop")
					ent:SetModel("models/healthvial.mdl")
					ent:SetPos(v.pos)
					ent:SetAngles(Angle(0,-90,-90))
					ent:Spawn()
					v.ent = ent -- Drop the fuse and set the entity to this fuse
					if v.done then
						chargedfuses:RegisterEntity(ent)
					else
						fuses:RegisterEntity(ent)
					end
					break
				end
			end
			ply:RemoveCarryItem("fuses")
			ply:RemoveCarryItem("chargedfuses")
		end
	end
	fuseholder:SetNWString("NZHasText", "Press E to place fuse back.")
	fuseholder:SetNWString("NZRequiredItem", "chargedfuses")
	fuseholder:SetUseType(SIMPLE_USE)
	
	local finishedcount = 0
	
	local finishfuseholder = ents.Create("nz_script_prop")
	finishfuseholder:SetPos(Vector(-365, 959, 37))
	finishfuseholder:SetAngles(Angle(0,0,0))
	finishfuseholder:SetModel("models/props_lab/reciever_cart.mdl")
	finishfuseholder:Spawn()
	finishfuseholder.OnUsed = function(self, ply) -- You can temporarily place fuses back here for storage
		if ply:HasCarryItem("chargedfuses") then
			for k,v in pairs(validfuses) do
				if v.ent == ply and v.done then
					local ent = ents.Create("nz_script_prop")
					ent:SetModel("models/healthvial.mdl")
					ent:SetPos(v.finishpos)
					ent:SetAngles(Angle(0,90,90))
					ent:Spawn()
					v.ent = ent -- Mark this as the fuse
					-- We don't register it, it can no longer be picked up
					finishedcount = finishedcount + 1
					break
				end
			end
			ply:RemoveCarryItem("chargedfuses")
		end
	end
	finishfuseholder:SetNWString("NZHasText", "Press E to place charged fuse.")
	finishfuseholder:SetNWString("NZRequiredItem", "chargedfuses")
	finishfuseholder:SetUseType(SIMPLE_USE)
	
	local light1 = ents.Create("nz_script_prop")
	light1:SetPos(Vector(-418, 974, 46))
	light1:SetAngles(Angle(0,-90, 180))
	light1:SetModel("models/props_c17/light_cagelight02_off.mdl")
	light1:Spawn()
	
	local light2 = ents.Create("nz_script_prop")
	light2:SetPos(Vector(-409, 974, 46))
	light2:SetAngles(Angle(0,-90, 180))
	light2:SetModel("models/props_c17/light_cagelight02_off.mdl")
	light2:Spawn()
	
	local light3 = ents.Create("nz_script_prop")
	light3:SetPos(Vector(-400, 974, 46))
	light3:SetAngles(Angle(0,-90, 180))
	light3:SetModel("models/props_c17/light_cagelight02_off.mdl")
	light3:Spawn()
	
	local lights = {light1, light2, light3}
	
	local running = false
	local completed = 0
	local maxtime
	local nextflip
	
	local but = ents.Create("nz_script_prop")
	but:SetPos(Vector(-406, 946, 32))
	but:SetAngles(Angle(-45,-90, 0))
	but:SetModel("models/props_combine/combinebutton.mdl")
	but:Spawn()
	but:SetUseType(SIMPLE_USE)
	but.OnUsed = function(self, ply)
		local light = lights[completed+1]
		
		if !running and finishedcount > completed then
			running = true
			light:SetModel("models/props_c17/light_cagelight01_off.mdl")
			but:EmitSound("buttons/button3.wav")
			local time = CurTime() + 60 -- When it ends
			nextflip = CurTime() + math.random(5,10)
			
			hook.Add("Think", "nzmapscript_EE_ButtonPuzzle", function()
				if time < CurTime() then -- We finished the time!
					light:SetModel("models/props_c17/light_cagelight02_on.mdl")
					but:EmitSound("buttons/button19.wav")
					completed = completed + 1
					running = false
					if completed == 3 then
						nzEE.Major:CompleteStep(1)
					end
					hook.Remove("Think", "nzmapscript_EE_ButtonPuzzle")
				elseif maxtime and maxtime < CurTime() then -- The flip happened more than 3 seconds ago :(
					light:SetModel("models/props_c17/light_cagelight02_off.mdl")
					but:EmitSound("buttons/combine_button_locked.wav")
					running = false
					maxtime = nil
					hook.Remove("Think", "nzmapscript_EE_ButtonPuzzle") -- This fails it and you need to retry
				elseif nextflip and nextflip < CurTime() then -- It's time for a random flip!
					light:SetModel("models/props_c17/light_cagelight01_on.mdl")
					nextflip = nil
					maxtime = CurTime() + 5
				end
			end)
		elseif running then
			if maxtime then -- We hit the button while it was running and you had to hit it!
				maxtime = nil
				light:SetModel("models/props_c17/light_cagelight01_off.mdl")
				but:EmitSound("buttons/combine_button1.wav")
				nextflip = CurTime() + math.random(2,15) -- It'll happen again >:D
			else -- We pushed when we didn't have to touch it! :(
				light:SetModel("models/props_c17/light_cagelight02_off.mdl")
				but:EmitSound("buttons/combine_button_locked.wav")
				running = false
				maxtime = nil
				hook.Remove("Think", "nzmapscript_EE_ButtonPuzzle") -- This fails it and you need to retry
			end
		end
	end
	
	local elight1 = ents.Create("nz_script_prop")
	elight1:SetPos(Vector(2110, 20, 225))
	elight1:SetAngles(Angle(-90,180, 180))
	elight1:SetModel("models/props_c17/light_cagelight02_off.mdl")
	elight1:Spawn()
	
	local elight2 = ents.Create("nz_script_prop")
	elight2:SetPos(Vector(2110, -8, 225))
	elight2:SetAngles(Angle(-90,180, 180))
	elight2:SetModel("models/props_c17/light_cagelight02_off.mdl")
	elight2:Spawn()
	
	local elight3 = ents.Create("nz_script_prop")
	elight3:SetPos(Vector(2110, -36, 225))
	elight3:SetAngles(Angle(-90,180, 180))
	elight3:SetModel("models/props_c17/light_cagelight02_off.mdl")
	elight3:Spawn()
	
	local elight4 = ents.Create("nz_script_prop")
	elight4:SetPos(Vector(2110, -64, 225))
	elight4:SetAngles(Angle(-90,180, 180))
	elight4:SetModel("models/props_c17/light_cagelight02_off.mdl")
	elight4:Spawn()
	
	local elights = {elight1, elight2, elight3, elight4}
	local elechits = 0
	local elecrunning = false
	
	local epanel = ents.Create("nz_script_prop")
	epanel:SetPos(Vector(2112, -23, 190))
	epanel:SetAngles(Angle(0,0,0))
	epanel:SetModel("models/props_wasteland/panel_leverbase001a.mdl")
	epanel:Spawn()
	epanel.OnTakeDamage = function(self, dmginfo)
		if nzEE.Major.CurrentStep == 2 then
			local wep = dmginfo:GetAttacker():GetActiveWeapon()
			if IsValid(wep) and wep:GetClass() == "nz_zombieshield" then
				if wep:GetElectrified() and elechit then
					elechits = elechits + 1
					self:EmitSound("ambient/energy/zap"..math.random(1,9)..".wav")
					local light = elights[elechits]
					if IsValid(light) then light:SetModel("models/props_c17/light_cagelight02_on.mdl") end
					if elechits == 4 then
						finalelectric()
						elecrunning = nil
					elseif elechits < 4 then
						elights[elechits+1]:SetModel("models/props_c17/light_cagelight01_on.mdl")
						electrify()
					end
					wep:SetElectrified(false)
				end
			end
		end
	end
	epanel.OnUsed = function(self, ply)
		if nzEE.Major.CurrentStep == 2 and !elecrunning then
			self:EmitSound("ambient/levels/labs/electric_explosion4.wav")
			electrify()
			elecrunning = true
			elights[1]:SetModel("models/props_c17/light_cagelight01_on.mdl")
		end
	end
	
	local doneforcefields = 0
	local force1 = ents.Create("nz_script_prop")
	force1:SetModel("models/props_combine/combine_fence01a.mdl")
	force1:SetPos(Vector(1253, -450, 410))
	force1:SetAngles(Angle(0,90,0))
	force1:Spawn()
	force1:SetSubMaterial(1, "color")
	force1.HasBeenPaPShot = false
	force1.OnTakeDamage = function(self, dmginfo)
		if !self.HasBeenPaPShot and nzEE.Major.CurrentStep == 3 then
			local wep = dmginfo:GetAttacker():GetActiveWeapon()
			if IsValid(wep) and wep:HasNZModifier("pap") then
				self:SetSubMaterial(1, "color")
				doneforcefields = doneforcefields + 1
				self.HasBeenPaPShot = true
				self:EmitSound("ambient/machines/thumper_shutdown1.wav", 100)
				if doneforcefields == 3 then
					nzEE.Major:CompleteStep(3)
				end
			end
		end
	end
	local force1gen = ents.Create("nz_script_prop")
	force1gen:SetPos(Vector(1240, -453, 380))
	force1gen:SetAngles(Angle(0,0,0))
	force1gen:SetModel("models/props_lab/servers.mdl")
	force1gen:Spawn()
	
	local force2 = ents.Create("nz_script_prop")
	force2:SetModel("models/props_combine/combine_fence01a.mdl")
	force2:SetPos(Vector(-1220, -629, 160))
	force2:SetAngles(Angle(0,0,0))
	force2:Spawn()
	force2:SetSubMaterial(1, "color")
	force2.HasBeenPaPShot = false
	force2.OnTakeDamage = function(self, dmginfo)
		if !self.HasBeenPaPShot and nzEE.Major.CurrentStep == 3 then
			local wep = dmginfo:GetAttacker():GetActiveWeapon()
			if IsValid(wep) and wep:HasNZModifier("pap") then
				self:SetSubMaterial(1, "color")
				doneforcefields = doneforcefields + 1
				self.HasBeenPaPShot = true
				self:EmitSound("ambient/machines/thumper_shutdown1.wav", 100)
				if doneforcefields == 3 then
					nzEE.Major:CompleteStep(3)
				end
			end
		end
	end
	local force2gen = ents.Create("nz_script_prop")
	force2gen:SetPos(Vector(-1232, -616, 127))
	force2gen:SetAngles(Angle(0,90,0))
	force2gen:SetModel("models/props_lab/servers.mdl")
	force2gen:Spawn()
	
	local force3 = ents.Create("nz_script_prop")
	force3:SetModel("models/props_combine/combine_fence01a.mdl")
	force3:SetPos(Vector(1651, 1415, 169))
	force3:SetAngles(Angle(0,0,0))
	force3:Spawn()
	force3:SetSubMaterial(1, "color")
	force3.HasBeenPaPShot = false
	force3.OnTakeDamage = function(self, dmginfo)
		if !self.HasBeenPaPShot and nzEE.Major.CurrentStep == 3 then
			local wep = dmginfo:GetAttacker():GetActiveWeapon()
			if IsValid(wep) and wep:HasNZModifier("pap") then
				self:SetSubMaterial(1, "color")
				doneforcefields = doneforcefields + 1
				self.HasBeenPaPShot = true
				self:EmitSound("ambient/machines/thumper_shutdown1.wav", 100)
				if doneforcefields == 3 then
					nzEE.Major:CompleteStep(3)
				end
			end
		end
	end
	local force3gen = ents.Create("nz_script_prop")
	force3gen:SetPos(Vector(1656, 1428, 128))
	force3gen:SetAngles(Angle(0,90,0))
	force3gen:SetModel("models/props_lab/servers.mdl")
	force3gen:Spawn()
	
	forcefieldgens = {force1, force2, force3}
	
	for k,v in pairs(validfuses) do
		if IsValid(v.ent) and v.ent:GetClass() == "nz_script_prop" then
			v.ent:Remove() -- Remove all valid fuses so we can reset
		end
		v.ent = nil
		v.done = false
	end
	
	for k,v in pairs(ents.FindByName("key_case")) do
		v:Remove() -- Prevent the key from auto-spawning
	end
	
	for k,v in pairs(ents.FindByName("gate_button_1")) do
		v:Remove() -- We don't want players accidentally opening these doors
	end
	for k,v in pairs(ents.FindByName("gate_button_2")) do
		v:Remove()
	end
	
	fuses:Reset()
end

function mapscript.ScriptUnload()
	for k,v in pairs(gen_ents) do
		if IsValid(v) then
			v:Remove()
		end
	end
	gen_ents = nil
end

function mapscript.PostCleanupMap()
	for k,v in pairs(validfuses) do
		if IsValid(v.ent) and v.ent:GetClass() == "nz_script_prop" then
			v.ent:Remove() -- Remove all valid fuses so we can reset
		end
		v.done = false
	end
end

-- Always return the mapscript table. This gives it on to the gamemode so it can use it.
return mapscript

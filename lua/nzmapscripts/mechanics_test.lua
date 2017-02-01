local script = {} -- Create the table in which to add functions to

local shieldparts = {
	[1] = { -- Fence
		{pos = Vector(850, -35, -140), ang = Angle(0,0,0)}
	},
	[2] = { -- Radiator
		{pos = Vector(850, -235, -140), ang = Angle(0,0,0)}
	},
	[3] = { -- Posts
		{pos = Vector(850, -435, -140), ang = Angle(0,0,0)}
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
shield2:SetModel("models/props_c17/furnitureradiator001a.mdl")
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
shield3:SetIcon("icon16/key.png")
shield3:SetModel("models/lostcoast/fisherman/fisherman_gestures.mdl")
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

local tbl = ents.Create("buildable_table")
tbl:AddValidCraft("Zombie Shield", buildabletbl)
tbl:SetPos(Entity(1):GetEyeTrace().HitPos)
tbl:Spawn()

shield1:Reset()
shield2:Reset()
shield3:Reset()

local elecbuttonpos = {
	Vector(1023, 189, -88),
	Vector(1119, 315, -86),
	Vector(1639, 847, -84),
	Vector(-5280, -2554, -92),
}
script.elecent = NULL
local elechit
function script.electrify()
	local rand = math.random(#elecbuttonpos)
	local pos = elecbuttonpos[rand]
	
	elechit = false
	
	if !IsValid(script.elecent) then
		script.elecent = ents.Create("nz_script_prop")
		function script.elecent:UpdateTransmitState()
			return TRANSMIT_ALWAYS
		end
		script.elecent:SetModel("models/hunter/blocks/cube025x025x025.mdl")
		script.elecent:SetNoDraw(true)
		script.elecent:Spawn()
		script.elecent.HitPlayer = NULL
		script.elecent.OnTakeDamage = function(self, dmginfo)
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
	script.elecent:SetPos(pos)
	timer.Simple(0.5, function()
		local e = EffectData()
		e:SetScale(-1) -- Infinite time
		e:SetEntity(script.elecent)
		util.Effect("lightning_aura", e)
	end)
end
script.electrify()

function script.camtest()
	nzEE.Cam:QueueView(5, nil, nil, nil, true)
	nzEE.Cam:Text("Beat it!")
	nzEE.Cam:Function( function() game.SetTimeScale(0.2) end)
	nzEE.Cam:Music("nz/easteregg/motd_standard.wav")
	nzEE.Cam:QueueView(15, Vector(31, -13, -43), Vector(400, -13, -43), Angle(-20,0,0), true)
	nzEE.Cam:Text("Beat it!")
	nzEE.Cam:Function( function() game.SetTimeScale(1) end)
	nzEE.Cam:Begin()
end

function script.OnRoundBegin(num)
	
end

-- Return the table - this is critical, never forget
return script

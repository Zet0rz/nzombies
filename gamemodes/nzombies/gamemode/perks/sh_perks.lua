
function nzPerks:NewPerk(id, data)
	if SERVER then
		//Sanitise any client data.
	else
		data.Func = nil
	end
	nzPerks.Data[id] = data
end

function nzPerks:Get(id)
	return nzPerks.Data[id]
end

function nzPerks:GetByName(name)
	for _, perk in pairs(nzPerks.Data) do
		if perk.name == name then
			return perk
		end
	end

	return nil
end

function nzPerks:GetList()
	local tbl = {}

	for k,v in pairs(nzPerks.Data) do
		tbl[k] = v.name
	end

	return tbl
end

function nzPerks:GetIcons()
	local tbl = {}
	
	for k,v in pairs(nzPerks.Data) do
		tbl[k] = v.icon
	end
	
	return tbl
end

function nzPerks:GetBottleMaterials()
	local tbl = {}
	
	for k,v in pairs(nzPerks.Data) do
		tbl[k] = v.material
	end
	
	return tbl
end

nzPerks:NewPerk("jugg", {
	name = "Juggernog",
	off_model = "models/alig96/perks/jugg/jugg_off.mdl",
	on_model = "models/alig96/perks/jugg/jugg_on.mdl",
	price = 2500,
	material = "models/perk_bottle/c_perk_bottle_jugg",
	icon = Material("perk_icons/jugg.png", "smooth unlitgeneric"),
	color = Color(255, 100, 100),
	func = function(self, ply, machine)
			ply:SetMaxHealth(250)
			ply:SetHealth(250)
			return true
	end,
	lostfunc = function(self, ply)
		ply:SetMaxHealth(100)
		if ply:Health() > 100 then ply:SetHealth(100) end
	end,
})

nzPerks:NewPerk("dtap", {
	name = "Double Tap",
	off_model = "models/alig96/perks/doubletap/doubletap_off.mdl",
	on_model = "models/alig96/perks/doubletap/doubletap_on.mdl",
	price = 2000,
	material = "models/perk_bottle/c_perk_bottle_dtap",
	icon = Material("perk_icons/dtap.png", "smooth unlitgeneric"),
	color = Color(255, 255, 100),
	func = function(self, ply, machine)
		local tbl = {}
		for k,v in pairs(ply:GetWeapons()) do
			if v:IsFAS2() then
				table.insert(tbl, v)
			end
		end
		if tbl[1] != nil then
			for k,v in pairs(tbl) do
				v:ApplyNZModifier("dtap")
			end
		end
		return true
	end,
	lostfunc = function(self, ply)
		if !ply:HasPerk("dtap2") then
			local tbl = {}
			for k,v in pairs(ply:GetWeapons()) do
				if v:IsFAS2() then
					table.insert(tbl, v)
				end
			end
			if tbl[1] != nil then
				for k,v in pairs(tbl) do
					v:RevertNZModifier("dtap")
				end
			end
		end
	end,
})

nzPerks:NewPerk("revive", {
	name = "Quick Revive",
	off_model = "models/alig96/perks/revive/revive_off.mdl",
	on_model = "models/alig96/perks/revive/revive_on.mdl",
	price = 1500,
	material = "models/perk_bottle/c_perk_bottle_revive",
	icon = Material("perk_icons/revive.png", "smooth unlitgeneric"),
	color = Color(100, 100, 255),
	func = function(self, ply, machine)
			if #player.GetAllPlaying() <= 1 then
				if !ply.SoloRevive or ply.SoloRevive < 3 or !IsValid(machine) then
					ply:ChatPrint("You got Quick Revive (Solo)!")
				else
					ply:ChatPrint("You can only get Quick Revive Solo 3 times.")
					return false
				end
			end
			--ply:PrintMessage( HUD_PRINTTALK, "You've got Quick Revive!")
			return true
	end,
	lostfunc = function(self, ply)

	end,
})

nzPerks:NewPerk("speed", {
	name = "Speed Cola",
	off_model = "models/alig96/perks/speed/speed_off.mdl",
	on_model = "models/alig96/perks/speed/speed_on.mdl",
	price = 3000,
	material = "models/perk_bottle/c_perk_bottle_speed",
	icon = Material("perk_icons/speed.png", "smooth unlitgeneric"),
	color = Color(100, 255, 100),
	func = function(self, ply, machine)
		local tbl = {}
		for k,v in pairs(ply:GetWeapons()) do
			if v:NZPerkSpecialTreatment() then
				table.insert(tbl, v)
			end
		end
		if tbl[1] != nil then
			--local str = ""
			for k,v in pairs(tbl) do
				v:ApplyNZModifier("speed")
				--str = str .. v.ClassName .. ", "
			end
		end
		return true
	end,
	lostfunc = function(self, ply)
		local tbl = {}
		for k,v in pairs(ply:GetWeapons()) do
			if v:NZPerkSpecialTreatment() then
				table.insert(tbl, v)
			end
		end
		if tbl[1] != nil then
			for k,v in pairs(tbl) do
				v:RevertNZModifier("speed")
			end
		end
	end,
})

nzPerks:NewPerk("pap", {
	name = "Pack-a-Punch",
	off_model = "models/alig96/perks/packapunch/packapunch.mdl", //Find a new model.
	on_model = "models/alig96/perks/packapunch/packapunch.mdl",
	price = 0,
	blockget = true, -- Prevents players from getting the perk when they buy it
	nobuy = true, -- A "Buy" event won't run when this is used (we do that ourselves in its function)
	-- We don't use materials
	icon = Material("vulture_icons/pap.png", "smooth unlitgeneric"),
	color = Color(200, 220, 220),
	func = function(self, ply, machine)
		local wep = ply:GetActiveWeapon()
		if (!wep:HasNZModifier("pap") or wep.OnRePaP or (wep:IsCW2() and CustomizableWeaponry)) and !machine:GetBeingUsed() then
			--local reroll = (wep:HasNZModifier("pap") and wep.OnRePaP or wep.Attachments and ((wep:IsCW2() and CustomizableWeaponry) or wep:IsFAS2()) and true or false)
			local reroll = false
			if wep:HasNZModifier("pap") and (wep.OnRePaP or (wep.Attachments and (wep:IsCW2() and CustomizableWeaponry) or wep:IsFAS2())) then
				reroll = true
			end
			local cost = reroll and 2000 or 5000

			return ply:Buy(cost, machine, function()
				--ply:TakePoints(cost)

				machine:SetBeingUsed(true)
				machine:EmitSound("nz/machines/pap_up.wav")
				local class = wep:GetClass()
				
				local e = EffectData()
				e:SetEntity(machine)
				local ang = machine:GetAngles()
				e:SetOrigin(machine:GetPos() + ang:Up()*35 + ang:Forward()*20 - ang:Right()*2)
				e:SetMagnitude(3)
				util.Effect("pap_glow", e)

				wep:Remove()
				local wep = ents.Create("pap_weapon_fly")
				local startpos = machine:GetPos() + ang:Forward()*30 + ang:Up()*25 + ang:Right()*-3
				wep:SetPos(startpos)
				wep:SetAngles(ang + Angle(0,90,0))
				wep.WepClass = class
				wep:Spawn()
				local weapon = weapons.Get(class)
				local model = (weapon and weapon.WM or weapon.WorldModel) or "models/weapons/w_rif_ak47.mdl"
				if !util.IsValidModel(model) then model = "models/weapons/w_rif_ak47.mdl" end
				wep:SetModel(model)
				wep.machine = machine
				wep.Owner = ply
				wep:SetMoveType( MOVETYPE_FLY )

				--wep:SetNotSolid(true)
				--wep:SetGravity(0.000001)
				--wep:SetCollisionBounds(Vector(0,0,0), Vector(0,0,0))
				timer.Simple(0.5, function()
					if IsValid(wep) then
						wep:SetLocalVelocity(ang:Forward()*-30)
					end
				end)
				timer.Simple(1.8, function()
					if IsValid(wep) then
						wep:SetMoveType(MOVETYPE_NONE)
						wep:SetLocalVelocity(Vector(0,0,0))
					end
				end)
				timer.Simple(3, function()
					if IsValid(wep) and IsValid(machine) then
						local weapon = weapons.Get(class)
						if weapon and weapon.NZPaPReplacement and weapons.Get(weapon.NZPaPReplacement) then
							local pos, ang = wep:GetPos(), wep:GetAngles()
							wep:Remove()
							wep = ents.Create("pap_weapon_fly") -- Recreate a new entity with the replacement class instead
							wep:SetPos(pos)
							wep:SetAngles(ang)
							wep.WepClass = weapon.NZPaPReplacement
							wep:Spawn()
							wep.TriggerPos = startpos
							
							local replacewep = weapons.Get(weapon.NZPaPReplacement)
							local model = (replacewep and replacewep.WM or replacewep.WorldModel) or "models/weapons/w_rif_ak47.mdl"
							if !util.IsValidModel(model) then model = "models/weapons/w_rif_ak47.mdl" end
							wep:SetModel(model) -- Changing the model and name
							wep.machine = machine
							wep.Owner = ply
							wep:SetMoveType( MOVETYPE_FLY )
						end
						
						--print(wep, wep.WepClass, wep:GetModel())
					
						machine:EmitSound("nz/machines/pap_ready.wav")
						wep:SetCollisionBounds(Vector(0,0,0), Vector(0,0,0))
						wep:SetMoveType(MOVETYPE_FLY)
						wep:SetGravity(0.000001)
						wep:SetLocalVelocity(ang:Forward()*30)
						--print(ang:Forward()*30, wep:GetVelocity())
						wep:CreateTriggerZone(reroll)
						--print(reroll)
					end
				end)
				timer.Simple(4.2, function()
					if IsValid(wep) then
						--print("YDA")
						--print(wep:GetMoveType())
						--print(ang:Forward()*30, wep:GetVelocity())
						wep:SetMoveType(MOVETYPE_NONE)
						wep:SetLocalVelocity(Vector(0,0,0))
					end
				end)
				timer.Simple(10, function()
					if IsValid(wep) then
						wep:SetMoveType(MOVETYPE_FLY)
						wep:SetLocalVelocity(ang:Forward()*-2)
					end
				end)
				timer.Simple(25, function()
					if IsValid(wep) then
						wep:Remove()
						if IsValid(machine) then
							machine:SetBeingUsed(false)
						end
					end
				end)

				timer.Simple(2, function() ply:RemovePerk("pap") end)
				return true
			end)
		else
			ply:PrintMessage( HUD_PRINTTALK, "This weapon is already Pack-a-Punched")
			return false
		end
	end,
	lostfunc = function(self, ply)

	end,
})

nzPerks:NewPerk("dtap2", {
	name = "Double Tap II",
	off_model = "models/alig96/perks/doubletap2/doubletap2_off.mdl",
	on_model = "models/alig96/perks/doubletap2/doubletap2.mdl",
	price = 2000,
	material = "models/perk_bottle/c_perk_bottle_dtap2",
	icon = Material("perk_icons/dtap2.png", "smooth unlitgeneric"),
	color = Color(255, 255, 100),
	func = function(self, ply, machine)
		local tbl = {}
		for k,v in pairs(ply:GetWeapons()) do
			if v:IsFAS2() then
				table.insert(tbl, v)
			end
		end
		if tbl[1] != nil then
			for k,v in pairs(tbl) do
				v:ApplyNZModifier("dtap")
			end
		end
		return true
	end,
	lostfunc = function(self, ply)
		if !ply:HasPerk("dtap") then
			local tbl = {}
			for k,v in pairs(ply:GetWeapons()) do
				if v:IsFAS2() then
					table.insert(tbl, v)
				end
			end
			if tbl[1] != nil then
				for k,v in pairs(tbl) do
					v:RevertNZModifier("dtap")
				end
			end
		end
	end,
})

nzPerks:NewPerk("staminup", {
	name = "Stamin-Up",
	off_model = "models/alig96/perks/staminup/staminup_off.mdl",
	on_model = "models/alig96/perks/staminup/staminup.mdl",
	price = 2000,
	material = "models/perk_bottle/c_perk_bottle_stamin",
	icon = Material("perk_icons/staminup.png", "smooth unlitgeneric"),
	color = Color(200, 255, 100),
	func = function(self, ply, machine)
		ply:SetRunSpeed(350)
		ply:SetMaxRunSpeed( 350 )
		ply:SetStamina( 200 )
		ply:SetMaxStamina( 200 )
		return true
	end,
	lostfunc = function(self, ply)
		ply:SetRunSpeed(300)
		ply:SetMaxRunSpeed( 300 )
		ply:SetStamina( 100 )
		ply:SetMaxStamina( 100 )
	end,
})

nzPerks:NewPerk("phd", {
	name = "PhD Flopper",
	off_model = "models/alig96/perks/phd/phdflopper_off.mdl",
	on_model = "models/alig96/perks/phd/phdflopper.mdl",
	price = 2000,
	material = "models/perk_bottle/c_perk_bottle_phd",
	icon = Material("perk_icons/phd.png", "smooth unlitgeneric"),
	color = Color(255, 50, 255),
	func = function(self, ply, machine)
		return true
	end,
	lostfunc = function(self, ply)
	end,
})

nzPerks:NewPerk("deadshot", {
	name = "Deadshot Daiquiri",
	off_model = "models/alig96/perks/deadshot/deadshot_off.mdl",
	on_model = "models/alig96/perks/deadshot/deadshot.mdl",
	price = 2000,
	material = "models/perk_bottle/c_perk_bottle_deadshot",
	icon = Material("perk_icons/deadshot.png", "smooth unlitgeneric"),
	color = Color(150, 200, 150),
	func = function(self, ply, machine)
		return true
	end,
	lostfunc = function(self, ply)
	end,
})

nzPerks:NewPerk("mulekick", {
	name = "Mule Kick",
	off_model = "models/alig96/perks/mulekick/mulekick_off.mdl",
	on_model = "models/alig96/perks/mulekick/mulekick.mdl",
	price = 4000,
	material = "models/perk_bottle/c_perk_bottle_mulekick",
	icon = Material("perk_icons/mulekick.png", "smooth unlitgeneric"),
	color = Color(100, 200, 100),
	func = function(self, ply, machine)
		return true
	end,
	lostfunc = function(self, ply)
		for k,v in pairs(ply:GetWeapons()) do
			if v:GetNWInt("SwitchSlot") == 3 then
				ply:StripWeapon(v:GetClass())
			end
		end
	end,
})

nzPerks:NewPerk("tombstone", {
	name = "Tombstone Soda",
	off_model = "models/alig96/perks/tombstone/tombstone_off.mdl",
	on_model = "models/alig96/perks/tombstone/tombstone.mdl",
	price = 2000,
	material = "models/perk_bottle/c_perk_bottle_tombstone",
	icon = Material("perk_icons/tombstone.png", "smooth unlitgeneric"),
	color = Color(100, 100, 100),
	func = function(self, ply, machine)
		return true
	end,
	lostfunc = function(self, ply)
	end,
})

nzPerks:NewPerk("whoswho", {
	name = "Who's Who",
	off_model = "models/alig96/perks/whoswho/whoswho_off.mdl",
	on_model = "models/alig96/perks/whoswho/whoswho.mdl",
	price = 2000,
	material = "models/perk_bottle/c_perk_bottle_whoswho",
	icon = Material("perk_icons/whoswho.png", "smooth unlitgeneric"),
	color = Color(100, 100, 255),
	func = function(self, ply, machine)
		return true
	end,
	lostfunc = function(self, ply)
	end,
})

nzPerks:NewPerk("cherry", {
	name = "Electric Cherry",
	off_model = "models/alig96/perks/cherry/cherry_off.mdl",
	on_model = "models/alig96/perks/cherry/cherry.mdl",
	price = 2000,
	material = "models/perk_bottle/c_perk_bottle_cherry",
	icon = Material("perk_icons/cherry.png", "smooth unlitgeneric"),
	color = Color(50, 50, 200),
	func = function(self, ply, machine)
		return true
	end,
	lostfunc = function(self, ply)
	end,
})

nzPerks:NewPerk("vulture", {
	name = "Vulture Aid Elixir",
	off_model = "models/alig96/perks/vulture/vultureaid_off.mdl",
	on_model = "models/alig96/perks/vulture/vultureaid.mdl",
	price = 3000,
	material = "models/perk_bottle/c_perk_bottle_vulture",
	icon = Material("perk_icons/vulture.png", "smooth unlitgeneric"),
	color = Color(255, 100, 100),
	func = function(self, ply, machine)
		return true
	end,
	lostfunc = function(self, ply)
	end,
})

nzPerks:NewPerk("wunderfizz", {
	name = "Der Wunderfizz", -- Nothing more is needed, it is specially handled
	blockget = true,
})

nzPerks:NewPerk("widowswine", {
	name = "Widow's Wine",
	model = "models/yolojoenshit/bo3perks/widows_wine/mc_mtl_p7_zm_vending_widows_wine.mdl",
	off_skin = 1,
	on_skin = 0,
	price = 4000,
	material = "models/perk_bottle/c_perk_bottle_widowswine",
	icon = Material("perk_icons/widows_wine.png", "smooth unlitgeneric"),
	color = Color(255, 50, 200),
	func = function(self, ply, machine)
		return true
	end,
	lostfunc = function(self, ply)
	end,
})
//

function nz.Perks.Functions.NewPerk(id, data)
	if SERVER then
		//Sanitise any client data.
	else
		data.Func = nil
	end
	nz.Perks.Data[id] = data
end

function nz.Perks.Functions.Get(id)
	return nz.Perks.Data[id]
end

function nz.Perks.Functions.GetList()
	local tbl = {}

	for k,v in pairs(nz.Perks.Data) do
		tbl[k] = v.name
	end

	return tbl
end

nz.Perks.Functions.NewPerk("jugg", {
	name = "Juggernog",
	off_model = "models/alig96/perks/jugg/jugg_off.mdl",
	on_model = "models/alig96/perks/jugg/jugg_on.mdl",
	price = 2500,
	func = function(self, ply)
			ply:SetMaxHealth(250)
			ply:SetHealth(250)
			ply:Give("zombies_perk_juggernog_nz")
			return true
	end,
})

nz.Perks.Functions.NewPerk("dtap", {
	name = "Double Tap",
	off_model = "models/alig96/perks/doubletap/doubletap_off.mdl",
	on_model = "models/alig96/perks/doubletap/doubletap_on.mdl",
	price = 2000,
	func = function(self, ply)
		local tbl = {}
		for k,v in pairs(ply:GetWeapons()) do
			if nz.Weps.Functions.IsFAS2( v ) then
				table.insert(tbl, v)
			end
		end
		if tbl[1] != nil then
			local str = ""
			for k,v in pairs(tbl) do
				nz.Weps.Functions.ApplyDTap( ply, v )
				str = str .. v.ClassName .. ", "
			end
			ply:PrintMessage( HUD_PRINTTALK, "Double Tap Applied to: " .. str)
			ply:Give("zombies_perk_juggernog_nz")
			return true
		else
			ply:PrintMessage( HUD_PRINTTALK, "You don't have a weapon that is compatible with this perk. (Requires a FAS2 weapon)")
			return false
		end
	end,
})

nz.Perks.Functions.NewPerk("revive", {
	name = "Quick Revive",
	off_model = "models/alig96/perks/revive/revive_off.mdl",
	on_model = "models/alig96/perks/revive/revive_on.mdl",
	price = 1500,
	func = function(self, ply)
			print(self)
			ply:PrintMessage( HUD_PRINTTALK, "You've got Quick Revive!")
			ply:Give("zombies_perk_juggernog_nz")
			return true
	end,
})

nz.Perks.Functions.NewPerk("sleight", {
	name = "Speed Cola",
	off_model = "models/alig96/perks/sleight/sleight_off.mdl",
	on_model = "models/alig96/perks/sleight/sleight_on.mdl",
	price = 3000,
	func = function(self, ply)
			local tbl = {}
			for k,v in pairs(ply:GetWeapons()) do
				if nz.Weps.Functions.IsFAS2( v ) then
					table.insert(tbl, v)
				end
			end
			if tbl[1] != nil then
				local str = ""
				for k,v in pairs(tbl) do
					nz.Weps.Functions.ApplySleight( ply, v )
					str = str .. v.ClassName .. ", "
				end
				ply:PrintMessage( HUD_PRINTTALK, "Speed Cola Applied to: " .. str)
				ply:Give("zombies_perk_juggernog_nz")
				return true
			else
				ply:PrintMessage( HUD_PRINTTALK, "You don't have a weapon that is compatible with this perk. (Requires a FAS2 weapon)")
				return false
			end
	end,
})

nz.Perks.Functions.NewPerk("pap", {
	name = "Pack-a-Punch",
	off_model = "models/alig96/perks/packapunch/packapunch.mdl", //Find a new model.
	on_model = "models/alig96/perks/packapunch/packapunch.mdl",
	price = 5000,
	func = function(self, ply)
		local wep = ply:GetActiveWeapon()
		if wep.pap != true then
			ply:PrintMessage( HUD_PRINTTALK, "Pack-a-Punch applied to: " .. wep.ClassName)
			nz.Weps.Functions.ApplyPaP( ply, wep )
			timer.Simple(2, function() ply:RemovePerk("pap") end)
			return true
		else
			ply:PrintMessage( HUD_PRINTTALK, "This weapon is already pap'd")
			return false
		end
	end,
})

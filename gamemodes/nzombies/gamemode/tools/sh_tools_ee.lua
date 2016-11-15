nzTools:CreateTool("ee", {
	displayname = "Easter Egg Placer",
	desc = "LMB: Easter Egg, RMB: Remove Easter Egg, Use Player Handler to select song",
	condition = function(wep, ply)
		return true
	end,
	PrimaryAttack = function(wep, ply, tr, data)
		nzMapping:EasterEgg(tr.HitPos, Angle(0,0,0), "models/props_lab/huladoll.mdl", ply)
	end,
	SecondaryAttack = function(wep, ply, tr, data)
		if IsValid(tr.Entity) and tr.Entity:GetClass() == "easter_egg" then
			tr.Entity:Remove()
		end
	end,
	Reload = function(wep, ply, tr, data)
		-- Nothing
	end,
	OnEquip = function(wep, ply, data)

	end,
	OnHolster = function(wep, ply, data)

	end
}, {
	displayname = "Easter Egg Placer",
	desc = "LMB: Easter Egg, RMB: Remove Easter Egg, Use Player Handler to select song",
	icon = "icon16/music.png",
	weight = 20,
	condition = function(wep, ply)
		return true
	end,
	interface = function(frame, data)

	end,
	--defaultdata = {}
})
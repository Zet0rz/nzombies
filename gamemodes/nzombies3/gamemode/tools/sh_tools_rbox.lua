nz.Tools.Functions.CreateTool("rbox", {
	displayname = "Random Box Spawnpoint",
	desc = "LMB: Place Random Box Spawnpoint, RMB: Remove Random Box Spawnpoint",
	condition = function(wep, ply)
		return true
	end,

	PrimaryAttack = function(wep, ply, tr, data)
		Mapping:BoxSpawn(tr.HitPos, Angle(0,(tr.HitPos - ply:GetPos()):Angle()[2] - 90,0), ply)
	end,

	SecondaryAttack = function(wep, ply, tr, data)
		if IsValid(tr.Entity) and tr.Entity:GetClass() == "random_box_spawns" then
			tr.Entity:Remove()
		end
	end,
	Reload = function(wep, ply, tr, data)
		//Nothing
	end,
	OnEquip = function(wep, ply, data)

	end,
	OnHolster = function(wep, ply, data)

	end
}, {
	displayname = "Random Box Spawnpoint",
	desc = "LMB: Place Random Box Spawnpoint, RMB: Remove Random Box Spawnpoint",
	icon = "icon16/briefcase.png",
	weight = 4,
	condition = function(wep, ply)
		return true
	end,
	interface = function(frame, data)

	end,
	//defaultdata = {}
})
nz.Tools.Functions.CreateTool("rbox", {
	displayname = "Random Box Spawnpoint",
	desc = "LMB: Place Random Box Spawnpoint, RMB: Remove Random Box Spawnpoint",
	condition = function(wep, ply)
		return true
	end,

	PrimaryAttack = function(wep, ply, tr, data)
		nzMapping:BoxSpawn(tr.HitPos, Angle(0,(tr.HitPos - ply:GetPos()):Angle()[2] - 90,0), data.PossibleSpawn, ply)
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
		local valz = {}
		valz["Row1"] = data.PossibleSpawn

		local function UpdateData()
			data.PossibleSpawn = valz["Row1"]
			nz.Tools.Functions.SendData(data, "rbox")
		end

		local DProperties = vgui.Create( "DProperties", frame )
		DProperties:SetSize( 280, 180 )
		DProperties:SetPos( 10, 10 )

		local Row1 = DProperties:CreateRow( "Random Box", "Possible Spawn?" )
		Row1:Setup( "Boolean" )
		Row1:SetValue( valz["Row1"] )
		Row1.DataChanged = function( _, val ) valz["Row1"] = val UpdateData() end

		return DProperties
	end,
	defaultdata = {
		PossibleSpawn = 0,
	}
})
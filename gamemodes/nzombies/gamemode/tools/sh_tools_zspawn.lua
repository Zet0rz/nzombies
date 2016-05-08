nz.Tools.Functions.CreateTool("zspawn", {
	displayname = "Zombie Spawn Creator",
	desc = "LMB: Place Spawnpoint, RMB: Remove Spawnpoint, R: Apply New Properties",
	condition = function(wep, ply)
		//Function to check whether a player can access this tool - always accessible
		return true
	end,
	PrimaryAttack = function(wep, ply, tr, data)
		//Create a new spawnpoint and set its data to the guns properties
		local ent = nzMapping:ZedSpawn(tr.HitPos, data.link, ply)

		ent.flag = data.flag
		if tobool(data.flag) and ent.link != "" then
			ent.link = data.link
		end

		//For the link displayer
		if data.link then
			ent:SetLink(data.link)
		end
	end,
	SecondaryAttack = function(wep, ply, tr, data)
		//Remove entity if it is a zombie spawnpoint
		if IsValid(tr.Entity) and tr.Entity:GetClass() == "nz_spawn_zombie_normal" then
			tr.Entity:Remove()
		end
	end,
	Reload = function(wep, ply, tr, data)
		//Target the entity and change its data
		local ent = tr.Entity
		if IsValid(ent) and ent:GetClass() == "nz_spawn_zombie_normal" then
			ent.link = data.link

			//For the link displayer
			if data.link then
				ent:SetLink(data.link)
			end
		end
	end,
	OnEquip = function(wep, ply, data)

	end,
	OnHolster = function(wep, ply, data)

	end
}, { //Switch on to the client table (interfaces, defaults, HUD elements)
	displayname = "Zombie Spawn Creator",
	desc = "LMB: Place Spawnpoint, RMB: Remove Spawnpoint, R: Apply New Properties",
	icon = "icon16/user_green.png",
	weight = 1,
	condition = function(wep, ply)
		//Function to check whether a player can access this tool - always accessible
		return true
	end,
	interface = function(frame, data)
		local valz = {}
		valz["Row1"] = data.flag
		valz["Row2"] = data.link

		local function UpdateData()
			local str="nil"
			if valz["Row1"] == 0 then
				str=nil
				data.flag = 0
			else
				str=valz["Row2"]
				data.flag = 1
			end
			data.link = str

			nz.Tools.Functions.SendData(data, "zspawn")
		end

		local DProperties = vgui.Create( "DProperties", frame )
		DProperties:SetSize( 280, 180 )
		DProperties:SetPos( 10, 10 )

		local Row1 = DProperties:CreateRow( "Zombie Spawn", "Enable Flag?" )
		Row1:Setup( "Boolean" )
		Row1:SetValue( valz["Row1"] )
		Row1.DataChanged = function( _, val ) valz["Row1"] = val UpdateData() end
		local Row2 = DProperties:CreateRow( "Zombie Spawn", "Flag" )
		Row2:Setup( "Integer" )
		Row2:SetValue( valz["Row2"] )
		Row2.DataChanged = function( _, val ) valz["Row2"] = val UpdateData() end

		return DProperties
	end,
	defaultdata = {
		flag = 0,
		link = 1,
	}
})

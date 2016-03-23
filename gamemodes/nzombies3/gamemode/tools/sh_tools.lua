//

function nz.Tools.Functions.CreateTool(id, serverdata, clientdata)
	if SERVER then
		nz.Tools.ToolData[id] = serverdata
	else
		nz.Tools.ToolData[id] = clientdata
	end
end

function nz.Tools.Functions.Get(id)
	return nz.Tools.ToolData[id]
end

function nz.Tools.Functions.GetList()
	local tbl = {}

	for k,v in pairs(nz.Tools.ToolData) do
		tbl[k] = v.displayname
	end

	return tbl
end

nz.Tools.Functions.CreateTool("default", {
	displayname = "Multitool",
	desc = "Hold Q to pick a tool to use",
	condition = function(wep, ply)
		return false
	end,

	PrimaryAttack = function(wep, ply, tr, data)
	end,

	SecondaryAttack = function(wep, ply, tr, data)
	end,
	Reload = function(wep, ply, tr, data)
		//Nothing
	end,
	OnEquip = function(wep, ply, data)

	end,
	OnHolster = function(wep, ply, data)

	end
}, {
	displayname = "Multitool",
	desc = "Hold Q to pick a tool to use",
	condition = function(wep, ply)
		return false
	end,
	interface = function(frame, data)
		local text = vgui.Create("DLabel", frame)
		text:SetText("Select a tool in the list to the left.")
		text:SetFont("Trebuchet18")
		text:SetTextColor( Color(50, 50, 50) )
		text:SizeToContents()
		text:Center()

		return text
	end,
	//defaultdata = {}
})

nz.Tools.Functions.CreateTool("zspawn", {
	displayname = "Zombie Spawn Creator",
	desc = "LMB: Place Spawnpoint, RMB: Remove Spawnpoint, R: Apply New Properties",
	condition = function(wep, ply)
		//Function to check whether a player can access this tool - always accessible
		return true
	end,
	PrimaryAttack = function(wep, ply, tr, data)
		//Create a new spawnpoint and set its data to the guns properties
		local ent = Mapping:ZedSpawn(tr.HitPos, nil, nil, ply)

		ent.flag = data.flag
		if tobool(data.flag) and ent.link != "" then
			ent.link = data.link
		end
		ent.respawnable = data.respawnable
		ent.spawnable = data.spawnable
		if data.respawnable != 1 then
			if table.HasValue(nz.Enemies.Data.RespawnableSpawnpoints, ent) then
				table.RemoveByValue(nz.Enemies.Data.RespawnableSpawnpoints, ent)
			end
		else
			if !table.HasValue(nz.Enemies.Data.RespawnableSpawnpoints, ent) then
				table.insert(nz.Enemies.Data.RespawnableSpawnpoints, ent)
			end
		end

		//For the link displayer
		if data.link then
			ent:SetLink(data.link)
		end
	end,
	SecondaryAttack = function(wep, ply, tr, data)
		//Remove entity if it is a zombie spawnpoint
		if IsValid(tr.Entity) and tr.Entity:GetClass() == "zed_spawns" then
			tr.Entity:Remove()
		end
	end,
	Reload = function(wep, ply, tr, data)
		//Target the entity and change its data
		local ent = tr.Entity
		if IsValid(ent) and ent:GetClass() == "zed_spawns" then
			ent.link = data.link
			ent.respawnable = data.respawnable
			ent.spawnable = data.spawnable
			if data.respawnable != 1 then
				if table.HasValue(nz.Enemies.Data.RespawnableSpawnpoints, ent) then
					table.RemoveByValue(nz.Enemies.Data.RespawnableSpawnpoints, ent)
				end
			else
				if !table.HasValue(nz.Enemies.Data.RespawnableSpawnpoints, ent) then
					table.insert(nz.Enemies.Data.RespawnableSpawnpoints, ent)
				end
			end
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
		valz["Row3"] = data.spawnable
		valz["Row4"] = data.respawnable

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
			data.spawnable = valz["Row3"]
			data.respawnable = valz["Row4"]

			PrintTable(data)

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

		if nz.Tools.Advanced then
			local Row3 = DProperties:CreateRow( "Advanced Zombie Spawn", "Spawnable at?" )
			Row3:Setup( "Boolean" )
			Row3:SetValue( valz["Row3"] )
			Row3.DataChanged = function( _, val ) valz["Row3"] = val UpdateData() end
			local Row4 = DProperties:CreateRow( "Advanced Zombie Spawn", "Respawn from?" )
			Row4:Setup( "Boolean" )
			Row4:SetValue( valz["Row4"] )
			Row4.DataChanged = function( _, val ) valz["Row4"] = val UpdateData() end
		else
			local text = vgui.Create("DLabel", DProperties)
			text:SetText("Enable Advanced Mode for more options.")
			text:SetFont("Trebuchet18")
			text:SetTextColor( Color(50, 50, 50) )
			text:SizeToContents()
			text:Center()
		end

		return DProperties
	end,
	defaultdata = {
		flag = 0,
		link = 1,
		spawnable = 1,
		respawnable = 1,
	}
})

nz.Tools.Functions.CreateTool("pspawn", {
	displayname = "Player Spawn Creator",
	desc = "LMB: Place Spawnpoint, RMB: Remove Spawnpoint",
	condition = function(wep, ply)
		return true
	end,
	PrimaryAttack = function(wep, ply, tr, data)
		Mapping:PlayerSpawn(tr.HitPos, ply)
	end,
	SecondaryAttack = function(wep, ply, tr, data)
		if IsValid(tr.Entity) and tr.Entity:GetClass() == "player_spawns" then
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
	displayname = "Player Spawn Creator",
	desc = "LMB: Place Spawnpoint, RMB: Remove Spawnpoint",
	icon = "icon16/controller.png",
	weight = 2,
	condition = function(wep, ply)
		return true
	end,
	interface = function(frame, data) end,
	//defaultdata = {}
})

nz.Tools.Functions.CreateTool("barricade", {
	displayname = "Barricade Creator",
	desc = "LMB: Place Barricade, RMB: Remove Barricade",
	condition = function(wep, ply)
		return true
	end,
	PrimaryAttack = function(wep, ply, tr, data)
		Mapping:BreakEntry(tr.HitPos, Angle(0,(tr.HitPos - ply:GetPos()):Angle()[2],0), ply)
	end,
	SecondaryAttack = function(wep, ply, tr, data)
		if IsValid(tr.Entity) and tr.Entity:GetClass() == "breakable_entry" then
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
	displayname = "Barricade Creator",
	desc = "LMB: Place Barricade, RMB: Remove Barricade",
	icon = "icon16/door.png",
	weight = 7,
	condition = function(wep, ply)
		return true
	end,
	interface = function(frame, data) return nil end,
	//defaultdata = {}
})

nz.Tools.Functions.CreateTool("block", {
	displayname = "Invisible Block Spawner",
	desc = "LMB: Create Invisible Block, RMB: Remove Invisible Block, R: Change Model",
	condition = function(wep, ply)
		return true
	end,
	PrimaryAttack = function(wep, ply, tr, data)
		Mapping:BlockSpawn(tr.HitPos,Angle(90,(tr.HitPos - ply:GetPos()):Angle()[2] + 90,90), data.model, ply)
	end,
	SecondaryAttack = function(wep, ply, tr, data)
		if IsValid(tr.Entity) and tr.Entity:GetClass() == "wall_block" then
			tr.Entity:Remove()
		end
	end,
	Reload = function(wep, ply, tr, data)
		if IsValid(tr.Entity) and tr.Entity:GetClass() == "wall_block" then
			tr.Entity:SetModel(data.model)
		end
	end,
	OnEquip = function(wep, ply, data)

	end,
	OnHolster = function(wep, ply, data)

	end
}, {
	displayname = "Invisible Block Spawner",
	desc = "LMB: Create Invisible Block, RMB: Remove Invisible Block, R: Change Model",
	icon = "icon16/shading.png",
	weight = 15,
	condition = function(wep, ply)
		return true
	end,
	interface = function(frame, data)
		local Scroll = vgui.Create( "DScrollPanel", frame )
		Scroll:SetSize( 280, 300 )
		Scroll:SetPos( 10, 10 )

		local List	= vgui.Create( "DIconLayout", Scroll )
		List:SetSize( 340, 200 )
		List:SetPos( 0, 0 )
		List:SetSpaceY( 5 )
		List:SetSpaceX( 5 )

		local function UpdateData()
			nz.Tools.Functions.SendData( {model = data.model}, "block", {model = data.model})
		end

		local models = util.KeyValuesToTable((file.Read("settings/spawnlist/default/023-general.txt", "MOD")))

		for k,v in pairs(models["contents"]) do
			if v.model then
				local Blockmodel = List:Add( "SpawnIcon" )
				Blockmodel:SetSize( 40, 40 )
				Blockmodel:SetModel(v.model)
				Blockmodel.DoClick = function()
					data.model = v.model
					UpdateData()
				end
				Blockmodel.Paint = function(self)
					if data.model == v.model then
						surface.SetDrawColor(0,0,200)
						self:DrawOutlinedRect()
					end
				end
			end
		end

		return Scroll
	end,
	defaultdata = {
		model = "models/hunter/plates/plate2x2.mdl"
	},
})

nz.Tools.Functions.CreateTool("door", {
	displayname = "Door Locker",
	desc = "LMB: Apply Door Data, RMB: Remove Door Data, C: Change Properties",
	condition = function(wep, ply)
		return true
	end,
	PrimaryAttack = function(wep, ply, tr, data)
		PrintTable(data)
		local ent = tr.Entity
		if !IsValid(ent) then return end
		if ent:IsDoor() or ent:IsBuyableProp() or ent:IsButton() then
			Doors:CreateLink(ent, data.flags)
		else
			ply:ChatPrint("That is not a valid door.")
		end
	end,
	SecondaryAttack = function(wep, ply, tr, data)
		local ent = tr.Entity
		if !IsValid(ent) then return end
		if ent:IsDoor() or ent:IsBuyableProp() or ent:IsButton() then
			nz.Nav.Functions.UnlinkAutoMergeLink(ent)
			Doors:RemoveLink(ent)
		end
	end,
	Reload = function(wep, ply, tr, data)
		local ent = tr.Entity
		if !IsValid(ent) then return end
		if ent:IsDoor() or ent:IsBuyableProp() or ent:IsButton() then
			Doors:DisplayDoorLinks(ent)
		end
	end,
	OnEquip = function(wep, ply, data)

	end,
	OnHolster = function(wep, ply, data)

	end
}, {
	displayname = "Door Locker",
	desc = "LMB: Apply Door Data, RMB: Remove Door Data, C: Change Properties",
	icon = "icon16/lock.png",
	weight = 3,
	condition = function(wep, ply)
		return true
	end,
	interface = function(frame, data)
		local valz = {}
		valz["Row1"] = data.flag
		valz["Row2"] = data.link
		valz["Row3"] = data.price
		valz["Row4"] = data.elec
		valz["Row5"] = data.buyable
		valz["Row6"] = data.rebuyable

		valz["Row7"] = data.navgroup1
		valz["Row8"] = data.navgroup2

		local function UpdateData()
			local function compileString(price, elec, flag, buyable, rebuyable, navgroup1, navgroup2)
				local str = "price="..price..",elec="..elec
				if flag then
					str = str..",link="..flag
				end
				str = str..",buyable="..buyable
				str = str..",rebuyable="..rebuyable
				if navgroup1 and navgroup1 != "" then
					str = str..",navgroup1="..navgroup1
				end
				if navgroup2 and navgroup2 != "" then
					str = str..",navgroup2="..navgroup2
				end
				return str
			end
			local flag = false
			if valz["Row1"] == 1 then
				flag = valz["Row2"]
			end
			local flagString = compileString(valz["Row3"], valz["Row4"], flag, valz["Row5"], valz["Row6"], valz["Row7"], valz["Row8"])
			print(flagString)

			nz.Tools.Functions.SendData( {flags = flagString}, "door", {
				flag = valz["Row1"],
				link = valz["Row2"],
				price = valz["Row3"],
				elec = valz["Row4"],
				buyable = valz["Row5"],
				rebuyable = valz["Row6"],
				navgroup1 = valz["Row7"],
				navgroup2 = valz["Row8"],
			})
		end

		-- We call it immediately as it would otherwise auto-send our table to the server, not the compiled string
		UpdateData()

		local DProperties = vgui.Create( "DProperties", frame )
		DProperties:SetSize( 280, 260 )
		DProperties:SetPos( 10, 10 )

		local Row1 = DProperties:CreateRow( "Door Settings", "Enable Flag?" )
		Row1:Setup( "Boolean" )
		Row1:SetValue( valz["Row1"] )
		Row1.DataChanged = function( _, val ) valz["Row1"] = val UpdateData() end
		local Row2 = DProperties:CreateRow( "Door Settings", "Flag" )
		Row2:Setup( "Integer" )
		Row2:SetValue( valz["Row2"] )
		Row2.DataChanged = function( _, val ) valz["Row2"] = val UpdateData() end
		local Row3 = DProperties:CreateRow( "Door Settings", "Price" )
		Row3:Setup( "Integer" )
		Row3:SetValue( valz["Row3"] )
		Row3.DataChanged = function( _, val ) valz["Row3"] = val UpdateData() end
		local Row4 = DProperties:CreateRow( "Door Settings", "Requires Electricity?" )
		Row4:Setup( "Boolean" )
		Row4:SetValue( valz["Row4"] )
		Row4.DataChanged = function( _, val ) valz["Row4"] = val UpdateData() end

		if nz.Tools.Advanced then
			local Row5 = DProperties:CreateRow( "Advanced Door Settings", "Purchaseable?" )
			Row5:Setup( "Boolean" )
			Row5:SetValue( valz["Row5"] )
			Row5.DataChanged = function( _, val ) valz["Row5"] = val UpdateData() end
			local Row6 = DProperties:CreateRow( "Advanced Door Settings", "Rebuyable?" )
			Row6:Setup( "Boolean" )
			Row6:SetValue( valz["Row6"] )
			Row6.DataChanged = function( _, val ) valz["Row6"] = val UpdateData() end

			local Row7 = DProperties:CreateRow( "Nav Group Merging", "Group 1 ID" )
			Row7:Setup( "Generic" )
			Row7:SetValue( valz["Row7"] )
			Row7.DataChanged = function( _, val ) valz["Row7"] = val UpdateData() end
			local Row8 = DProperties:CreateRow( "Nav Group Merging", "Group 2 ID" )
			Row8:Setup( "Generic" )
			Row8:SetValue( valz["Row8"] )
			Row8.DataChanged = function( _, val ) valz["Row8"] = val UpdateData() end
		else
			local text = vgui.Create("DLabel", DProperties)
			text:SetText("Enable Advanced Mode for more options.")
			text:SetFont("Trebuchet18")
			text:SetTextColor( Color(50, 50, 50) )
			text:SizeToContents()
			text:Center()
		end

		return DProperties
	end,
	defaultdata = {
		flags = "flag=0,price=1000,elec=0,buyable=1,rebuyable=0",
		flag = 0,
		link = 1,
		price = 1000,
		elec = 0,
		buyable = 1,
		rebuyable = 0,

		navgroup1 = "",
		navgroup2 = "",
	}
})

nz.Tools.Functions.CreateTool("ee", {
	displayname = "Easter Egg Placer",
	desc = "LMB: Easter Egg, RMB: Remove Easter Egg, Use Player Handler to select song",
	condition = function(wep, ply)
		return true
	end,
	PrimaryAttack = function(wep, ply, tr, data)
		Mapping:EasterEgg(tr.HitPos, Angle(0,0,0), "models/props_lab/huladoll.mdl", ply)
	end,
	SecondaryAttack = function(wep, ply, tr, data)
		if IsValid(tr.Entity) and tr.Entity:GetClass() == "easter_egg" then
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
	displayname = "Easter Egg Placer",
	desc = "LMB: Easter Egg, RMB: Remove Easter Egg, Use Player Handler to select song",
	icon = "icon16/music.png",
	weight = 20,
	condition = function(wep, ply)
		return true
	end,
	interface = function(frame, data)

	end,
	//defaultdata = {}
})

nz.Tools.Functions.CreateTool("elec", {
	displayname = "Electricity Switch Placer",
	desc = "LMB: Place Electricity Switch, RMB: Remove Switch",
	condition = function(wep, ply)
		return true
	end,

	PrimaryAttack = function(wep, ply, tr, data)
		Mapping:Electric(tr.HitPos + tr.HitNormal*5, tr.HitNormal:Angle(), nil, ply)
	end,

	SecondaryAttack = function(wep, ply, tr, data)
		if IsValid(tr.Entity) and tr.Entity:GetClass() == "power_box" then
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
	displayname = "Electricity Switch Placer",
	desc = "LMB: Place Electricity Switch, RMB: Remove Switch",
	icon = "icon16/lightning.png",
	weight = 8,
	condition = function(wep, ply)
		return true
	end,
	interface = function(frame, data)

	end,
	//defaultdata = {}
})

nz.Tools.Functions.CreateTool("navlock", {
	displayname = "Nav Locker Tool",
	desc = "LMB: Connect doors and navmeshes, RMB: Lock/Unlock navmeshes",
	condition = function(wep, ply)
		//Serverside doesn't need to block
		return true
	end,
	PrimaryAttack = function(wep, ply, tr, data)
		local pos = tr.HitPos
		if tr.HitWorld or wep.Owner:KeyDown(IN_SPEED) then
			if !IsValid(wep.Ent1) then wep.Owner:ChatPrint("You need to mark a door first to link an area.") return end
			local navarea = navmesh.GetNearestNavArea(pos)
			local id = navarea:GetID()

			nz.Nav.Data[id] = {
				prev = navarea:GetAttributes(),
				locked = true,
				link = wep.Ent1:GetDoorData().link
			}
			//Purely to visualize, resets when game begins or shuts down
			navarea:SetAttributes(NAV_MESH_STOP)

			wep.Owner:ChatPrint("Navmesh ["..id.."] locked to door "..wep.Ent1:GetClass().."["..wep.Ent1:EntIndex().."] with link ["..wep.Ent1:GetDoorData().link.."]!")
			wep.Ent1:SetMaterial( "" )
			nz.Nav.Functions.CreateAutoMergeLink(wep.Ent1, id)
			wep.Ent1 = nil
		return end

		local ent = tr.Entity
		if !IsNavApplicable(ent) then
			wep.Owner:ChatPrint("Only buyable props, doors, and buyable buttons with LINKS can be linked to navareas.")
		return end

		if IsValid(wep.Ent1) and wep.Ent1 != ent then
			wep.Ent1:SetMaterial( "" )
		end

		wep.Ent1 = ent
		ent:SetMaterial( "hunter/myplastic.vtf" )
	end,
	SecondaryAttack = function(wep, ply, tr, data)
		if(!tr.HitPos)then return false end
		local pos = tr.HitPos
		local navarea = navmesh.GetNearestNavArea(pos)
		local navid = navarea:GetID()

		if nz.Nav.Data[navid] then
			navarea:SetAttributes(nz.Nav.Data[navid].prev)
			wep.Owner:ChatPrint("Navmesh ["..navid.."] unlocked!")
			nz.Nav.Data[navid] = nil
		return end

		nz.Nav.Data[navid] = {
			prev = navarea:GetAttributes(),
			locked = true,
			link = nil
		}

		navarea:SetAttributes(NAV_MESH_AVOID)
		wep.Owner:ChatPrint("Navmesh ["..navid.."] locked!")
	end,
	Reload = function(wep, ply, tr, data)
		//Nothing
	end,
	OnEquip = function(wep, ply, data)
		if wep.Owner:IsListenServerHost() then
			RunConsoleCommand("nav_edit", 1)
			RunConsoleCommand("nav_quicksave", 0)
		end
	end,
	OnHolster = function(wep, ply, data)
		if SERVER and wep.Owner:IsListenServerHost() then
			RunConsoleCommand("nav_edit", 0)
		end
		return true
	end
}, {
	displayname = "Nav Locker Tool",
	desc = "LMB: Connect doors and navmeshes, RMB: Lock/Unlock navmeshes",
	icon = "icon16/arrow_switch.png",
	weight = 40,
	condition = function(wep, ply)
		//Client needs advanced editing on to see the tool
		return nz.Tools.Advanced
	end,
	interface = function(frame, data)
		local panel = vgui.Create("DPanel", frame)
		panel:SetSize(frame:GetSize())

		local textw = vgui.Create("DLabel", panel)
		textw:SetText("You need to be in a listen/local server to be")
		textw:SetFont("Trebuchet18")
		textw:SetTextColor( Color(150, 50, 50) )
		textw:SizeToContents()
		textw:SetPos(0, 20)
		textw:CenterHorizontal()

		local textw2 = vgui.Create("DLabel", panel)
		textw2:SetText("able to see the Navmeshes!")
		textw2:SetFont("Trebuchet18")
		textw2:SetTextColor( Color(150, 50, 50) )
		textw2:SizeToContents()
		textw2:SetPos(0, 30)
		textw2:CenterHorizontal()

		local textw3 = vgui.Create("DLabel", panel)
		textw3:SetText("The tool can still be used blindly")
		textw3:SetFont("Trebuchet18")
		textw3:SetTextColor( Color(50, 50, 50) )
		textw3:SizeToContents()
		textw3:SetPos(0, 40)
		textw3:CenterHorizontal()

		local text = vgui.Create("DLabel", panel)
		text:SetText("Right click on the ground to lock a Navmesh")
		text:SetFont("Trebuchet18")
		text:SetTextColor( Color(50, 50, 50) )
		text:SizeToContents()
		text:SetPos(0, 80)
		text:CenterHorizontal()

		local text2 = vgui.Create("DLabel", panel)
		text2:SetText("Left click a door to mark the door")
		text2:SetFont("Trebuchet18")
		text2:SetTextColor( Color(50, 50, 50) )
		text2:SizeToContents()
		text2:SetPos(0, 120)
		text2:CenterHorizontal()

		local text3 = vgui.Create("DLabel", panel)
		text3:SetText("then left click the ground to link")
		text3:SetFont("Trebuchet18")
		text3:SetTextColor( Color(50, 50, 50) )
		text3:SizeToContents()
		text3:SetPos(0, 130)
		text3:CenterHorizontal()

		local text4 = vgui.Create("DLabel", panel)
		text4:SetText("the Navmesh with the door")
		text4:SetFont("Trebuchet18")
		text4:SetTextColor( Color(50, 50, 50) )
		text4:SizeToContents()
		text4:SetPos(0, 140)
		text4:CenterHorizontal()

		local text5 = vgui.Create("DLabel", panel)
		text5:SetText("Zombies can't pathfind through locked Navmeshes")
		text5:SetFont("Trebuchet18")
		text5:SetTextColor( Color(50, 50, 50) )
		text5:SizeToContents()
		text5:SetPos(0, 180)
		text5:CenterHorizontal()

		local text6 = vgui.Create("DLabel", panel)
		text6:SetText("unless their door link is opened")
		text6:SetFont("Trebuchet18")
		text6:SetTextColor( Color(50, 50, 50) )
		text6:SizeToContents()
		text6:SetPos(0, 190)
		text6:CenterHorizontal()

		return panel
	end,
	//defaultdata = {}
})

nz.Tools.Functions.CreateTool("perk", {
	displayname = "Perk Machine Placer",
	desc = "LMB: Place Perk Machine, RMB: Remove Perk Machine, C: Change Perk",
	condition = function(wep, ply)
		return true
	end,

	PrimaryAttack = function(wep, ply, tr, data)
		Mapping:PerkMachine(tr.HitPos, Angle(0,(ply:GetPos() - tr.HitPos):Angle()[2],0), data.perk, ply)
	end,

	SecondaryAttack = function(wep, ply, tr, data)
		if IsValid(tr.Entity) and tr.Entity:GetClass() == "perk_machine" then
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
	displayname = "Perk Machine Placer",
	desc = "LMB: Place Perk Machine, RMB: Remove Perk Machine, C: Change Perk",
	icon = "icon16/drink.png",
	weight = 6,
	condition = function(wep, ply)
		return true
	end,
	interface = function(frame, data)

		local choices = vgui.Create( "DComboBox", frame )
		choices:SetPos( 10, 10 )
		choices:SetSize( 280, 30 )
		choices:SetValue( nz.Perks.Functions.Get(data.perk).name )
		for k,v in pairs(nz.Perks.Functions.GetList()) do
			choices:AddChoice( v, k )
		end
		choices.OnSelect = function( panel, index, value, id )
			data.perk = id
			nz.Tools.Functions.SendData( data, "perk" )
		end

		return choices
	end,
	defaultdata = {perk = "jugg"},
})

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

nz.Tools.Functions.CreateTool("wallbuy", {
	displayname = "Weapon Buy Placer",
	desc = "LMB: Place Weapon Buy, RMB: Remove Weapon Buy, R: Rotate, C: Change Properties",
	condition = function(wep, ply)
		return true
	end,

	PrimaryAttack = function(wep, ply, tr, data)
		local ang = tr.HitNormal:Angle()
		ang:RotateAroundAxis(tr.HitNormal:Angle():Up()*-1, 90)
		Mapping:WallBuy(tr.HitPos + tr.HitNormal*0.5, data.class, tonumber(data.price), ang, nil, ply)
	end,

	SecondaryAttack = function(wep, ply, tr, data)
		if IsValid(tr.Entity) and tr.Entity:GetClass() == "wall_buys" then
			tr.Entity:Remove()
		end
	end,
	Reload = function(wep, ply, tr, data)
		if IsValid(tr.Entity) and tr.Entity:GetClass() == "wall_buys" then
			tr.Entity:ToggleRotate()
		end
	end,
	OnEquip = function(wep, ply, data)

	end,
	OnHolster = function(wep, ply, data)

	end
}, {
	displayname = "Weapon Buy Placer",
	desc = "LMB: Place Weapon Buy, RMB: Remove Weapon Buy, R: Rotate, C: Change Properties",
	icon = "icon16/cart.png",
	weight = 5,
	condition = function(wep, ply)
		return true
	end,
	interface = function(frame, data)
		local valz = {}
		valz["Row1"] = data.class
		valz["Row2"] = data.price

		local function UpdateData()
		//Check the weapon class is fine first
			if weapons.Get( valz["Row1"] ) then
				data.class = valz["Row1"]
				data.price = tostring(valz["Row2"])
				nz.Tools.Functions.SendData( data, "wallbuy" )
			else
				ErrorNoHalt("NZ: This weapon class is not valid!")
			end
		end

		local DProperties = vgui.Create( "DProperties", frame )
		DProperties:SetSize( 280, 180 )
		DProperties:SetPos( 10, 10 )

		local Row1 = DProperties:CreateRow( "Weapon Settings", "Weapon Class" )
		Row1:Setup( "Combo" )
		for k,v in pairs(weapons.GetList()) do
			if v.Category and v.Category != "" then
				Row1:AddChoice(v.PrintName and v.PrintName != "" and v.Category.. " - "..v.PrintName or v.ClassName, v.ClassName, false)
			else
				Row1:AddChoice(v.PrintName and v.PrintName != "" and v.PrintName or v.ClassName, v.ClassName, false)
			end
		end
		Row1.DataChanged = function( _, val ) valz["Row1"] = val UpdateData() end

		local Row2 = DProperties:CreateRow( "Weapon Settings", "Price" )
		Row2:Setup( "Integer" )
		Row2:SetValue( valz["Row2"] )
		Row2.DataChanged = function( _, val ) valz["Row2"] = val UpdateData() end

		return DProperties
	end,
	defaultdata = {
		class = "weapon_class",
		price = 500,
	}
})

nz.Tools.Functions.CreateTool("navladder", {
	displayname = "Nav Ladder Generation Tool",
	desc = "LMB: Add Ladder at Cursor to Navmesh, Use console command 'nav_save' to save changes",
	condition = function(wep, ply)
		return nz.Tools.Advanced
	end,

	PrimaryAttack = function(wep, ply, tr, data)
		ply:ConCommand( "nav_build_ladder" )
	end,

	SecondaryAttack = function(wep, ply, tr, data)
	end,
	Reload = function(wep, ply, tr, data)
	end,
	OnEquip = function(wep, ply, data)
		if wep.Owner:IsListenServerHost() and GetConVar("sv_cheats"):GetBool() then
			RunConsoleCommand("nav_edit", 1)
		end
	end,
	OnHolster = function(wep, ply, data)
		if SERVER and wep.Owner:IsListenServerHost() and GetConVar("sv_cheats"):GetBool() then
			RunConsoleCommand("nav_edit", 0)
		end
	end
}, {
	displayname = "Nav Ladder Generation Tool",
	desc = "LMB: Create Nav Ladder at Cursor, Use console command 'nav_save' to save changes",
	icon = "icon16/table_relationship.png",
	weight = 50,
	condition = function(wep, ply)
		return nz.Tools.Advanced
	end,
	interface = function(frame, data)
		local panel = vgui.Create("DPanel", frame)
		panel:SetSize(frame:GetSize())

		local textw = vgui.Create("DLabel", panel)
		textw:SetText("You need to be in a listen/local server to be")
		textw:SetFont("Trebuchet18")
		textw:SetTextColor( Color(150, 50, 50) )
		textw:SizeToContents()
		textw:SetPos(0, 80)
		textw:CenterHorizontal()

		local textw2 = vgui.Create("DLabel", panel)
		textw2:SetText("able to see the Navmeshes!")
		textw2:SetFont("Trebuchet18")
		textw2:SetTextColor( Color(150, 50, 50) )
		textw2:SizeToContents()
		textw2:SetPos(0, 90)
		textw2:CenterHorizontal()

		local textw3 = vgui.Create("DLabel", panel)
		textw3:SetText("The tool can still be used blindly")
		textw3:SetFont("Trebuchet18")
		textw3:SetTextColor( Color(50, 50, 50) )
		textw3:SizeToContents()
		textw3:SetPos(0, 100)
		textw3:CenterHorizontal()

		local text = vgui.Create("DLabel", panel)
		text:SetText("Use nav_save to save changes into the map's .nav")
		text:SetFont("Trebuchet18")
		text:SetTextColor( Color(50, 50, 50) )
		text:SizeToContents()
		text:SetPos(0, 140)
		text:CenterHorizontal()

		local text2 = vgui.Create("DLabel", panel)
		text2:SetText("This requires sv_cheats 1!")
		text2:SetFont("Trebuchet18")
		text2:SetTextColor( Color(150, 50, 50) )
		text2:SizeToContents()
		text2:SetPos(0, 150)
		text2:CenterHorizontal()

		return panel
	end,
	//defaultdata = {}
})

nz.Tools.Functions.CreateTool("settings", {
	displayname = "Map Settings",
	desc = "Use the Tool Interface and press Submit to save changes",
	condition = function(wep, ply)
		return true
	end,

	PrimaryAttack = function(wep, ply, tr, data)
	end,
	SecondaryAttack = function(wep, ply, tr, data)
	end,
	Reload = function(wep, ply, tr, data)
	end,
	OnEquip = function(wep, ply, data)
	end,
	OnHolster = function(wep, ply, data)
	end
}, {
	displayname = "Map Settings",
	desc = "Use the Tool Interface and press Submit to save changes",
	icon = "icon16/cog.png",
	weight = 25,
	condition = function(wep, ply)
		return true
	end,
	interface = function(frame, data)
		local data = table.Copy(Mapping.Settings)
		local valz = {}
		valz["Row1"] = data.startwep or "Select ..."
		valz["Row2"] = data.startpoints or 500
		valz["Row3"] = data.maxwep or 2
		valz["Row4"] = data.eeurl or ""
		valz["Row5"] = data.script or false
		valz["Row6"] = data.scriptinfo or ""
		valz["RBoxWeps"] = data.RBoxWeps or {}

		local sheet = vgui.Create( "DPropertySheet", frame )
		sheet:SetSize( 280, 250 )
		sheet:SetPos( 10, 10 )

		local DProperties = vgui.Create( "DProperties", DProperySheet )
		DProperties:SetSize( 280, 250 )
		DProperties:SetPos( 0, 0 )
		sheet:AddSheet( "Map Properties", DProperties, "icon16/cog.png")

		local Row1 = DProperties:CreateRow( "Map Settings", "Starting Weapon" )
		Row1:Setup( "Combo" )
		for k,v in pairs(weapons.GetList()) do
			if v.Category and v.Category != "" then
				Row1:AddChoice(v.PrintName and v.PrintName != "" and v.Category.. " - "..v.PrintName or v.ClassName, v.ClassName, false)
			else
				Row1:AddChoice(v.PrintName and v.PrintName != "" and v.PrintName or v.ClassName, v.ClassName, false)
			end
		end
		if data.startwep then
			local wep = weapons.Get(data.startwep)
			if !wep then wep = weapons.Get(nz.Config.BaseStartingWeapons[1]) end
			if wep.Category and wep.Category != "" then
				Row1:AddChoice(wep.PrintName and wep.PrintName != "" and wep.Category.. " - "..wep.PrintName or wep.ClassName, wep.ClassName, false)
			else
				Row1:AddChoice(wep.PrintName and wep.PrintName != "" and wep.PrintName or wep.ClassName, wep.ClassName, false)
			end
		end

		Row1.DataChanged = function( _, val ) valz["Row1"] = val end

		local Row2 = DProperties:CreateRow( "Map Settings", "Starting Points" )
		Row2:Setup( "Integer" )
		Row2:SetValue( valz["Row2"] )
		Row2.DataChanged = function( _, val ) valz["Row2"] = val end

		local Row3 = DProperties:CreateRow( "Map Settings", "Max Weapons" )
		Row3:Setup( "Integer" )
		Row3:SetValue( valz["Row3"] )
		Row3.DataChanged = function( _, val ) valz["Row3"] = val end

		local Row4 = DProperties:CreateRow( "Map Settings", "Easter Egg Song URL" )
		Row4:Setup( "Generic" )
		Row4:SetValue( valz["Row4"] )
		Row4.DataChanged = function( _, val ) valz["Row4"] = val end
		Row4:SetTooltip("Add a link to a SoundCloud track to play this when all easter eggs have been found")
		
		if nz.Tools.Advanced then
			local Row5 = DProperties:CreateRow( "Map Settings", "Includes Map Script?" )
			Row5:Setup( "Boolean" )
			Row5:SetValue( valz["Row5"] )
			Row5.DataChanged = function( _, val ) valz["Row5"] = val end
			Row5:SetTooltip("Loads a .lua file with the same name as the config .txt from /lua/nzmapscripts - for advanced developers.")
		
			local Row6 = DProperties:CreateRow( "Map Settings", "Script Description" )
			Row6:Setup( "Generic" )
			Row6:SetValue( valz["Row6"] )
			Row6.DataChanged = function( _, val ) valz["Row6"] = val end
			Row6:SetTooltip("Sets the description displayed when attempting to load the script.")
		end
		
		local function UpdateData()
			if !weapons.Get( valz["Row1"] ) then data.startwep = nil else data.startwep = valz["Row1"] end
			if !tonumber(valz["Row2"]) then data.startpoints = 500 else data.startpoints = tonumber(valz["Row2"]) end
			if !tonumber(valz["Row3"]) then data.numweps = 2 else data.numweps = tonumber(valz["Row3"]) end
			if !valz["Row4"] or valz["Row4"] == "" then data.eeurl = nil else data.eeurl = valz["Row4"] end
			if !valz["Row5"] then data.script = nil else data.script = valz["Row5"] end
			if !valz["Row6"] or valz["Row6"] == "" then data.scriptinfo = nil else data.scriptinfo = valz["Row6"] end
			if !valz["RBoxWeps"] or !valz["RBoxWeps"][1] then data.rboxweps = nil else data.rboxweps = valz["RBoxWeps"] end
			PrintTable(data)

			Mapping:SendMapData( data )
		end

		local DermaButton = vgui.Create( "DButton", DProperties )
		DermaButton:SetText( "Submit" )
		DermaButton:SetPos( 0, 180 )
		DermaButton:SetSize( 260, 30 )
		DermaButton.DoClick = UpdateData

		if nz.Tools.Advanced then
			local weplist = {}
			local numweplist = 0

			local rboxpanel = vgui.Create("DPanel", sheet)
			sheet:AddSheet( "Random Box Weapons", rboxpanel, "icon16/box.png")
			rboxpanel.Paint = function() return end

			local rbweplist = vgui.Create("DScrollPanel", rboxpanel)
			rbweplist:SetPos(0, 0)
			rbweplist:SetSize(265, 150)
			rbweplist:SetPaintBackground(true)
			rbweplist:SetBackgroundColor( Color(200, 200, 200) )

			local function InsertWeaponToList(name, class)
				if IsValid(weplist[class]) then return end
				weplist[class] = vgui.Create("DPanel", rbweplist)
				weplist[class]:SetSize(265, 16)
				weplist[class]:SetPos(0, numweplist*16)
				table.insert(valz["RBoxWeps"], class)

				local dname = vgui.Create("DLabel", weplist[class])
				dname:SetText(name)
				dname:SetTextColor(Color(50, 50, 50))
				dname:SetPos(5, 0)
				dname:SetSize(250, 16)
				local ddelete = vgui.Create("DImageButton", weplist[class])
				ddelete:SetImage("icon16/delete.png")
				ddelete:SetPos(235, 0)
				ddelete:SetSize(16, 16)
				ddelete.DoClick = function()
					if table.HasValue(valz["RBoxWeps"], class) then table.RemoveByValue(valz["RBoxWeps"], class) end
					weplist[class]:Remove()
					weplist[class] = nil
					local num = 0
					for k,v in pairs(weplist) do
						v:SetPos(0, num*16)
						num = num + 1
					end
					numweplist = numweplist - 1
				end

				numweplist = numweplist + 1
			end

			if Mapping.Settings.rboxweps then
				for k,v in pairs(Mapping.Settings.rboxweps) do
					local wep = weapons.Get(v)
					if wep.Category and wep.Category != "" then
						InsertWeaponToList(wep.PrintName and wep.PrintName != "" and wep.Category.." - "..wep.PrintName or wep.ClassName, v)
					else
						InsertWeaponToList(wep.PrintName and wep.PrintName != "" and wep.PrintName or wep.ClassName, v)
					end
				end
			else
				for k,v in pairs(weapons.GetList()) do
					-- By default, add all weapons that have print names unless they are blacklisted
					if v.PrintName and v.PrintName != "" and !nz.Config.WeaponBlackList[v.ClassName] and v.PrintName != "Scripted Weapon" then
						if v.Category and v.Category != "" then
							InsertWeaponToList(v.PrintName and v.PrintName != "" and v.PrintName.." ["..v.Category.."]" or v.ClassName, v.ClassName)
						else
							InsertWeaponToList(v.PrintName and v.PrintName != "" and v.PrintName.." [No Category]" or v.ClassName, v.ClassName)
						end
					end
					-- The rest are still available in the dropdown
				end
			end

			local wepentry = vgui.Create( "DComboBox", rboxpanel )
			wepentry:SetPos( 0, 155 )
			wepentry:SetSize( 203, 20 )
			wepentry:SetValue( "Weapon ..." )
			for k,v in pairs(weapons.GetList()) do
				if v.Category and v.Category != "" then
					wepentry:AddChoice(v.PrintName and v.PrintName != "" and v.Category.. " - "..v.PrintName or v.ClassName, v.ClassName, false)
				else
					wepentry:AddChoice(v.PrintName and v.PrintName != "" and v.PrintName or v.ClassName, v.ClassName, false)
				end
			end
			wepentry.OnSelect = function( panel, index, value )
			end

			local wepadd = vgui.Create( "DButton", rboxpanel )
			wepadd:SetText( "Add" )
			wepadd:SetPos( 207, 155 )
			wepadd:SetSize( 53, 20 )
			wepadd.DoClick = function()
				InsertWeaponToList(wepentry:GetSelected())
				wepentry:SetValue( "Weapon..." )
			end

			local DermaButton2 = vgui.Create( "DButton", rboxpanel )
			DermaButton2:SetText( "Submit" )
			DermaButton2:SetPos( 0, 180 )
			DermaButton2:SetSize( 260, 30 )
			DermaButton2.DoClick = UpdateData
		else
			local text = vgui.Create("DLabel", DProperties)
			text:SetText("Enable Advanced Mode for more options.")
			text:SetFont("Trebuchet18")
			text:SetTextColor( Color(50, 50, 50) )
			text:SizeToContents()
			text:SetPos(0, 140)
			text:CenterHorizontal()
		end

		return sheet
	end,
	//defaultdata = {}
})

if SERVER then
	util.AddNetworkString("nz_NavMeshGrouping")
	util.AddNetworkString("nz_NavMeshGroupRequest")

	net.Receive("nz_NavMeshGroupRequest", function(len, ply)
		if !IsValid(ply) or !ply:IsSuperAdmin() then return end

		local delete = net.ReadBool()
		local data = net.ReadTable()

		//Reselect all areas from the seed provided
		local areas = FloodSelectNavAreas(navmesh.GetNavAreaByID(data.areaid))

		if delete then
			for k,v in pairs(areas) do
				//Remove nav area from group - add true to delete the group ID as well
				nz.Nav.Functions.RemoveNavGroupArea(v, true)
			end
		else
			for k,v in pairs(areas) do
				//Set their ID in the table
				nz.Nav.Functions.AddNavGroupIDToArea(v, data.id)
			end
		end
	end)
else
	net.Receive("nz_NavMeshGrouping", function()

		local data = net.ReadTable()

		local frame = vgui.Create("DFrame")
		frame:SetPos( 100, 100 )
		frame:SetSize( 300, 450 )
		frame:SetTitle( "Nav Mesh Grouping" )
		frame:SetVisible( true )
		frame:SetDraggable( false )
		frame:ShowCloseButton( true )
		frame:MakePopup()
		frame:Center()

		local numareas = vgui.Create( "DLabel", frame )
		numareas:SetPos( 10, 30 )
		numareas:SetSize( frame:GetWide() - 10, 10)
		numareas:SetText( data.num.." areas selected" )

		local map = vgui.Create("DPanel", frame)
		map:SetPos( 25, 50 )
		map:SetSize( 250, 250 )
		map:SetVisible( true )
		map.Paint = function(self, w, h)
			local posx, posy = frame:GetPos()
			cam.Start2D()
				render.RenderView({
					origin = LocalPlayer():GetPos()+Vector(0,0,7000),
					angles = Angle(90,0,0),
					aspectratio = 1,
					x = posx + 12,
					y = posy + 100,
					w = 275,
					h = 275,
					dopostprocess = false,
					drawhud = false,
					drawviewmodel = false,
					viewmodelfov = 0,
					fov = 90,
					ortho = false,
					znear = 0,
					zfar = 10000,
				})
			cam.End2D()
		end

		local DProperties = vgui.Create( "DProperties", frame )
		DProperties:SetSize( 280, 180 )
		DProperties:SetPos( 10, 50 )

		local Row1 = DProperties:CreateRow( "Nav Group", "ID" )
		Row1:Setup( "Integer" )
		Row1:SetValue( data.id )
		Row1.DataChanged = function( _, val ) data.id = val end

		local Submit = vgui.Create( "DButton", frame )
		Submit:SetText( "Submit" )
		Submit:SetPos( 10, 410 )
		Submit:SetSize( 280, 30 )
		Submit.DoClick = function()
			net.Start("nz_NavMeshGroupRequest")
				net.WriteBool(false)
				net.WriteTable(data)
			net.SendToServer()
			frame:Close()
		end

		local Delete = vgui.Create( "DButton", frame )
		Delete:SetText( "Delete Group" )
		Delete:SetPos( 10, 380 )
		Delete:SetSize( 280, 20 )
		Delete.DoClick = function()
			net.Start("nz_NavMeshGroupRequest")
				net.WriteBool(true)
				net.WriteTable(data)
			net.SendToServer()
			frame:Close()
		end
	end)
end

nz.Tools.Functions.CreateTool("navgroup", {
	displayname = "Nav Grouping Tool",
	desc = "LMB: Create/Edit Nav Groups",
	condition = function(wep, ply)
		return true
	end,
	PrimaryAttack = function(wep, ply, tr, data)
		local nav = navmesh.GetNearestNavArea(tr.HitPos)
		local areas = FloodSelectNavAreas(nav)

		net.Start("nz_NavMeshGrouping")
			net.WriteTable({num = #areas, areaid = nav:GetID(), id = nz.Nav.NavGroups[nav:GetID()] or ""})
		net.Send(ply)
	end,

	SecondaryAttack = function(wep, ply, tr, data)
	end,

	Reload = function(wep, ply, tr, data)
	end,

	OnEquip = function(wep, ply, data)
		if wep.Owner:IsListenServerHost() and GetConVar("sv_cheats"):GetBool() then
			RunConsoleCommand("nav_edit", 1)
		end
	end,

	OnHolster = function(wep, ply, data)
		if SERVER and wep.Owner:IsListenServerHost() and GetConVar("sv_cheats"):GetBool() then
			RunConsoleCommand("nav_edit", 0)
		end
	end

}, {
	displayname = "Nav Grouping Tool",
	desc = "LMB: Create/Edit Nav Groups",
	icon = "icon16/chart_organisation.png",
	weight = 45,
	condition = function(wep, ply)
		//Client needs advanced editing on to see the tool
		return nz.Tools.Advanced
	end,
	interface = function(frame, data)
		local panel = vgui.Create("DPanel", frame)
		panel:SetSize(frame:GetSize())

		local textw = vgui.Create("DLabel", panel)
		textw:SetText("You need to be in a listen/local server to be")
		textw:SetFont("Trebuchet18")
		textw:SetTextColor( Color(150, 50, 50) )
		textw:SizeToContents()
		textw:SetPos(0, 20)
		textw:CenterHorizontal()

		local textw2 = vgui.Create("DLabel", panel)
		textw2:SetText("able to see the Navmeshes!")
		textw2:SetFont("Trebuchet18")
		textw2:SetTextColor( Color(150, 50, 50) )
		textw2:SizeToContents()
		textw2:SetPos(0, 30)
		textw2:CenterHorizontal()

		local textw3 = vgui.Create("DLabel", panel)
		textw3:SetText("The tool can still be used blindly")
		textw3:SetFont("Trebuchet18")
		textw3:SetTextColor( Color(50, 50, 50) )
		textw3:SizeToContents()
		textw3:SetPos(0, 40)
		textw3:CenterHorizontal()

		local text = vgui.Create("DLabel", panel)
		text:SetText("Click on the ground to open")
		text:SetFont("Trebuchet18")
		text:SetTextColor( Color(50, 50, 50) )
		text:SizeToContents()
		text:SetPos(0, 80)
		text:CenterHorizontal()

		local text2 = vgui.Create("DLabel", panel)
		text2:SetText("the Nav Grouping Interface of that area.")
		text2:SetFont("Trebuchet18")
		text2:SetTextColor( Color(50, 50, 50) )
		text2:SizeToContents()
		text2:SetPos(0, 90)
		text2:CenterHorizontal()

		local text3 = vgui.Create("DLabel", panel)
		text3:SetText("Nav Groups are flood-selected but will")
		text3:SetFont("Trebuchet18")
		text3:SetTextColor( Color(50, 50, 50) )
		text3:SizeToContents()
		text3:SetPos(0, 110)
		text3:CenterHorizontal()

		local text4 = vgui.Create("DLabel", panel)
		text4:SetText("be blocked by locked Navmeshes.")
		text4:SetFont("Trebuchet18")
		text4:SetTextColor( Color(50, 50, 50) )
		text4:SizeToContents()
		text4:SetPos(0, 120)
		text4:CenterHorizontal()

		local text5 = vgui.Create("DLabel", panel)
		text5:SetText("Zombies can't target players in different")
		text5:SetFont("Trebuchet18")
		text5:SetTextColor( Color(50, 50, 50) )
		text5:SizeToContents()
		text5:SetPos(0, 170)
		text5:CenterHorizontal()

		local text6 = vgui.Create("DLabel", panel)
		text6:SetText("navgroups unless one of them is in no navgroup.")
		text6:SetFont("Trebuchet18")
		text6:SetTextColor( Color(50, 50, 50) )
		text6:SizeToContents()
		text6:SetPos(0, 180)
		text6:CenterHorizontal()

		local text7 = vgui.Create("DLabel", panel)
		text7:SetText("Use this in maps with completely seperate")
		text7:SetFont("Trebuchet18")
		text7:SetTextColor( Color(50, 50, 50) )
		text7:SizeToContents()
		text7:SetPos(0, 200)
		text7:CenterHorizontal()

		local text8 = vgui.Create("DLabel", panel)
		text8:SetText("areas such as elevator-based maps.")
		text8:SetFont("Trebuchet18")
		text8:SetTextColor( Color(50, 50, 50) )
		text8:SizeToContents()
		text8:SetPos(0, 210)
		text8:CenterHorizontal()

		local text9 = vgui.Create("DLabel", panel)
		text9:SetText("Use doors to merge groups.")
		text9:SetFont("Trebuchet18")
		text9:SetTextColor( Color(50, 50, 50) )
		text9:SizeToContents()
		text9:SetPos(0, 230)
		text9:CenterHorizontal()

		return panel
	end,
	//defaultdata = {}
})

nz.Tools.Functions.CreateTool("testzombie", {
	displayname = "Spawn Test Zombie",
	desc = "LMB: Create a test zombie, RMB: Remove test zombie",
	condition = function(wep, ply)
		return true
	end,

	PrimaryAttack = function(wep, ply, tr, data)
		local z = ents.Create("nz_zombie_walker")
		z:SetPos(tr.HitPos)
		z:SetHealth(100)
		z.SpecialInit = function(self)
			self:SetRunSpeed(51)
		end
		z:Spawn()
		z:SetRunSpeed(51)

		undo.Create( "Test Zombie" )
			undo.SetPlayer( ply )
			undo.AddEntity( z )
		undo.Finish( "Effect (" .. tostring( model ) .. ")" )
	end,

	SecondaryAttack = function(wep, ply, tr, data)
		if IsValid(tr.Entity) and tr.Entity:GetClass() == "nz_zombie_walker" then
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
	displayname = "Spawn Test Zombie",
	desc = "LMB: Create a test zombie, RMB: Remove test zombie",
	icon = "icon16/user_green.png",
	weight = 400,
	condition = function(wep, ply)
		return nz.Tools.Advanced
	end,
	interface = function(frame, data)

	end,
	//defaultdata = {}
})

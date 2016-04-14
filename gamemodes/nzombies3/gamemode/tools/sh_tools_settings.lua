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
						InsertWeaponToList(wep.PrintName and wep.PrintName != "" and wep.PrintName.." ["..wep.Category.."]" or v, v)
					else
						InsertWeaponToList(wep.PrintName and wep.PrintName != "" and wep.PrintName.." [No Category]" or v, v)
					end
				end
			else
				for k,v in pairs(weapons.GetList()) do
					-- By default, add all weapons that have print names unless they are blacklisted
					if v.PrintName and v.PrintName != "" and !nz.Config.WeaponBlackList[v.ClassName] and v.PrintName != "Scripted Weapon" and !v.NZPreventBox then
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
				local v = weapons.Get(wepentry:GetOptionData(wepentry:GetSelectedID()))
				if v.Category and v.Category != "" then
					InsertWeaponToList(v.PrintName and v.PrintName != "" and v.PrintName.." ["..v.Category.."]" or v.ClassName, v.ClassName)
				else
					InsertWeaponToList(v.PrintName and v.PrintName != "" and v.PrintName.." [No Category]" or v.ClassName, v.ClassName)
				end
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
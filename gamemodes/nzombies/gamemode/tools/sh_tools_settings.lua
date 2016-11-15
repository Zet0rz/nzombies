nzTools:CreateTool("settings", {
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
		local data = table.Copy(nzMapping.Settings)
		local valz = {}
		valz["Row1"] = data.startwep or "Select ..."
		valz["Row2"] = data.startpoints or 500
		valz["Row3"] = data.eeurl or ""
		valz["Row4"] = data.script or false
		valz["Row5"] = data.scriptinfo or ""
		valz["Row6"] = data.gamemodeentities or false
		valz["Row7"] = data.specialroundtype or "Hellhounds"
		valz["Row8"] = data.bosstype or "Panzer"
		valz["RBoxWeps"] = data.RBoxWeps or {}

		local sheet = vgui.Create( "DPropertySheet", frame )
		sheet:SetSize( 280, 250 )
		sheet:SetPos( 10, 10 )

		local DProperties = vgui.Create( "DProperties", DProperySheet )
		DProperties:SetSize( 280, 250 )
		DProperties:SetPos( 0, 0 )
		sheet:AddSheet( "Map Properties", DProperties, "icon16/cog.png", false, false, "Allows you to set a list of general settings. The Easter Egg Song URL needs to be from Soundcloud.")

		local Row1 = DProperties:CreateRow( "Map Settings", "Starting Weapon" )
		Row1:Setup( "Combo" )
		for k,v in pairs(weapons.GetList()) do
			if !v.NZTotalBlacklist then
				if v.Category and v.Category != "" then
					Row1:AddChoice(v.PrintName and v.PrintName != "" and v.Category.. " - "..v.PrintName or v.ClassName, v.ClassName, false)
				else
					Row1:AddChoice(v.PrintName and v.PrintName != "" and v.PrintName or v.ClassName, v.ClassName, false)
				end
			end
		end
		if data.startwep then
			local wep = weapons.Get(data.startwep)
			if !wep then wep = weapons.Get(nzConfig.BaseStartingWeapons[1]) end
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

		local Row3 = DProperties:CreateRow( "Map Settings", "Easter Egg Song URL" )
		Row3:Setup( "Generic" )
		Row3:SetValue( valz["Row3"] )
		Row3.DataChanged = function( _, val ) valz["Row3"] = val end
		Row3:SetTooltip("Add a link to a SoundCloud track to play this when all easter eggs have been found")
		
		if nzTools.Advanced then
			local Row4 = DProperties:CreateRow( "Map Settings", "Includes Map Script?" )
			Row4:Setup( "Boolean" )
			Row4:SetValue( valz["Row4"] )
			Row4.DataChanged = function( _, val ) valz["Row4"] = val end
			Row4:SetTooltip("Loads a .lua file with the same name as the config .txt from /lua/nzmapscripts - for advanced developers.")
		
			local Row5 = DProperties:CreateRow( "Map Settings", "Script Description" )
			Row5:Setup( "Generic" )
			Row5:SetValue( valz["Row5"] )
			Row5.DataChanged = function( _, val ) valz["Row5"] = val end
			Row5:SetTooltip("Sets the description displayed when attempting to load the script.")
			
			local Row6 = DProperties:CreateRow( "Map Settings", "Gamemode Extensions" )
			Row6:Setup( "Boolean" )
			Row6:SetValue( valz["Row6"] )
			Row6.DataChanged = function( _, val ) valz["Row6"] = val end
			Row6:SetTooltip("Sets whether the gamemode should spawn in map entities from other gamemodes, such as ZS.")
			
			local Row7 = DProperties:CreateRow( "Map Settings", "Special Round" )
			Row7:Setup( "Combo" )
			local found = false
			for k,v in pairs(nzRound.SpecialData) do
				if k == valz["Row7"] then
					Row7:AddChoice(k, k, true)
					found = true
				else
					Row7:AddChoice(k, k, false)
				end
			end
			Row7:AddChoice(" None", "None", !found)
			Row7.DataChanged = function( _, val ) valz["Row7"] = val end
			Row7:SetTooltip("Sets what type of special round will appear.")
			
			local Row8 = DProperties:CreateRow( "Map Settings", "Boss" )
			Row8:Setup( "Combo" )
			local found = false
			for k,v in pairs(nzRound.BossData) do
				if k == valz["Row8"] then
					Row8:AddChoice(k, k, true)
					found = true
				else
					Row8:AddChoice(k, k, false)
				end
			end
			Row8:AddChoice(" None", "None", !found)
			Row8.DataChanged = function( _, val ) valz["Row8"] = val end
			Row8:SetTooltip("Sets what type of boss will appear.")
			
		end
		
		local function UpdateData() -- Will remain a local function here. There is no need for the context menu to intercept
			if !weapons.Get( valz["Row1"] ) then data.startwep = nil else data.startwep = valz["Row1"] end
			if !tonumber(valz["Row2"]) then data.startpoints = 500 else data.startpoints = tonumber(valz["Row2"]) end
			if !valz["Row3"] or valz["Row3"] == "" then data.eeurl = nil else data.eeurl = valz["Row3"] end
			if !valz["Row4"] then data.script = nil else data.script = valz["Row4"] end
			if !valz["Row5"] or valz["Row5"] == "" then data.scriptinfo = nil else data.scriptinfo = valz["Row5"] end
			if !valz["Row6"] or valz["Row6"] == "0" then data.gamemodeentities = nil else data.gamemodeentities = tobool(valz["Row6"]) end
			if !valz["Row7"] then data.specialroundtype = "Hellhounds" else data.specialroundtype = valz["Row7"] end
			if !valz["Row8"] then data.bosstype = "Panzer" else data.bosstype = valz["Row8"] end
			if !valz["RBoxWeps"] or table.Count(valz["RBoxWeps"]) < 1 then data.rboxweps = nil else data.rboxweps = valz["RBoxWeps"] end
			if !valz["WMPerks"] or !valz["WMPerks"][1] then data.wunderfizzperks = nil else data.wunderfizzperks = valz["WMPerks"] end
			PrintTable(data)

			nzMapping:SendMapData( data )
		end

		local DermaButton = vgui.Create( "DButton", DProperties )
		DermaButton:SetText( "Submit" )
		DermaButton:SetPos( 0, 185 )
		DermaButton:SetSize( 260, 30 )
		DermaButton.DoClick = UpdateData

		if nzTools.Advanced then
			local weplist = {}
			local numweplist = 0

			local rboxpanel = vgui.Create("DPanel", sheet)
			sheet:AddSheet( "Random Box Weapons", rboxpanel, "icon16/box.png", false, false, "Allows you to set which weapons appear in the Random Box.")
			rboxpanel.Paint = function() return end

			local rbweplist = vgui.Create("DScrollPanel", rboxpanel)
			rbweplist:SetPos(0, 0)
			rbweplist:SetSize(265, 150)
			rbweplist:SetPaintBackground(true)
			rbweplist:SetBackgroundColor( Color(200, 200, 200) )

			local function InsertWeaponToList(name, class, weight, tooltip)
				weight = weight or 10
				if IsValid(weplist[class]) then return end
				weplist[class] = vgui.Create("DPanel", rbweplist)
				weplist[class]:SetSize(265, 16)
				weplist[class]:SetPos(0, numweplist*16)
				valz["RBoxWeps"][class] = weight

				local dname = vgui.Create("DLabel", weplist[class])
				dname:SetText(name)
				dname:SetTextColor(Color(50, 50, 50))
				dname:SetPos(5, 0)
				dname:SetSize(250, 16)
				
				local dhover = vgui.Create("DPanel", weplist[class])
				dhover.Paint = function() end
				dhover:SetText("")
				dhover:SetSize(265, 16)
				dhover:SetPos(0,0)
				if tooltip then
					dhover:SetTooltip(tooltip)
				end
				
				local dweight = vgui.Create("DNumberWang", weplist[class])
				dweight:SetPos(195, 1)
				dweight:SetSize(40, 14)
				dweight:SetTooltip("The chance of this weapon appearing in the box")
				dweight:SetMinMax( 1, 100 )
				dweight:SetValue(valz["RBoxWeps"][class])
				function dweight:OnValueChanged(val)
					valz["RBoxWeps"][class] = val
				end
				
				local ddelete = vgui.Create("DImageButton", weplist[class])
				ddelete:SetImage("icon16/delete.png")
				ddelete:SetPos(235, 0)
				ddelete:SetSize(16, 16)
				ddelete.DoClick = function()
					valz["RBoxWeps"][class] = nil
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

			if nzMapping.Settings.rboxweps then
				for k,v in pairs(nzMapping.Settings.rboxweps) do
					local wep = weapons.Get(k)
					if wep then
						if wep.Category and wep.Category != "" then
							InsertWeaponToList(wep.PrintName != "" and wep.PrintName or k, k, v or 10, k.." ["..wep.Category.."]")
						else
							InsertWeaponToList(wep.PrintName != "" and wep.PrintName or k, k, v or 10, k.." [No Category]")
						end
					end
				end
			else
				for k,v in pairs(weapons.GetList()) do
					-- By default, add all weapons that have print names unless they are blacklisted
					if v.PrintName and v.PrintName != "" and !nzConfig.WeaponBlackList[v.ClassName] and v.PrintName != "Scripted Weapon" and !v.NZPreventBox and !v.NZTotalBlacklist then
						if v.Category and v.Category != "" then
							InsertWeaponToList(v.PrintName != "" and v.PrintName or v.ClassName, v.ClassName, 10, v.ClassName.." ["..v.Category.."]")
						else
							InsertWeaponToList(v.PrintName != "" and v.PrintName or v.ClassName, v.ClassName, 10, v.ClassName.." [No Category]")
						end
					end
					-- The rest are still available in the dropdown
				end
			end

			local wepentry = vgui.Create( "DComboBox", rboxpanel )
			wepentry:SetPos( 0, 155 )
			wepentry:SetSize( 146, 20 )
			wepentry:SetValue( "Weapon ..." )
			for k,v in pairs(weapons.GetList()) do
				if !v.NZTotalBlacklist and !v.NZPreventBox then
					if v.Category and v.Category != "" then
						wepentry:AddChoice(v.PrintName and v.PrintName != "" and v.Category.. " - "..v.PrintName or v.ClassName, v.ClassName, false)
					else
						wepentry:AddChoice(v.PrintName and v.PrintName != "" and v.PrintName or v.ClassName, v.ClassName, false)
					end
				end
			end
			wepentry.OnSelect = function( panel, index, value )
			end

			local wepadd = vgui.Create( "DButton", rboxpanel )
			wepadd:SetText( "Add" )
			wepadd:SetPos( 150, 155 )
			wepadd:SetSize( 53, 20 )
			wepadd.DoClick = function()
				local v = weapons.Get(wepentry:GetOptionData(wepentry:GetSelectedID()))
				if v then
					if v.Category and v.Category != "" then
						InsertWeaponToList(v.PrintName != "" and v.PrintName or v.ClassName, v.ClassName, 10, v.ClassName.." ["..v.Category.."]")
					else
						InsertWeaponToList(v.PrintName != "" and v.PrintName or v.ClassName, v.ClassName, 10, v.ClassName.." [No Category]")
					end
				end
				wepentry:SetValue( "Weapon..." )
			end
			
			local wepmore = vgui.Create( "DButton", rboxpanel )
			wepmore:SetText( "More ..." )
			wepmore:SetPos( 207, 155 )
			wepmore:SetSize( 53, 20 )
			wepmore.DoClick = function()
				local morepnl = vgui.Create("DFrame")
				morepnl:SetSize(300, 170)
				morepnl:SetTitle("More weapon options ...")
				morepnl:Center()
				morepnl:SetDraggable(true)
				morepnl:ShowCloseButton(true)
				morepnl:MakePopup()
				
				local morecat = vgui.Create("DComboBox", morepnl)
				morecat:SetSize(150, 20)
				morecat:SetPos(10, 30)
				local cattbl = {}
				for k,v in pairs(weapons.GetList()) do
					if v.Category and v.Category != "" then
						if !cattbl[v.Category] then
							morecat:AddChoice(v.Category, v.Category, false)
							cattbl[v.Category] = true
						end
					end
				end
				morecat:AddChoice(" Category ...", nil, true)
					
				local morecatadd = vgui.Create("DButton", morepnl)
				morecatadd:SetText( "Add all" )
				morecatadd:SetPos( 165, 30 )
				morecatadd:SetSize( 60, 20 )
				morecatadd.DoClick = function()
					local cat = morecat:GetOptionData(morecat:GetSelectedID())
					if cat and cat != "" then
						for k,v in pairs(weapons.GetList()) do
							if  v.Category and v.Category == cat and !nzConfig.WeaponBlackList[v.ClassName] and !v.NZPreventBox and !v.NZTotalBlacklist then
								InsertWeaponToList(v.PrintName != "" and v.PrintName or v.ClassName, v.ClassName, 10, v.ClassName.." ["..v.Category.."]")
							end
						end
					end
				end
				
				local morecatdel = vgui.Create("DButton", morepnl)
				morecatdel:SetText( "Remove all" )
				morecatdel:SetPos( 230, 30 )
				morecatdel:SetSize( 60, 20 )
				morecatdel.DoClick = function()
					local cat = morecat:GetOptionData(morecat:GetSelectedID())
					if cat and cat != "" then
						for k,v in pairs(weplist) do
							local wep = weapons.Get(k)
							if wep then
								if wep.Category and wep.Category == cat then
									valz["RBoxWeps"][k] = nil
									weplist[k]:Remove()
									weplist[k] = nil
									local num = 0
									for k,v in pairs(weplist) do
										v:SetPos(0, num*16)
										num = num + 1
									end
									numweplist = numweplist - 1
								end
							end
						end
					end
				end
				
				local moreprefix = vgui.Create("DComboBox", morepnl)
				moreprefix:SetSize(150, 20)
				moreprefix:SetPos(10, 60)
				local prefixtbl = {}
				for k,v in pairs(weapons.GetList()) do
					local prefix = string.sub(v.ClassName, 0, string.find(v.ClassName, "_"))
					if prefix and !prefixtbl[prefix] then
						moreprefix:AddChoice(prefix, prefix, false)
						prefixtbl[prefix] = true
					end
				end
				moreprefix:AddChoice(" Prefix ...", nil, true)
					
				local moreprefixadd = vgui.Create("DButton", morepnl)
				moreprefixadd:SetText( "Add all" )
				moreprefixadd:SetPos( 165, 60 )
				moreprefixadd:SetSize( 60, 20 )
				moreprefixadd.DoClick = function()
					local prefix = moreprefix:GetOptionData(moreprefix:GetSelectedID())
					if prefix and prefix != "" then
						for k,v in pairs(weapons.GetList()) do
							local wepprefix = string.sub(v.ClassName, 0, string.find(v.ClassName, "_"))
							if wepprefix and wepprefix == prefix and !nzConfig.WeaponBlackList[v.ClassName] and !v.NZPreventBox and !v.NZTotalBlacklist then
								if v.Category and v.Category != "" then
									InsertWeaponToList(v.PrintName != "" and v.PrintName or v.ClassName, v.ClassName, 10, v.ClassName.." ["..v.Category.."]")
								else
									InsertWeaponToList(v.PrintName != "" and v.PrintName or v.ClassName, v.ClassName, 10, v.ClassName.." [No Category]")
								end
							end
						end
					end
				end
				
				local moreprefixdel = vgui.Create("DButton", morepnl)
				moreprefixdel:SetText( "Remove all" )
				moreprefixdel:SetPos( 230, 60 )
				moreprefixdel:SetSize( 60, 20 )
				moreprefixdel.DoClick = function()
					local prefix = moreprefix:GetOptionData(moreprefix:GetSelectedID())
					if prefix and prefix != "" then
						for k,v in pairs(weplist) do
							local wepprefix = string.sub(k, 0, string.find(k, "_"))
							if wepprefix and wepprefix == prefix then
								valz["RBoxWeps"][k] = nil
								weplist[k]:Remove()
								weplist[k] = nil
								local num = 0
								for k,v in pairs(weplist) do
									v:SetPos(0, num*16)
									num = num + 1
								end
								numweplist = numweplist - 1
							end
						end
					end
				end
				
				local removeall = vgui.Create("DButton", morepnl)
				removeall:SetText( "Remove all" )
				removeall:SetPos( 10, 100 )
				removeall:SetSize( 140, 25 )
				removeall.DoClick = function()
					for k,v in pairs(weplist) do
						valz["RBoxWeps"][k] = nil
						weplist[k]:Remove()
						weplist[k] = nil
						numweplist = 0
					end
				end
				
				local addall = vgui.Create("DButton", morepnl)
				addall:SetText( "Add all" )
				addall:SetPos( 150, 100 )
				addall:SetSize( 140, 25 )
				addall.DoClick = function()
					for k,v in pairs(weplist) do
						valz["RBoxWeps"][k] = nil
						weplist[k]:Remove()
						weplist[k] = nil
						numweplist = 0
					end
					for k,v in pairs(weapons.GetList()) do
						-- By default, add all weapons that have print names unless they are blacklisted
						if v.PrintName and v.PrintName != "" and !nzConfig.WeaponBlackList[v.ClassName] and v.PrintName != "Scripted Weapon" and !v.NZPreventBox and !v.NZTotalBlacklist then
							if v.Category and v.Category != "" then
								InsertWeaponToList(v.PrintName != "" and v.PrintName or v.ClassName, v.ClassName, 10, v.ClassName.." ["..v.Category.."]")
							else
								InsertWeaponToList(v.PrintName != "" and v.PrintName or v.ClassName, v.ClassName, 10, v.ClassName.." [No Category]")
							end
						end
						-- The same reset as when no random box list exists on server
					end
				end
				
				local reload = vgui.Create("DButton", morepnl)
				reload:SetText( "Reload from server" )
				reload:SetPos( 10, 130 )
				reload:SetSize( 280, 25 )
				reload.DoClick = function()
					-- Remove all and insert from random box list
					for k,v in pairs(weplist) do
						valz["RBoxWeps"][k] = nil
						weplist[k]:Remove()
						weplist[k] = nil
						numweplist = 0
					end
					if nzMapping.Settings.rboxweps then
						for k,v in pairs(nzMapping.Settings.rboxweps) do
							local wep = weapons.Get(v)
							if wep then
								if wep.Category and wep.Category != "" then
									InsertWeaponToList(wep.PrintName != "" and wep.PrintName or v, v, 10, v.." ["..v.Category.."]")
								else
									InsertWeaponToList(wep.PrintName != "" and wep.PrintName or v, v, 10, v.." [No Category]")
								end
							end
						end
					end
				end
			end
			
			local DermaButton2 = vgui.Create( "DButton", rboxpanel )
			DermaButton2:SetText( "Submit" )
			DermaButton2:SetPos( 0, 185 )
			DermaButton2:SetSize( 260, 30 )
			DermaButton2.DoClick = UpdateData
			
			local perklist = {}

			local perkpanel = vgui.Create("DPanel", sheet)
			sheet:AddSheet( "Wunderfizz Perks", perkpanel, "icon16/drink.png", false, false, "Allows you to set which perks appears in Der Wunderfizz.")
			perkpanel.Paint = function() return end

			local perklistpnl = vgui.Create("DScrollPanel", perkpanel)
			perklistpnl:SetPos(0, 0)
			perklistpnl:SetSize(265, 250)
			perklistpnl:SetPaintBackground(true)
			perklistpnl:SetBackgroundColor( Color(200, 200, 200) )
			
			local perkchecklist = vgui.Create( "DIconLayout", perklistpnl )
			perkchecklist:SetSize( 265, 250 )
			perkchecklist:SetPos( 0, 0 )
			perkchecklist:SetSpaceY( 5 )
			perkchecklist:SetSpaceX( 5 )
			
			for k,v in pairs(nzPerks:GetList()) do
				if k != "wunderfizz" and k != "pap" then
					local perkitem = perkchecklist:Add( "DPanel" )
					perkitem:SetSize( 130, 20 )
					
					local check = perkitem:Add("DCheckBox")
					check:SetPos(2,2)
					local has = nzMapping.Settings.wunderfizzperks and table.HasValue(nzMapping.Settings.wunderfizzperks, k) or 1
					check:SetValue(has)
					if has then perklist[k] = true else perklist[k] = nil end
					check.OnChange = function(self, val)
						if val then perklist[k] = true else perklist[k] = nil end
						nzMapping:SendMapData( {wunderfizzperks = perklist} )
					end
					
					local name = perkitem:Add("DLabel")
					name:SetTextColor(Color(50,50,50))
					name:SetSize(105, 20)
					name:SetPos(20,1)
					name:SetText(v)
				end
			end
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
	-- defaultdata = {}
})
nz.Tools.Functions.CreateTool("navedit", {
	displayname = "Navmesh Editor",
	desc = "Q: Select edit mode",
	condition = function(wep, ply)
		return true
	end,

	PrimaryAttack = function(wep, ply, tr, data)
		if data.Primary then
			RunConsoleCommand(data.Primary)
		end
	end,

	SecondaryAttack = function(wep, ply, tr, data)
		if data.Secondary then
			RunConsoleCommand(data.Secondary)
		end
	end,
	Reload = function(wep, ply, tr, data)
		if data.Reload then
			RunConsoleCommand(data.Reload)
		else
			RunConsoleCommand("nav_mark")
		end
	end,
	OnEquip = function(wep, ply, data)
		if wep.Owner:IsListenServerHost() then
			RunConsoleCommand("nav_edit", 1)
		end
	end,
	OnHolster = function(wep, ply, data)
		if SERVER and wep.Owner:IsListenServerHost() then
			RunConsoleCommand("nav_edit", 0)
		end
	end
}, {
	displayname = "Navmesh Editor",
	desc = "Q: Select edit mode",
	icon = "icon16/map.png",
	weight = 39,
	condition = function(wep, ply)
		return nz.Tools.Advanced
	end,
	interface = function(frame, data)

		local cont = vgui.Create("DScrollPanel", frame)
		cont:Dock(FILL)

		--command and mode declaration

		local modes = {
			["Change Attributes"] = {
				Primary = "nav_jump",
				PrimaryDesc = "Toggle jumping",
				Secondary = "nav_no_jump",
				SecondaryDesc = "Toggle no jumping"
			},
			["Delete Area"] = {
				Primary = "nav_delete",
				PrimaryDesc = "Delete Area"
			},
			["Corners"] = {
				Primary = "nav_corner_place_on_ground",
				PrimaryDesc = "Lower corner to ground"
			},
			["Edit Area"] = {
				Primary = "nav_split",
				PrimaryDesc = "Split an area at the white line",
				Secondary = "nav_merge",
				SecondaryDesc = "Merge 2 areas"
			},
			["Create Areas"] = {
				Primary = "nav_begin_area",
				PrimaryDesc = "Begin area creation",
				Secondary = "nav_end_area",
				SecondaryDesc = "End area creation"
			},
			["Connect Areas"] = {
				Primary = "nav_connect",
				PrimaryDesc = "Add a 1-way connection",
				Secondary = "nav_disconnect",
				SecondaryDesc = "Remove a connection"
			},
			["Ladder"] = {
				Primary = "nav_build_ladder",
				PrimaryDesc = "Build a navmesh for a ladder"
			},
			["Splice"] = {
				Primary = "nav_splice",
				PrimaryDesc = "Splice 2 areas together",
				Secondary = "nav_split",
				SecondaryDesc = "Split an area at the white line",
			}
		}

		local commands = {
			["Build Ladder"] = "nav_build_ladder",
			["Toggle jump area"] = "nav_jump",
			["Toggle no jump area"] = "nav_no_jump",
			["Begin Area Creation"] = "nav_begin_area",
			["End Area Creation"] = "nav_end_area",
			["Merge Areas"] = "nav_merge",
			["Place Corner on Ground"] = "nav_corner_place_on_ground",
			["Connect Areas"] = "nav_connect",
			["Disconnect Areas"] = "nav_disconnect",
			["Delete Area"] = "nav_delete",
			["Split Area"] = "nav_split",
			["Mark Area"] = "nav_mark",
			["Generate Incremental"] = "nav_generate_incremental",
			["Clear Selected Set"] = "nav_clear_selected_set",
			["Mark Walkable"] = "nav_mark_walkable",
		}

		--update helper

		local function UpdateData()
			nz.Tools.Functions.SendData( data, "navedit" )
		end

		local function UpdateDesc()
			local result = ""
			if data.PrimaryDesc then
				result = "LMB: " .. data.PrimaryDesc
			end
			if data.SecondaryDesc then
				if result != "" then
					result = result .. ", "
				end
				result = result .. "RMB: " .. data.SecondaryDesc
			end
			if data.ReloadDesc then
				if result != "" then
					result = result .. ", "
				end
				result = result .. "R: " .. data.ReloadDesc
			else
				if result != "" then
					result = result .. ", "
				end
				result = result .. "R: Mark area"
			end
			nz.Tools.ToolData["navedit"].desc = result
		end

		--"basic" stuff

		local basicCat = vgui.Create( "DCollapsibleCategory", cont )
		basicCat:SetExpanded( 1 )
		basicCat:SetLabel( "Basics" )
		basicCat:Dock(TOP)

		local basic = vgui.Create("DListLayout", cont)
		basic:Dock(TOP)
		basic:DockMargin(5,5,5,5)

		local modePnl = basic:Add( "DPanel" )
		modePnl:Dock(TOP)

		local modeLbl = modePnl:Add( "DLabel" )
		modeLbl:SetText("Select edit mode:")
		modeLbl:SetDark(true)
		modeLbl.Paint = function() end
		modeLbl:Dock(LEFT)
		modeLbl:SizeToContents()

		local mode = modePnl:Add( "DComboBox" )
		mode:Dock(TOP)
		for k,v in pairs(modes) do
			mode:AddChoice(k,v)
		end
		mode:AddChoice("Custom")

		-- custom mode

		local custom = basic:Add( "DPanel" )
		custom:Dock(TOP)
		custom:SetVisible(false)

		local primCust = custom:Add( "DComboBox" )
		primCust:Dock(LEFT)
		for k,v in pairs(commands) do
			primCust:AddChoice(v, k)
		end
		primCust:SetValue("Primary")

		local secCust = custom:Add( "DComboBox" )
		secCust:Dock(LEFT)
		for k,v in pairs(commands) do
			secCust:AddChoice(v, k)
		end
		secCust:SetValue("Secondary")

		local reCust = custom:Add( "DComboBox" )
		reCust:Dock(LEFT)
		for k,v in pairs(commands) do
			reCust:AddChoice(v, k)
		end
		reCust:SetValue("Reload")

		local subCust = custom:Add( "DButton" )
		subCust:Dock(LEFT)
		subCust:SetText("Submit")
		function subCust:DoClick()
			if primCust:GetValue() != "Primary" then
				data.Primary, data.PrimaryDesc = primCust:GetSelected()
			end
			if secCust:GetValue() != "Secondary" then
				data.Secondary, data.SecondaryDesc = secCust:GetSelected()
			end
			if reCust:GetValue() != "Reload" then
				data.Reload, data.ReloadDesc = reCust:GetSelected()
			end
			UpdateDesc()
			UpdateData()
		end

		-- end custom mode

		-- basic settings
		local settingsPnl = basic:Add( "DListLayout" )
		settingsPnl:Dock(TOP)
		settingsPnl:DockMargin(0,10,0,0)

		local settingsLbl = settingsPnl:Add( "DLabel" )
		settingsLbl:SetText("Settings:")
		settingsLbl:SetDark(true)
		settingsLbl.Paint = function() end
		settingsLbl:Dock(TOP)
		settingsLbl:SetContentAlignment(5)

		local snapGrid = settingsPnl:Add("DNumSlider")
		snapGrid:Dock(TOP)
		snapGrid:SetText("Snap to Grid")
		snapGrid:SetMin(0)
		snapGrid:SetMax(2)
		snapGrid:SetDecimals(0)
		snapGrid:SetDark(true)
		snapGrid:SetConVar("nav_snap_to_grid")

		local showInfo = settingsPnl:Add("DNumSlider")
		showInfo:Dock(TOP)
		showInfo:SetText("Display area info (sec)")
		showInfo:SetMin(0)
		showInfo:SetMax(60)
		showInfo:SetDecimals(1)
		showInfo:SetDark(true)
		showInfo:SetConVar("nav_show_area_info")

		local cvars = {
			["Place created areas on ground"] = "nav_create_place_on_ground",
			["Place splitted areas on ground"] = "nav_split_place_on_ground",
			["Show Compass"] = "nav_show_compass"
		}

		for k,v in pairs(cvars) do
			local cvar = settingsPnl:Add( "DCheckBoxLabel" )
			cvar:SetConVar(v)
			cvar:SetText(k)
			cvar:SizeToContents()
			cvar:SetDark(true)
			cvar:Dock(TOP)
		end

		-- end settings

		function mode:OnSelect(index, name, val)
			if name == "Custom" then
				custom:SetVisible(true)
			else
				custom:SetVisible(false)
				data.Primary = val.Primary
				data.Secondary = val.Secondary
				data.PrimaryDesc = val.PrimaryDesc
				data.SecondaryDesc = val.SecondaryDesc
				UpdateDesc()
				UpdateData()
			end
		end

		basicCat:SetContents(basic)

		--danger zone

		local dangerCat = vgui.Create( "DCollapsibleCategory", cont )
		dangerCat:SetExpanded( 1 )
		dangerCat:SetLabel( "Danger Zone" )
		dangerCat:Dock(TOP)

		local danger = vgui.Create("DListLayout", cont)
		danger:Dock(TOP)
		danger:DockMargin(5,5,5,5)

		local innerPnl = danger:Add("DPanel")
		innerPnl:Dock(TOP)

		local save = innerPnl:Add("DButton")
		save:Dock(FILL)
		save:SetText("Save")
		save:SetConsoleCommand("nav_save")
		save:SizeToContents()

		local gen = innerPnl:Add("DButton")
		gen:Dock(LEFT)
		gen:SetText("Generate")
		gen:SizeToContents()
		gen:DockPadding(5,0,5,0)
		gen:SetConsoleCommand("say", "/generate")

		local analyze = innerPnl:Add("DButton")
		analyze:Dock(RIGHT)
		analyze:SetText("Analyze")
		analyze:SizeToContents()
		analyze:DockPadding(5,0,5,0)
		analyze:SetConsoleCommand("nav_analyze")

		local quick = danger:Add("DCheckBoxLabel")
		quick:SetConVar("nav_quicksave")
		quick:SetText("Enable quicksave")
		quick:SizeToContents()
		quick:SetDark(true)
		quick:Dock(TOP)
		quick:DockMargin(0,10,0,0)

		dangerCat:SetContents(danger)


		-- end danger zone

		--"advanced" stuff

		local advCat = vgui.Create( "DCollapsibleCategory", cont )
		advCat:SetExpanded( 0 )
		advCat:SetLabel( "Quick Commands" )
		advCat:Dock(TOP)

		local adv = vgui.Create("DListLayout", cont)
		adv:Dock(TOP)

		for k,v in pairs(commands) do
			local btn = vgui.Create("DButton")
			btn:SetText(k)
			btn:Dock(TOP)
			btn:DockMargin(5,5,5,0)
			btn:SetConsoleCommand(v)
			adv:Add(btn)
		end

		advCat:SetContents(adv)

		return cont
	end,
	defaultdata = {
	}
})

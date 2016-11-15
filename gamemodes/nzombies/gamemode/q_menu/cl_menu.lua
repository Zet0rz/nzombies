function nzQMenu:CreatePropsMenu( )

	-- Data we will need later
	local data -- Table with spawnlist data
	local SpawnSheet -- Spawnlist sheet
	local UtilitySheet -- Utility sheet
	local CategoryEditor -- Function for creating Category Editor
	local ReloadSpawnlist -- Function for creating/reloading spawnlist sheet

	-- Create a Frame to contain everything.
	local frame = vgui.Create( "DFrame" )
	frame:SetTitle( "Props Menu" )
	frame:SetSize( 475, 340 )
	frame:Center()
	frame:SetPopupStayAtBack(true)
	frame:MakePopup()
	frame:ShowCloseButton( true )
	frame:SetVisible( false )
	frame.SpawnlistActive = true
	
	local oncolor = Color(255,255,255)
	local offcolor = Color(200,200,200)
	
	local utilitiestab -- Store it here so Spawntab can refer back to it
	
	local spawntab = vgui.Create("DPanel", frame)
	spawntab:SetPos(5,5)
	spawntab:SetSize(75,15)
	spawntab:SetBackgroundColor( oncolor )
	
	local spawntext = vgui.Create("DLabel", spawntab)
	spawntext:SetText("Spawnlist")
	spawntext:SetPos(14,-2)
	spawntext:SetTextColor( Color(10,10,10) )
	
	local spawnbut = vgui.Create("DButton", spawntab)
	spawnbut:SetSize(spawntab:GetSize())
	spawnbut.Paint = function() end
	spawnbut:SetText("")
	spawnbut.DoClick = function(self)
		UtilitySheet:SetVisible(false)
		SpawnSheet:SetVisible(true)
		spawntab:SetBackgroundColor( oncolor )
		utilitiestab:SetBackgroundColor( offcolor )
		frame.SpawnlistActive = true
	end
	
	utilitiestab = vgui.Create("DPanel", frame)
	utilitiestab:SetPos(85,5)
	utilitiestab:SetSize(75,15)
	utilitiestab:SetBackgroundColor( offcolor )
	
	local utilitiestext = vgui.Create("DLabel", utilitiestab)
	utilitiestext:SetText("Utilities")
	utilitiestext:SetPos(20,-2)
	utilitiestext:SetTextColor( Color(10,10,10) )
	
	local utilitiesbut = vgui.Create("DButton", utilitiestab)
	utilitiesbut:SetSize(utilitiestab:GetSize())
	utilitiesbut.Paint = function() end
	utilitiesbut:SetText("")
	utilitiesbut.DoClick = function(self)
		UtilitySheet:SetVisible(true)
		SpawnSheet:SetVisible(false)
		spawntab:SetBackgroundColor( offcolor )
		utilitiestab:SetBackgroundColor( oncolor )
		frame.SpawnlistActive = false
	end
	
	
	nzQMenu.Data.MainFrame = frame

	-- Loop to make all the tabs
	local tabs = {}
	tabs.Scrolls = {}
	tabs.Lists = {}
	tabs.Categories = {}
	
	CategoryEditor = function(oldcat, model)
		local frame = vgui.Create("DFrame")
		frame:SetTitle(oldcat and "Edit Category ..." or "Add Category ...")
		frame:SetSize(400, 250)
		frame:SetPos(ScrW()/2 - 200, ScrH()/2 - 125)
		
		local highlightcolor = Color(150,150,150)
		
		local name = vgui.Create( "DTextEntry", frame )
		name:SetSize( 380, 20 )
		name:SetPos( 10, 30 )
		if oldcat then
			name:SetValue(oldcat)
		end
		name.PaintOver = function(self, w, h)
			if self.HighlightRed then
				surface.SetDrawColor(255,0,0,self.HighlightRed)
				local x2,y2 = self:GetSize()
				surface.DrawRect(-50, -50, x2+50, y2+50)
				self.HighlightRed = self.HighlightRed - FrameTime() * 100
				if self.HighlightRed <= 0 then
					self.HighlightRed = nil
				end
			end
			if self:GetValue() == "" then
				draw.SimpleText("Name", "DermaDefault", 4, 3, highlightcolor)
			end
		end
		
		local tooltip = vgui.Create( "DTextEntry", frame )
		tooltip:SetSize( 380, 20 )
		tooltip:SetPos( 10, 55 )
		if oldcat then
			tooltip:SetValue(data[tabs.Categories[oldcat]].tooltip)
		end
		tooltip.PaintOver = function(self, w, h)
			if self:GetValue() == "" then
				draw.SimpleText("Tooltip (Optional)", "DermaDefault", 4, 3, highlightcolor)
			end
		end
		
		local icons = vgui.Create( "DIconBrowser", frame )
		icons:SetSize( 380, 130 )
		icons:SetPos( 10, 80 )
		if oldcat then
			icons:SetSelectedIcon(data[tabs.Categories[oldcat]].icon)
		else
			icons:SetSelectedIcon("icon16/accept.png")
		end
		
		local save = vgui.Create("DButton", frame)
		save:SetSize( 350, 25 )
		save:SetPos( 25, 215 )
		save:SetText(oldcat and "Save" or "Add")
		save.DoClick = function(self)
			local chosenname = name:GetValue()
			if chosenname == "" then
				name.HighlightRed = 255
			else
				local good = true
				if oldcat != chosenname then
					for k,v in pairs(data) do
						if v.name == chosenname then
							name.HighlightRed = 255
							good = false
							break
						end
					end
				end
				
				if good then
					if oldcat then
						local tbl = data[tabs.Categories[oldcat]]
						tbl.name = chosenname
						tbl.icon = icons:GetSelectedIcon()
						if tooltip:GetValue() != "" then
							tbl.tooltip = tooltip:GetValue()
						else
							tbl.tooltip = nil
						end
					else
						local tbl = {}
						if tooltip:GetValue() != "" then
							tbl.tooltip = tooltip:GetValue()
						end
						tbl.icon = icons:GetSelectedIcon()
						tbl.name = chosenname
						tbl.models = {}
						if model then table.insert(tbl.models, model) end
						table.insert(data, tbl)
					end
					ReloadSpawnlist()
					frame:Close()
				end
			end
		end
		
		frame:MakePopup()
	end
	
	ReloadSpawnlist = function()
	
		if IsValid(SpawnSheet) then SpawnSheet:Remove() end
		SpawnSheet = vgui.Create( "DPropertySheet", nzQMenu.Data.MainFrame )
		SpawnSheet:SetPos( 10, 30 )
		SpawnSheet:SetSize( 455, 300 )
		
		tabs.Scrolls = {}
		tabs.Lists = {}
		tabs.Categories = {}
	
		-- Then re-add from the data table
		for k,v in pairs(data) do		
			local cat = v.name
			tabs.Scrolls[cat] = vgui.Create( "DScrollPanel", nzQMenu.Data.MainFrame )
			tabs.Scrolls[cat]:SetSize( 455, 300 )
			tabs.Scrolls[cat]:SetPos( 10, 30 )

			tabs.Lists[cat] = vgui.Create( "DIconLayout", tabs.Scrolls[cat] )
			tabs.Lists[cat]:SetSize( 440, 300 )
			tabs.Lists[cat]:SetPos( 0, 0 )
			tabs.Lists[cat]:SetSpaceY( 5 )
			tabs.Lists[cat]:SetSpaceX( 5 )
			local tab = SpawnSheet:AddSheet( cat, tabs.Scrolls[cat], v.icon, false, false, v.tooltip ).Tab
			tab.DoRightClick = function(self)
				local menu = DermaMenu()
				menu:AddOption("Edit Category ...", function()
					CategoryEditor(cat)
				end)
				local submenu = menu:AddSubMenu( "Set Order" )
				for i = 1, #data do
					submenu:AddOption(i, function()
						local temp = v
						table.remove(data, k)
						table.insert(data, i, v)
						ReloadSpawnlist()
					end)
				end
				
				menu:AddSpacer()

				menu:AddOption("Remove Category", function()
					table.remove(data, k)
					ReloadSpawnlist()
				end)
				menu:Open()
			end
			
			for k2,v2 in pairs(v.models) do
				local ListItem = tabs.Lists[cat]:Add( "SpawnIcon" )
				ListItem:SetSize( 48, 48 )
				ListItem:SetModel(v2)
				ListItem.Model = v2
				ListItem.DoClick = function( item )
					nzQMenu:Request(item.Model)
					surface.PlaySound( "ui/buttonclickrelease.wav" )
				end
				ListItem.DoRightClick = function( item )
					local menu = DermaMenu()
					local submenu = menu:AddSubMenu( "Add to category" )
					
					for k3,v3 in pairs(data) do
						submenu:AddOption(v3.name, function()
							table.insert(v3.models, v2)
							ReloadSpawnlist()
						end)
					end
					
					menu:AddOption("Add to new category ...", function()
						CategoryEditor(nil, v2)
					end)
					
					menu:AddSpacer()
					
					menu:AddOption("Remove from category", function()
						table.remove(v.models, k2)
						ReloadSpawnlist()
					end)
					menu:Open()
				end
			end
			tabs.Categories[cat] = k
		end
		
		if !frame.SpawnlistActive then
			SpawnSheet:SetVisible(false)
		end
	end
	
	tabs.Utilities = {}
	local function CreateUtilities()
		if IsValid(UtilitySheet) then UtilitySheet:Remove() end
		UtilitySheet = vgui.Create( "DPropertySheet", nzQMenu.Data.MainFrame )
		UtilitySheet:SetPos( 10, 30 )
		UtilitySheet:SetSize( 455, 300 )
	
		tabs.Utilities["Entities"] = vgui.Create( "DScrollPanel", nzQMenu.Data.MainFrame )
		tabs.Utilities["Entities"]:SetSize( 455, 300 )
		tabs.Utilities["Entities"]:SetPos( 10, 30 )

		local lists = vgui.Create( "DIconLayout", tabs.Utilities["Entities"] )
		lists:SetSize( 440, 300 )
		lists:SetPos( 0, 0 )
		lists:SetSpaceY( 5 )
		lists:SetSpaceX( 5 )
		tabs.Utilities["Entities"].List = lists
		UtilitySheet:AddSheet( "Entities", tabs.Utilities["Entities"], nil, false, false, v )
		
		tabs.Utilities["Search"] = vgui.Create( "DPanel", nzQMenu.Data.MainFrame )
		tabs.Utilities["Search"]:SetSize( 455, 300 )
		tabs.Utilities["Search"]:SetPos( 10, 30 )
		
		tabs.Utilities["Search"].Warn = vgui.Create( "DLabel", tabs.Utilities["Search"] )
		tabs.Utilities["Search"].Warn:SetSize( 420, 20 )
		tabs.Utilities["Search"].Warn:SetPos( 60, 5 )
		tabs.Utilities["Search"].Warn:SetTextColor( Color(0,0,0) )
		tabs.Utilities["Search"].Warn:SetText("Warning: May cause severe lag and/or crash. Be sure to save first.")
		
		tabs.Utilities["Search"].Search = vgui.Create( "DTextEntry", tabs.Utilities["Search"] )
		tabs.Utilities["Search"].Search:SetSize( 420, 20 )
		tabs.Utilities["Search"].Search:SetPos( 10, 25 )
		tabs.Utilities["Search"].Search.OnEnter = function() tabs.Utilities["Search"]:RefreshResults() end
		tabs.Utilities["Search"].Search:SetTooltip("Press Enter to search/update results")
		
		tabs.Utilities["Search"].Content = vgui.Create( "DScrollPanel", tabs.Utilities["Search"] )
		tabs.Utilities["Search"].Content:SetSize( 430, 210 )
		tabs.Utilities["Search"].Content:SetPos( 0, 50 )

		lists = vgui.Create( "DIconLayout", tabs.Utilities["Search"].Content )
		lists:SetSize( 440, 210 )
		lists:SetPos( 10, 00 )
		lists:SetSpaceY( 5 )
		lists:SetSpaceX( 5 )
		tabs.Utilities["Search"].List = lists
		
		tabs.Utilities["MapProps"] = vgui.Create( "DPanel", nzQMenu.Data.MainFrame )
		tabs.Utilities["MapProps"]:SetSize( 455, 300 )
		tabs.Utilities["MapProps"]:SetPos( 10, 30 )
		
		tabs.Utilities["MapProps"].Search = vgui.Create( "DButton", tabs.Utilities["MapProps"] )
		tabs.Utilities["MapProps"].Search:SetSize( 420, 20 )
		tabs.Utilities["MapProps"].Search:SetPos( 10, 10 )
		tabs.Utilities["MapProps"].Search.DoClick = function() tabs.Utilities["MapProps"]:RefreshResults() end
		tabs.Utilities["MapProps"].Search:SetText("Update")
		
		tabs.Utilities["MapProps"].Content = vgui.Create( "DScrollPanel", tabs.Utilities["MapProps"] )
		tabs.Utilities["MapProps"].Content:SetSize( 430, 220 )
		tabs.Utilities["MapProps"].Content:SetPos( 0, 40 )

		lists = vgui.Create( "DIconLayout", tabs.Utilities["MapProps"].Content )
		lists:SetSize( 440, 210 )
		lists:SetPos( 10, 00 )
		lists:SetSpaceY( 5 )
		lists:SetSpaceX( 5 )
		tabs.Utilities["MapProps"].List = lists
		
		function tabs.Utilities.Search:RefreshResults() 
			if ( self.Search:GetText() == "" ) then return end
			local pnl = tabs.Utilities["Search"].List
			pnl:Clear()
			local results = search.GetResults( self.Search:GetText() )
			for k,v in pairs(results) do
				local ListItem = pnl:Add( "SpawnIcon" )
				ListItem:SetSize( 45, 45 )
				ListItem:SetModel(v)
				ListItem.Model = v
				ListItem.DoClick = function( item )
					nzQMenu:Request(item.Model)
					surface.PlaySound( "ui/buttonclickrelease.wav" )
				end
				ListItem.DoRightClick = function( item )
					local menu = DermaMenu()
					local submenu = menu:AddSubMenu( "Add to category" )
					for k2,v2 in pairs(data) do
						submenu:AddOption(v2.name, function()
							table.insert(v2.models, v)
							ReloadSpawnlist()
						end)
					end
					
					menu:AddSpacer()
					
					menu:AddOption("Add to new category ...", function()
						CategoryEditor(nil, v)
					end)
					menu:Open()
				end
			end
		end
		
		function tabs.Utilities.MapProps:RefreshResults() 
			local pnl = tabs.Utilities["MapProps"].List
			pnl:Clear()
			local used = {}
			for k,v in pairs(ents.GetAll()) do
				if string.find(v:GetClass(), "prop") then
					local model = v:GetModel()
					if !used[model] then
						local ListItem = pnl:Add( "SpawnIcon" )
						ListItem:SetSize( 45, 45 )
						ListItem:SetModel(model)
						ListItem.Model = model
						ListItem.DoClick = function( item )
							nzQMenu:Request(item.Model)
							surface.PlaySound( "ui/buttonclickrelease.wav" )
						end
						ListItem.DoRightClick = function( item )
							local menu = DermaMenu()
							local submenu = menu:AddSubMenu( "Add to category" )
							for k,v in pairs(data) do
								submenu:AddOption(v.name, function()
									table.insert(v.models, model)
									ReloadSpawnlist()
								end)
							end
							
							menu:AddSpacer()
							
							menu:AddOption("Add to new category ...", function()
								CategoryEditor(nil, v)
							end)
							menu:Open()
						end
						used[model] = true
					end
				end
			end
		end
		
		UtilitySheet:AddSheet( "Map Props", tabs.Utilities["MapProps"], "icon16/map.png", false, false, v )
		UtilitySheet:AddSheet( "Search", tabs.Utilities["Search"], "icon16/magnifier.png", false, false, v )
		
		for k,v in pairs(nzQMenu.Data.Entities) do
			local ListItem = tabs.Utilities["Entities"].List:Add( "DImageButton" )
			ListItem:SetSize( 48, 48 )
			ListItem:SetImage(v[2])
			ListItem.Entity = v[1]
			ListItem.DoClick = function( item )
				nzQMenu:Request(item.Entity, true)
				surface.PlaySound( "ui/buttonclickrelease.wav" )
			end
			ListItem:SetTooltip(v[3] or v[1])
			-- You don't need to set the position, that is done automatically

		end
		
		tabs.Utilities["Addons"] = vgui.Create( "DPanel", nzQMenu.Data.MainFrame )
		tabs.Utilities["Addons"]:SetSize( 455, 300 )
		tabs.Utilities["Addons"]:SetPos( 0, 30 )
		
		tabs.Utilities["Addons"].AddonList = vgui.Create( "DTree", tabs.Utilities["Addons"] )
		tabs.Utilities["Addons"].AddonList:SetSize(200, 280)
		tabs.Utilities["Addons"].AddonList:SetPos(-20, 0)
		tabs.Utilities["Addons"].AddonList:SetPadding(0)
		
		tabs.Utilities["Addons"].Content = vgui.Create( "DScrollPanel", tabs.Utilities["Addons"] )
		tabs.Utilities["Addons"].Content:SetSize( 330, 220 )
		tabs.Utilities["Addons"].Content:SetPos( 180, 10 )

		lists = vgui.Create( "DIconLayout", tabs.Utilities["Addons"].Content )
		lists:SetSize( 340, 210 )
		lists:SetPos( 10, 0 )
		lists:SetSpaceY( 5 )
		lists:SetSpaceX( 5 )
		tabs.Utilities["Addons"].List = lists
		
		-- From Sandbox
		local function AddRecursive( pnl, folder, path, wildcard )
			local files, folders = file.Find( folder .. "*", path )
			for k, v in pairs( files ) do
				if ( !string.EndsWith( v, ".mdl" ) ) then continue end
				
				local model = folder..v
				
				local ListItem = pnl:Add( "SpawnIcon" )
				ListItem:SetSize( 45, 45 )
				ListItem:SetModel(model)
				ListItem.Model = model
				ListItem.DoClick = function( item )
					nzQMenu:Request(item.Model)
					surface.PlaySound( "ui/buttonclickrelease.wav" )
				end
				ListItem.DoRightClick = function( item )
					local menu = DermaMenu()
					local submenu = menu:AddSubMenu( "Add to category" )
					for k2,v2 in pairs(data) do
						submenu:AddOption(v2.name, function()
							table.insert(v2.models, model)
							ReloadSpawnlist()
						end)
					end
					
					menu:AddSpacer()
					
					menu:AddOption("Add to new category ...", function()
						CategoryEditor(nil, model)
					end)
					menu:Open()
				end
				
			end
			for k, v in pairs( folders ) do
				AddRecursive( pnl, folder .. v .. "/", path, wildcard )
			end
		end
		
		for _, addon in SortedPairsByMemberValue( engine.GetAddons(), "title" ) do
			if ( !addon.downloaded || !addon.mounted ) then continue end
			if ( addon.models <= 0 ) then continue end

			local models = tabs.Utilities["Addons"].AddonList:AddNode( addon.title .. " (" .. addon.models .. ")", "icon16/bricks.png" )
			models.DoClick = function()

				local pnl = tabs.Utilities["Addons"].List
				pnl:Clear()
				
				AddRecursive(pnl, "models/", addon.title, "*.mdl")

			end
		end
		
		UtilitySheet:AddSheet( "Addons", tabs.Utilities["Addons"], "icon16/bricks.png", false, false, v )
		
		if !frame.SpawnlistActive then
			UtilitySheet:SetVisible(false)
		end
	end
	
	if !file.Exists( "nz/spawnlist.txt", "DATA" ) then
		if !file.Exists( "nz/", "DATA" ) then
			file.CreateDir( "nz" )
		end
		local content = file.Read("nzmapscripts/defaultspawnlist.lua", "LUA")
		file.Write("nz/spawnlist.txt", content)
	end
	
	local content = file.Read( "nz/spawnlist.txt", "DATA" )
	if content then
		data = util.KeyValuesToTable(content)
		ReloadSpawnlist()
		CreateUtilities()
		UtilitySheet:SetVisible(false) -- This starts off
	end	

	hook.Add( "SearchUpdate", "SearchUpdate", function()
		if ( !tabs.Utilities["Search"]:IsVisible() ) then return end
		tabs.Utilities["Search"]:RefreshResults()
	end)
	
	local save = vgui.Create("DButton", frame)
	save:SetPos(325, 4)
	save:SetSize(50, 16)
	save:SetText("Save")
	save.DoClick = function()
		local tbl = {}
		for k,v in pairs(data) do
			table.insert(tbl, v)
		end		
		local keyvalues = util.TableToKeyValues(tbl)
		file.Write("nz/spawnlist.txt", keyvalues)
	end

end

function nzQMenu:CreateToolsMenu( )

	-- Create a Frame to contain everything.
	nzQMenu.Data.MainFrame = vgui.Create( "DFrame" )
	--nzQMenu.Data.MainFrame:SetTitle( "Tools Menu" )
	nzQMenu.Data.MainFrame:SetSize( 465, 300 )
	nzQMenu.Data.MainFrame:Center()
	nzQMenu.Data.MainFrame:MakePopup()
	nzQMenu.Data.MainFrame:ShowCloseButton( true )
	nzQMenu.Data.MainFrame:SetTitle("")
	nzQMenu.Data.MainFrame.Paint = function(self, w, h) end
	nzQMenu.Data.MainFrame.ToolMode = true
	nzQMenu.Data.MainFrame:MakePopup()
	
	local ToolPanel = vgui.Create("DFrame", nzQMenu.Data.MainFrame )
	ToolPanel:SetPos( 305, 25 )
	ToolPanel:SetSize( 155, 260 )
	ToolPanel:SetZPos(-30)
	ToolPanel:ShowCloseButton(false)
	ToolPanel:SetDraggable(false)
	ToolPanel:SetTitle("Tool List")
	
	local ToolInterface = vgui.Create("DFrame", nzQMenu.Data.MainFrame )
	ToolInterface:SetPos( 0, 0 )
	ToolInterface:SetSize( 310, 300 )
	ToolInterface:ShowCloseButton(false)
	ToolInterface:SetDraggable(true)
	ToolInterface:SetTitle(nzTools.ToolData[LocalPlayer():GetActiveWeapon().ToolMode or "default"].displayname)
	
	local FrameMerge = vgui.Create("DPanel", nzQMenu.Data.MainFrame )
	FrameMerge:SetPos( 308, 49 )
	FrameMerge:SetSize( 4, 235 )
	FrameMerge.Paint = function(self, w, h)
		surface.SetDrawColor(96, 100, 103)
		surface.DrawRect(0, 0, w, h)
	end
	
	local ToolList = vgui.Create( "DScrollPanel", nzQMenu.Data.MainFrame )
	ToolList:SetPos( 305, 58 )
	ToolList:SetSize( 150, 220 )
	
	local ToolData = vgui.Create("DPanel", ToolInterface )
	ToolData:SetPos( 5, 30 )
	ToolData:SetSize( 300, 265 )
	
	-- Loop to make all the tabs
	local tabs = {}
	tabs.Tools = {}
	local curtool = nil
	local numtools = 0
	
	local function RebuildToolInterface(id)
		--print(ToolData.interface)
		if nzTools.ToolData[id] then
			if ToolData.interface then ToolData.interface:Remove() end
			ToolData.interface = nzTools.ToolData[id].interface(ToolData, nzTools.SavedData[id])
			
			if tabs.Tools[curtool] then tabs.Tools[curtool]:SetBackgroundColor( Color(150, 150, 150) ) end
			if tabs.Tools[id] then tabs.Tools[id]:SetBackgroundColor( Color(255, 255, 255) ) end
			ToolInterface:SetTitle(nzTools.ToolData[id or "default"].displayname)
			curtool = id
			
			if !IsValid(ToolData.interface) then
				ToolData.interface = vgui.Create("DLabel", ToolData)
				ToolData.interface:SetText("This tool does not have any properties.")
				ToolData.interface:SetFont("Trebuchet18")
				ToolData.interface:SetTextColor( Color(50, 50, 50) )
				ToolData.interface:SizeToContents()
				ToolData.interface:Center()
			return end
		end
	end
	
	local function RebuildToolList() 
		for k,v in pairs(tabs.Tools) do
			v:Remove()
			numtools = 0
		end
		local tbl = {}
		
		-- Create a new cloned table that we can sort by weight
		for k,v in pairs(nzTools.ToolData) do
			if !nzTools.SavedData[k] then
				nzTools.SavedData[k] = v.defaultdata
			end
			local num = table.insert(tbl, v)
			tbl[num].id = k
		end
		table.SortByMember(tbl, "weight", true)
		
		for k,v in pairs(tbl) do
			if v.condition(LocalPlayer():GetActiveWeapon(), LocalPlayer()) then
				tabs.Tools[v.id] = vgui.Create("DPanel", ToolList)
				tabs.Tools[v.id]:SetSize(145, 20)
				tabs.Tools[v.id]:SetPos(0, 0 + numtools*22)
				tabs.Tools[v.id]:SetZPos(30000)
				if LocalPlayer():GetActiveWeapon().ToolMode and LocalPlayer():GetActiveWeapon().ToolMode == k then
					tabs.Tools[v.id]:SetBackgroundColor( Color(255, 255, 255) )
					RebuildToolInterface(v.id)
				else
					tabs.Tools[v.id]:SetBackgroundColor( Color(150, 150, 150) )
				end
				
				local icon = vgui.Create("DImage", tabs.Tools[v.id])
				icon:SetImage(v.icon)
				icon:SetPos(3,3)
				icon:SizeToContents()
				
				local tooltext = vgui.Create("DLabel", tabs.Tools[v.id])
				tooltext:SetText(v.displayname)
				tooltext:SetTextColor( Color(10, 10, 10) )
				tooltext:SetPos(24,3)
				tooltext:SizeToContents()
				
				local toolbutton = vgui.Create("DButton", tabs.Tools[v.id])
				toolbutton:SetPos(0,0)
				toolbutton:SetSize(145, 20)
				toolbutton:SetText("")
				toolbutton.Paint = function() end
				toolbutton.DoClick = function()
					local wep = LocalPlayer():GetActiveWeapon()
					if wep and wep:GetClass() == "nz_multi_tool" then
						LocalPlayer():GetActiveWeapon():SwitchTool(v.id)
						RebuildToolInterface(v.id)
					end
				end
				
				numtools = numtools + 1
			end
		end
	end
	RebuildToolList()
	RebuildToolInterface(LocalPlayer():GetActiveWeapon().ToolMode or "default")
	
	ToolInterface.OnFocusChanged = function(self, bool)
		if bool then
			-- Keep the design here, the buttons are supposed to leak into the main frame
			self:SetZPos(-10)
		end
	end
	
	local advanced = vgui.Create("DCheckBoxLabel", ToolInterface)
	advanced:SetPos(200, 6)
	advanced:SetText("Advanced Mode")
	advanced:SetValue(nzTools.Advanced)
	advanced:SizeToContents()
	advanced.OnChange = function(self)
		nzTools.Advanced = self:GetChecked()
		RebuildToolList()
		RebuildToolInterface(LocalPlayer():GetActiveWeapon().ToolMode or "default")
	end
	
end

function nzQMenu:Open()
	-- Check if we're in create mode
	if nzRound:InState( ROUND_CREATE ) and LocalPlayer():IsInCreative() then
		if !IsValid(nzQMenu.Data.MainFrame) then
			if IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass() == "nz_multi_tool" then
				nzQMenu:CreateToolsMenu()
			else
				nzQMenu:CreatePropsMenu()
			end
		end
		
		-- If the toolgun is equipped and the menu isn't the toolmenu or vice versa, recreate
		if IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass() == "nz_multi_tool" and !nzQMenu.Data.MainFrame.ToolMode then
			nzQMenu.Data.MainFrame:Remove()
			nzQMenu:CreateToolsMenu()
		elseif IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass() != "nz_multi_tool" and nzQMenu.Data.MainFrame.ToolMode then
			nzQMenu.Data.MainFrame:Remove()
			nzQMenu:CreatePropsMenu()
		end

		nzQMenu.Data.MainFrame:SetVisible( true )
	end
end

local textentryfocus = false

function nzQMenu:Close()

	-- We don't want to close if we're currently typing
	if textentryfocus then return end
	
	if !IsValid(nzQMenu.Data.MainFrame) then
		if IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass() == "nz_multi_tool" then
			nzQMenu:CreateToolsMenu()
		else
			nzQMenu:CreatePropsMenu()
		end
	end

	nzQMenu.Data.MainFrame:SetVisible( false )
	nzQMenu.Data.MainFrame:KillFocus()
	nzQMenu.Data.MainFrame:SetKeyboardInputEnabled(false)
	textentryfocus = false
end

hook.Add( "OnSpawnMenuOpen", "OpenSpawnMenu", nzQMenu.Open )
hook.Add( "OnSpawnMenuClose", "CloseSpawnMenu", nzQMenu.Close )

hook.Add( "OnTextEntryGetFocus", "StartTextFocus", function(panel) 
	textentryfocus = true
	if IsValid(nzQMenu.Data.MainFrame) then
		nzQMenu.Data.MainFrame:SetKeyboardInputEnabled(true)
	end
end )
hook.Add( "OnTextEntryLoseFocus", "EndTextFocus", function(panel) 
	textentryfocus = false 
	TextEntryLoseFocus()
	if IsValid(nzQMenu.Data.MainFrame) then
		nzQMenu.Data.MainFrame:KillFocus()
		nzQMenu.Data.MainFrame:SetKeyboardInputEnabled(false)
	end
end )
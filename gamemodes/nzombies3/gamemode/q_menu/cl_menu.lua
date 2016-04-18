
function nz.QMenu.Functions.CreatePropsMenu( )

	//Create a Frame to contain everything.
	nz.QMenu.Data.MainFrame = vgui.Create( "DFrame" )
	nz.QMenu.Data.MainFrame:SetTitle( "Props Menu" )
	nz.QMenu.Data.MainFrame:SetSize( 475, 340 )
	nz.QMenu.Data.MainFrame:Center()
	nz.QMenu.Data.MainFrame:SetPopupStayAtBack(true)
	nz.QMenu.Data.MainFrame:MakePopup()
	nz.QMenu.Data.MainFrame:ShowCloseButton( true )
	nz.QMenu.Data.MainFrame:SetVisible( false )

	local PropertySheet = vgui.Create( "DPropertySheet", nz.QMenu.Data.MainFrame )
	PropertySheet:SetPos( 10, 30 )
	PropertySheet:SetSize( 455, 300 )

	//Loop to make all the tabs
	local tabs = {}
	tabs.Scrolls = {}
	tabs.Lists = {}

	for k,v in pairs(nz.QMenu.Data.Categories) do
		tabs.Scrolls[k] = vgui.Create( "DScrollPanel", nz.QMenu.Data.MainFrame )
		tabs.Scrolls[k]:SetSize( 455, 300 )
		tabs.Scrolls[k]:SetPos( 10, 30 )

		tabs.Lists[k] = vgui.Create( "DIconLayout", tabs.Scrolls[k] )
		tabs.Lists[k]:SetSize( 440, 300 )
		tabs.Lists[k]:SetPos( 0, 0 )
		tabs.Lists[k]:SetSpaceY( 5 ) //Sets the space in between the panels on the X Axis by 5
		tabs.Lists[k]:SetSpaceX( 5 ) //Sets the space in between the panels on the Y Axis by 5
		if v == true then v = nil end
		PropertySheet:AddSheet( k, tabs.Scrolls[k], nil, false, false, v )
	end
	
	tabs.Scrolls["Entities"] = vgui.Create( "DScrollPanel", nz.QMenu.Data.MainFrame )
	tabs.Scrolls["Entities"]:SetSize( 455, 300 )
	tabs.Scrolls["Entities"]:SetPos( 10, 30 )

	tabs.Lists["Entities"] = vgui.Create( "DIconLayout", tabs.Scrolls["Entities"] )
	tabs.Lists["Entities"]:SetSize( 440, 300 )
	tabs.Lists["Entities"]:SetPos( 0, 0 )
	tabs.Lists["Entities"]:SetSpaceY( 5 )
	tabs.Lists["Entities"]:SetSpaceX( 5 )
	PropertySheet:AddSheet( "Entities", tabs.Scrolls["Entities"], nil, false, false, v )
	
	tabs.Scrolls["Search"] = vgui.Create( "DPanel", nz.QMenu.Data.MainFrame )
	tabs.Scrolls["Search"]:SetSize( 455, 300 )
	tabs.Scrolls["Search"]:SetPos( 10, 30 )
	
	tabs.Scrolls["Search"].Warn = vgui.Create( "DLabel", tabs.Scrolls["Search"] )
	tabs.Scrolls["Search"].Warn:SetSize( 420, 20 )
	tabs.Scrolls["Search"].Warn:SetPos( 60, 5 )
	tabs.Scrolls["Search"].Warn:SetTextColor( Color(0,0,0) )
	tabs.Scrolls["Search"].Warn:SetText("Warning: May cause severe lag and/or crash. Be sure to save first.")
	
	tabs.Scrolls["Search"].Search = vgui.Create( "DTextEntry", tabs.Scrolls["Search"] )
	tabs.Scrolls["Search"].Search:SetSize( 420, 20 )
	tabs.Scrolls["Search"].Search:SetPos( 10, 25 )
	tabs.Scrolls["Search"].Search.OnEnter = function() tabs.Scrolls["Search"]:RefreshResults() end
	tabs.Scrolls["Search"].Search:SetTooltip("Press Enter to search/update results")
	
	tabs.Scrolls["Search"].Content = vgui.Create( "DScrollPanel", tabs.Scrolls["Search"] )
	tabs.Scrolls["Search"].Content:SetSize( 430, 210 )
	tabs.Scrolls["Search"].Content:SetPos( 0, 50 )

	tabs.Lists["Search"] = vgui.Create( "DIconLayout", tabs.Scrolls["Search"].Content )
	tabs.Lists["Search"]:SetSize( 440, 210 )
	tabs.Lists["Search"]:SetPos( 10, 00 )
	tabs.Lists["Search"]:SetSpaceY( 5 )
	tabs.Lists["Search"]:SetSpaceX( 5 )
	
	function tabs.Scrolls.Search:RefreshResults() 
		--print(self.Search:GetText(), "Refresh")
		if ( self.Search:GetText() == "" ) then return end
		local pnl = tabs.Lists["Search"]
		pnl:Clear()
		local results = search.GetResults( self.Search:GetText() )
		--PrintTable(results)
		for k,v in pairs(results) do
			local ListItem = pnl:Add( "SpawnIcon" )
			ListItem:SetSize( 45, 45 )
			ListItem:SetModel(v)
			ListItem.Model = v
			ListItem.DoClick = function( item )
				nz.QMenu.Functions.Request(item.Model)
				surface.PlaySound( "ui/buttonclickrelease.wav" )
			end
		end
	end
	
	PropertySheet:AddSheet( "Search", tabs.Scrolls["Search"], "icon16/magnifier.png", false, false, v )

	hook.Add( "SearchUpdate", "SearchUpdate", function()
		if ( !tabs.Scrolls["Search"]:IsVisible() ) then return end
		tabs.Scrolls["Search"]:RefreshResults()
	end)

	for k,v in pairs(nz.QMenu.Data.Models) do //Make a loop to create a bunch of panels inside of the DIconLayout
		local ListItem = tabs.Lists[v[1]]:Add( "SpawnIcon" ) //Add DPanel to the DIconLayout
		ListItem:SetSize( 48, 48 ) //Set the size of it
		ListItem:SetModel(v[2])
		ListItem.Model = v[2]
		ListItem.DoClick = function( item )
			nz.QMenu.Functions.Request(item.Model)
			surface.PlaySound( "ui/buttonclickrelease.wav" )
		end
		//You don't need to set the position, that is done automatically.

	end
	
	for k,v in pairs(nz.QMenu.Data.Entities) do //Make a loop to create a bunch of panels inside of the DIconLayout
		local ListItem = tabs.Lists["Entities"]:Add( "DImageButton" ) //Add DPanel to the DIconLayout
		ListItem:SetSize( 48, 48 ) //Set the size of it
		ListItem:SetImage(v[2])
		ListItem.Entity = v[1]
		ListItem.DoClick = function( item )
			nz.QMenu.Functions.Request(item.Entity, true)
			surface.PlaySound( "ui/buttonclickrelease.wav" )
		end
		ListItem:SetTooltip(v[3] or v[1])
		//You don't need to set the position, that is done automatically.

	end

end

function nz.QMenu.Functions.CreateToolsMenu( )

	//Create a Frame to contain everything.
	nz.QMenu.Data.MainFrame = vgui.Create( "DFrame" )
	--nz.QMenu.Data.MainFrame:SetTitle( "Tools Menu" )
	nz.QMenu.Data.MainFrame:SetSize( 465, 300 )
	nz.QMenu.Data.MainFrame:Center()
	nz.QMenu.Data.MainFrame:MakePopup()
	nz.QMenu.Data.MainFrame:ShowCloseButton( true )
	nz.QMenu.Data.MainFrame:SetTitle("")
	nz.QMenu.Data.MainFrame.Paint = function(self, w, h) end
	nz.QMenu.Data.MainFrame.ToolMode = true
	nz.QMenu.Data.MainFrame:MakePopup()
	
	local ToolPanel = vgui.Create("DFrame", nz.QMenu.Data.MainFrame )
	ToolPanel:SetPos( 305, 25 )
	ToolPanel:SetSize( 155, 260 )
	ToolPanel:SetZPos(-30)
	ToolPanel:ShowCloseButton(false)
	ToolPanel:SetDraggable(false)
	ToolPanel:SetTitle("Tool List")
	
	local ToolInterface = vgui.Create("DFrame", nz.QMenu.Data.MainFrame )
	ToolInterface:SetPos( 0, 0 )
	ToolInterface:SetSize( 310, 300 )
	ToolInterface:ShowCloseButton(false)
	ToolInterface:SetDraggable(true)
	ToolInterface:SetTitle(nz.Tools.ToolData[LocalPlayer():GetActiveWeapon().ToolMode or "default"].displayname)
	
	local FrameMerge = vgui.Create("DPanel", nz.QMenu.Data.MainFrame )
	FrameMerge:SetPos( 308, 49 )
	FrameMerge:SetSize( 4, 235 )
	FrameMerge.Paint = function(self, w, h)
		surface.SetDrawColor(96, 100, 103)
		surface.DrawRect(0, 0, w, h)
	end
	
	local ToolList = vgui.Create( "DScrollPanel", nz.QMenu.Data.MainFrame )
	ToolList:SetPos( 305, 58 )
	ToolList:SetSize( 150, 220 )
	
	local ToolData = vgui.Create("DPanel", ToolInterface )
	ToolData:SetPos( 5, 30 )
	ToolData:SetSize( 300, 265 )
	
	//Loop to make all the tabs
	local tabs = {}
	tabs.Tools = {}
	local curtool = nil
	local numtools = 0
	
	local function RebuildToolInterface(id)
		--print(ToolData.interface)
		if nz.Tools.ToolData[id] then
			if ToolData.interface then ToolData.interface:Remove() end
			ToolData.interface = nz.Tools.ToolData[id].interface(ToolData, nz.Tools.SavedData[id])
			
			if tabs.Tools[curtool] then tabs.Tools[curtool]:SetBackgroundColor( Color(150, 150, 150) ) end
			if tabs.Tools[id] then tabs.Tools[id]:SetBackgroundColor( Color(255, 255, 255) ) end
			ToolInterface:SetTitle(nz.Tools.ToolData[id or "default"].displayname)
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
		for k,v in pairs(nz.Tools.ToolData) do
			if !nz.Tools.SavedData[k] then
				nz.Tools.SavedData[k] = v.defaultdata
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
			//Keep the design here, the buttons are supposed to leak into the main frame
			self:SetZPos(-10)
		end
	end
	
	local advanced = vgui.Create("DCheckBoxLabel", ToolInterface)
	advanced:SetPos(200, 6)
	advanced:SetText("Advanced Mode")
	advanced:SetValue(nz.Tools.Advanced)
	advanced:SizeToContents()
	advanced.OnChange = function(self)
		nz.Tools.Advanced = self:GetChecked()
		RebuildToolList()
		RebuildToolInterface(LocalPlayer():GetActiveWeapon().ToolMode or "default")
	end
	
end

function nz.QMenu.Functions.Open()
	//Check if we're in create mode
	if nzRound:InState( ROUND_CREATE ) and LocalPlayer():IsSuperAdmin() then
		if !IsValid(nz.QMenu.Data.MainFrame) then
			if IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass() == "nz_multi_tool" then
				nz.QMenu.Functions.CreateToolsMenu()
			else
				nz.QMenu.Functions.CreatePropsMenu()
			end
		end
		
		//If the toolgun is equipped and the menu isn't the toolmenu or vice versa, recreate
		if IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass() == "nz_multi_tool" and !nz.QMenu.Data.MainFrame.ToolMode then
			nz.QMenu.Data.MainFrame:Remove()
			nz.QMenu.Functions.CreateToolsMenu()
		elseif IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass() != "nz_multi_tool" and nz.QMenu.Data.MainFrame.ToolMode then
			nz.QMenu.Data.MainFrame:Remove()
			nz.QMenu.Functions.CreatePropsMenu()
		end

		nz.QMenu.Data.MainFrame:SetVisible( true )
	end
end

local textentryfocus = false

function nz.QMenu.Functions.Close()

	//We don't want to close if we're currently typing
	if textentryfocus then return end
	
	if !IsValid(nz.QMenu.Data.MainFrame) then
		if IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass() == "nz_multi_tool" then
			nz.QMenu.Functions.CreateToolsMenu()
		else
			nz.QMenu.Functions.CreatePropsMenu()
		end
	end

	nz.QMenu.Data.MainFrame:SetVisible( false )
	nz.QMenu.Data.MainFrame:KillFocus()
	nz.QMenu.Data.MainFrame:SetKeyboardInputEnabled(false)
	textentryfocus = false
end

hook.Add( "OnSpawnMenuOpen", "OpenSpawnMenu", nz.QMenu.Functions.Open )
hook.Add( "OnSpawnMenuClose", "CloseSpawnMenu", nz.QMenu.Functions.Close )

hook.Add( "OnTextEntryGetFocus", "StartTextFocus", function(panel) 
	textentryfocus = true
	if IsValid(nz.QMenu.Data.MainFrame) then
		nz.QMenu.Data.MainFrame:SetKeyboardInputEnabled(true)
	end
end )
hook.Add( "OnTextEntryLoseFocus", "EndTextFocus", function(panel) 
	textentryfocus = false 
	TextEntryLoseFocus()
	if IsValid(nz.QMenu.Data.MainFrame) then
		nz.QMenu.Data.MainFrame:KillFocus()
		nz.QMenu.Data.MainFrame:SetKeyboardInputEnabled(false)
	end
end )
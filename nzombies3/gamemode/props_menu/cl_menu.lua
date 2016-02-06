
function nz.PropsMenu.Functions.Create( )

	//Create a Frame to contain everything.
	nz.PropsMenu.Data.MainFrame = vgui.Create( "DFrame" )
	nz.PropsMenu.Data.MainFrame:SetTitle( "Props Menu" )
	nz.PropsMenu.Data.MainFrame:SetSize( 375, 240 )
	nz.PropsMenu.Data.MainFrame:Center()
	nz.PropsMenu.Data.MainFrame:MakePopup()
	nz.PropsMenu.Data.MainFrame:ShowCloseButton( false )
	nz.PropsMenu.Data.MainFrame:SetVisible( false )

	local PropertySheet = vgui.Create( "DPropertySheet", nz.PropsMenu.Data.MainFrame )
	PropertySheet:SetPos( 10, 30 )
	PropertySheet:SetSize( 355, 200 )

	//Loop to make all the tabs
	local tabs = {}
	tabs.Scrolls = {}
	tabs.Lists = {}

	for k,v in pairs(nz.PropsMenu.Data.Categories) do
		tabs.Scrolls[k] = vgui.Create( "DScrollPanel", nz.PropsMenu.Data.MainFrame )
		tabs.Scrolls[k]:SetSize( 355, 200 )
		tabs.Scrolls[k]:SetPos( 10, 30 )

		tabs.Lists[k]	= vgui.Create( "DIconLayout", tabs.Scrolls[k] )
		tabs.Lists[k]:SetSize( 340, 200 )
		tabs.Lists[k]:SetPos( 0, 0 )
		tabs.Lists[k]:SetSpaceY( 5 ) //Sets the space in between the panels on the X Axis by 5
		tabs.Lists[k]:SetSpaceX( 5 ) //Sets the space in between the panels on the Y Axis by 5
		if v == true then v = nil end
		PropertySheet:AddSheet( k, tabs.Scrolls[k], nil, false, false, v )
	end
	
	tabs.Scrolls["Entities"] = vgui.Create( "DScrollPanel", nz.PropsMenu.Data.MainFrame )
	tabs.Scrolls["Entities"]:SetSize( 355, 200 )
	tabs.Scrolls["Entities"]:SetPos( 10, 30 )

	tabs.Lists["Entities"]	= vgui.Create( "DIconLayout", tabs.Scrolls["Entities"] )
	tabs.Lists["Entities"]:SetSize( 340, 200 )
	tabs.Lists["Entities"]:SetPos( 0, 0 )
	tabs.Lists["Entities"]:SetSpaceY( 5 )
	tabs.Lists["Entities"]:SetSpaceX( 5 )
	if v == true then v = nil end
	PropertySheet:AddSheet( "Entities", tabs.Scrolls["Entities"], nil, false, false, v )



	for k,v in pairs(nz.PropsMenu.Data.Models) do //Make a loop to create a bunch of panels inside of the DIconLayout
		local ListItem = tabs.Lists[v[1]]:Add( "SpawnIcon" ) //Add DPanel to the DIconLayout
		ListItem:SetSize( 40, 40 ) //Set the size of it
		ListItem:SetModel(v[2])
		ListItem.Model = v[2]
		ListItem.DoClick = function( item )
			nz.PropsMenu.Functions.Request(item.Model)
			surface.PlaySound( "ui/buttonclickrelease.wav" )
		end
		//You don't need to set the position, that is done automatically.

	end
	
	for k,v in pairs(nz.PropsMenu.Data.Entities) do //Make a loop to create a bunch of panels inside of the DIconLayout
		local ListItem = tabs.Lists["Entities"]:Add( "DImageButton" ) //Add DPanel to the DIconLayout
		ListItem:SetSize( 40, 40 ) //Set the size of it
		ListItem:SetImage(v[2])
		ListItem.Entity = v[1]
		ListItem.DoClick = function( item )
			nz.PropsMenu.Functions.Request(item.Entity, true)
			surface.PlaySound( "ui/buttonclickrelease.wav" )
		end
		//You don't need to set the position, that is done automatically.

	end

end

function nz.PropsMenu.Functions.Open()
	//Check if we're in create mode
	if nz.Rounds.Data.CurrentState == ROUND_CREATE and LocalPlayer():IsSuperAdmin() then
		if nz.PropsMenu.Data.MainFrame == nil then
			nz.PropsMenu.Functions.Create()
		end

		nz.PropsMenu.Data.MainFrame:SetVisible( true )
	end
end

function nz.PropsMenu.Functions.Close()
	if nz.Rounds.Data.CurrentState == ROUND_CREATE then
		if nz.PropsMenu.Data.MainFrame == nil then
			nz.PropsMenu.Functions.Create()
		end

		nz.PropsMenu.Data.MainFrame:SetVisible( false )
	end
end

hook.Add( "OnSpawnMenuOpen", "OpenSpawnMenu", nz.PropsMenu.Functions.Open )
hook.Add( "OnSpawnMenuClose", "CloseSpawnMenu", nz.PropsMenu.Functions.Close )

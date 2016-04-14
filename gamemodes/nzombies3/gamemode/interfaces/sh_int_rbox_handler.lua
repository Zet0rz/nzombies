//

if SERVER then
	function nz.Interfaces.Functions.RBoxHandlerHandler( ply, data )
		if ply:IsSuperAdmin() then
			Mapping:RBoxHandler(data.vec, data.classes, data.ang, data.keep, ply)
		end
	end
end

if CLIENT then

		//Create the Panel so we can reopen it
	function nz.Interfaces.Functions.CreateRBoxHandlerPanel()
		local wepz = {}

		local DermaPanel = vgui.Create( "DFrame" )
		DermaPanel:SetPos( 100, 100 )
		DermaPanel:SetSize( 300, 350 )
		DermaPanel:SetTitle( "Handle Random Box Weapons" )
		DermaPanel:SetVisible( false )
		DermaPanel:SetDraggable( true )
		DermaPanel:ShowCloseButton( true )
		DermaPanel:SetDeleteOnClose(false)

		local DProperties = vgui.Create( "DProperties", DermaPanel )
		DProperties:SetSize( 280, 280 )
		DProperties:SetPos( 10, 30 )
		
		for k,v in pairs(weapons.GetList()) do
			local Row = DProperties:CreateRow( "Weapon Settings", "Weapon #"..k )
			Row:Setup( "Combo" )
			Row:AddChoice(" Select ...", nil)
			for k,v in pairs(weapons.GetList()) do
				Row:AddChoice(v.PrintName and v.PrintName != "" and v.PrintName or v.ClassName, v.ClassName, false)
			end
			
			Row.DataChanged = function( _, val ) 
				wepz[k] = val
				PrintTable(wepz)
			end
		end
		
		return DermaPanel, wepz
	end
	
	//Reloading on a handler doesn't actually load its data - it just reopens the last panel
	local DermaPanel, wepz = nz.Interfaces.Functions.CreateRBoxHandlerPanel()
	
	function nz.Interfaces.Functions.RBoxHandler( data )
	
		//Recreate the list if Reload was not fired on the handler
		if !data.keep then
			DermaPanel, wepz = nz.Interfaces.Functions.CreateRBoxHandlerPanel()
		end
		
		DermaPanel:SetVisible(true)
		DermaPanel:MakePopup()
		DermaPanel:Center()
		
		local DermaButton = vgui.Create( "DButton" )
		DermaButton:SetParent( DermaPanel )
		DermaButton:SetText( "Submit" )
		DermaButton:SetPos( 10, 315 )
		DermaButton:SetSize( 280, 30 )
		DermaButton.DoClick = function()
		
				data.classes = wepz
				--data.keep = data.keep
				PrintTable(data)
				nz.Interfaces.Functions.SendRequests( "RBoxHandler", data )

				DermaPanel:Hide()

		end
	end
end

//

if SERVER then
	function nz.Interfaces.Functions.ZombLinkHandler( ply, data )
		if ply:IsSuperAdmin() then
			PrintTable(data)
			data.ent.link = data.link
			data.ent.respawnable = data.respawnable
			data.ent.spawnable = data.spawnable
			//For the link displayer
			if data.link then
				data.ent:SetLink(data.link)
			end
		end
	end
end

if CLIENT then
	function nz.Interfaces.Functions.ZombLink( data )
		PrintTable(data)
		local name = "Add New Zombie Link"
		local valz = {}
		valz["Row1"] = 0
		valz["Row2"] = 1
		//Check if the ent has flags already
		if data.link != nil then
			valz["Row1"] = 1
			valz["Row2"] = data.link
			name = "Modifying Zombie Link"
		end

		local DermaPanel = vgui.Create( "DFrame" )
		DermaPanel:SetPos( 100, 100 )
		DermaPanel:SetSize( 300, 180 )
		DermaPanel:SetTitle( name )
		DermaPanel:SetVisible( true )
		DermaPanel:SetDraggable( true )
		DermaPanel:ShowCloseButton( true )
		DermaPanel:MakePopup()
		DermaPanel:Center()

		local DProperties = vgui.Create( "DProperties", DermaPanel )
		DProperties:SetSize( 280, 180 )
		DProperties:SetPos( 10, 30 )

		local Row1 = DProperties:CreateRow( "Zombie Spawn", "Enable Flag?" )
		Row1:Setup( "Boolean" )
		Row1:SetValue( valz["Row1"] )
		Row1.DataChanged = function( _, val ) valz["Row1"] = val end
		local Row2 = DProperties:CreateRow( "Zombie Spawn", "Flag" )
		Row2:Setup( "Integer" )
		Row2:SetValue( valz["Row2"] )
		Row2.DataChanged = function( _, val ) valz["Row2"] = val end

		local DermaButton = vgui.Create( "DButton" )
		DermaButton:SetParent( DermaPanel )
		DermaButton:SetText( "Submit" )
		DermaButton:SetPos( 10, 140 )
		DermaButton:SetSize( 280, 30 )
		DermaButton.DoClick = function()
			local str="nil"
			if valz["Row1"] == 0 then
				str=nil
			else
				str=valz["Row2"]
			end
			data.link = str
			nz.Interfaces.Functions.SendRequests( "ZombLink", data )

			DermaPanel:Close()
		end
	end
end

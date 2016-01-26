//

if SERVER then
	function nz.Interfaces.Functions.ConfigLoaderHandler( ply, data )
		if ply:IsSuperAdmin() then
			nz.Mapping.Functions.LoadConfig( data.config )
		end
	end
end

if CLIENT then
	function nz.Interfaces.Functions.ConfigLoader( data )
		local DermaPanel = vgui.Create( "DFrame" )
		DermaPanel:SetPos( 100, 100 )
		DermaPanel:SetSize( 300, 180 )
		DermaPanel:SetTitle( "Load a config" )
		DermaPanel:SetVisible( true )
		DermaPanel:SetDraggable( true )
		DermaPanel:ShowCloseButton( true )
		DermaPanel:MakePopup()
		DermaPanel:Center()

		local DermaListView = vgui.Create("DListView")
		DermaListView:SetParent(DermaPanel)
		DermaListView:SetPos(10, 30)
		DermaListView:SetSize(280, 100)
		DermaListView:SetMultiSelect(false)
		DermaListView:AddColumn("Name")
		//Populate
		for k,v in pairs(data.configs) do
			DermaListView:AddLine(v)
		end

		local DermaButton = vgui.Create( "DButton" )
		DermaButton:SetParent( DermaPanel )
		DermaButton:SetText( "Submit" )
		DermaButton:SetPos( 10, 140 )
		DermaButton:SetSize( 280, 30 )
		DermaButton.DoClick = function()
			if DermaListView:GetSelectedLine() != nil then
				local str = DermaListView:GetLine(DermaListView:GetSelectedLine()):GetValue(1)
				if str != nil then
					data.configs = nil
					data.config = str
					nz.Interfaces.Functions.SendRequests( "ConfigLoader", data )
					DermaPanel:Close()
				end
			end
		end
	end
end

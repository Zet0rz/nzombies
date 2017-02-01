-- 

if SERVER then
	util.AddNetworkString("nz_SaveConfig")

	function nzInterfaces.ConfigSaverHandler( ply, data )
		if ply:IsSuperAdmin() then
			nzMapping:SaveConfig( data.name )
		end
	end
end

if CLIENT then
	function nzInterfaces.ConfigSaver(name)
		local DermaPanel = vgui.Create( "DFrame" )
		DermaPanel:SetPos( 100, 100 )
		DermaPanel:SetSize( 300, 120 )
		DermaPanel:SetTitle( "Save config" )
		DermaPanel:SetVisible( true )
		DermaPanel:SetDraggable( true )
		DermaPanel:ShowCloseButton( true )
		DermaPanel:MakePopup()
		DermaPanel:Center()
		
		local WarnText = vgui.Create("DLabel", DermaPanel)
		WarnText:SetSize(280, 20)
		WarnText:SetPos(10, 50)
		WarnText:SetText("")
		WarnText:SetTextColor( Color(150,0,0) )

		local TextEntry = vgui.Create("DTextEntry", DermaPanel)
		TextEntry:SetPos(10, 30)
		TextEntry:SetSize(280, 20)
		TextEntry:SetText(name)
		TextEntry.OnChange = function(self)
			if string.find(self:GetValue(), ";") then
				WarnText:SetText("The name cannot contain ';'!")
			else
				WarnText:SetText("")
			end
		end

		local DermaButton = vgui.Create( "DButton", DermaPanel )
		DermaButton:SetText( "Save" )
		DermaButton:SetPos( 10, 80 )
		DermaButton:SetSize( 280, 30 )
		DermaButton.DoClick = function()
			local name = TextEntry:GetValue()
			nzInterfaces.SendRequests( "ConfigSaver", {name = name} )
		end
	end
	
	net.Receive("nz_SaveConfig", function()
		local name = net.ReadString()
		nzInterfaces.ConfigSaver(name)
	end)
	
end

//

if SERVER then
	util.AddNetworkString("nz_ChangeLevel")
	net.Receive("nz_ChangeLevel", function(len, ply)
		if ply:IsSuperAdmin() then
			RunConsoleCommand("changelevel", net.ReadString())
		end
	end)
	
	function nz.Interfaces.Functions.ConfigLoaderHandler( ply, data )
		if ply:IsSuperAdmin() then
			nzMapping:LoadConfig( data.config, ply )
		end
	end
end

if CLIENT then
	function nz.Interfaces.Functions.ConfigLoader( data )
		local configs = {}
		local selectedconfig
		local hoveredpanel
		
		if data.officialconfigs then
			for k,v in pairs(data.officialconfigs) do
				local name = string.Explode(";", v)
				local map, configname = name[1], name[2]
				if name[2] then
					local config = {}
					config.map = string.sub(map, 4)
					config.name = string.sub(configname, 0, #configname-4)
					config.config = v
					config.official = true
					table.insert(configs, config)
				end
			end
		end
		if data.configs then
			for k,v in pairs(data.configs) do
				local name = string.Explode(";", v)
				local map, configname = name[1], name[2]
				if name[2] then
					local config = {}
					config.map = string.sub(map, 4)
					config.name = string.sub(configname, 0, #configname-4)
					config.config = v
					table.insert(configs, config)
				end
			end
		end
		if data.workshopconfigs then
			for k,v in pairs(data.workshopconfigs) do
				local name = string.Explode(";", v)
				local map, configname = name[1], name[2]
				if name[2] then
					local config = {}
					config.map = string.sub(map, 4)
					config.name = string.sub(configname, 0, #configname-4)
					config.config = v
					config.workshop = true
					table.insert(configs, config)
				end
			end
		end
		
		local DermaPanel = vgui.Create( "DFrame" )
		DermaPanel:SetPos( 100, 100 )
		DermaPanel:SetSize( 400, 500 )
		DermaPanel:SetTitle( "Load a config" )
		DermaPanel:SetVisible( true )
		DermaPanel:SetDraggable( true )
		DermaPanel:ShowCloseButton( true )
		DermaPanel:MakePopup()
		DermaPanel:Center()
		
		local SubmitButton = vgui.Create( "DButton", DermaPanel )
		SubmitButton:SetText( "Click a config to load" )
		SubmitButton:SetPos( 10, 460 )
		SubmitButton:SetSize( 380, 30 )
		SubmitButton.DoClick = function(self)
			if selectedconfig != nil and selectedconfig != "" then
				if string.find(self:GetText(), "Change map to") then
					net.Start("nz_ChangeLevel")
						net.WriteString(string.sub(string.Explode(";", selectedconfig)[1], 4))
					net.SendToServer()
				elseif string.find(self:GetText(), "This map is not installed") then
					chat.AddText("This map cannot be loaded as it is not installed")
				elseif selectedconfig and selectedconfig != "" then
					nz.Interfaces.Functions.SendRequests( "ConfigLoader", {config = selectedconfig} )
					DermaPanel:Close()
				end
			end
		end
		
		local sheet = vgui.Create("DPropertySheet", DermaPanel)
		sheet:SetPos(5, 30)
		sheet:SetSize(390, 420)
		
		local ConfigsScroll = vgui.Create("DScrollPanel", sheet)
		ConfigsScroll:SetPos(5, 5)
		ConfigsScroll:SetSize(380, 420)
		sheet:AddSheet("Configs", ConfigsScroll, "icon16/brick.png")
		
		local OldConfigs = vgui.Create("DListView", sheet)
		OldConfigs:SetPos(175, 350)
		OldConfigs:SetSize(250, 100)
		OldConfigs:SetMultiSelect(false)
		OldConfigs:AddColumn("Name")
		if data.configs then
			for k,v in pairs(data.configs) do
				OldConfigs:AddLine(v)
			end
		end
		if data.workshopconfigs then
			for k,v in pairs(data.workshopconfigs) do
				OldConfigs:AddLine(v)
			end
		end
		if data.officialconfigs then
			for k,v in pairs(data.officialconfigs) do
				OldConfigs:AddLine(v)
			end
		end
		OldConfigs.OnRowSelected = function(self, index, row)
			selectedconfig = row:GetValue(1)
			SubmitButton:SetText( "                                Load config\nWarning: May not work properly without changing map" )
		end
		sheet:AddSheet("All config files", OldConfigs, "icon16/database_table.png")
		
		local ConfigList = vgui.Create("DListLayout", ConfigsScroll)
		ConfigList:SetPos(0,150)
		ConfigList:SetSize(370, 420)
		ConfigList:SetPaintBackground(true)
		ConfigList:SetBackgroundColor(Color(255,255,255))
		
		local CurMapConfigList = vgui.Create("DListLayout", ConfigsScroll)
		CurMapConfigList:SetPos(0,0)
		CurMapConfigList:SetSize(370, 120)
		CurMapConfigList:SetPaintBackground(true)
		CurMapConfigList:SetBackgroundColor(Color(255,255,255))
		
		for k,v in pairs(configs) do
			local config = vgui.Create("DPanel", v.map == game.GetMap() and CurMapConfigList or ConfigList)
			config:SetPos(0,0)
			config:SetSize(380, 50)
			config:SetPaintBackground(true)
			config.Paint = function(self, w, h)
				if selectedconfig == v.config then
					surface.SetDrawColor(200,200,255)
				elseif hoveredpanel == k then
					surface.SetDrawColor(230,230,255)
				else
					surface.SetDrawColor(255,255,255)
				end
				self:DrawFilledRect()
			end
			--config:SetBackgroundColor(ColorRand())
			
			local mapicon = "nzmapicons/"..string.StripExtension(v.config)..".png"
			if ( Material(mapicon):IsError() ) then mapicon = "maps/thumb/" .. v.map .. ".png" end
			if ( Material(mapicon):IsError() ) then mapicon = "maps/" .. v.map .. ".png" end
			if ( Material(mapicon):IsError() ) then mapicon = "noicon.png" end
			
			local map = vgui.Create("DImage", config)
			map:SetPos(5, 5)
			map:SetSize(40, 40)
			map:SetImage(mapicon)
			
			local configname = vgui.Create("DLabel", config)
			configname:SetText(v.name)
			configname:SetTextColor(Color(20, 20, 20))
			configname:SizeToContents()
			configname:SetPos(70, 18)
			
			local mapname = vgui.Create("DLabel", config)
			mapname:SetText(v.map)
			mapname:SetTextColor(Color(20, 20, 20))
			mapname:SizeToContents()
			mapname:SetPos(180, 18)
			
			local mapstatus = vgui.Create("DLabel", config)
			local status = file.Find("maps/"..v.map..".bsp", "GAME")[1] and true or false
			mapstatus:SetText(status and "Map installed" or "Map not installed" )
			mapstatus:SetTextColor(status and Color(20, 200, 20) or Color(200, 20, 20))
			mapstatus:SizeToContents()
			mapstatus:SetPos(360 - mapstatus:GetWide(), 12)
			
			local configlocation = vgui.Create("DLabel", config)
			configlocation:SetText(v.workshop and "Workshop" or v.official and "Official" or "Local")
			configlocation:SetTextColor(v.workshop and Color(150, 20, 100) or v.official and Color(255,0,0) or Color(20, 20, 200))
			configlocation:SizeToContents()
			configlocation:SetPos(360 - configlocation:GetWide(), 26)
			
			local click = vgui.Create("DButton", config)
			click:SetText("")
			click:SetPos(0,0)
			click:SetSize(380, 50)
			click.Paint = function(self) 
				if self:IsHovered() then hoveredpanel = k end
			end
			click.DoClick = function(self)
				selectedconfig = v.config
				if game.GetMap() != v.map then
					SubmitButton:SetText(status and "Change map to "..v.map or "This map is not installed")
				else
					SubmitButton:SetText( "Load config" )
				end
				-- Doesn't work? :/
				OldConfigs:SelectItem(nil)
			end
			
		end
		
		local curmapcount = table.Count(CurMapConfigList:GetChildren())
		if curmapcount <= 0 then
			local txtpnl = vgui.Create("DPanel", CurMapConfigList)
			txtpnl:SetSize(380,50)
			
			local txt = vgui.Create("DLabel", txtpnl)
			txt:SetText("No configs found for the current map.")
			txt:SizeToContents()
			txt:Center()
			txt:SetTextColor(Color(0,0,0))
			curmapcount = 1
		end
		ConfigList:SetPos(0,curmapcount*50 + 20)
	end
end

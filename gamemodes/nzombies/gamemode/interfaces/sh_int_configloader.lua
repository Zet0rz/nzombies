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

	if not ConVarExists("nz_configloader_fetchworkshop") then CreateConVar("nz_configloader_fetchworkshop", 1, {FCVAR_ARCHIVE}) end

	function nz.Interfaces.Functions.ConfigLoader( data )
		local configs = {}
		local selectedconfig
		local hoveredpanel
		
		if data.officialconfigs then
			for k,v in pairs(data.officialconfigs) do
				local name = string.Explode(";", string.StripExtension(v))
				local map, configname, workshopid = name[1], name[2], name[3]
				if name[2] then
					local config = {}
					config.map = string.sub(map, 4)
					config.name = configname
					config.config = v
					config.official = true
					if workshopid then config.workshopid = workshopid end
					table.insert(configs, config)
				end
			end
		end
		if data.configs then
			for k,v in pairs(data.configs) do
				local name = string.Explode(";", string.StripExtension(v))
				local map, configname, workshopid = name[1], name[2], name[3]
				if name[2] then
					local config = {}
					config.map = string.sub(map, 4)
					config.name = configname
					config.config = v
					if workshopid then config.workshopid = workshopid end
					table.insert(configs, config)
				end
			end
		end
		if data.workshopconfigs then
			for k,v in pairs(data.workshopconfigs) do
				local name = string.Explode(";", string.StripExtension(v))
				local map, configname, workshopid = name[1], name[2], name[3]
				if name[2] then
					local config = {}
					config.map = string.sub(map, 4)
					config.name = configname
					config.config = v
					config.workshop = true
					if workshopid then config.workshopid = workshopid end
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
			
			local mapicon = "nzmapicons/nz_"..v.map..";"..v.name..".png"
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
			
			local configlocation = vgui.Create(v.workshopid and "DLabelURL" or "DLabel", config)
			if v.workshopid then 
				configlocation:SetURL("http://steamcommunity.com/sharedfiles/filedetails/?id="..v.workshopid)
				-- It isn't underlined? :(
			end
			configlocation:SetText(v.workshop and "Workshop" or v.official and "Official" or "Local")
			configlocation:SetTextColor(v.workshop and Color(150, 20, 100) or v.official and Color(255,0,0) or Color(20, 20, 200))
			configlocation:SizeToContents()
			configlocation:SetPos(360 - configlocation:GetWide(), 26)
			
			local function IsLocalCopy(name)
				if configs then
					for k2,v2 in pairs(configs) do
						if v2.official or v2.workshop then
							if v2.name == name then return true end
						end
					end
				end
				return false
			end
			
			local maphover = vgui.Create("DButton", config)
			maphover:SetText("")
			maphover:SetPos(0,0)
			maphover:SetSize(50, 50)
			maphover.Paint = function(self) 
				if self:IsHovered() then 
					hoveredpanel = k
					if !IsValid(self.ExtendedInfo) then
						self.ExtendedInfo = vgui.Create("DPanel")
						self.ExtendedInfo:SetSize(400, 150)
						local x, y = self:LocalToScreen(0, 25)
						self.ExtendedInfo:SetPos(x - 400, y - 75)
						
						self.ExtendedInfo.MapIcon = vgui.Create("DImage", self.ExtendedInfo)
						self.ExtendedInfo.MapIcon:SetPos(5, 5)
						self.ExtendedInfo.MapIcon:SetSize(140, 140)
						self.ExtendedInfo.MapIcon:SetImage(mapicon)
						
						self.ExtendedInfo.Title = vgui.Create("DLabel", self.ExtendedInfo)
						self.ExtendedInfo.Title:SetText(v.name)
						self.ExtendedInfo.Title:SetTextColor(Color(50,50,50))
						self.ExtendedInfo.Title:SetFont("Trebuchet18")
						self.ExtendedInfo.Title:SizeToContents()
						self.ExtendedInfo.Title:SetPos(265 - self:GetWide()/2, 10)
						
						self.ExtendedInfo.CreateLayout = function(self2)
							if !IsValid(self2.Msg) then
								self2.Msg = vgui.Create("DLabel", self2)
								self2.Msg:SetPos(155, 35)
								self2.Msg:SetSize(235, 45)
								self2.Msg:SetWrap(true)
								self2.Msg:SetTextColor(Color(100,100,100))
							end
							if !GetConVar("nz_configloader_fetchworkshop"):GetBool() then
								self2.Msg:SetText("Set 'nz_configloader_fetchworkshop' to 1 to be able to load metadata from the config's workshop page.")
								self2.NoLoad = true
							elseif !v.workshop and !v.official then
								if IsLocalCopy(v.name) then
									self2.Msg:SetText("Local copy of "..v.name..".")
								else
									self2.Msg:SetText("Local config.")
								end
								self2.NoLoad = true
							elseif !v.workshopid then
								self2.Msg:SetText("This config does not have any set Workshop ID to get data from.")
								self2.NoLoad = true
							else
								self2.Msg:SetText("Loading ...")
							end
						end
						
						self.ExtendedInfo.UpdateData = function(self2)
							if !self2.DataTable then 
								if !IsValid(self2.Msg) then
									self2.Msg = vgui.Create("DLabel", self2)
									self2.Msg:SetPos(155, 25)
									self2.Msg:SetSize(235, 45)
									self2.Msg:SetWrap(true)
									self2.Msg:SetTextColor(Color(100,100,100))
								end
								self2.Msg:SetText("Failed loading information!")
							return end
							
							if IsValid(self2.Msg) then
								self2.Msg:Remove()
							end
							
							if !IsValid(self2.Desc) then 
								self2.Desc = vgui.Create("DLabel", self2)
								self2.Desc:SetPos(155, 25)
								self2.Desc:SetSize(235, 45)
								self2.Desc:SetWrap(true)
								self2.Desc:SetTextColor(Color(100,100,100))
							end
							self2.Desc:SetText(self2.DataTable.Description or "No Description found.")
							
							if !IsValid(self2.MidLine) then
								self2.MidLine = vgui.Create("DPanel", self2)
								self2.MidLine:SetPos(155, 74)
								self2.MidLine:SetSize(235, 2)
								self2.MidLine:SetBackgroundColor(Color(225,225,225))
							end
							
							if !IsValid(self2.SplitLine) then
								self2.SplitLine = vgui.Create("DPanel", self2)
								self2.SplitLine:SetPos(299, 80)
								self2.SplitLine:SetSize(2, 60)
								self2.SplitLine:SetBackgroundColor(Color(225,225,225))
							end
							
							if !IsValid(self2.Creator) then
								self2.Creator = vgui.Create("DLabel", self2)
								self2.Creator:SetPos(155, 80)
								self2.Creator:SetSize(140, 10)
								self2.Creator:SetTextColor(Color(100,100,100))
							end
							self2.Creator:SetText(self2.DataTable.Creator and "Creator: "..self2.DataTable.Creator or "Creator: N/A")
							self2.Creator:SetTooltip(self2.DataTable.Creator or "N/A")
							
							if !IsValid(self2.Map) then
								self2.Map = vgui.Create("DLabel", self2)
								self2.Map:SetPos(155, 92)
								self2.Map:SetSize(30, 15)
								self2.Map:SetTextColor(Color(100,100,100))
								self2.Map:SetText("Map:")
							end
							
							if !IsValid(self2.MapLink) then
								self2.MapLink = vgui.Create(self2.DataTable["Map ID"] and "DLabelURL" or "DLabel", self2)
								self2.MapLink:SetPos(185, 92)
								self2.MapLink:SetSize(110, 15)
								self2.MapLink:SetTextColor(self2.DataTable["Map ID"] and Color(50,50,200) or Color(100,100,100))
								self2.MapLink:SetText(v.map)
								self2.MapLink:SetTooltip(v.map)
								if self2.DataTable["Map ID"] then self2.MapLink:SetURL("http://steamcommunity.com/sharedfiles/filedetails/?id="..self2.DataTable["Map ID"]) end
							end
							
							if !IsValid(self2.ConfigPack) then
								self2.ConfigPack = vgui.Create("DLabel", self2)
								self2.ConfigPack:SetPos(155, 104)
								self2.ConfigPack:SetSize(30, 15)
								self2.ConfigPack:SetTextColor(Color(100,100,100))
								self2.ConfigPack:SetText("Pack:")
							end
							
							if !IsValid(self2.ConfigLink) then
								self2.ConfigLink = vgui.Create(self2.DataTable["Pack Name"] and "DLabelURL" or "DLabel", self2)
								self2.ConfigLink:SetPos(185, 104)
								self2.ConfigLink:SetSize(110, 15)
								self2.ConfigLink:SetTextColor(self2.DataTable["Pack Name"] and Color(50,50,200) or Color(100,100,100))
								self2.ConfigLink:SetText(self2.DataTable["Pack Name"] or "N/A")
								self2.ConfigLink:SetTooltip(self2.DataTable["Pack Name"] or "N/A")
								if self2.DataTable["Pack Name"] then self2.ConfigLink:SetURL("http://steamcommunity.com/sharedfiles/filedetails/?id="..v.workshopid) end
							end
							
							if !IsValid(self2.Note) and self2.DataTable["Note"] then
								self2.Note = vgui.Create("DLabel", self2)
								self2.Note:SetPos(155, 118)
								self2.Note:SetSize(140, 30)
								self2.Note:SetWrap(true)
								self2.Note:SetTextColor(Color(120,120,120))
								self2.Note:SetText(self2.DataTable["Note"])
								self2.Note:SetTooltip(self2.DataTable["Note"])
							end
							
							if !IsValid(self2.Packs) then
								self2.Packs = vgui.Create("DLabel", self2)
								self2.Packs:SetPos(320, 80)
								self2.Packs:SetSize(60, 15)
								self2.Packs:SetTextColor(Color(50,50,50))
								self2.Packs:SetText("Used Packs")
							end
							
							if !IsValid(self2.PackScroll) then
								self2.PackScroll = vgui.Create("DScrollPanel", self2)
								self2.PackScroll:SetPos(310, 95)
								self2.PackScroll:SetSize(80, 50)
								self2.PackScroll.Paint = function() end
								--print(self2.PackScroll:GetChildren().DVScrollBar)
								--PrintTable(self2.PackScroll:GetChildren())
								local scroll = self2.PackScroll:GetChildren()[2]
								scroll.Paint = function() end
								for k,v in pairs(scroll:GetChildren()) do
									v.Paint = function() end
								end
							end
							
							if self2.DataTable["Used Packs"] then
								local count = 0
								for k,v in pairs(self2.DataTable["Used Packs"]) do
									local pack = vgui.Create("DLabelURL", self2.PackScroll)
									pack:SetText(k)
									pack:SetTooltip(k)
									pack:SetURL("http://steamcommunity.com/sharedfiles/filedetails/?id="..v)
									pack:SetSize(80, 15)
									pack:SetPos(0, count*15)
									count = count + 1
									--self2.PackScroll:AddItem(pack)
								end
							end
							
						end
						
						self.ExtendedInfo.Think = function(self2)
							if !self2.DataTable and !self2.NoLoad then
								self2:CreateLayout()
								
								if !self2.NoLoad then
									if !self2.TimeMark then self2.TimeMark = CurTime() + 0.2 end
									if CurTime() > self2.TimeMark then
										self2.NoLoad = true
										http.Fetch( "http://steamcommunity.com/sharedfiles/filedetails/?id="..v.workshopid,
										function( body, len, headers, code )
											--print(body)
											local strstart1, strend1 = string.find(body, '{'..v.name..'} = {')
											if !strend1 then self2:UpdateData() return end
											--print(v.name, strstart1 and string.sub(body, strstart1, strend1 + 50) or "Not found", #body, strstart1, strend1)
											local strstart2, strend2 = string.find(body, '{end}', strend1)
											if !strend2 then self2:UpdateData() return end
											local data = string.sub(body, strend1, strstart2 - 1)
											if !data then self2:UpdateData() return end
											data = string.Replace(data, "&quot;", '"')
											data = string.Replace(data, "<br>", '')
											--print(data)
											--PrintTable(util.JSONToTable(data))
											self2.DataTable = util.JSONToTable(data)
											self2:UpdateData()
											
										end,
										function( error )
											print("Couldn't get information from the workshop! Error: ".. error)
										end
										)
									end
								end
							end
						end
						
						self.ExtendedInfo:MakePopup()
					elseif !self.ExtendedInfo:IsVisible() then 
						self.ExtendedInfo:Show()
						local x, y = self:LocalToScreen(0, 25)
						self.ExtendedInfo:SetPos(x - 400, y - 75)
						self.ExtendedInfo:MakePopup()
					end
				else
					if IsValid(self.ExtendedInfo) and !self.ExtendedInfo:IsHovered() and !self.ExtendedInfo:IsChildHovered() and self.ExtendedInfo:IsVisible() then self.ExtendedInfo:Hide() end
				end
			end
			maphover.OnRemove = function(self)
				if IsValid(self.ExtendedInfo) then self.ExtendedInfo:Remove() end
			end
			--[[maphover.DoClick = function(self)
				selectedconfig = v.config
				if game.GetMap() != v.map then
					SubmitButton:SetText(status and "Change map to "..v.map or "This map is not installed")
				else
					SubmitButton:SetText( "Load config" )
				end
				-- Doesn't work? :/
				OldConfigs:SelectItem(nil)
			end]]
			
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

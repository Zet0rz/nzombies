if SERVER then
	util.AddNetworkString("nzReceiveVotes")
	util.AddNetworkString("nzStartVote")
	
	function nzInterfaces.ConfigLoaderHandler( ply, data )
		if ply:IsSuperAdmin() then
			nzMapping:LoadConfig( data.config, ply )
		end
	end
	
	local votetime = votetime or 0
	local votes = votes or {}
	local voting = false
	local convartime = GetConVar("nz_rtv_time"):GetInt()
	local nextvote
	if convartime > 0 then
		nextvote = nextvote or CurTime() + convartime*60
	end
	
	function nzInterfaces.StartVote( time, caller )
		local tbl = nzMapping:GetConfigs()
		
		votes = {}
		
		for k,v in pairs(tbl.configs) do
			votes[v] = 0
		end
		for k,v in pairs(tbl.workshopconfigs) do
			votes[v] = 0
		end
		for k,v in pairs(tbl.officialconfigs) do
			votes[v] = 0
		end
		
		net.Start("nzStartVote")
			net.WriteUInt(time, 6)
			net.WriteTable(tbl)
		net.Broadcast()
		
		for k,v in pairs(player.GetAll()) do
			v.nzConfigVote = nil -- Reset what config they voted on
		end
		
		votetime = CurTime() + time
		hook.Add("Think", "nzVoteHandler", function()
			if CurTime() > votetime then
				local winner = {}
				local winvotes = 0
				
				for k,v in pairs(votes) do
					if v > winvotes then
						winner = {k}
						winvotes = v
					elseif v == winvotes then
						table.insert(winner, k)
					end
				end
				
				winner = table.Random(winner)
				
				net.Start("nzReceiveVotes")
					net.WriteBool(true) -- We're done voting
					net.WriteString(winner)
					net.WriteBool(false) -- No one added a vote
					net.WriteBool(false) -- No one removed a vote
				net.Broadcast()
				
				hook.Remove("Think", "nzVoteHandler")
				timer.Simple(5, function()
					voting = false
					--PrintMessage(HUD_PRINTTALK, "[nZ] The winner is "..winner)
					if nzRound:InProgress() then
						PrintMessage(HUD_PRINTTALK, "[nZ] The config will be loaded after the current game.")
						nzMapping:QueueConfig( winner, caller ) -- Caller of the vote is responsible for mismatch if done via nz_rtv command
					else
						nzMapping:LoadConfig( winner, caller )
					end
				end)
			end
		end)
		
		voting = true
		local convartime = GetConVar("nz_rtv_time"):GetInt()
		if convartime > 0 then
			nextvote = CurTime() + convartime*60
		else
			nextvote = nil
		end
	end
	concommand.Add("nz_rtv", function(ply,cmd,args,argstr)
		local time = args[1] and tonumber(args[1]) or 30
		nzInterfaces.StartVote(time, ply)
	end, nil, "Starts a config vote. Accepts 1 argument: The amount of time to have the vote running. Defaults to 30 seconds.",
	FCVAR_SERVER_CAN_EXECUTE)
	
	local function votechange(newvote, oldvote, ply)
		if !voting then return end -- We're not even voting, wut?!
		
		--print(new, old, ply)
		
		net.Start("nzReceiveVotes")
			net.WriteBool(false) -- We haven't finished yet
			if newvote then
				if votes[newvote] then
					votes[newvote] = votes[newvote] + 1
				end
				net.WriteBool(true) -- Vote was added
				net.WriteString(newvote) -- This was the vote
			else
				net.WriteBool(false)
			end
			if oldvote then
				if votes[oldvote] then
					votes[oldvote] = votes[oldvote] - 1
				end
				net.WriteBool(true)
				net.WriteString(oldvote)
			else
				net.WriteBool(false)
			end
		net.Broadcast()
		
		ply.nzConfigVote = newvote
	end
	
	net.Receive("nzReceiveVotes", function(len, ply)
		if !voting then return end -- We're not even voting, wut?!
		
		local newvote = net.ReadString()
		local oldvote = ply.nzConfigVote
		
		votechange(newvote, oldvote, ply)
	end)
	
	local rtvs = rtvs or {}
	local rtvcount = rtvcount or 0
	
	hook.Add("EntityRemoved", "nzVotePlayerLeft", function(ent)
		if ent:IsPlayer() then
			votechange(nil, ent.nzConfigVote, ent)
			if rtvs[ent] then
				rtvcount = rtvcount - 1
				rtvs[ent] = nil
			end
		end
	end)
	
	hook.Add("OnRoundWaiting", "nzVoteOnRoundEnd", function()
		if nextvote and CurTime() >= nextvote then
			nzInterfaces.StartVote( 30 )
		end
	end)
	
	
	nzChatCommand.Add("/rtv", function(ply, text)
		if IsValid(ply) then
			if voting then
				ply:ChatPrint("A vote is already going. Press F1 to open the window.")
			else
				if !rtvs[ply] then
					rtvcount = rtvcount + 1
					rtvs[ply] = true
					
					local req = math.ceil(#player.GetAll()/2)
					PrintMessage(HUD_PRINTTALK, ply:Nick().." has voted to change map. "..rtvcount.."/"..req.." votes.")
					if rtvcount >= req then
						if nzRound:InState( ROUND_WAITING ) or nzRound:InState( ROUND_CREATE ) then
							PrintMessage(HUD_PRINTTALK, "Vote succeeded!")
							nzInterfaces.StartVote(30)
						else
							PrintMessage(HUD_PRINTTALK, "Vote succeeded! Vote will take place at the end of the current game.")
							nextvote = CurTime()
						end
					end
				else
					ply:ChatPrint("You have already voted to change map.")
				end
			end
		end
	end, true, "   Vote to change map.")
end

if CLIENT then

	if not ConVarExists("nz_configloader_fetchworkshop") then CreateConVar("nz_configloader_fetchworkshop", 1, {FCVAR_ARCHIVE}) end
	
	local maxvote -- Used to calculate the green bars filling them up

	function nzInterfaces.ConfigLoader( data, vote, votetime )
		if vote and IsValid(nzInterfaces.ConfigVoter) then
			nzInterfaces.ConfigVoter:Show() -- If players closed the config voter, recalling this func will just reopen it
			return
		end
		
		local time = CurTime()
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
		DermaPanel:SetTitle( vote and "Vote on a config (Press F1 to reopen)" or "Load a config" )
		DermaPanel:SetVisible( true )
		DermaPanel:SetDraggable( true )
		DermaPanel:ShowCloseButton( true )
		DermaPanel:MakePopup()
		DermaPanel:Center()
		
		if vote then 
			DermaPanel:SetDeleteOnClose(false)
			nzInterfaces.ConfigVoter = DermaPanel
		end
		
		local SubmitButton = vgui.Create( "DButton", DermaPanel )
		SubmitButton:SetText( vote and "Click a config to vote" or "Click a config to load" )
		SubmitButton:SetPos( 10, 460 )
		SubmitButton:SetSize( 380, 30 )
		SubmitButton.DoClick = function(self)
			if vote then
				if selectedconfig != nil and selectedconfig != "" then
					net.Start("nzReceiveVotes")
						net.WriteString(selectedconfig)
					net.SendToServer()
				end
			else
				if selectedconfig != nil and selectedconfig != "" then
					if string.find(self:GetText(), "This map is not installed") then
						chat.AddText("This map cannot be loaded as it is not installed")
					elseif selectedconfig and selectedconfig != "" then
						nzInterfaces.SendRequests( "ConfigLoader", {config = selectedconfig} )
						DermaPanel:Close()
					end
				end
			end
		end
		if vote and time then
			SubmitButton.PaintOver = function(self, w, h)
				local pct = (CurTime() - time)/votetime
				surface.SetDrawColor(100, 100, 255, 150)
				surface.DrawRect(0, 0, w*pct, h)
			end
		end
		
		local sheet = vgui.Create("DPropertySheet", DermaPanel)
		sheet:SetPos(5, 30)
		sheet:SetSize(390, 420)
		
		local ConfigsScroll = vgui.Create("DScrollPanel", sheet)
		ConfigsScroll:SetPos(5, 5)
		ConfigsScroll:SetSize(380, 420)
		sheet:AddSheet("Configs", ConfigsScroll, "icon16/brick.png")
		
		if !vote then
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
		end
		
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
			
				surface.SetDrawColor(255,255,255)
				self:DrawFilledRect()
				
				if vote and maxvote and maxvote > 0 then
					local votes = nzInterfaces.ConfigVotes[v.config]
					if votes then
						if votes > maxvote then maxvote = votes end
						surface.SetDrawColor(100,255,100)
						surface.DrawRect(0,0, w * votes/maxvote, h)
					end
				end
				
				if selectedconfig == v.config then
					surface.SetDrawColor(100,100,255,100)
					self:DrawFilledRect()
				elseif hoveredpanel == k then
					surface.SetDrawColor(180,180,255,100)
					self:DrawFilledRect()
				end
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
			mapname:SetPos(180, vote and 11 or 18)
			
			if vote then
				local votecount = vgui.Create("DLabel", config)
				votecount:SetText("Votes: 0")
				votecount:SetTextColor(Color(200, 20, 20))
				votecount:SizeToContents()
				votecount:SetPos(190, 25)
				votecount.Think = function(self)
					--PrintTable(nzInterfaces.ConfigVotes)
					self:SetText("Votes: "..nzInterfaces.ConfigVotes[v.config])
				end
			end
			
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
				if game.GetMap() != v.map and !vote then
					SubmitButton:SetText(status and "Change map to "..v.map.." and load" or "This map is not installed")
				else
					SubmitButton:SetText( vote and "Cast vote" or "Load config" )
				end
				-- Doesn't work? :/
				--OldConfigs:SelectItem(nil)
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
	
	net.Receive("nzReceiveVotes", function()
		maxvote = 0
		
		local finished = net.ReadBool() -- Reused later
		if finished then -- Vote finished
			local config = net.ReadString()
			
			if IsValid(nzInterfaces.ConfigVoter) then nzInterfaces.ConfigVoter:Remove() end
			nzInterfaces.ConfigVotes = nil
			config = config and string.Explode(";", string.StripExtension(config))[2] or config or "[INVALID]"
			chat.AddText("[nZ] Vote finished! The winning map is ", Color(255,150,150), config..".")
		end
		
		if net.ReadBool() then -- Vote added. This will never be true if the above is true
			local config = net.ReadString()
			if !nzInterfaces.ConfigVotes then nzInterfaces.ConfigVotes = {} end
			if !nzInterfaces.ConfigVotes[config] then nzInterfaces.ConfigVotes[config] = 0 end
			
			nzInterfaces.ConfigVotes[config] = nzInterfaces.ConfigVotes[config] + 1
		end
		
		if net.ReadBool() then -- Vote removed. Either from changing vote or disconnecting
			local config = net.ReadString()
			if nzInterfaces.ConfigVotes[config] then
				nzInterfaces.ConfigVotes[config] = nzInterfaces.ConfigVotes[config] - 1
			else
				nzInterfaces.ConfigVotes[config] = 0
			end
		end
		
		if !finished then
			-- Recalculate every time it's not finished, after votes have changed
			for k,v in pairs(nzInterfaces.ConfigVotes) do
				if v > maxvote then maxvote = v end
			end
		end
	end)
	
	net.Receive("nzStartVote", function()
		local time = net.ReadUInt(6)
		local data = net.ReadTable()
		
		if IsValid(nzInterfaces.ConfigVoter) then nzInterfaces.ConfigVoter:Remove() end -- Reset it
		nzInterfaces.ConfigVotes = {}
		for k,v in pairs(data.configs) do
			nzInterfaces.ConfigVotes[v] = 0
		end
		for k,v in pairs(data.workshopconfigs) do
			nzInterfaces.ConfigVotes[v] = 0
		end
		for k,v in pairs(data.officialconfigs) do
			nzInterfaces.ConfigVotes[v] = 0
		end
		maxvote = 0
		nzInterfaces.ConfigLoader(data, true, time)
	end)
end

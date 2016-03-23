Mapping.Mismatch = Mapping.Mismatch or {}
Mapping.MismatchData = Mapping.MismatchData or {}

if SERVER then
	util.AddNetworkString("nzMappingMismatchData")
	util.AddNetworkString("nzMappingMismatchEnd")

	net.Receive("nzMappingMismatchData", function(len, ply)
		if !ply:IsSuperAdmin() then
			print(ply:Nick() .. " tried to correct map data. You need to be a super admin to do this.")
			return
		end
		local id = net.ReadString()
		local data = net.ReadTable()
		Mapping.Mismatch[id].Correct(data)
	end)

else
	net.Receive("nzMappingMismatchData", function()
		local id = net.ReadString()
		local data = net.ReadTable()
		Mapping.MismatchData[id] = data
	end)

	net.Receive("nzMappingMismatchEnd", function()
		OpenMismatchInterface()
	end)

	function OpenMismatchInterface()
		local frame = vgui.Create("DFrame")
		frame:SetSize(400, 500)
		frame:Center()
		frame:SetTitle("Config Loading Mismatch!")
		frame:MakePopup()

		local sheet = vgui.Create("DPropertySheet", frame)
		sheet:SetPos(5, 25)
		sheet:SetSize(390, 435)
		sheet.sheets = {}
		
		frame.OnClose = function()
			local corrected = nil
			for k,v in pairs(sheet.sheets) do
				v.ReturnCorrectedData()
				corrected = true
			end
			if corrected then
				chat.AddText("Applied default actions on the rest of the mismatches, some entities may have disappeared.")
			end
		end

		for k,v in pairs(Mapping.MismatchData) do
			if table.Count(v) > 0 then
				local panel = Mapping.Mismatch[k].Interface(sheet)
				local info = sheet:AddSheet(k, panel)
				--table.insert(sheet.sheets, {tab = info.Tab, panel = info.Panel, name = tab.Name})
				sheet.sheets[info.Tab] = info.Panel
			end
		end
		
		sheet.CloseTabAndOpenNew = function(update)
			local tab = sheet:GetActiveTab()
			local panel = sheet.sheets[tab]
			if update then
				panel.ReturnCorrectedData()
			end
			
			local newtab = table.GetKeys(sheet.sheets)[1]
			if newtab == tab then newtab = table.GetKeys(sheet.sheets)[2] end
			if !IsValid(newtab) then
				sheet.sheets[tab] = nil
				frame:Close()
				chat.AddText("Remember to re-save the cleaned config if you don't want to go through this every time.")
				return
			end
			sheet:SetActiveTab(newtab)
			
			timer.Simple(0.1, function() 
				if IsValid(tab) then
					sheet.sheets[tab] = nil
					sheet:CloseTab(tab) 
				end 
			end)
		end
		
		local submit = vgui.Create("DButton", frame)
		submit:SetText("Submit Changes")
		submit:SetSize(200, 30)
		submit:SetPos(90, 465)
		submit:CenterHorizontal()
		submit.DoClick = function()
			sheet.CloseTabAndOpenNew(true)
		end
	end
end

function CreateMismatchCheck(id, sv_check, cl_interface, sv_correct)
	-- Create tables for storing it
	Mapping.Mismatch[id] = Mapping.Mismatch[id] or {}
	Mapping.MismatchData[id] = Mapping.MismatchData[id] or {}

	if SERVER then
		Mapping.Mismatch[id].Check = sv_check
		Mapping.Mismatch[id].Correct = sv_correct
	else
		Mapping.Mismatch[id].Interface = cl_interface
	end
end

function Mapping:CheckMismatch( loader )
	if !IsValid(loader) then return end
	local faults = nil
	
	for k,v in pairs(self.Mismatch) do
		local data = self.Mismatch[k].Check() -- Run the check function and save the data
		if data and table.Count(data) > 0 then -- Empty tables don't get sent, no errors
			net.Start("nzMappingMismatchData")
				net.WriteString(k)
				net.WriteTable(data)
			net.Send(loader)
			faults = true
		end
	end
	
	if faults then -- No need to send if there's nothing wrong
		net.Start("nzMappingMismatchEnd") -- Mark the end of all data so the client can compile it all
		net.Send(loader)
	end
end

CreateMismatchCheck("Wall Buys", function()
	local tbl = {}
	for k,v in pairs(ents.FindByClass("wall_buys")) do
		if !weapons.Get(v:GetEntName()) then
			print("Wall Buy has non-existant weapon class: " .. v:GetEntName() .. "!")
			tbl[v:GetEntName()] = true
		end
	end
	
	return tbl -- Return the data you want to send to the client

end, function(frame)

	local pnl = vgui.Create("DPanel", frame)
	pnl:SetPos(5, 5)
	pnl:SetSize(380, 425)

	local properties = vgui.Create("DProperties", pnl)
	properties:SetPos(0, 0)
	properties:SetSize(380, 420)

	for k,v in pairs(Mapping.MismatchData["Wall Buys"]) do
		local choice = properties:CreateRow( "Missing Weapons", k )
		choice:Setup( "Combo", {} )
		choice:AddChoice( " Remove ...", "nz_removeweapon", true )
		Mapping.MismatchData["Wall Buys"][k] = "nz_removeweapon"
		for _, v2 in pairs(weapons.GetList()) do
			if v2.Category and v2.Category != "" then
				choice:AddChoice(v2.PrintName and v2.PrintName != "" and v2.Category.. " - "..v2.PrintName or v2.ClassName, v2.ClassName, false)
			else
				choice:AddChoice(v2.PrintName and v2.PrintName != "" and v2.PrintName or v2.ClassName, v2.ClassName, false)
			end
		end
		choice.DataChanged = function(self, val)
			Mapping.MismatchData["Wall Buys"][k] = val
		end
	end

	pnl.ReturnCorrectedData = function() -- Add the function to the returned panel so we can access it outside
		net.Start("nzMappingMismatchData")
			net.WriteString("Wall Buys")
			net.WriteTable(Mapping.MismatchData["Wall Buys"])
		net.SendToServer()
		Mapping.MismatchData["Wall Buys"] = nil -- Clear the data
	end

	return pnl -- Return it to add it the the sheets

end, function( data )
	for k,v in pairs(ents.FindByClass("wall_buys")) do
		local new = data[v:GetEntName()]
		if new then
			if new == "nz_removeweapon" then
				v:Remove()
			else
				v:SetEntName(new)
			end
		end
	end

	Mapping.MismatchData["Wall Buys"] = nil -- Clear the data
end)

CreateMismatchCheck("Perks", function()
	local tbl = {}
	for k,v in pairs(ents.FindByClass("perk_machine")) do
		if !nz.Perks.Functions.Get(v:GetPerkID()) then
			print("Perk with non-existant perk: " .. v:GetPerkID() .. "!")
			tbl[v:GetPerkID()] = true
		end
	end

	return tbl -- Return the data you want to send to the client

end, function(frame)

	local pnl = vgui.Create("DPanel", frame)
	pnl:SetPos(5, 5)
	pnl:SetSize(380, 425)

	local properties = vgui.Create("DProperties", pnl)
	properties:SetPos(0, 0)
	properties:SetSize(380, 420)

	for k,v in pairs(Mapping.MismatchData["Perks"]) do
		local choice = properties:CreateRow( "Invalid Perks", k )
		choice:Setup( "Combo", {} )
		choice:AddChoice( " Remove ...", "nz_removeperk", true )
		Mapping.MismatchData["Perks"][k] = "nz_removeperk"
		for k2, v2 in pairs(weapons.GetList()) do
			choice:AddChoice(v2.name or k2, k2, false)
		end
		choice.DataChanged = function(self, val)
			Mapping.MismatchData["Petks"][k] = val
		end
	end

	pnl.ReturnCorrectedData = function()
		net.Start("nzMappingMismatchData")
			net.WriteString("Perks")
			net.WriteTable(Mapping.MismatchData["Perks"])
		net.SendToServer()
		Mapping.MismatchData["Perks"] = nil -- Clear the data
	end

	return pnl

end, function( data )
	for k,v in pairs(ents.FindByClass("perk_machine")) do
		local new = data[v:GetPerkID()]
		if new then
			if new == "nz_removeperk" then
				v:Remove()
			else
				v:SetPerkID(new)
				v:Update() -- Update model and perk values
			end
		end
	end

	Mapping.MismatchData["Perks"] = nil -- Clear the data
end)

CreateMismatchCheck("Map Settings", function()
	local tbl = {}
	local settings = Mapping.Settings

	if !weapons.Get(settings.startwep) then tbl["startwep"] = settings.startwep end
	-- Later add stuff like model packs, special round entity types etc.

	return tbl

	end, function(frame)

		local pnl = vgui.Create("DPanel", frame)
		pnl:SetPos(5, 5)
		pnl:SetSize(380, 425)

		local properties = vgui.Create("DProperties", pnl)
		properties:SetPos(0, 0)
		properties:SetSize(380, 420)

		local tbl = Mapping.MismatchData["Map Settings"]

		if tbl.startwep then
			local choice = properties:CreateRow( "Invalid Map Settings", "Start Weapon" )
			choice:Setup( "Combo", {} )
			for k,v2 in pairs(weapons.GetList()) do
				choice:AddChoice(v2.PrintName and v2.PrintName != "" and v2.PrintName or v2.ClassName, v2.ClassName, false)
			end
			choice.DataChanged = function(self, val)
				Mapping.MismatchData["Map Settings"]["startwep"] = val
			end
		end

		pnl.ReturnCorrectedData = function()
			net.Start("nzMappingMismatchData")
				net.WriteString("Map Settings")
				net.WriteTable(Mapping.MismatchData["Map Settings"])
			net.SendToServer()
			Mapping.MismatchData["Map Settings"] = nil
		end

		return pnl

	end, function( data )

		if data.startwep then
			Mapping.Settings.startwep = data.startwep
		end

		for k,v in pairs(player.GetAll()) do
			Mapping:SendMapData(ply) -- Update the data to players
		end

		Mapping.MismatchData["Map Settings"] = nil
end)

CreateMismatchCheck("Map Script", function()
	local tbl = {}
	if tobool(Mapping.Settings.script) then tbl["script"] = true end
	--if true then tbl["script"] = true end
	
	return tbl

	end, function(frame)

		local pnl = vgui.Create("DPanel", frame)
		pnl:SetPos(5, 5)
		pnl:SetSize(380, 425)
		
		local txt = vgui.Create("DLabel", pnl)
		txt:SetText("Map Script Load")
		txt:SetFont("DermaLarge")
		txt:SetTextColor(Color(75,75,75))
		txt:SizeToContents()
		txt:SetPos(0, 30)
		txt:CenterHorizontal()
		
		local txt2 = vgui.Create("DLabel", pnl)
		txt2:SetText("This config is attempting to load a lua script along with it.")
		txt2:SetTextColor(Color(75,75,75))
		txt2:SetFont("Trebuchet18")
		txt2:SizeToContents()
		txt2:SetPos(0, 70)
		txt2:CenterHorizontal()
		
		local txt3 = vgui.Create("DLabel", pnl)
		txt3:SetText("Lua scripts can be potentially dangerous as they can do")
		txt3:SetTextColor(Color(75,75,75))
		txt3:SetFont("Trebuchet18")
		txt3:SizeToContents()
		txt3:SetPos(0, 90)
		txt3:CenterHorizontal()
		
		local txt4 = vgui.Create("DLabel", pnl)
		txt4:SetText("anything any other addon or gamemode could potentially do.")
		txt4:SetTextColor(Color(75,75,75))
		txt4:SetFont("Trebuchet18")
		txt4:SizeToContents()
		txt4:SetPos(0, 100)
		txt4:CenterHorizontal()
		
		local txt5 = vgui.Create("DLabel", pnl)
		txt5:SetText("including kicking, banning, saving data, and more.")
		txt5:SetTextColor(Color(175,75,75))
		txt5:SetFont("Trebuchet18")
		txt5:SizeToContents()
		txt5:SetPos(0, 110)
		txt5:CenterHorizontal()
		
		local txt6 = vgui.Create("DLabel", pnl)
		txt6:SetText("However map scripts is what allows special events,")
		txt6:SetTextColor(Color(75,75,75))
		txt6:SetFont("Trebuchet18")
		txt6:SizeToContents()
		txt6:SetPos(0, 130)
		txt6:CenterHorizontal()
		
		local txt7 = vgui.Create("DLabel", pnl)
		txt7:SetText("objectives, or whole easter eggs to be coded directly.")
		txt7:SetTextColor(Color(75,75,75))
		txt7:SetFont("Trebuchet18")
		txt7:SizeToContents()
		txt7:SetPos(0, 140)
		txt7:CenterHorizontal()
		
		local txt8 = vgui.Create("DLabel", pnl)
		txt8:SetText("Load scripts from configs you trust or have verified yourself.")
		txt8:SetTextColor(Color(75,75,75))
		txt8:SetFont("Trebuchet18")
		txt8:SizeToContents()
		txt8:SetPos(0, 160)
		txt8:CenterHorizontal()
		
		local txt9 = vgui.Create("DLabel", pnl)
		txt9:SetText("This config claims to do the following:")
		txt9:SetTextColor(Color(75,75,75))
		txt9:SetFont("Trebuchet18")
		txt9:SizeToContents()
		txt9:SetPos(0, 190)
		txt9:CenterHorizontal()
		
		local txt10 = vgui.Create("DLabel", pnl)
		txt10:SetSize(350, 100)
		txt10:SetWrap(true)
		txt10:SetText(Mapping.Settings.scriptinfo or "- no description -")
		txt10:SetTextColor(Color(75,175,75))
		txt10:SetFont("Trebuchet18")
		txt10:SetPos(0, 210)
		txt10:CenterHorizontal()
		
		local txt11 = vgui.Create("DLabel", pnl)
		txt11:SetText("Load Script?")
		txt11:SetTextColor(Color(75,75,75))
		txt11:SetFont("Trebuchet18")
		txt11:SizeToContents()
		txt11:SetPos(0, 320)
		txt11:CenterHorizontal()
		
		local yes = vgui.Create("DButton", pnl)
		yes:SetText("Yes")
		yes:SetSize(75, 20)
		yes:SetPos(100, 340)
		yes.DoClick = function()
			net.Start("nzMappingMismatchData")
				net.WriteString("Map Script")
				net.WriteTable({load = true})
			net.SendToServer()
			Mapping.MismatchData["Map Script"] = nil
			frame:CloseTabAndOpenNew()
		end
		
		local no = vgui.Create("DButton", pnl)
		no:SetText("No")
		no:SetSize(75, 20)
		no:SetPos(200, 340)
		no.DoClick = function()
			net.Start("nzMappingMismatchData")
				net.WriteString("Map Script")
				net.WriteTable({load = false})
			net.SendToServer()
			Mapping.MismatchData["Map Script"] = nil
			frame:CloseTabAndOpenNew()
		end
		
		local txt12 = vgui.Create("DLabel", pnl)
		txt12:SetText("Clicking submit or closing will make it not load.")
		txt12:SetTextColor(Color(75,75,75))
		txt12:SetFont("Trebuchet18")
		txt12:SizeToContents()
		txt12:SetPos(0, 380)
		txt12:CenterHorizontal()

		pnl.ReturnCorrectedData = function() -- In this case, just a default action
			net.Start("nzMappingMismatchData")
				net.WriteString("Map Script")
				net.WriteTable({load = false})
			net.SendToServer()
			Mapping.MismatchData["Map Script"] = nil
		end

		return pnl

	end, function( data )

		if data.load then
			Mapping:LoadScript(Mapping.CurrentConfig)
		end

		Mapping.MismatchData["Map Script"] = nil
end)

CreateMismatchCheck("Random Box Weapons", function()
	local tbl = {}
	if Mapping.Settings.rboxweps and table.Count(Mapping.Settings.rboxweps) > 0 then
		for k,v in pairs(Mapping.Settings.rboxweps) do
			if !weapons.Get(v) then
				print("Random Box has non-existant weapon class: " .. v .. "!")
				tbl[v] = true
			end
		end
	end
	
	return tbl -- Return the data you want to send to the client

end, function(frame)

	local pnl = vgui.Create("DPanel", frame)
	pnl:SetPos(5, 5)
	pnl:SetSize(380, 425)

	local properties = vgui.Create("DProperties", pnl)
	properties:SetPos(0, 0)
	properties:SetSize(380, 420)

	for k,v in pairs(Mapping.MismatchData["Random Box Weapons"]) do
		local choice = properties:CreateRow( "Missing Box Weapons", k )
		choice:Setup( "Combo", {} )
		choice:AddChoice( " Remove ...", "nz_removeweapon", true )
		Mapping.MismatchData["Random Box Weapons"][k] = "nz_removeweapon"
		for _, v2 in pairs(weapons.GetList()) do
			if v2.Category and v2.Category != "" then
				choice:AddChoice(v2.PrintName and v2.PrintName != "" and v2.Category.. " - "..v2.PrintName or v2.ClassName, v2.ClassName, false)
			else
				choice:AddChoice(v2.PrintName and v2.PrintName != "" and v2.PrintName or v2.ClassName, v2.ClassName, false)
			end
		end
		choice.DataChanged = function(self, val)
			Mapping.MismatchData["Random Box Weapons"][k] = val
		end
	end

	pnl.ReturnCorrectedData = function() -- Add the function to the returned panel so we can access it outside
		net.Start("nzMappingMismatchData")
			net.WriteString("Random Box Weapons")
			net.WriteTable(Mapping.MismatchData["Random Box Weapons"])
		net.SendToServer()
		Mapping.MismatchData["Random Box Weapons"] = nil -- Clear the data
	end

	return pnl -- Return it to add it the the sheets

end, function( data )
	if Mapping.Settings.rboxweps and table.Count(Mapping.Settings.rboxweps) > 0 then
		for k,v in pairs(Mapping.Settings.rboxweps) do
			local new = data[v]
			if new then
				if new == "nz_removeweapon" then
					table.RemoveByValue(Mapping.Settings.rboxweps, v)
				else
					Mapping.Settings.rboxweps[table.KeyFromValue(Mapping.Settings.rboxweps, v)] = new
				end
			end
		end
	end

	Mapping.MismatchData["Wall Buys"] = nil -- Clear the data
end)
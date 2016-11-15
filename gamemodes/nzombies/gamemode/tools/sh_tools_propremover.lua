
if SERVER then
	util.AddNetworkString("nzPropRemoverSearch")
	
	net.Receive("nzPropRemoverSearch", function(len, ply)
		if ply:IsInCreative() then
			local tbl = net.ReadTable()
			PrintTable(tbl)
			for k,v in pairs(tbl) do
				local id = k:MapCreationID()
				if IsValid(k) and k != Entity(0) and id != -1 then
					if v and !nzMapping.MarkedProps[id] then
						ply:ChatPrint("Marked "..k:GetClass().." ["..k:EntIndex().."] for removal (ID: "..id..").")
						k:SetColor(Color(200,0,0))
						nzMapping.MarkedProps[id] = true
					elseif !v and nzMapping.MarkedProps[id] then
						ply:ChatPrint("Unmarked "..k:GetClass().." ["..k:EntIndex().."] for removal (ID: "..id..").")
						k:SetColor(Color(255,255,255))
						nzMapping.MarkedProps[id] = nil
					end
				end
			end
		end
	end)
	
else

	local function CreateWindowEntityList()
		local tbl = net.ReadTable()
		
		local frame = vgui.Create("DFrame")
		frame:SetSize(300, 300)
		frame:SetTitle("Mark props for removal ...")
		frame:Center()
		frame:MakePopup()
		
		local entlist = vgui.Create("DScrollPanel", frame)
		entlist:SetPos(10, 30)
		entlist:SetSize(280, 230)
		entlist:SetPaintBackground(true)
		entlist:SetBackgroundColor( Color(200, 200, 200) )
		
		local entchecklist = vgui.Create( "DIconLayout", entlist )
		entchecklist:SetSize( 265, 250 )
		entchecklist:SetPos( 5, 5 )
		entchecklist:SetSpaceY( 5 )
		entchecklist:SetSpaceX( 5 )
		
		for k,v in pairs(tbl) do
			if IsValid(k) and string.sub(k:GetClass(), 1, 5) != "class" then
				local entity = entchecklist:Add( "DPanel" )
				entity:SetSize( 130, 20 )
				
				local check = entity:Add("DCheckBox")
				check:SetPos(2,2)
				check:SetValue(v)
				check.OnChange = function(self, val)
					tbl[k] = val
				end
				check:SetTooltip(tostring(k))
				
				local name = entity:Add("DLabel")
				name:SetTextColor(Color(50,50,50))
				name:SetSize(105, 20)
				name:SetPos(20,1)
				name:SetText(k:GetClass())
				name:SetTooltip(tostring(k))
			end
		end
		
		local submit = vgui.Create("DButton", frame)
		submit:SetSize(200, 25)
		submit:SetText("Submit")
		submit:SetPos(50, 265)
		submit.DoClick = function(self)
			net.Start("nzPropRemoverSearch")
				net.WriteTable(tbl)
			net.SendToServer()
		end
	end
	net.Receive("nzPropRemoverSearch", CreateWindowEntityList)

end


nzTools:CreateTool("propremover", {
	displayname = "Prop Remover Tool",
	desc = "LMB: Mark Prop for Removal, RMB: Unmark Prop, R: Search Entities in 100 unit radius",
	condition = function(wep, ply)
		return true
	end,
	PrimaryAttack = function(wep, ply, tr, data)
		local ent = tr.Entity
		local id = ent:MapCreationID()
		if IsValid(ent) and ent != Entity(0) and id != -1 then
			ply:ChatPrint("Marked "..ent:GetClass().." ["..ent:EntIndex().."] for removal (ID: "..id..").")
			ent:SetColor(Color(200,0,0))
			nzMapping.MarkedProps[id] = true
		end
	end,
	SecondaryAttack = function(wep, ply, tr, data)
		local ent = tr.Entity
		local id = ent:MapCreationID()
		if IsValid(ent) and ent != Entity(0) and id != -1 then
			ply:ChatPrint("Unmarked "..ent:GetClass().." ["..ent:EntIndex().."] for removal (ID: "..id..").")
			ent:SetColor(Color(255,255,255))
			nzMapping.MarkedProps[id] = nil
		end
	end,
	Reload = function(wep, ply, tr, data)
		local tbl = ents.FindInSphere(tr.HitPos, 100)
		local send = {}
		for k,v in pairs(tbl) do
			local id = v:MapCreationID()
			if IsValid(v) and v != Entity(0) and id != -1 and string.sub(v:GetClass(), 1, 5) != "class" then
				send[v] = nzMapping.MarkedProps[id] or false
			end
		end
		net.Start("nzPropRemoverSearch")
			net.WriteTable(send)
		net.Send(ply)
	end,
	OnEquip = function(wep, ply, data)
	end,
	OnHolster = function(wep, ply, data)
	end
}, {
	displayname = "Prop Remover Tool",
	desc = "LMB: Mark Prop for Removal, RMB: Unmark Prop, R: Search Entities in 100 unit radius",
	icon = "icon16/cancel.png",
	weight = 35,
	condition = function(wep, ply)
		return true
	end,
	interface = function(frame, data)
		local panel = vgui.Create("DPanel", frame)
		panel:SetSize(frame:GetSize())

		local textw = vgui.Create("DLabel", panel)
		textw:SetText("This tool marks props to be removed in-game.")
		textw:SetFont("Trebuchet18")
		textw:SetTextColor( Color(50, 50, 50) )
		textw:SizeToContents()
		textw:SetPos(0, 80)
		textw:CenterHorizontal()

		local textw2 = vgui.Create("DLabel", panel)
		textw2:SetText("It will only apply once a game begins")
		textw2:SetFont("Trebuchet18")
		textw2:SetTextColor( Color(50, 50, 50) )
		textw2:SizeToContents()
		textw2:SetPos(0, 100)
		textw2:CenterHorizontal()

		local textw3 = vgui.Create("DLabel", panel)
		textw3:SetText("and will reset when entering Creative Mode.")
		textw3:SetFont("Trebuchet18")
		textw3:SetTextColor( Color(50, 50, 50) )
		textw3:SizeToContents()
		textw3:SetPos(0, 110)
		textw3:CenterHorizontal()

		return panel
	end,
	-- defaultdata = {}
})

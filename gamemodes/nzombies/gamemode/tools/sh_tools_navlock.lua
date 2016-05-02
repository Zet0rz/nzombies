nz.Tools.Functions.CreateTool("navlock", {
	displayname = "Nav Locker Tool",
	desc = "LMB: Connect doors and navmeshes, RMB: Lock/Unlock navmeshes",
	condition = function(wep, ply)
		//Serverside doesn't need to block
		return true
	end,
	PrimaryAttack = function(wep, ply, tr, data)
		local pos = tr.HitPos
		if tr.HitWorld or wep.Owner:KeyDown(IN_SPEED) then
			if !IsValid(wep.Ent1) then wep.Owner:ChatPrint("You need to mark a door first to link an area.") return end
			local navarea = navmesh.GetNearestNavArea(pos)
			local id = navarea:GetID()

			nz.Nav.Data[id] = {
				prev = navarea:GetAttributes(),
				locked = true,
				link = wep.Ent1:GetDoorData().link
			}
			//Purely to visualize, resets when game begins or shuts down
			navarea:SetAttributes(NAV_MESH_STOP)

			wep.Owner:ChatPrint("Navmesh ["..id.."] locked to door "..wep.Ent1:GetClass().."["..wep.Ent1:EntIndex().."] with link ["..wep.Ent1:GetDoorData().link.."]!")
			wep.Ent1:SetMaterial( "" )
			nz.Nav.Functions.CreateAutoMergeLink(wep.Ent1, id)
			wep.Ent1 = nil
		return end

		local ent = tr.Entity
		if !IsNavApplicable(ent) then
			wep.Owner:ChatPrint("Only buyable props, doors, and buyable buttons with LINKS can be linked to navareas.")
		return end

		if IsValid(wep.Ent1) and wep.Ent1 != ent then
			wep.Ent1:SetMaterial( "" )
		end

		wep.Ent1 = ent
		ent:SetMaterial( "hunter/myplastic.vtf" )
	end,
	SecondaryAttack = function(wep, ply, tr, data)
		if(!tr.HitPos)then return false end
		local pos = tr.HitPos
		local navarea = navmesh.GetNearestNavArea(pos)
		local navid = navarea:GetID()

		if nz.Nav.Data[navid] then
			navarea:SetAttributes(nz.Nav.Data[navid].prev)
			wep.Owner:ChatPrint("Navmesh ["..navid.."] unlocked!")
			nz.Nav.Data[navid] = nil
		return end

		nz.Nav.Data[navid] = {
			prev = navarea:GetAttributes(),
			locked = true,
			link = nil
		}

		navarea:SetAttributes(NAV_MESH_AVOID)
		wep.Owner:ChatPrint("Navmesh ["..navid.."] locked!")
	end,
	Reload = function(wep, ply, tr, data)
		//Nothing
	end,
	OnEquip = function(wep, ply, data)
		if wep.Owner:IsListenServerHost() then
			RunConsoleCommand("nav_edit", 1)
			RunConsoleCommand("nav_quicksave", 0)
		end
	end,
	OnHolster = function(wep, ply, data)
		if SERVER and wep.Owner:IsListenServerHost() then
			RunConsoleCommand("nav_edit", 0)
		end
		return true
	end
}, {
	displayname = "Nav Locker Tool",
	desc = "LMB: Connect doors and navmeshes, RMB: Lock/Unlock navmeshes",
	icon = "icon16/arrow_switch.png",
	weight = 40,
	condition = function(wep, ply)
		//Client needs advanced editing on to see the tool
		return nz.Tools.Advanced
	end,
	interface = function(frame, data)
		local panel = vgui.Create("DPanel", frame)
		panel:SetSize(frame:GetSize())

		local textw = vgui.Create("DLabel", panel)
		textw:SetText("You need to be in a listen/local server to be")
		textw:SetFont("Trebuchet18")
		textw:SetTextColor( Color(150, 50, 50) )
		textw:SizeToContents()
		textw:SetPos(0, 20)
		textw:CenterHorizontal()

		local textw2 = vgui.Create("DLabel", panel)
		textw2:SetText("able to see the Navmeshes!")
		textw2:SetFont("Trebuchet18")
		textw2:SetTextColor( Color(150, 50, 50) )
		textw2:SizeToContents()
		textw2:SetPos(0, 30)
		textw2:CenterHorizontal()

		local textw3 = vgui.Create("DLabel", panel)
		textw3:SetText("The tool can still be used blindly")
		textw3:SetFont("Trebuchet18")
		textw3:SetTextColor( Color(50, 50, 50) )
		textw3:SizeToContents()
		textw3:SetPos(0, 40)
		textw3:CenterHorizontal()

		local text = vgui.Create("DLabel", panel)
		text:SetText("Right click on the ground to lock a Navmesh")
		text:SetFont("Trebuchet18")
		text:SetTextColor( Color(50, 50, 50) )
		text:SizeToContents()
		text:SetPos(0, 80)
		text:CenterHorizontal()

		local text2 = vgui.Create("DLabel", panel)
		text2:SetText("Left click a door to mark the door")
		text2:SetFont("Trebuchet18")
		text2:SetTextColor( Color(50, 50, 50) )
		text2:SizeToContents()
		text2:SetPos(0, 120)
		text2:CenterHorizontal()

		local text3 = vgui.Create("DLabel", panel)
		text3:SetText("then left click the ground to link")
		text3:SetFont("Trebuchet18")
		text3:SetTextColor( Color(50, 50, 50) )
		text3:SizeToContents()
		text3:SetPos(0, 130)
		text3:CenterHorizontal()

		local text4 = vgui.Create("DLabel", panel)
		text4:SetText("the Navmesh with the door")
		text4:SetFont("Trebuchet18")
		text4:SetTextColor( Color(50, 50, 50) )
		text4:SizeToContents()
		text4:SetPos(0, 140)
		text4:CenterHorizontal()

		local text5 = vgui.Create("DLabel", panel)
		text5:SetText("Zombies can't pathfind through locked Navmeshes")
		text5:SetFont("Trebuchet18")
		text5:SetTextColor( Color(50, 50, 50) )
		text5:SizeToContents()
		text5:SetPos(0, 180)
		text5:CenterHorizontal()

		local text6 = vgui.Create("DLabel", panel)
		text6:SetText("unless their door link is opened")
		text6:SetFont("Trebuchet18")
		text6:SetTextColor( Color(50, 50, 50) )
		text6:SizeToContents()
		text6:SetPos(0, 190)
		text6:CenterHorizontal()

		return panel
	end,
	//defaultdata = {}
})
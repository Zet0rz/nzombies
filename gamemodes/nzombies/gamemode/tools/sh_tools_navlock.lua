nzTools:CreateTool("navlock", {
	displayname = "Nav Locker Tool",
	desc = "LMB: Connect doors and navmeshes, RMB: Lock/Unlock navmeshes",
	condition = function(wep, ply)
		-- Serverside doesn't need to block
		return true
	end,
	PrimaryAttack = function(wep, ply, tr, data)
		local pos = tr.HitPos
		if tr.HitWorld or wep.Owner:KeyDown(IN_SPEED) then
			if !IsValid(wep.Ent1) then wep.Owner:ChatPrint("You need to mark a door first to link an area.") return end
			local navarea = navmesh.GetNearestNavArea(pos)
			local id = navarea:GetID()

			nzNav.Locks[id] = {
				locked = true,
				link = wep.Ent1:GetDoorData().link
			}

			wep.Owner:ChatPrint("Navmesh ["..id.."] locked to door "..wep.Ent1:GetClass().."["..wep.Ent1:EntIndex().."] with link ["..wep.Ent1:GetDoorData().link.."]!")
			wep.Ent1:SetMaterial( "" )
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

		if nzNav.Locks[navid] then
			wep.Owner:ChatPrint("Navmesh ["..navid.."] unlocked!")
			nzNav.Locks[navid] = nil
		return end

		nzNav.Locks[navid] = {
			locked = true,
			link = nil
		}
		
		wep.Owner:ChatPrint("Navmesh ["..navid.."] locked!")
	end,
	Reload = function(wep, ply, tr, data)
		-- Nothing
	end,
	OnEquip = function(wep, ply, data)
		if wep.Owner:IsListenServerHost() then
			RunConsoleCommand("nav_edit", 1)
		end
	end,
	OnHolster = function(wep, ply, data)
		if SERVER and wep.Owner:IsListenServerHost() then
			RunConsoleCommand("nav_edit", 0)
		end
		return true
	end,
	Think = function()
		if GetConVar("nav_edit"):GetBool() and GetConVar("developer"):GetBool() then
			local pos = navmesh.GetEditCursorPosition()
			local area = navmesh.GetNearestNavArea(pos)
			local id = area:GetID()
			
			local tbl = nzNav.Locks[id]
			if tbl then
				if tbl.locked then
					if tbl.link then
						debugoverlay.Sphere(area:GetCenter(), 10, 0.1, Color(0,255,0,50))
					else
						debugoverlay.Sphere(area:GetCenter(), 10, 0.1, Color(255,0,0,50))
					end
				end
			end
		end
	end
}, {
	displayname = "Nav Locker Tool",
	desc = "LMB: Connect doors and navmeshes, RMB: Lock/Unlock navmeshes",
	icon = "icon16/arrow_switch.png",
	weight = 40,
	condition = function(wep, ply)
		-- Client needs advanced editing on to see the tool
		return nzTools.Advanced
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
		textw3:SetText("sv_cheats is needed in multiplayer.")
		textw3:SetFont("Trebuchet18")
		textw3:SetTextColor( Color(150, 50, 50) )
		textw3:SizeToContents()
		textw3:SetPos(0, 50)
		textw3:CenterHorizontal()

		local textw4 = vgui.Create("DLabel", panel)
		textw4:SetText("The tool can still be used blindly")
		textw4:SetFont("Trebuchet18")
		textw4:SetTextColor( Color(50, 50, 50) )
		textw4:SizeToContents()
		textw4:SetPos(0, 60)
		textw4:CenterHorizontal()
		
		local textw5 = vgui.Create("DLabel", panel)
		textw5:SetText("Console 'developer 1' is needed to see navlocks.")
		textw5:SetFont("Trebuchet18")
		textw5:SetTextColor( Color(150, 50, 50) )
		textw5:SizeToContents()
		textw5:SetPos(0, 80)
		textw5:CenterHorizontal()

		local text = vgui.Create("DLabel", panel)
		text:SetText("Right click on the ground to lock a Navmesh")
		text:SetFont("Trebuchet18")
		text:SetTextColor( Color(50, 50, 50) )
		text:SizeToContents()
		text:SetPos(0, 120)
		text:CenterHorizontal()

		local text2 = vgui.Create("DLabel", panel)
		text2:SetText("Left click a door to mark the door")
		text2:SetFont("Trebuchet18")
		text2:SetTextColor( Color(50, 50, 50) )
		text2:SizeToContents()
		text2:SetPos(0, 160)
		text2:CenterHorizontal()

		local text3 = vgui.Create("DLabel", panel)
		text3:SetText("then left click the ground to link")
		text3:SetFont("Trebuchet18")
		text3:SetTextColor( Color(50, 50, 50) )
		text3:SizeToContents()
		text3:SetPos(0, 170)
		text3:CenterHorizontal()

		local text4 = vgui.Create("DLabel", panel)
		text4:SetText("the Navmesh with the door")
		text4:SetFont("Trebuchet18")
		text4:SetTextColor( Color(50, 50, 50) )
		text4:SizeToContents()
		text4:SetPos(0, 180)
		text4:CenterHorizontal()

		local text5 = vgui.Create("DLabel", panel)
		text5:SetText("Zombies can't pathfind through locked Navmeshes")
		text5:SetFont("Trebuchet18")
		text5:SetTextColor( Color(50, 50, 50) )
		text5:SizeToContents()
		text5:SetPos(0, 210)
		text5:CenterHorizontal()

		local text6 = vgui.Create("DLabel", panel)
		text6:SetText("unless their door link is opened")
		text6:SetFont("Trebuchet18")
		text6:SetTextColor( Color(50, 50, 50) )
		text6:SizeToContents()
		text6:SetPos(0, 220)
		text6:CenterHorizontal()

		return panel
	end,
	//defaultdata = {}
})
nz.Tools.Functions.CreateTool("propremover", {
	displayname = "Prop Remover Tool",
	desc = "LMB: Mark Prop for Removal, RMB: Unmark Prop",
	condition = function(wep, ply)
		return true
	end,
	PrimaryAttack = function(wep, ply, tr, data)
		local ent = tr.Entity
		local id = ent:MapCreationID()
		if IsValid(ent) and ent != Entity(0) and id != -1 then
			ply:ChatPrint("Marked "..ent:GetClass().." ["..ent:EntIndex().."] for removal.")
			ent:SetColor(Color(200,0,0))
			Mapping.MarkedProps[id] = true
		end
	end,
	SecondaryAttack = function(wep, ply, tr, data)
		local ent = tr.Entity
		local id = ent:MapCreationID()
		if IsValid(ent) and ent != Entity(0) and id != -1 then
			ply:ChatPrint("Unarked "..ent:GetClass().." ["..ent:EntIndex().."] for removal.")
			ent:SetColor(Color(255,255,255))
			Mapping.MarkedProps[id] = nil
		end
	end,
	Reload = function(wep, ply, tr, data)
		//Nothing
	end,
	OnEquip = function(wep, ply, data)
	end,
	OnHolster = function(wep, ply, data)
	end
}, {
	displayname = "Prop Remover Tool",
	desc = "LMB: Mark Prop for Removal, RMB: Unmark Prop",
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
	//defaultdata = {}
})

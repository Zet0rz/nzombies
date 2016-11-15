local mat = Material("color")
local white = Color(255,0,0,50)
local point1, point2, height

-- Networking is in the invis wall tool, the bool makes it a normal invis wall

nzTools:CreateTool("damagewall", {
	displayname = "Damage Wall Creator",
	desc = "LMB: Set Corners, RMB: Remove Damage Wall at spot, R: Reset corners",
	condition = function(wep, ply)
		return true
	end,
	PrimaryAttack = function(wep, ply, tr, data)
		
	end,
	SecondaryAttack = function(wep, ply, tr, data)
		local walls = ents.FindInSphere(tr.HitPos, 5)
		for k,v in pairs(walls) do
			if v:GetClass() == "invis_damage_wall" then v:Remove() end
		end
	end,
	Reload = function(wep, ply, tr, data)

	end,
	OnEquip = function(wep, ply, data)

	end,
	OnHolster = function(wep, ply, data)

	end
}, {
	displayname = "Damage Wall Creator",
	desc = "LMB: Set Corners, RMB: Remove Damage Wall at spot, R: Reset corners",
	icon = "icon16/shape_square_error.png",
	weight = 17,
	condition = function(wep, ply)
		return nzTools.Advanced
	end,
	interface = function(frame, data)
	end,
	PrimaryAttack = function(wep, ply, tr, data)
		local pos = tr.HitPos
		if !pos then return end
		
		if !point1 then
			point1 = pos
		elseif !point2 then
			point2 = Vector(pos.x - point1.x, pos.y - point1.y, point1.z)
		elseif !height then
			height = pos.z - point1.z
			net.Start("nz_InvisWallCreation")
				net.WriteVector(point1)
				net.WriteVector(Vector(point2.x, point2.y, height))
				net.WriteBool(false)
			net.SendToServer()
			point1 = nil
			point2 = nil
			height = nil
		end
	end,
	Reload = function()
		point1 = nil
		point2 = nil
		height = nil
	end,
	interface = function(frame, data)
		local pnl = vgui.Create("DPanel", frame)
		pnl:Dock(FILL)
		
		
		
		local data = data or {}
		
		local valz = {}
		if data then
			valz["Dmg"] = data.dmg or 10
			valz["Delay"] = data.delay or 0.5
			valz["DmgType"] = data.dmgtype or 1
		end
		
		function pnl.CompileData()
			data.dmg = valz["Dmg"]
			data.delay = valz["Delay"]
			data.dmgtype = valz["DmgType"]
			
			return data
		end
		
		function pnl.UpdateData(data)
			nzTools:SendData(data, "damagewall", data) -- Save the same data here
		end
		
		local chk = vgui.Create("DCheckBoxLabel", pnl)
		chk:SetPos( 100, 20 )
		chk:SetText( "Preview Config" )
		chk:SetTextColor( Color(50,50,50) )
		chk:SetConVar( "nz_creative_preview" )
		chk:SetValue( GetConVar("nz_creative_preview"):GetBool() )
		chk:SizeToContents()
		
		local properties = vgui.Create("DProperties", pnl)
		properties:SetPos(5, 50)
		properties:SetSize(290, 100)
		
		local dmg = properties:CreateRow( "Damage Properties", "Damage" )
		dmg:Setup( "Int", {min = 1, max = 250} )
		dmg:SetValue( data.dmg )
		dmg.DataChanged = function( _, val ) valz["Dmg"] = val pnl.UpdateData(pnl.CompileData()) end
		
		local delay = properties:CreateRow( "Damage Properties", "Delay" )
		delay:Setup( "Float", {min = 0, max = 10} )
		delay:SetValue( data.delay )
		delay.DataChanged = function( _, val ) valz["Delay"] = val pnl.UpdateData(pnl.CompileData()) end
		
		local dmgtype = properties:CreateRow( "Damage Properties", "Type" )
		dmgtype:Setup( "Combo", {text = "Select type ..."} )
		dmgtype:AddChoice( "Radiation", 1 )
		dmgtype:AddChoice( "Poison", 2 )
		dmgtype:AddChoice( "Tesla", 3 )
		dmgtype.DataChanged = function( _, val ) valz["DmgType"] = val pnl.UpdateData(pnl.CompileData()) end
		
		return pnl
	end,
	drawhud = function()
		cam.Start3D()
			render.SetMaterial(mat)
			local x = point1 or nil
			local y
			if x then
				if point2 then
					if height then
						y = Vector(point2.x, point2.y, height)
					else
						y = Vector(point2.x, point2.y, LocalPlayer():GetEyeTrace().HitPos.z - point1.z)
					end
				else
					y = Vector(LocalPlayer():GetEyeTrace().HitPos.x - point1.x, LocalPlayer():GetEyeTrace().HitPos.y - point1.y, 0)
				end
			end
			if x and y then
				render.DrawBox(x, Angle(0,0,0), Vector(0,0,0), y, white, true)
			end
		cam.End3D()
	end,
	defaultdata = {
		dmg = 10,
		delay = 0.5,
		dmgtype = 1,
	}
})
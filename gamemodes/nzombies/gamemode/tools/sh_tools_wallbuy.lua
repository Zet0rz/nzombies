nzTools:CreateTool("wallbuy", {
	displayname = "Weapon Buy Placer",
	desc = "LMB: Place Weapon Buy, RMB: Remove Weapon Buy, R: Rotate, C: Change Properties",
	condition = function(wep, ply)
		return true
	end,

	PrimaryAttack = function(wep, ply, tr, data)
		local ent = tr.Entity
		if IsValid(ent) and ent:GetClass() == "wall_buys" then
			nzMapping:WallBuy(ent:GetPos(), data.class, tonumber(data.price), ent:GetAngles(), nil, ply)
			ent:Remove()
		else
			local ang = tr.HitNormal:Angle()
			ang:RotateAroundAxis(tr.HitNormal:Angle():Up()*-1, 90)
			nzMapping:WallBuy(tr.HitPos + tr.HitNormal*0.5, data.class, tonumber(data.price), ang, nil, ply)
		end
	end,

	SecondaryAttack = function(wep, ply, tr, data)
		if IsValid(tr.Entity) and tr.Entity:GetClass() == "wall_buys" then
			tr.Entity:Remove()
		end
	end,
	Reload = function(wep, ply, tr, data)
		if IsValid(tr.Entity) and tr.Entity:GetClass() == "wall_buys" then
			tr.Entity:ToggleRotate()
		end
	end,
	OnEquip = function(wep, ply, data)

	end,
	OnHolster = function(wep, ply, data)

	end
}, {
	displayname = "Weapon Buy Placer",
	desc = "LMB: Place Weapon Buy, RMB: Remove Weapon Buy, R: Rotate, C: Change Properties",
	icon = "icon16/cart.png",
	weight = 5,
	condition = function(wep, ply)
		return true
	end,
	interface = function(frame, data)
		local valz = {}
		valz["Row1"] = data.class
		valz["Row2"] = data.price

		local DProperties = vgui.Create( "DProperties", frame )
		DProperties:SetSize( 280, 180 )
		DProperties:SetPos( 10, 10 )
		
		function DProperties.CompileData()
			if weapons.Get( valz["Row1"] ) then
				data.class = valz["Row1"]
				data.price = tostring(valz["Row2"])
			else
				ErrorNoHalt("NZ: This weapon class is not valid!")
			end
			return data
		end
		
		function DProperties.UpdateData(data)
			nzTools:SendData(data, "wallbuy")
		end

		local Row1 = DProperties:CreateRow( "Weapon Settings", "Weapon Class" )
		Row1:Setup( "Combo" )
		for k,v in pairs(weapons.GetList()) do
			if !v.NZTotalBlacklist then
				if v.Category and v.Category != "" then
					Row1:AddChoice(v.PrintName and v.PrintName != "" and v.Category.. " - "..v.PrintName or v.ClassName, v.ClassName, false)
				else
					Row1:AddChoice(v.PrintName and v.PrintName != "" and v.PrintName or v.ClassName, v.ClassName, false)
				end
			end
		end
		Row1.DataChanged = function( _, val ) valz["Row1"] = val DProperties.UpdateData(DProperties.CompileData()) end

		local Row2 = DProperties:CreateRow( "Weapon Settings", "Price" )
		Row2:Setup( "Integer" )
		Row2:SetValue( valz["Row2"] )
		Row2.DataChanged = function( _, val ) valz["Row2"] = val DProperties.UpdateData(DProperties.CompileData()) end

		return DProperties
	end,
	defaultdata = {
		class = "weapon_class",
		price = 500,
	}
})

nzTools:EnableProperties("wallbuy", "Edit Wallbuy...", "icon16/cart_edit.png", 9004, true, function( self, ent, ply )
	if ( !IsValid( ent ) or !IsValid(ply) ) then return false end
	if ( ent:GetClass() != "wall_buys" ) then return false end
	if !nzRound:InState( ROUND_CREATE ) then return false end
	if ( ent:IsPlayer() ) then return false end
	if ( !ply:IsInCreative() ) then return false end

	return true

end, function(ent)
	return {class = ent:GetWepClass(), price = ent:GetPrice()}
end)
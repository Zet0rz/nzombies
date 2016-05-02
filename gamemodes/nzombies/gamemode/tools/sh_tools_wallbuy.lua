nz.Tools.Functions.CreateTool("wallbuy", {
	displayname = "Weapon Buy Placer",
	desc = "LMB: Place Weapon Buy, RMB: Remove Weapon Buy, R: Rotate, C: Change Properties",
	condition = function(wep, ply)
		return true
	end,

	PrimaryAttack = function(wep, ply, tr, data)
		local ang = tr.HitNormal:Angle()
		ang:RotateAroundAxis(tr.HitNormal:Angle():Up()*-1, 90)
		nzMapping:WallBuy(tr.HitPos + tr.HitNormal*0.5, data.class, tonumber(data.price), ang, nil, ply)
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

		local function UpdateData()
		//Check the weapon class is fine first
			if weapons.Get( valz["Row1"] ) then
				data.class = valz["Row1"]
				data.price = tostring(valz["Row2"])
				nz.Tools.Functions.SendData( data, "wallbuy" )
			else
				ErrorNoHalt("NZ: This weapon class is not valid!")
			end
		end

		local DProperties = vgui.Create( "DProperties", frame )
		DProperties:SetSize( 280, 180 )
		DProperties:SetPos( 10, 10 )

		local Row1 = DProperties:CreateRow( "Weapon Settings", "Weapon Class" )
		Row1:Setup( "Combo" )
		for k,v in pairs(weapons.GetList()) do
			if v.Category and v.Category != "" then
				Row1:AddChoice(v.PrintName and v.PrintName != "" and v.Category.. " - "..v.PrintName or v.ClassName, v.ClassName, false)
			else
				Row1:AddChoice(v.PrintName and v.PrintName != "" and v.PrintName or v.ClassName, v.ClassName, false)
			end
		end
		Row1.DataChanged = function( _, val ) valz["Row1"] = val UpdateData() end

		local Row2 = DProperties:CreateRow( "Weapon Settings", "Price" )
		Row2:Setup( "Integer" )
		Row2:SetValue( valz["Row2"] )
		Row2.DataChanged = function( _, val ) valz["Row2"] = val UpdateData() end

		return DProperties
	end,
	defaultdata = {
		class = "weapon_class",
		price = 500,
	}
})
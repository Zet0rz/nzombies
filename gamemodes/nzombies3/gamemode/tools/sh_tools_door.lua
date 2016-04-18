nz.Tools.Functions.CreateTool("door", {
	displayname = "Door Locker",
	desc = "LMB: Apply Door Data, RMB: Remove Door Data, C: Change Properties",
	condition = function(wep, ply)
		return true
	end,
	PrimaryAttack = function(wep, ply, tr, data)
		PrintTable(data)
		local ent = tr.Entity
		if !IsValid(ent) then return end
		if ent:IsDoor() or ent:IsBuyableProp() or ent:IsButton() then
			nzDoors:CreateLink(ent, data.flags)
		else
			ply:ChatPrint("That is not a valid door.")
		end
	end,
	SecondaryAttack = function(wep, ply, tr, data)
		local ent = tr.Entity
		if !IsValid(ent) then return end
		if ent:IsDoor() or ent:IsBuyableProp() or ent:IsButton() then
			nz.Nav.Functions.UnlinkAutoMergeLink(ent)
			nzDoors:RemoveLink(ent)
		end
	end,
	Reload = function(wep, ply, tr, data)
		local ent = tr.Entity
		if !IsValid(ent) then return end
		if ent:IsDoor() or ent:IsBuyableProp() or ent:IsButton() then
			nzDoors:DisplayDoorLinks(ent)
		end
	end,
	OnEquip = function(wep, ply, data)

	end,
	OnHolster = function(wep, ply, data)

	end
}, {
	displayname = "Door Locker",
	desc = "LMB: Apply Door Data, RMB: Remove Door Data, C: Change Properties",
	icon = "icon16/lock.png",
	weight = 3,
	condition = function(wep, ply)
		return true
	end,
	interface = function(frame, data)
		local valz = {}
		valz["Row1"] = data.flag
		valz["Row2"] = data.link
		valz["Row3"] = data.price
		valz["Row4"] = data.elec
		valz["Row5"] = data.buyable
		valz["Row6"] = data.rebuyable

		valz["Row7"] = data.navgroup1
		valz["Row8"] = data.navgroup2

		local function UpdateData()
			local function compileString(price, elec, flag, buyable, rebuyable, navgroup1, navgroup2)
				local str = "price="..price..",elec="..elec
				if flag then
					str = str..",link="..flag
				end
				str = str..",buyable="..buyable
				str = str..",rebuyable="..rebuyable
				if navgroup1 and navgroup1 != "" then
					str = str..",navgroup1="..navgroup1
				end
				if navgroup2 and navgroup2 != "" then
					str = str..",navgroup2="..navgroup2
				end
				return str
			end
			local flag = false
			if valz["Row1"] == 1 then
				flag = valz["Row2"]
			end
			local flagString = compileString(valz["Row3"], valz["Row4"], flag, valz["Row5"], valz["Row6"], valz["Row7"], valz["Row8"])
			print(flagString)

			nz.Tools.Functions.SendData( {flags = flagString}, "door", {
				flag = valz["Row1"],
				link = valz["Row2"],
				price = valz["Row3"],
				elec = valz["Row4"],
				buyable = valz["Row5"],
				rebuyable = valz["Row6"],
				navgroup1 = valz["Row7"],
				navgroup2 = valz["Row8"],
			})
		end

		-- We call it immediately as it would otherwise auto-send our table to the server, not the compiled string
		UpdateData()

		local DProperties = vgui.Create( "DProperties", frame )
		DProperties:SetSize( 280, 260 )
		DProperties:SetPos( 10, 10 )

		local Row1 = DProperties:CreateRow( "Door Settings", "Enable Flag?" )
		Row1:Setup( "Boolean" )
		Row1:SetValue( valz["Row1"] )
		Row1.DataChanged = function( _, val ) valz["Row1"] = val UpdateData() end
		local Row2 = DProperties:CreateRow( "Door Settings", "Flag" )
		Row2:Setup( "Integer" )
		Row2:SetValue( valz["Row2"] )
		Row2.DataChanged = function( _, val ) valz["Row2"] = val UpdateData() end
		local Row3 = DProperties:CreateRow( "Door Settings", "Price" )
		Row3:Setup( "Integer" )
		Row3:SetValue( valz["Row3"] )
		Row3.DataChanged = function( _, val ) valz["Row3"] = val UpdateData() end
		local Row4 = DProperties:CreateRow( "Door Settings", "Requires Electricity?" )
		Row4:Setup( "Boolean" )
		Row4:SetValue( valz["Row4"] )
		Row4.DataChanged = function( _, val ) valz["Row4"] = val UpdateData() end

		if nz.Tools.Advanced then
			local Row5 = DProperties:CreateRow( "Advanced Door Settings", "Purchaseable?" )
			Row5:Setup( "Boolean" )
			Row5:SetValue( valz["Row5"] )
			Row5.DataChanged = function( _, val ) valz["Row5"] = val UpdateData() end
			local Row6 = DProperties:CreateRow( "Advanced Door Settings", "Rebuyable?" )
			Row6:Setup( "Boolean" )
			Row6:SetValue( valz["Row6"] )
			Row6.DataChanged = function( _, val ) valz["Row6"] = val UpdateData() end

			local Row7 = DProperties:CreateRow( "Nav Group Merging", "Group 1 ID" )
			Row7:Setup( "Generic" )
			Row7:SetValue( valz["Row7"] )
			Row7.DataChanged = function( _, val ) valz["Row7"] = val UpdateData() end
			local Row8 = DProperties:CreateRow( "Nav Group Merging", "Group 2 ID" )
			Row8:Setup( "Generic" )
			Row8:SetValue( valz["Row8"] )
			Row8.DataChanged = function( _, val ) valz["Row8"] = val UpdateData() end
		else
			local text = vgui.Create("DLabel", DProperties)
			text:SetText("Enable Advanced Mode for more options.")
			text:SetFont("Trebuchet18")
			text:SetTextColor( Color(50, 50, 50) )
			text:SizeToContents()
			text:Center()
		end

		return DProperties
	end,
	defaultdata = {
		flags = "flag=0,price=1000,elec=0,buyable=1,rebuyable=0",
		flag = 0,
		link = 1,
		price = 1000,
		elec = 0,
		buyable = 1,
		rebuyable = 0,

		navgroup1 = "",
		navgroup2 = "",
	}
})
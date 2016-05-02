//

if SERVER then
	function nz.Interfaces.Functions.DoorPropsHandler( ply, data )
		if ply:IsSuperAdmin() then
			PrintTable(data)
			nzDoors:CreateLink( data.ent, data.flags )
		end
	end
end

if CLIENT then
	function nz.Interfaces.Functions.DoorProps( data )
		local ent = data.door
		local name = "Add New Door"
		local valz = {}
		valz["Row1"] = 0
		valz["Row2"] = 1
		valz["Row3"] = 1000
		valz["Row4"] = 0
		valz["Row5"] = 1
		valz["Row6"] = 0
		
		valz["Row7"] = ""
		valz["Row8"] = ""

		local door_data = nil

		//Check if the ent has flags already
		if ent:IsDoor() or ent:IsButton() then
			door_data = nzDoors.MapDoors[ent:DoorIndex()].flags
		elseif ent:IsBuyableProp() then
			door_data = nzDoors.PropDoors[ent:EntIndex()].flags
		end
		//If we do then;
		if door_data != nil then
			if door_data.link != nil then
				valz["Row1"] = 1
				valz["Row2"] = door_data.link
			end
			valz["Row3"] = door_data.price
			valz["Row4"] = door_data.elec
			valz["Row5"] = door_data.buyable
			valz["Row6"] = door_data.rebuyable
			
			if door_data.navgroup1 != nil then
				valz["Row7"] = door_data.navgroup1
			end
			if door_data.navgroup2 != nil then
				valz["Row8"] = door_data.navgroup2
			end
			name = "Modifying Door Flag"
		end
		local DermaPanel = vgui.Create( "DFrame" )
		DermaPanel:SetPos( 100, 100 )
		DermaPanel:SetSize( 300, 280 )
		DermaPanel:SetTitle( name )
		DermaPanel:SetVisible( true )
		DermaPanel:SetDraggable( true )
		DermaPanel:ShowCloseButton( true )
		DermaPanel:MakePopup()
		DermaPanel:Center()

		local DProperties = vgui.Create( "DProperties", DermaPanel )
		DProperties:SetSize( 280, 260 )
		DProperties:SetPos( 10, 30 )

		local Row1 = DProperties:CreateRow( "Door Settings", "Enable Flag?" )
		Row1:Setup( "Boolean" )
		Row1:SetValue( valz["Row1"] )
		Row1.DataChanged = function( _, val ) valz["Row1"] = val end
		local Row2 = DProperties:CreateRow( "Door Settings", "Flag" )
		Row2:Setup( "Integer" )
		Row2:SetValue( valz["Row2"] )
		Row2.DataChanged = function( _, val ) valz["Row2"] = val end
		local Row3 = DProperties:CreateRow( "Door Settings", "Price" )
		Row3:Setup( "Integer" )
		Row3:SetValue( valz["Row3"] )
		Row3.DataChanged = function( _, val ) valz["Row3"] = val end
		local Row4 = DProperties:CreateRow( "Door Settings", "Requires Electricity?" )
		Row4:Setup( "Boolean" )
		Row4:SetValue( valz["Row4"] )
		Row4.DataChanged = function( _, val ) valz["Row4"] = val end
		local Row5 = DProperties:CreateRow( "Door Settings", "Purchaseable?" )
		Row5:Setup( "Boolean" )
		Row5:SetValue( valz["Row5"] )
		Row5.DataChanged = function( _, val ) valz["Row5"] = val end
		local Row6 = DProperties:CreateRow( "Door Settings", "Rebuyable?" )
		Row6:Setup( "Boolean" )
		Row6:SetValue( valz["Row6"] )
		Row6.DataChanged = function( _, val ) valz["Row6"] = val end
		
		local Row7 = DProperties:CreateRow( "Nav Group Merging", "Group 1 ID" )
		Row7:Setup( "Generic" )
		Row7:SetValue( valz["Row7"] )
		Row7.DataChanged = function( _, val ) valz["Row7"] = val end
		local Row8 = DProperties:CreateRow( "Nav Group Merging", "Group 2 ID" )
		Row8:Setup( "Generic" )
		Row8:SetValue( valz["Row8"] )
		Row8.DataChanged = function( _, val ) valz["Row8"] = val end

		local DermaButton = vgui.Create( "DButton" )
		DermaButton:SetParent( DermaPanel )
		DermaButton:SetText( "Submit" )
		DermaButton:SetPos( 10, 240 )
		DermaButton:SetSize( 280, 30 )
		DermaButton.DoClick = function()
			local function compileString(price, elec, flag, buyable, rebuyable, navgroup1, navgroup2)
				local str = "price="..price..",elec="..elec
				if flag != false then
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
			DermaPanel:SetTitle( "Modifying Door Flag" )
			local flagString = compileString(valz["Row3"], valz["Row4"], flag, valz["Row5"], valz["Row6"], valz["Row7"], valz["Row8"])
			print(flagString)

			//Send the data
			nz.Interfaces.Functions.SendRequests( "DoorProps", {flags = flagString, ent = ent} )

		end
	end

end

//

if SERVER then
	function nz.Interfaces.Functions.PlayerHandlerHandler( ply, data )
		if ply:IsSuperAdmin() then
			nz.Mapping.Functions.PlayerHandler(data.vec, data.ang, data.startwep, data.startpoints, data.numweps, data.eeurl, data.keep, ply)
		end
	end
end

if CLIENT then
	function nz.Interfaces.Functions.PlayerHandler( data )

		local valz = {}
		valz["Row1"] = "weapon_class"
		valz["Row2"] = 500
		valz["Row3"] = 2
		valz["Row4"] = "URL"
		
		//If we already have on and we reload on it
		if data.keep and IsValid(ents.FindByClass("player_handler")[1]) then
			local phandler = ents.FindByClass("player_handler")[1]
			valz["Row1"] = phandler:GetStartWep()
			valz["Row2"] = phandler:GetStartPoints()
			valz["Row3"] = phandler:GetNumWeps()
			valz["Row4"] = phandler:GetEEURL()
		end

		local DermaPanel = vgui.Create( "DFrame" )
		DermaPanel:SetPos( 100, 100 )
		DermaPanel:SetSize( 300, 180 )
		DermaPanel:SetTitle( "Player Handler" )
		DermaPanel:SetVisible( true )
		DermaPanel:SetDraggable( true )
		DermaPanel:ShowCloseButton( true )
		DermaPanel:MakePopup()
		DermaPanel:Center()

		local DProperties = vgui.Create( "DProperties", DermaPanel )
		DProperties:SetSize( 280, 180 )
		DProperties:SetPos( 10, 30 )
		
		local Row1 = DProperties:CreateRow( "Weapon Settings", "Starting Weapon" )
		Row1:Setup( "Combo" )
		for k,v in pairs(weapons.GetList()) do
			Row1:AddChoice(v.PrintName and v.PrintName != "" and v.PrintName or v.ClassName, v.ClassName, false)
		end
		
		if data.keep and IsValid(ents.FindByClass("player_handler")[1]) then
			local wep = weapons.Get(ents.FindByClass("player_handler")[1]:GetStartWep())
			Row1:AddChoice(wep.PrintName and wep.PrintName != "" and wep.PrintName or wep.ClassName, wep.ClassName, true)
		end
		
		Row1.DataChanged = function( _, val ) valz["Row1"] = val end
		
		local Row2 = DProperties:CreateRow( "Weapon Settings", "Starting Points" )
		Row2:Setup( "Integer" )
		Row2:SetValue( valz["Row2"] )
		Row2.DataChanged = function( _, val ) valz["Row2"] = val end
		
		local Row3 = DProperties:CreateRow( "Weapon Settings", "Max Weapons" )
		Row3:Setup( "Integer" )
		Row3:SetValue( valz["Row3"] )
		Row3.DataChanged = function( _, val ) valz["Row3"] = val end
		
		local Row4 = DProperties:CreateRow( "Weapon Settings", "Easter Egg Song URL" )
		Row4:Setup( "Generic" )
		Row4:SetValue( valz["Row4"] )
		Row4.DataChanged = function( _, val ) valz["Row4"] = val end

		local DermaButton = vgui.Create( "DButton" )
		DermaButton:SetParent( DermaPanel )
		DermaButton:SetText( "Submit" )
		DermaButton:SetPos( 10, 140 )
		DermaButton:SetSize( 280, 30 )
		DermaButton.DoClick = function()

			//Check the weapon class is fine first
			if weapons.Get( valz["Row1"] ) != nil then
				data.startwep = valz["Row1"]
				data.startpoints = valz["Row2"]
				data.numweps = valz["Row3"]
				data.eeurl = valz["Row4"]
				PrintTable(data)
				nz.Interfaces.Functions.SendRequests( "PlayerHandler", data )

				DermaPanel:Close()
			end

		end
	end
end

//

if SERVER then
	function nz.Interfaces.Functions.PerkMachineHandler( ply, data )
		if ply:IsSuperAdmin() then
			data.ent:SetPerkID(data.id)
			data.ent:TurnOff() //Quickly update the model
		end
	end
end

if CLIENT then
	function nz.Interfaces.Functions.PerkMachine( data )
		local DermaPanel = vgui.Create( "DFrame" )
		DermaPanel:SetPos( 100, 100 )
		DermaPanel:SetSize( 300, 180 )
		DermaPanel:SetTitle( "Modifying Perk Machines" )
		DermaPanel:SetVisible( true )
		DermaPanel:SetDraggable( true )
		DermaPanel:ShowCloseButton( true )
		DermaPanel:MakePopup()
		DermaPanel:Center()

		local choices = vgui.Create( "DComboBox", DermaPanel )
		choices:SetPos( 10, 30 )
		choices:SetSize( 280, 30 )
		choices:SetValue( nz.Perks.Functions.Get(data.ent:GetPerkID()).name )
		for k,v in pairs(nz.Perks.Functions.GetList()) do
			choices:AddChoice( v, k )
		end
		choices.OnSelect = function( panel, index, value, id )
			data.id = id
			nz.Interfaces.Functions.SendRequests( "PerkMachine", data )
		end
	end
end

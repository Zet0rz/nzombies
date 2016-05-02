nz.Tools.Functions.CreateTool("perk", {
	displayname = "Perk Machine Placer",
	desc = "LMB: Place Perk Machine, RMB: Remove Perk Machine, C: Change Perk",
	condition = function(wep, ply)
		return true
	end,

	PrimaryAttack = function(wep, ply, tr, data)
		nzMapping:PerkMachine(tr.HitPos, Angle(0,(ply:GetPos() - tr.HitPos):Angle()[2],0), data.perk, ply)
	end,

	SecondaryAttack = function(wep, ply, tr, data)
		if IsValid(tr.Entity) and tr.Entity:GetClass() == "perk_machine" then
			tr.Entity:Remove()
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
	displayname = "Perk Machine Placer",
	desc = "LMB: Place Perk Machine, RMB: Remove Perk Machine, C: Change Perk",
	icon = "icon16/drink.png",
	weight = 6,
	condition = function(wep, ply)
		return true
	end,
	interface = function(frame, data)

		local choices = vgui.Create( "DComboBox", frame )
		choices:SetPos( 10, 10 )
		choices:SetSize( 280, 30 )
		choices:SetValue( nz.Perks.Functions.Get(data.perk).name )
		for k,v in pairs(nz.Perks.Functions.GetList()) do
			choices:AddChoice( v, k )
		end
		choices.OnSelect = function( panel, index, value, id )
			data.perk = id
			nz.Tools.Functions.SendData( data, "perk" )
		end

		return choices
	end,
	defaultdata = {perk = "jugg"},
})
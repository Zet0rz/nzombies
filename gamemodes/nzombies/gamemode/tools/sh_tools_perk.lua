nzTools:CreateTool("perk", {
	displayname = "Perk Machine Placer",
	desc = "LMB: Place Perk Machine, RMB: Remove Perk Machine, C: Change Perk",
	condition = function(wep, ply)
		return true
	end,

	PrimaryAttack = function(wep, ply, tr, data)
		local ent = tr.Entity
		if IsValid(ent) and ent:GetClass() == "perk_machine" or ent:GetClass() == "wunderfizz_machine" then
			nzMapping:PerkMachine(ent:GetPos(), ent:GetAngles(), data.perk, ply) -- Hitting a perk, replace it
			ent:Remove()
		else
			nzMapping:PerkMachine(tr.HitPos, Angle(0,(ply:GetPos() - tr.HitPos):Angle()[2],0), data.perk, ply)
		end
	end,

	SecondaryAttack = function(wep, ply, tr, data)
		local ent = tr.Entity
		if IsValid(ent) and ent:GetClass() == "perk_machine" or ent:GetClass() == "wunderfizz_machine" then
			tr.Entity:Remove()
		end
	end,
	Reload = function(wep, ply, tr, data)
		-- Nothing
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
	interface = function(frame, data, context)

		local choices = vgui.Create( "DComboBox", frame )
		choices:SetPos( 10, 10 )
		choices:SetSize( 280, 30 )
		choices:SetValue( nzPerks:Get(data.perk).name )
		for k,v in pairs(nzPerks:GetList()) do
			choices:AddChoice( v, k )
		end
		
		function choices.CompileData()
			return data
		end
		
		function choices.UpdateData(data)
			nzTools:SendData(data, "perk")
		end
		
		choices.OnSelect = function( panel, index, value, id )
			data.perk = id
			choices.UpdateData(choices.CompileData())
		end

		return choices
	end,
	defaultdata = {perk = "jugg"},
})

nzTools:EnableProperties("perk", "Edit Perk...", "icon16/tag_blue_edit.png", 9005, true, function( self, ent, ply )
	if ( !IsValid( ent ) or !IsValid(ply) ) then return false end
	if ( ent:GetClass() != "perk_machine" ) then return false end
	if !nzRound:InState( ROUND_CREATE ) then return false end
	if ( ent:IsPlayer() ) then return false end
	if ( !ply:IsInCreative() ) then return false end

	return true

end, function(ent)
	return {perk = ent:GetPerkID()}
end)
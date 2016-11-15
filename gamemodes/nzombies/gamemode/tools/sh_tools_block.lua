nzTools:CreateTool("block", {
	displayname = "Invisible Block Spawner",
	desc = "LMB: Create Invisible Block, RMB: Remove Invisible Block, R: Change Model",
	condition = function(wep, ply)
		return true
	end,
	PrimaryAttack = function(wep, ply, tr, data)
		local ent = tr.Entity
		if IsValid(ent) and ent:GetClass() == "wall_block" then
			nzMapping:BlockSpawn(ent:GetPos(),ent:GetAngles(), data.model, ply)
			ent:Remove()
		else
			nzMapping:BlockSpawn(tr.HitPos,Angle(90,(tr.HitPos - ply:GetPos()):Angle()[2] + 90,90), data.model, ply)
		end
	end,
	SecondaryAttack = function(wep, ply, tr, data)
		if IsValid(tr.Entity) and tr.Entity:GetClass() == "wall_block" then
			tr.Entity:Remove()
		end
	end,
	Reload = function(wep, ply, tr, data)
		if IsValid(tr.Entity) and tr.Entity:GetClass() == "wall_block" then
			tr.Entity:SetModel(data.model)
		end
	end,
	OnEquip = function(wep, ply, data)

	end,
	OnHolster = function(wep, ply, data)

	end
}, {
	displayname = "Invisible Block Spawner",
	desc = "LMB: Create Invisible Block, RMB: Remove Invisible Block, R: Change Model",
	icon = "icon16/shading.png",
	weight = 15,
	condition = function(wep, ply)
		return true
	end,
	interface = function(frame, data, context)
		local Scroll = vgui.Create( "DScrollPanel", frame )
		Scroll:SetSize( 280, 300 )
		Scroll:SetPos( 10, 10 )
		
		function Scroll.CompileData()
			return {model = data.model}
		end
		
		function Scroll.UpdateData(data)
			nzTools:SendData(data, "block", data) -- Save the same data here
		end

		local List	= vgui.Create( "DIconLayout", Scroll )
		List:SetSize( 340, 200 )
		List:SetPos( 0, 0 )
		List:SetSpaceY( 5 )
		List:SetSpaceX( 5 )

		local models = util.KeyValuesToTable((file.Read("settings/spawnlist/default/023-general.txt", "MOD")))

		for k,v in pairs(models["contents"]) do
			if v.model then
				local Blockmodel = List:Add( "SpawnIcon" )
				Blockmodel:SetSize( 40, 40 )
				Blockmodel:SetModel(v.model)
				Blockmodel.DoClick = function()
					data.model = v.model
					Scroll.UpdateData(Scroll.CompileData())
				end
				Blockmodel.Paint = function(self)
					if data.model == v.model then
						surface.SetDrawColor(0,0,200)
						self:DrawOutlinedRect()
					end
				end
			end
		end

		return Scroll
	end,
	defaultdata = {
		model = "models/hunter/plates/plate2x2.mdl"
	},
})

nzTools:EnableProperties("block", "Edit Model...", "icon16/brick_edit.png", 9009, true, function( self, ent, ply )
	if ( !IsValid( ent ) or !IsValid(ply) ) then return false end
	if ( ent:GetClass() != "wall_block" ) then return false end
	if !nzRound:InState( ROUND_CREATE ) then return false end
	if ( ent:IsPlayer() ) then return false end
	if ( !ply:IsInCreative() ) then return false end

	return true

end, function(ent)
	return {model = ent:GetModel()}
end)
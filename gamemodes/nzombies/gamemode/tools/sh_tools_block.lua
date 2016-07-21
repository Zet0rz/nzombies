nz.Tools.Functions.CreateTool("block", {
	displayname = "Invisible Block Spawner",
	desc = "LMB: Create Invisible Block, RMB: Remove Invisible Block, R: Change Model",
	condition = function(wep, ply)
		return true
	end,
	PrimaryAttack = function(wep, ply, tr, data)
		nzMapping:BlockSpawn(tr.HitPos,Angle(90,(tr.HitPos - ply:GetPos()):Angle()[2] + 90,90), data.model, ply)
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
	interface = function(frame, data)
		local Scroll = vgui.Create( "DScrollPanel", frame )
		Scroll:SetSize( 280, 300 )
		Scroll:SetPos( 10, 10 )

		local List	= vgui.Create( "DIconLayout", Scroll )
		List:SetSize( 340, 200 )
		List:SetPos( 0, 0 )
		List:SetSpaceY( 5 )
		List:SetSpaceX( 5 )

		local function UpdateData()
			nz.Tools.Functions.SendData( {model = data.model}, "block", {model = data.model})
		end

		local models = util.KeyValuesToTable((file.Read("settings/spawnlist/default/023-general.txt", "MOD")))

		for k,v in pairs(models["contents"]) do
			if v.model then
				local Blockmodel = List:Add( "SpawnIcon" )
				Blockmodel:SetSize( 40, 40 )
				Blockmodel:SetModel(v.model)
				Blockmodel.DoClick = function()
					data.model = v.model
					UpdateData()
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
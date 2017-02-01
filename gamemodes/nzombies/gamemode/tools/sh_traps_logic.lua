nzTools:CreateTool("traps_logic", {
	displayname = "Traps, Buttons, Logic",
	desc = "LMB: Create Entity, RMB: Remove Entity, R: Duplicate Entity, C: Edit Properties",
	condition = function(wep, ply)
		return true
	end,
	PrimaryAttack = function(wep, ply, tr, data)
		local ent
		if data.clone then
			ent = duplicator.CreateEntityFromTable(ply, data.dupe)
			if !IsValid(ent) then return end
		else
			ent = ents.Create(data.classname)
		end
		ent:SetPos(tr.HitPos)
		--ent:SetAngles(tr.HitNormal:Angle() + Angle(90,0,0))
		ent:Spawn()
		ent:Activate()
		
		if IsValid(ply) then
			undo.Create( "Logic/Trap" )
				undo.SetPlayer( ply )
				undo.AddEntity( ent )
			undo.Finish()
		end

		if data.clone then
			for k, v in pairs(data.dupe.DT) do
				if ent["Set" .. k] then
					timer.Simple( 0.1, function() ent["Set" .. k](ent, v) end)
				end
			end
		end
	end,
	SecondaryAttack = function(wep, ply, tr, data)
		if IsValid(tr.Entity) then
			tr.Entity:Remove()
		end
	end,
	Reload = function(wep, ply, tr, data)
		ply:SetNZToolData({dupe = duplicator.CopyEntTable( tr.Entity ), clone = true})
	end,
	OnEquip = function(wep, ply, data)

	end,
	OnHolster = function(wep, ply, data)

	end
}, {
	displayname = "Traps, Buttons, Logic",
	desc = "LMB: Create Entity, RMB: Remove Entity, R: Duplicate Entity, C: Edit Properties",
	icon = "icon16/controller.png",
	weight = 40,
	condition = function(wep, ply)
		return nzTools.Advanced
	end,
	interface = function(frame, data, context)

		local cont = vgui.Create("DScrollPanel", frame)
		cont:Dock(FILL)

		function cont.CompileData()
			return data
		end

		function cont.UpdateData(data)
			nzTools:SendData(data, "traps_logic") -- Save the same data here
		end

		local function genSpawnList(tbl, parent)
			for _, classname in pairs(tbl) do
				local info = baseclass.Get(classname)
				local model = info.SpawnIcon
				local name = info.PrintName
				local desc = info.Description
				if model then
					local panel = vgui.Create("DPanel", parent)
					panel:Dock(TOP)
					panel:DockMargin(2, 0, 2, 2)
					panel:DockPadding(2, 2, 2, 2)
					panel:SetHeight(64)

					local entityIcon = vgui.Create( "SpawnIcon", panel )
					entityIcon:Dock(LEFT)
					entityIcon:SetModel(model)
					entityIcon:SetTooltip(name)
					entityIcon:SetWidth(64)
					entityIcon.DoClick = function()
						cont.UpdateData({classname = classname, clone = false})
					end

					local richText = vgui.Create( "RichText" , panel)
					richText:SetFontInternal("DermaDefault")
					richText:InsertColorChange(9, 9, 9, 255)
					richText:AppendText(name .. "\n\n")
					richText:InsertColorChange(40, 40, 40, 255)
					richText:AppendText(desc)
					richText:Dock(FILL)

					panel:InvalidateLayout( true )
					panel:SizeToChildren( false, true )
				end
			end

			return list
		end

		local traps = vgui.Create( "DCollapsibleCategory", cont )
		traps:SetExpanded( 1 )
		traps:SetLabel( "Traps" )
		traps:Dock(TOP)

		genSpawnList(nzTraps:GetAll(), traps)


		local logic = vgui.Create( "DCollapsibleCategory", cont )
		logic:SetExpanded( 1 )
		logic:SetLabel( "Logic" )
		logic:Dock(TOP)

		PrintTable(nzLogic:GetAll())
		genSpawnList(nzLogic:GetAll(), logic)

		return cont
	end,
	defaultdata = {
		model = "models/hunter/plates/plate2x2.mdl"
	},
})

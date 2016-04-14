//

function nz.Tools.Functions.CreateTool(id, serverdata, clientdata)
	if SERVER then
		nz.Tools.ToolData[id] = serverdata
	else
		nz.Tools.ToolData[id] = clientdata
	end
end

function nz.Tools.Functions.Get(id)
	return nz.Tools.ToolData[id]
end

function nz.Tools.Functions.GetList()
	local tbl = {}

	for k,v in pairs(nz.Tools.ToolData) do
		tbl[k] = v.displayname
	end

	return tbl
end

nz.Tools.Functions.CreateTool("default", {
	displayname = "Multitool",
	desc = "Hold Q to pick a tool to use",
	condition = function(wep, ply)
		return false
	end,

	PrimaryAttack = function(wep, ply, tr, data)
	end,

	SecondaryAttack = function(wep, ply, tr, data)
	end,
	Reload = function(wep, ply, tr, data)
		//Nothing
	end,
	OnEquip = function(wep, ply, data)

	end,
	OnHolster = function(wep, ply, data)

	end
}, {
	displayname = "Multitool",
	desc = "Hold Q to pick a tool to use",
	condition = function(wep, ply)
		return false
	end,
	interface = function(frame, data)
		local text = vgui.Create("DLabel", frame)
		text:SetText("Select a tool in the list to the left.")
		text:SetFont("Trebuchet18")
		text:SetTextColor( Color(50, 50, 50) )
		text:SizeToContents()
		text:Center()

		return text
	end,
	//defaultdata = {}
})
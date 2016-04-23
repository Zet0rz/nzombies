-- Actual Commands

-- Quick reload for dedicated severs
concommand.Add("nz_qr", function()
	RunConsoleCommand("changelevel", game.GetMap())
end)

concommand.Add( "nz_print_weps", function()
	for k,v in pairs( weapons.GetList() ) do
		print( v.ClassName )
	end
end)

concommand.Add("nz_door_id", function()
	local tr = util.TraceLine( util.GetPlayerTrace( player.GetByID(1) ) )
	if IsValid( tr.Entity ) then print( tr.Entity:doorIndex() ) end
end)

concommand.Add("nz_test1", function()
	nz.nzDoors.Functions.CreateMapDoorLink( 1236, "price=500,elec=0,link=1" )

	timer.Simple(5, function() nz.nzDoors.Functions.RemoveMapDoorLink( 1236 ) end)
end)

concommand.Add("nz_forceround", function(ply, cmd, args, argStr)
	if !IsValid(ply) or ply:IsSuperAdmin() then
		local round = args[1] and tonumber(args[1]) or nil
		local nokill = args[2] and tobool(args[2]) or false

		if !nokill then
			nz.PowerUps.Functions.Nuke(nil, true) -- Nuke kills them all, no points, no position delay
		end

		if round then
			nzRound:SetNumber( round - 1 )
			local specint = GetConVar("nz_round_special_interval"):GetInt() or 6
			nzRound:SetNextSpecialRound( math.ceil(round/specint)*specint)
		end
		nzRound:Prepare()
	end
end)

-- Isn't used anywhere, marked for removal
function lmne(name, find, listall)
	if !IsValid(ply) or ply:IsSuperAdmin() then
		if name then
			local tbl = {}
			if find then
				for k,v in pairs(ents.GetAll()) do
					if v:GetName() != "" and string.find(string.lower(v:GetName()), string.lower(name)) then
						table.insert(tbl, v)
						print(v:GetName(),"\t\t\t",v)
					end
				end
			else
				tbl = ents.FindByName(name)
			end
			if !listall then
				return tbl[1]
			else
				return tbl
			end
		else
			local tbl = {}
			for k,v in pairs(ents.GetAll()) do
				if v:GetName() != "" then
					table.insert(tbl, v)
					print(v:GetName(),"\t\t\t",v)
				end
			end
			return tbl
		end
	end
end

concommand.Add("printeyeentityinfo", function(ply, cmd, args, argstr)
	if !ply:IsSuperAdmin() then return end
	local ent = ply:GetEyeTrace().Entity
	if IsValid(ent) then
		local pos = ent:GetPos()
		local ang = ent:GetAngles()
		print("{pos = Vector("..math.Round(pos.x)..", "..math.Round(pos.y)..", "..math.Round(pos.z).."), ang = Angle("..math.Round(ang[1])..", "..math.Round(ang[2])..", "..math.Round(ang[3])..")}")
	end
end)
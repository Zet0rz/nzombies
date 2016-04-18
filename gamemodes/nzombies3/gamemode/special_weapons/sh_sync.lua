if SERVER then
	util.AddNetworkString("nzSendSpecialWeapon")

	function nzSpecialWeapons:SendSpecialWeaponAdded(ply, wep, id)
		timer.Simple(0.1, function()
			if IsValid(ply) then
				net.Start("nzSendSpecialWeapon")
					net.WriteString(id)
					net.WriteBool(true)
					net.WriteEntity(wep)
				net.Send(ply)
			end
		end)
	end
	
	function nzSpecialWeapons:SendSpecialWeaponRemoved(ply, id)
		timer.Simple(0.1, function()
			if IsValid(ply) then
				net.Start("nzSendSpecialWeapon")
					net.WriteString(id)
					net.WriteBool(false)
				net.Send(ply)
			end
		end)
	end
end

if CLIENT then
	local function ReceiveSpecialWeaponAdded()
		if !LocalPlayer().NZSpecialWeapons then LocalPlayer().NZSpecialWeapons = {} end
		local id = net.ReadString()
		local bool = net.ReadBool()
		
		if bool then
			local ent = net.ReadEntity()
			LocalPlayer().NZSpecialWeapons[id] = ent
		else
			LocalPlayer().NZSpecialWeapons[id] = nil
		end
	end
	net.Receive("nzSendSpecialWeapon", ReceiveSpecialWeaponAdded)
end
if SERVER then
	util.AddNetworkString("nzSendSpecialWeapon")

	function SpecialWeapons:SendSpecialWeaponAdded(ply, wep, id)
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
	
	function SpecialWeapons:SendSpecialWeaponRemoved(ply, id)
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
		if !LocalPlayer().SpecialWeapons then LocalPlayer().SpecialWeapons = {} end
		local id = net.ReadString()
		local bool = net.ReadBool()
		
		if bool then
			local ent = net.ReadEntity()
			LocalPlayer().SpecialWeapons[id] = ent
		else
			LocalPlayer().SpecialWeapons[id] = nil
		end
	end
	net.Receive("nzSendSpecialWeapon", ReceiveSpecialWeaponAdded)
end
local function DrawItemCarryHud()

	local scale = (ScrW()/1920 + 1)/2
	local ply = LocalPlayer()
	surface.SetDrawColor(255,255,255)
	local num = 0
	for k,v in pairs(ply:GetCarryItems()) do
		local item = ItemCarry.Items[v]
		if item.icon then
			surface.SetMaterial(item.icon)
			surface.DrawTexturedRect(ScrW() - 400*scale - num*32*scale, ScrH() - 90*scale, 30*scale, 30*scale)
			num = num + 1
		end
	end
	--[[local num = LocalPlayer():GetAmmoCount("nz_grenade")
	local numspecial = LocalPlayer():GetAmmoCount("nz_specialgrenade")
	local scale = (ScrW()/1920 + 1)/2

	--print(num)
	if num > 0 then
		surface.SetMaterial(grenade_icon)
		surface.SetDrawColor(255,255,255)
		for i = num, 1, -1 do
			--print(i)
			surface.DrawTexturedRect(ScrW() - 250*scale - i*10*scale, ScrH() - 90*scale, 30*scale, 30*scale)
		end
	end
	if numspecial > 0 then
		surface.SetMaterial(grenade_icon)
		surface.SetDrawColor(255,100,100)
		for i = numspecial, 1, -1 do
			--print(i)
			surface.DrawTexturedRect(ScrW() - 300*scale - i*10*scale, ScrH() - 90*scale, 30*scale, 30*scale)
		end
	end
	--surface.DrawTexturedRect(ScrW()/2, ScrH()/2, 100, 100)]]
end

hook.Add("HUDPaint", "itemcarryHUD", DrawItemCarryHud )

local function DrawItemCarryHud()

	local scale = (ScrW()/1920 + 1)/2
	local ply = LocalPlayer()
	surface.SetDrawColor(255,255,255)
	local num = 0
	for k,v in pairs(ply:GetCarryItems()) do
		local item = nzItemCarry.Items[v]
		if item then
			if item.model then
				surface.SetMaterial(item.model)
				surface.DrawTexturedRect(ScrW() - 400*scale - num*40*scale, ScrH() - 90*scale, 30*scale, 30*scale)
				if item.icon then
					surface.SetMaterial(item.icon)
					surface.DrawTexturedRect(ScrW() - 384*scale - num*40*scale, ScrH() - 90*scale, 16*scale, 16*scale)
				end
			elseif item.icon then
				surface.SetMaterial(item.icon)
				surface.DrawTexturedRect(ScrW() - 400*scale - num*40*scale, ScrH() - 90*scale, 30*scale, 30*scale)
			end
			num = num + 1
		end
	end
	
end

local itemnotif = itemnotif or {}

net.Receive( "nzItemCarryPlayersNotif", function()
	local ply = net.ReadEntity()
	local id = net.ReadString()
	
	if itemnotif[id] then
		itemnotif[id].time = CurTime() + 5
		if IsValid(itemnotif[id].avatar) then
			if IsValid(ply) then
				itemnotif[id].avatar:SetPlayer(ply)
			else
				itemnotif[id].avatar:Remove()
				itemnotif[id].avatar = nil
			end
		else
			if IsValid(ply) then
				itemnotif[id].avatar = vgui.Create("AvatarImage")
				itemnotif[id].avatar:SetSize( 32, 32 )
				itemnotif[id].avatar:SetPos( 0, 0 )
				itemnotif[id].avatar:SetPlayer( ply, 32 )
			end
		end
	else
		local item = nzItemCarry.Items[id]
		local avatar
		if IsValid(ply) then
			avatar = vgui.Create("AvatarImage")
			avatar:SetSize( 32, 32 )
			avatar:SetPos( 0, 0 )
			avatar:SetPlayer( ply, 32 )
		end
		if item then --and item.notif then
			itemnotif[id] = {
				avatar = avatar,
				time = CurTime() + 5,
			}
		end
	end
	
	surface.PlaySound("ambient/levels/caves/dist_grub3.wav")
end)

local function DrawItemCarryNotifications()
	--local scale = (ScrW()/1920 + 1)/2
	surface.SetDrawColor(255,255,255)
	local num = 0
	for k,v in pairs(itemnotif) do
		local item = nzItemCarry.Items[k]
		if item and (item.icon or item.model) then
			local avatar = v.avatar
			local time = v.time
			if time < CurTime() then
				local fade = (1-(CurTime()-time))*255
				surface.SetDrawColor(255,255,255, fade)
				if fade <= 0 then
					itemnotif[k] = nil
					if IsValid(avatar) then
						avatar:Remove()
					end
				end
			end
			
			local x = ScrW() - 96 - num*66
			
			if item.model then
				surface.SetMaterial(item.model)
				surface.DrawTexturedRect(x, 32, 64, 64)
				if item.icon then
					surface.SetMaterial(item.icon)
					surface.DrawTexturedRect(x+48, 26, 16, 16)
				end
			else
				surface.SetMaterial(item.icon)
				surface.DrawTexturedRect(x, 32, 64, 64)
			end
			
			if IsValid(avatar) then
				avatar:SetPos(x + 32, 75)
			end
			num = num + 1
		end
	end
end

hook.Add("HUDPaint", "nzItemCarryHUD", DrawItemCarryHud )
hook.Add("HUDPaint", "nzItemCarryNotifications", DrawItemCarryNotifications )

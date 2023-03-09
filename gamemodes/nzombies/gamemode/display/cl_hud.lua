-- 
nzDisplay = nzDisplay or AddNZModule("Display")

local bloodline_points = Material("bloodline_score2.png", "unlitgeneric smooth")
local bloodline_gun = Material("cod_hud.png", "unlitgeneric smooth")

--[[local bloodDecals = {
	Material("decals/blood1"),
	Material("decals/blood2"),
	Material("decals/blood3"),
	Material("decals/blood4"),
	Material("decals/blood5"),
	Material("decals/blood6"),
	Material("decals/blood7"),
	Material("decals/blood8"),
	nil
}]]

CreateClientConVar( "nz_hud_points_show_names", "1", true, false )

local function StatesHud()
	if GetConVar("cl_drawhud"):GetBool() then
		local text = ""
		local font = "nz.display.hud.main"
		local w = ScrW() / 2
		if nzRound:InState( ROUND_WAITING ) then
			text = "Waiting for players. Type /ready to ready up."
			font = "nz.display.hud.small"
		elseif nzRound:InState( ROUND_CREATE ) then
			text = "Creative Mode"
		elseif nzRound:InState( ROUND_GO ) then
			text = "Game Over"
		end
		draw.SimpleText(text, font, w, ScrH() * 0.85, Color(200, 0, 0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

local tbl = {Entity(3), Entity(1), Entity(3), Entity(4), Entity(5),}

local function ScoreHud()
	if GetConVar("cl_drawhud"):GetBool() then
		if nzRound:InProgress() then

			local scale = (ScrW() / 1920 + 1) / 2
			local offset = 0

			for k,v in pairs(player.GetAll()) do
				local hp = v:Health()
				if hp == 0 then hp = "Dead" elseif nzRevive.Players[v:EntIndex()] then hp = "Downed" else hp = hp .. " HP"  end
				if v:GetPoints() >= 0 then

					local text = ""
					local nameoffset = 0
					if GetConVar("nz_hud_points_show_names"):GetBool() then
						local nick
						if #v:Nick() >= 20 then
							nick = string.sub(v:Nick(), 1, 20)  -- limit name to 20 chars
						else
							nick = v:Nick()
						end
						text = nick
						nameoffset = 10
					end

					local font = "nz.display.hud.small"

					surface.SetFont(font)

					local textW, textH = surface.GetTextSize(text)

					if LocalPlayer() == v then
						offset = offset + textH + 5 -- change this if you change the size of nz.display.hud.medium
					else
						offset = offset + textH
					end

					surface.SetDrawColor(200,200,200)
					local index = v:EntIndex()
					local color = player.GetColorByIndex(v:EntIndex())
					local blood = player.GetBloodByIndex(v:EntIndex())
					--for i = 0, 8 do
						--surface.SetMaterial(bloodDecals[((index + i - 1) % #bloodDecals) + 1 ])
						surface.SetMaterial(blood)
						surface.DrawTexturedRect(ScrW() - textW - 180, ScrH() - 275 * scale - offset, textW + 150, 45)
					--end
					--surface.DrawTexturedRect(ScrW() - 325*scale - numname * 10, ScrH() - 285*scale - (30*k), 250 + numname*10, 35)
					if text then draw.SimpleText(text, font, ScrW() - textW - 60, ScrH() - 255 * scale - offset, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end
					if LocalPlayer() == v then
						font = "nz.display.hud.medium"
					end
					draw.SimpleText(v:GetPoints(), font, ScrW() - textW - 60 - nameoffset, ScrH() - 255 * scale - offset, color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
					v.PointsSpawnPosition = {x = ScrW() - textW - 170, y = ScrH() - 255 * scale - offset}
				end
			end
		end
	end
end

local function GunHud()
	if GetConVar("cl_drawhud"):GetBool() then
		if !LocalPlayer():IsNZMenuOpen() then
			local wep = LocalPlayer():GetActiveWeapon()
			local w,h = ScrW(), ScrH()
			local scale = ((w/1920)+1)/2

			surface.SetMaterial(bloodline_gun)
			surface.SetDrawColor(200,200,200)
			surface.DrawTexturedRect(w - 630*scale, h - 225*scale, 600*scale, 225*scale)
			if IsValid(wep) then
				if wep:GetClass() == "nz_multi_tool" then
					draw.SimpleTextOutlined(nzTools.ToolData[wep.ToolMode].displayname or wep.ToolMode, "nz.display.hud.small", w - 240*scale, h - 125*scale, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, color_black)
					draw.SimpleTextOutlined(nzTools.ToolData[wep.ToolMode].desc or "", "nz.display.hud.smaller", w - 240*scale, h - 90*scale, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 2, color_black)
				else
					local name = wep:GetPrintName()					
					local x = 250
					local y = 165
					if wep:GetPrimaryAmmoType() != -1 then
						local clip
						if wep.Primary.ClipSize and wep.Primary.ClipSize != -1 then
							draw.SimpleTextOutlined("/"..wep:Ammo1(), "nz.display.hud.ammo2", ScrW() - 310*scale, ScrH() - 120*scale, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 2, color_black)
							clip = wep:Clip1()
							x = 315
							y = 155
						else
							clip = wep:Ammo1()
						end
						draw.SimpleTextOutlined(clip, "nz.display.hud.ammo", ScrW() - x*scale, ScrH() - 115*scale, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, color_black)
						x = x + 80
					end
					
					draw.SimpleTextOutlined(name, "nz.display.hud.small", ScrW() - x*scale, ScrH() - 120*scale, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, color_black)
					
					x = 270
					if wep:GetSecondaryAmmoType() != -1 then
						local clip
						if wep.Secondary.ClipSize and wep.Secondary.ClipSize != -1 then
							draw.SimpleTextOutlined("/"..wep:Ammo2(), "nz.display.hud.ammo4", ScrW() - x*scale, ScrH() - y*scale, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 2, color_black)
							clip = wep:Clip2()
							x = x + 3
						else
							clip = wep:Ammo2()
						end
						draw.SimpleTextOutlined(clip, "nz.display.hud.ammo3", ScrW() - x*scale, ScrH() - y*scale, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, color_black)
						x = x + 80
					end
					
					--[[if clip >= 0 then
						draw.SimpleTextOutlined(name, "nz.display.hud.small", ScrW() - 390*scale, ScrH() - 120*scale, Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, Color(0,0,0))
						draw.SimpleTextOutlined(clip, "nz.display.hud.ammo", ScrW() - 315*scale, ScrH() - 115*scale, Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, Color(0,0,0))
						draw.SimpleTextOutlined("/"..wep:Ammo1(), "nz.display.hud.ammo2", ScrW() - 310*scale, ScrH() - 120*scale, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 2, Color(0,0,0))
					else
						draw.SimpleTextOutlined(name, "nz.display.hud.small", ScrW() - 250*scale, ScrH() - 120*scale, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, color_black)
					end]]
				end
			end
		end
	end
end

local function PowerUpsHud()
	if nzRound:InProgress() or nzRound:InState(ROUND_CREATE) then
		local font = "nz.display.hud.main"
		local w = ScrW() / 2
		local offset = 40
		local c = 0
		for k,v in pairs(nzPowerUps.ActivePowerUps) do
			if nzPowerUps:IsPowerupActive(k) then
				local powerupData = nzPowerUps:Get(k)
				draw.SimpleText(powerupData.name .. " - " .. math.Round(v - CurTime()), font, w, ScrH() * 0.85 + offset * c, Color(255, 255, 255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				c = c + 1
			end
		end
		if !nzPowerUps.ActivePlayerPowerUps[LocalPlayer()] then nzPowerUps.ActivePlayerPowerUps[LocalPlayer()] = {} end
		for k,v in pairs(nzPowerUps.ActivePlayerPowerUps[LocalPlayer()]) do
			if nzPowerUps:IsPlayerPowerupActive(LocalPlayer(), k) then
				local powerupData = nzPowerUps:Get(k)
				draw.SimpleText(powerupData.name .. " - " .. math.Round(v - CurTime()), font, w, ScrH() * 0.85 + offset * c, Color(255, 255, 255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				c = c + 1
			end
		end
	end
end

local Laser = Material( "cable/redlaser" )
function nzDisplay.DrawLinks( ent, link )

	local tbl = {}
	-- Check for zombie spawns
	for k, v in pairs(ents.GetAll()) do
		if v:IsBuyableProp()  then
			if nzDoors.PropDoors[k] != nil then
				if v.link == link then
					table.insert(tbl, Entity(k))
				end
			end
		elseif v:IsDoor() then
			if nzDoors.MapDoors[v:doorIndex()] != nil then
				if nzDoors.MapDoors[v:doorIndex()].link == link then
					table.insert(tbl, v)
				end
			end
		elseif v:GetClass() == "nz_spawn_zombie_normal" then
			if v:GetLink() == link then
				table.insert(tbl, v)
			end
		end
	end


	--  Draw
	if tbl[1] != nil then
		for k,v in pairs(tbl) do
			render.SetMaterial( Laser )
			render.DrawBeam( ent:GetPos(), v:GetPos(), 20, 1, 1, Color( 255, 255, 255, 255 ) )
		end
	end
end

local PointsNotifications = {}
local function PointsNotification(ply, amount)
	if !IsValid(ply) then return end
	local data = {ply = ply, amount = amount, diry = math.random(-20, 20), time = CurTime()}
	table.insert(PointsNotifications, data)
	--PrintTable(data)
end

net.Receive("nz_points_notification", function()
	local amount = net.ReadInt(20)
	local ply = net.ReadEntity()

	PointsNotification(ply, amount)
end)

local function DrawPointsNotification()

	if GetConVar("nz_point_notification_clientside"):GetBool() then
		for k,v in pairs(player.GetAll()) do
			if v:GetPoints() >= 0 then
				if !v.LastPoints then v.LastPoints = 0 end
				if v:GetPoints() != v.LastPoints then
					PointsNotification(v, v:GetPoints() - v.LastPoints)
					v.LastPoints = v:GetPoints()
				end
			end
		end
	end

	local font = "nz.display.hud.points"

	for k,v in pairs(PointsNotifications) do
		local fade = math.Clamp((CurTime()-v.time), 0, 1)
		if !v.ply.PointsSpawnPosition then return end
		if v.amount >= 0 then
			draw.SimpleText(v.amount, font, v.ply.PointsSpawnPosition.x - 50*fade, v.ply.PointsSpawnPosition.y + v.diry*fade, Color(255,255,0,255-255*fade), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		else
			draw.SimpleText(v.amount, font, v.ply.PointsSpawnPosition.x - 50*fade, v.ply.PointsSpawnPosition.y + v.diry*fade, Color(255,0,0,255-255*fade), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		end
		if fade >= 1 then
			table.remove(PointsNotifications, k)
		end
	end
end

-- Now handled via perks individual icon table entries
--[[local perk_icons = {
	["jugg"] = Material("perk_icons/jugg.png", "smooth unlitgeneric"),
	["speed"] = Material("perk_icons/speed.png", "smooth unlitgeneric"),
	["dtap"] = Material("perk_icons/dtap.png", "smooth unlitgeneric"),
	["revive"] = Material("perk_icons/revive.png", "smooth unlitgeneric"),
	["dtap2"] = Material("perk_icons/dtap2.png", "smooth unlitgeneric"),
	["staminup"] = Material("perk_icons/staminup.png", "smooth unlitgeneric"),
	["phd"] = Material("perk_icons/phd.png", "smooth unlitgeneric"),
	["deadshot"] = Material("perk_icons/deadshot.png", "smooth unlitgeneric"),
	["mulekick"] = Material("perk_icons/mulekick.png", "smooth unlitgeneric"),
	["cherry"] = Material("perk_icons/cherry.png", "smooth unlitgeneric"),
	["tombstone"] = Material("perk_icons/tombstone.png", "smooth unlitgeneric"),
	["whoswho"] = Material("perk_icons/whoswho.png", "smooth unlitgeneric"),
	["vulture"] = Material("perk_icons/vulture.png", "smooth unlitgeneric"),

	-- Only used to see PaP through walls with Vulture Aid
	["pap"] = Material("vulture_icons/pap.png", "smooth unlitgeneric"),
}]]

local function PerksHud()
	local scale = (ScrW()/1920 + 1)/2
	local w = 175
	local size = 50
	for k,v in pairs(LocalPlayer():GetPerks()) do
		surface.SetMaterial(nzPerks:Get(v).icon)
		surface.SetDrawColor(255,255,255)
		surface.DrawTexturedRect(w + k*(size*scale + 1), ScrH() - 85, size*scale, size*scale)
	end
end

local vulture_textures = {
	["wall_buys"] = Material("vulture_icons/wall_buys.png", "smooth unlitgeneric"),
	["random_box"] = Material("vulture_icons/random_box.png", "smooth unlitgeneric"),
	["wunderfizz_machine"] = Material("vulture_icons/wunderfizz.png", "smooth unlitgeneric"),
}

local function VultureVision()
	if !LocalPlayer():HasPerk("vulture") then return end
	local scale = (ScrW()/1920 + 1)/2

	for k,v in pairs(ents.FindInSphere(LocalPlayer():GetPos(), 700)) do
		local target = v:GetClass()
		if vulture_textures[target] then
			local data = v:WorldSpaceCenter():ToScreen()
			if data.visible then
				surface.SetMaterial(vulture_textures[target])
				surface.SetDrawColor(255,255,255,150)
				surface.DrawTexturedRect(data.x - 15*scale, data.y - 15*scale, 30*scale, 30*scale)
			end
		elseif target == "perk_machine" then
			local data = v:WorldSpaceCenter():ToScreen()
			if data.visible then
				local icon = nzPerks:Get(v:GetPerkID()).icon
				if icon then
					surface.SetMaterial(icon)
					surface.SetDrawColor(255,255,255,150)
					surface.DrawTexturedRect(data.x - 15*scale, data.y - 15*scale, 30*scale, 30*scale)
				end
			end
		end
	end
end

local round_white = 0
local round_alpha = 255
local round_num = 0
local infmat = Material("materials/round_-1.png", "smooth")
local function RoundHud()

	local text = ""
	local font = "nz.display.hud.rounds"
	local w = 40
	local h = ScrH() - 30
	local round = round_num
	local col = Color(200 + round_white*55, round_white, round_white,round_alpha)
	if round == -1 then
		--text = "∞"
		surface.SetMaterial(infmat)
		surface.SetDrawColor(col.r,round_white,round_white,round_alpha)
		surface.DrawTexturedRect(w - 25, h - 100, 200, 100)
		return
	elseif round < 6 then
		for i = 1, round do
			if i == 5 or i == 6 then
				text = text.." "
			else
				text = text.."i"
			end
		end
		if round >= 5 then
			draw.TextRotatedScaled( "i", w + 100, h - 150, col, font, 60, 1, 1.7 )
		end
		if round >= 10 then
			draw.TextRotatedScaled( "i", w + 220, h - 150, col, font, 60, 1, 1.7 )
		end
	else
		text = round
	end
	draw.SimpleText(text, font, w, h, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

end

//

local bloodline_points = Material("bloodline_score.png", "unlitgeneric smooth")
local bloodline_gun = Material("cod_hud.png", "unlitgeneric smooth")

function nz.Display.Functions.StatesHud()
	local text = ""
	local font = "nz.display.hud.main"
	local w = ScrW() / 2
	if nz.Rounds.Data.CurrentState == ROUND_INIT then
		text = "Waiting for players. Type /ready to ready up."
		font = "nz.display.hud.small"
	elseif nz.Rounds.Data.CurrentState == ROUND_PREP then
		if nz.Rounds.Data.CurrentRound != 0 then
			text = nz.Rounds.Data.CurrentRound
		else 
			text = "1"
		end
		w = ScrW() * 0.1
	elseif nz.Rounds.Data.CurrentState == ROUND_PROG then
		if nz.Rounds.Data.CurrentRound != 0 then
			text = nz.Rounds.Data.CurrentRound
		else
			text = "1"
		end
		w = ScrW() * 0.1
	elseif nz.Rounds.Data.CurrentState == ROUND_CREATE then
		text = "Creative Mode"
	elseif nz.Rounds.Data.CurrentState == ROUND_GO then
		text = "Game Over"
	end
	draw.SimpleText(text, font, w, ScrH() * 0.85, Color(200, 0, 0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function nz.Display.Functions.ScoreHud()
	if nz.Rounds.Data.CurrentState == ROUND_PREP or nz.Rounds.Data.CurrentState == ROUND_PROG or nz.Rounds.Data.CurrentState == ROUND_INIT or nz.Rounds.Data.CurrentState == ROUND_GO then
		for k,v in pairs(player.GetAll()) do
			local hp = v:Health()
			if hp == 0 then hp = "Dead" elseif nz.Revive.Data.Players[v] then hp = "Downed" else hp = hp .. " HP"  end
			if v:GetPoints() >= 0 then 
				surface.SetMaterial(bloodline_points)
				surface.SetDrawColor(255,255,255)
				surface.DrawTexturedRect(ScrW() - 325 - #v:Nick()*10, ScrH() - 285 + (30*k), 250 + #v:Nick()*10, 35)
				draw.SimpleText(v:GetPoints().." - "..v:Nick().." (" .. hp ..  ")", "nz.display.hud.small", ScrW() - 100, ScrH() - 270 + (30*k), Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
				v.PointsSpawnPosition = {x = ScrW() - 325 - #v:Nick()*10, y = ScrH() - 270 + (30*k)}
			end
		end
	end
end

function nz.Display.Functions.GunHud()

	local wep = LocalPlayer():GetActiveWeapon()
	
	surface.SetMaterial(bloodline_gun)
	surface.SetDrawColor(255,255,255)
	surface.DrawTexturedRect(ScrW() - 630, ScrH() - 225, 600, 225)
	if IsValid(wep) then
		if wep:GetClass() == "nz_multi_tool" then
			draw.SimpleTextOutlined(nz.Tools.ToolData[wep.ToolMode].displayname or wep.ToolMode, "nz.display.hud.small", ScrW() - 240, ScrH() - 150, Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, Color(0,0,0))
			draw.SimpleTextOutlined(nz.Tools.ToolData[wep.ToolMode].desc or "", "nz.display.hud.smaller", ScrW() - 240, ScrH() - 90, Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, Color(0,0,0))
		else
			local name = wep:GetPrintName()
			if !name or name == "" then name = wep:GetClass() end
			if wep.pap then name = "Upgraded "..name end
			draw.SimpleTextOutlined(name, "nz.display.hud.small", ScrW() - 390, ScrH() - 150, Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, Color(0,0,0))
			draw.SimpleTextOutlined(wep:Clip1(), "nz.display.hud.ammo", ScrW() - 315, ScrH() - 175, Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, Color(0,0,0))
			draw.SimpleTextOutlined("/"..LocalPlayer():GetAmmoCount(wep:GetPrimaryAmmoType()), "nz.display.hud.ammo2", ScrW() - 310, ScrH() - 160, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 2, Color(0,0,0))
		end
	end
end

function nz.Display.Functions.PowerUpsHud()
	if nz.Rounds.Data.CurrentState == ROUND_PREP or nz.Rounds.Data.CurrentState == ROUND_PROG then
		local font = "nz.display.hud.main"
		local w = ScrW() / 2
		local offset = 40
		local c = 0
		for k,v in pairs(nz.PowerUps.Data.ActivePowerUps) do
			if nz.PowerUps.Functions.IsPowerupActive(k) then
				local powerupData = nz.PowerUps.Functions.Get(k)
				draw.SimpleText(powerupData.name .. " - " .. math.Round(v - CurTime()), font, w, ScrH() * 0.85 + offset * c, Color(255, 255, 255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				c = c + 1
			end
		end
	end
end

local Laser = Material( "cable/redlaser" )
function nz.Display.Functions.DrawLinks( ent, link )

	local tbl = {}
	//Check for zombie spawns
	for k, v in pairs(ents.GetAll()) do
		if v:IsBuyableProp()  then
			if nz.Doors.Data.BuyableProps[k] != nil then
				if v.link == link then
					table.insert(tbl, Entity(k))
				end
			end
		elseif v:IsDoor() then
			if nz.Doors.Data.LinkFlags[v:doorIndex()] != nil then
				if nz.Doors.Data.LinkFlags[v:doorIndex()].link == link then
					table.insert(tbl, v)
				end
			end
		elseif v:GetClass() == "zed_spawns" then
			if v:GetLink() == link then
				table.insert(tbl, v)
			end
		end
	end
	
	
	// Draw
	if tbl[1] != nil then
		for k,v in pairs(tbl) do
			render.SetMaterial( Laser )
			render.DrawBeam( ent:GetPos(), v:GetPos(), 20, 1, 1, Color( 255, 255, 255, 255 ) )
		end		
	end
end

function nz.Display.Functions.PointsNotification(ply, amount)
	local data = {ply = ply, amount = amount, diry = math.random(-20, 20), time = CurTime()}
	table.insert(nz.Display.Data.PointsNotifications, data)
	chat.AddText(amount) 
	--PrintTable(data)
end

net.Receive("nz_points_notification", function()
	local amount = net.ReadInt(20)
	local ply = net.ReadEntity()
	
	nz.Display.Functions.PointsNotification(ply, amount)
end)

function nz.Display.Functions.DrawPointsNotification()

	if nz.Config.PointNotifcationMode == NZ_POINT_NOTIFCATION_CLIENT then
		for k,v in pairs(player.GetAll()) do
			if v:GetPoints() >= 0 then
				if !v.LastPoints then v.LastPoints = 0 end
				if v:GetPoints() != v.LastPoints then
					nz.Display.Functions.PointsNotification(v, v:GetPoints() - v.LastPoints)
					v.LastPoints = v:GetPoints()
				end
			end
		end
	end

	local font = "nz.display.hud.points"
	
	for k,v in pairs(nz.Display.Data.PointsNotifications) do
		local fade = math.Clamp((CurTime()-v.time), 0, 1) 
		if v.amount >= 0 then
			draw.SimpleText(v.amount, font, v.ply.PointsSpawnPosition.x - 50*fade, v.ply.PointsSpawnPosition.y + v.diry*fade, Color(255,255,0,255-255*fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
			draw.SimpleText(v.amount, font, v.ply.PointsSpawnPosition.x - 50*fade, v.ply.PointsSpawnPosition.y + v.diry*fade, Color(255,0,0,255-255*fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		if fade >= 1 then
			table.remove(nz.Display.Data.PointsNotifications, k)
		end 
	end
end

local perk_icons = {
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
}

function nz.Display.Functions.PerksHud()
	local w = -20
	local size = 50
	for k,v in pairs(LocalPlayer():GetPerks()) do
		surface.SetMaterial(perk_icons[v])
		surface.SetDrawColor(255,255,255)
		surface.DrawTexturedRect(w + k*(size + 10), ScrH() - 150, size, size) 
	end
end

local vulture_textures = {
	["wall_buys"] = Material("vulture_icons/wall_buys.png", "smooth unlitgeneric"),
	["random_box"] = Material("vulture_icons/random_box.png", "smooth unlitgeneric"),
}

function nz.Display.Functions.VultureVision()
	if !LocalPlayer():HasPerk("vulture") then return end
	for k,v in pairs(ents.FindInSphere(LocalPlayer():GetPos(), 700)) do
		local target = v:GetClass()
		if vulture_textures[target] then
			local data = v:WorldSpaceCenter():ToScreen()
			if data.visible then
				surface.SetMaterial(vulture_textures[target])
				surface.SetDrawColor(255,255,255)
				surface.DrawTexturedRect(data.x - 25, data.y - 25, 50, 50)
			end
		elseif target == "perk_machine" then
			local data = v:WorldSpaceCenter():ToScreen()
			if data.visible then
				surface.SetMaterial(perk_icons[v:GetPerkID()])
				surface.SetDrawColor(255,255,255)
				surface.DrawTexturedRect(data.x - 25, data.y - 25, 50, 50)
			end
		end
	end
end

//Hooks
hook.Add("HUDPaint", "roundHUD", nz.Display.Functions.StatesHud )
hook.Add("HUDPaint", "scoreHUD", nz.Display.Functions.ScoreHud )
hook.Add("HUDPaint", "gunHUD", nz.Display.Functions.GunHud )
hook.Add("HUDPaint", "powerupHUD", nz.Display.Functions.PowerUpsHud )
hook.Add("HUDPaint", "pointsNotifcationHUD", nz.Display.Functions.DrawPointsNotification )
hook.Add("HUDPaint", "perksHUD", nz.Display.Functions.PerksHud )
hook.Add("HUDPaint", "vultureVision", nz.Display.Functions.VultureVision )
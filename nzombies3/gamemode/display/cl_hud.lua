//
nzDisplay = {}

local bloodline_points = Material("bloodline_score.png", "unlitgeneric smooth")
local bloodline_gun = Material("cod_hud.png", "unlitgeneric smooth")

local function StatesHud()
	local text = ""
	local font = "nz.display.hud.main"
	local w = ScrW() / 2
	if Round:InState( ROUND_WAITING ) then
		text = "Waiting for players. Type /ready to ready up."
		font = "nz.display.hud.small"
	elseif Round:InState( ROUND_CREATE ) then
		text = "Creative Mode"
	elseif Round:InState( ROUND_GO ) then
		text = "Game Over"
	end
	draw.SimpleText(text, font, w, ScrH() * 0.85, Color(200, 0, 0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

local function ScoreHud()
	local scale = (ScrW()/1920 + 1)/2

	if Round:InProgress() then
		for k,v in pairs(player.GetAll()) do
			local hp = v:Health()
			if hp == 0 then hp = "Dead" elseif nz.Revive.Data.Players[v] then hp = "Downed" else hp = hp .. " HP"  end
			if v:GetPoints() >= 0 then
				local numname = #v:Nick()
				surface.SetMaterial(bloodline_points)
				surface.SetDrawColor(255,255,255)
				surface.DrawTexturedRect(ScrW() - 325*scale - numname*10, ScrH() - 285*scale - (30*k), 250 + numname*10, 35)
				draw.SimpleText(v:GetPoints().." - "..v:Nick().." (" .. hp ..  ")", "nz.display.hud.small", ScrW() - (325*scale - 230), ScrH() - 270*scale - (30*k), Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
				v.PointsSpawnPosition = {x = ScrW() - 325*scale - numname*10, y = ScrH() - 270*scale - (30*k)}
			end
		end
	end
end

local function GunHud()

	local wep = LocalPlayer():GetActiveWeapon()
	local scale = ((ScrW()/1920)+1)/2

	surface.SetMaterial(bloodline_gun)
	surface.SetDrawColor(255,255,255)
	surface.DrawTexturedRect(ScrW() - 630*scale, ScrH() - 225*scale, 600*scale, 225*scale)
	if IsValid(wep) then
		if wep:GetClass() == "nz_multi_tool" then
			draw.SimpleTextOutlined(nz.Tools.ToolData[wep.ToolMode].displayname or wep.ToolMode, "nz.display.hud.small", ScrW() - 240*scale, ScrH() - 150*scale, Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, Color(0,0,0))
			draw.SimpleTextOutlined(nz.Tools.ToolData[wep.ToolMode].desc or "", "nz.display.hud.smaller", ScrW() - 240*scale, ScrH() - 90*scale, Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, Color(0,0,0))
		else
			local name = wep:GetPrintName()
			local clip = wep:Clip1()
			if !name or name == "" then name = wep:GetClass() end
			if wep.pap then
				name = nz.Display_PaPNames[wep:GetClass()] or nz.Display_PaPNames[name] or "Upgraded "..name
			end
			if clip >= 0 then
				draw.SimpleTextOutlined(name, "nz.display.hud.small", ScrW() - 390*scale, ScrH() - 150*scale, Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, Color(0,0,0))
				draw.SimpleTextOutlined(clip, "nz.display.hud.ammo", ScrW() - 315*scale, ScrH() - 175*scale, Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, Color(0,0,0))
				draw.SimpleTextOutlined("/"..LocalPlayer():GetAmmoCount(wep:GetPrimaryAmmoType()), "nz.display.hud.ammo2", ScrW() - 310*scale, ScrH() - 160*scale, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 2, Color(0,0,0))
			else
				draw.SimpleTextOutlined(name, "nz.display.hud.small", ScrW() - 250*scale, ScrH() - 150*scale, Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, Color(0,0,0))
			end
		end
	end
end

local function PowerUpsHud()
	if Round:InProgress() then
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
function nzDisplay.DrawLinks( ent, link )

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

	for k,v in pairs(PointsNotifications) do
		local fade = math.Clamp((CurTime()-v.time), 0, 1)
		if !v.ply.PointsSpawnPosition then return end
		if v.amount >= 0 then
			draw.SimpleText(v.amount, font, v.ply.PointsSpawnPosition.x - 50*fade, v.ply.PointsSpawnPosition.y + v.diry*fade, Color(255,255,0,255-255*fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
			draw.SimpleText(v.amount, font, v.ply.PointsSpawnPosition.x - 50*fade, v.ply.PointsSpawnPosition.y + v.diry*fade, Color(255,0,0,255-255*fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		if fade >= 1 then
			table.remove(PointsNotifications, k)
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

local function PerksHud()
	local scale = (ScrW()/1920 + 1)/2
	local w = -20
	local size = 50
	for k,v in pairs(LocalPlayer():GetPerks()) do
		surface.SetMaterial(perk_icons[v])
		surface.SetDrawColor(255,255,255)
		surface.DrawTexturedRect(w + k*(size*scale + 10), ScrH() - 200, size*scale, size*scale)
	end
end

local vulture_textures = {
	["wall_buys"] = Material("vulture_icons/wall_buys.png", "smooth unlitgeneric"),
	["random_box"] = Material("vulture_icons/random_box.png", "smooth unlitgeneric"),
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
				surface.SetMaterial(perk_icons[v:GetPerkID()])
				surface.SetDrawColor(255,255,255,150)
				surface.DrawTexturedRect(data.x - 15*scale, data.y - 15*scale, 30*scale, 30*scale)
			end
		end
	end
end

local round_white = 0
local round_alpha = 255
local round_num = 0 --nz.Rounds.Data.CurrentRound or 0
local function RoundHud()

	local text = ""
	local font = "nz.display.hud.rounds"
	local w = 70
	local h = ScrH() - 30
	local round = round_num
	local col = Color(200 + round_white*55, round_white, round_white,round_alpha)
	if round < 11 then
		for i = 1, round do
			if i == 5 or i == 10 then
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
	draw.SimpleText(text, font, w, h, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

end

local roundchangeending = false
local function StartChangeRound()

	print(Round:GetNumber())

	if Round:GetNumber() >= 1 then
		surface.PlaySound("nz/round/round_end.mp3")
	else
		round_num = 0
	end

	roundchangeending = false
	round_white = 0
	local round_charger = 0.25
	local alphafading = false
	local haschanged = false
	hook.Add("HUDPaint", "nz_roundnumWhiteFade", function()
		if !alphafading then
			round_white = math.Approach(round_white, round_charger > 0 and 255 or 0, round_charger*350*FrameTime())
			if round_white >= 255 and !roundchangeending then
				alphafading = true
				round_charger = -1
			elseif round_white <= 0 and roundchangeending then
				hook.Remove("HUDPaint", "nz_roundnumWhiteFade")
			end
		else
			round_alpha = math.Approach(round_alpha, round_charger > 0 and 255 or 0, round_charger*350*FrameTime())
			if round_alpha >= 255 then
				if haschanged then
					round_charger = -0.25
					alphafading = false
				else
					round_charger = -1
				end
			elseif round_alpha <= 0 then
				if roundchangeending then
					round_num = Round:GetNumber()
					round_charger = 0.5
					surface.PlaySound("nz/round/round_start.mp3")
					haschanged = true
				else
					round_charger = 1
				end
			end
		end
	end)

end

local function EndChangeRound()
	roundchangeending = true
end

local grenade_icon = Material("grenade-256.png", "unlitgeneric smooth")
local function DrawGrenadeHud()
	local num = LocalPlayer():GetAmmoCount("nz_specialgrenade")
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
	--surface.DrawTexturedRect(ScrW()/2, ScrH()/2, 100, 100)
end

//Hooks
hook.Add("HUDPaint", "roundHUD", StatesHud )
hook.Add("HUDPaint", "scoreHUD", ScoreHud )
hook.Add("HUDPaint", "gunHUD", GunHud )
hook.Add("HUDPaint", "powerupHUD", PowerUpsHud )
hook.Add("HUDPaint", "pointsNotifcationHUD", DrawPointsNotification )
hook.Add("HUDPaint", "perksHUD", PerksHud )
hook.Add("HUDPaint", "vultureVision", VultureVision )
hook.Add("HUDPaint", "roundnumHUD", RoundHud )
hook.Add("HUDPaint", "grenadeHUD", DrawGrenadeHud )

hook.Add("OnRoundPreperation", "BeginRoundHUDChange", StartChangeRound)
hook.Add("OnRoundStart", "EndRoundHUDChange", EndChangeRound)

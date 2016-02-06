//Useful ToScreen replacement for better directional
function XYCompassToScreen(pos, boundary)
	local boundary = boundary or 0
	local eyedir = EyeVector()
	local w = ScrW() - boundary
	local h = ScrH() - boundary
	local dir = (pos - EyePos()):GetNormalized()
	dir = Vector(dir.x, dir.y, 0)
	eyedir = Vector(eyedir.x, eyedir.y, 0)
	
	eyedir:Rotate(Angle(0,-90,0))
	local newdirx = eyedir:Dot(dir)
	--draw.SimpleText(newdirx, "nz.display.hud.small", ScrW()/2, ScrH() - 50, Color(255, 255, 255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	
	return ScrW()/2 + (newdirx*w/2), math.Clamp(pos:ToScreen().y, boundary, h)
end

local tab = {
 [ "$pp_colour_addr" ] = 0,
 [ "$pp_colour_addg" ] = 0,
 [ "$pp_colour_addb" ] = 0,
 [ "$pp_colour_brightness" ] = 0,
 [ "$pp_colour_contrast" ] = 1,
 [ "$pp_colour_colour" ] = 1,
 [ "$pp_colour_mulr" ] = 0,
 [ "$pp_colour_mulg" ] = 0,
 [ "$pp_colour_mulb" ] = 0
} 
local fade = 1

local mat_revive = Material("materials/revive.png", "unlitgeneric smooth")

function nz.Revive.Functions.ResetColorFade()
	tab = {
		 [ "$pp_colour_addr" ] = 0,
		 [ "$pp_colour_addg" ] = 0,
		 [ "$pp_colour_addb" ] = 0,
		 [ "$pp_colour_brightness" ] = 0,
		 [ "$pp_colour_contrast" ] = 1,
		 [ "$pp_colour_colour" ] = 1,
		 [ "$pp_colour_mulr" ] = 0,
		 [ "$pp_colour_mulg" ] = 0,
		 [ "$pp_colour_mulb" ] = 0
	}
	fade = 1
	
	--print("Color reset!")
end

function nz.Revive.Functions.CalcDownView(ply, pos, ang, fov, znear, zfar)
	if !nz.Revive.Data.Players[LocalPlayer()] then return end
	
	local pos = pos + Vector(0,0,-30)
	local ang = ang + Angle(0,0,20)
	
	return {origin = pos, angles = ang, fov = fov, znear = znear, zfar = zfar, drawviewer = false }
end

function nz.Revive.Functions.CalcDownViewmodelView(wep, vm, oldpos, oldang, pos, ang)
	if !nz.Revive.Data.Players[LocalPlayer()] then return end
	
	local oldpos = oldpos + Vector(0,0,-30)
	local oldang = oldang + Angle(0,0,20)
	
	return oldpos, oldang
end

function nz.Revive.Functions.DrawColorModulation()
	if !nz.Revive.Data.Players[LocalPlayer()] then return end
	
	local fadeadd = ((1/nz.Config.DownTime) * FrameTime()) * -1 	//Change 45 to the revival time
	tab[ "$pp_colour_colour" ] = math.Approach(tab[ "$pp_colour_colour" ], 0, fadeadd)
	tab[ "$pp_colour_brightness" ] = math.Approach(tab[ "$pp_colour_brightness" ], -0.5, fadeadd * 0.5)
	
	--print(fadeadd, tab[ "$pp_colour_colour" ], tab[ "$pp_colour_brightness" ]) 
	DrawColorModify(tab)
end

function surface.DrawTexturedRectRotatedPoint( x, y, w, h, rot, x0, y0 )

	local c = math.cos( math.rad( rot ) )
	local s = math.sin( math.rad( rot ) )

	local newx = y0 * s - x0 * c
	local newy = y0 * c + x0 * s

	surface.DrawTexturedRectRotated( x + newx, y + newy, w, h, rot )

end

function nz.Revive.Functions.DrawDownedPlayers()
	
	for k,v in pairs(nz.Revive.Data.Players) do
		if k == LocalPlayer() then return end
		local posxy = (k:GetPos() + Vector(0,0,35)):ToScreen()
		local dir = ((k:GetPos() + Vector(0,0,35)) - EyeVector()*2):GetNormal():ToScreen()
		--print(posxy["x"], posxy["y"], posxy["visible"])
		
		if posxy.x - 35 < 60 or posxy.x - 35 > ScrW()-130 or posxy.y - 50 < 60 or posxy.y - 50 > ScrH()-110 then
			posxy.x, posxy.y = XYCompassToScreen((k:GetPos() + Vector(0,0,35)), 60)
		end
		
		surface.SetMaterial(mat_revive)
		if v.ReviveTime then
			surface.SetDrawColor(255, 255, 255)
		else
			surface.SetDrawColor(255, 150 - (CurTime() - v.DownTime)*(150/nz.Config.DownTime), 0)
		end
		
		--draw.SimpleText(v.ReviveTime and "REVIVING" or "DOWNED", font, posxy["x"], posxy["y"] + 10, v.ReviveTime and Color(255,255,255) or Color(200, 0, 0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		--draw.SimpleText(k:Nick(), font2, posxy["x"], posxy["y"] - 20, v.ReviveTime and Color(255,255,255) or Color(200, 0, 0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		
		surface.DrawTexturedRect(posxy.x - 35, posxy.y - 50, 70, 50)
		
	end
end

function nz.Revive.Functions.DrawRevivalProgress()
	local tr = util.QuickTrace(LocalPlayer():EyePos(), LocalPlayer():GetAimVector()*100, LocalPlayer())
	local dply = tr.Entity
	
	local revtime = LocalPlayer():HasPerk("revive") and 2 or 5
	
	if IsValid(dply) and nz.Revive.Data.Players[dply] and nz.Revive.Data.Players[dply].RevivePlayer == LocalPlayer() then
		surface.SetDrawColor(0,0,0)
		surface.DrawRect(ScrW()/2 - 150, ScrH() - 300, 300, 20)
		
		surface.SetDrawColor(255,255,255)
		surface.DrawRect(ScrW()/2 - 145, ScrH() - 295, 290 * (CurTime()-nz.Revive.Data.Players[dply].ReviveTime)/revtime, 10)
	end
end

function nz.Revive.Functions.DrawDownedNotify()

	if !LocalPlayer():GetNotDowned() then
		local text = "YOU NEED HELP!"
		local font = "nz.display.hud.main"
		local rply = nz.Revive.Data.Players[LocalPlayer()].RevivePlayer
		
		if IsValid(rply) and rply:IsPlayer() then
			text = rply:Nick().." is reviving you!"
		end
		draw.SimpleText(text, font, ScrW() / 2, ScrH() * 0.85, Color(200, 0, 0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

end

function nz.Revive.Functions.DownedHeadsUp(ply, wasrevived)
	nz.Revive.Data.Notify[ply] = {time = CurTime(), revive = wasrevived}
	PrintTable(nz.Revive.Data.Notify[ply])
end

function nz.Revive.Functions.DrawDownedHeadsUp()
	local font = "nz.display.hud.small"
	local h = 40
	local offset = 20
	local max = 2
	local c = 0
	--table.SortByMember(nz.Revive.Data.Notify, "time")
	
	for k,v in pairs(nz.Revive.Data.Notify) do
		local fade = math.Clamp(CurTime() - v.time - 5, 0, 1)
		local status = " needs to be revived!"
		if v.revive == 1 then
			status = " has been revived!"
		elseif v.revive == 2 then
			status = " has died!"
		end
		draw.SimpleText(k:Nick()..status, font, ScrW()/2, ScrH() - h - offset * c, Color(255, 255, 255,255-(255*fade)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		if fade >= 1 then nz.Revive.Data.Notify[k] = nil end
		c = c + 1
	end
end

CreateClientConVar("nz_bloodoverlay", 1, true, false)

local blood_overlay = Material("materials/overlay_low_health.png", "unlitgeneric smooth")
local bloodpulse = true //if true, going up
local pulse = 0
function nz.Revive.Functions.DrawDamagedOverlay()
	if !GetConVar("nz_bloodoverlay"):GetBool() then return end
	if !LocalPlayer():Alive() then return end

	local fade = (math.Clamp(LocalPlayer():Health()/LocalPlayer():GetMaxHealth(), 0.2, 0.5)-0.2)/0.3
	local fade2 = 1 - math.Clamp(LocalPlayer():Health()/LocalPlayer():GetMaxHealth(), 0, 0.5)/0.5
	
	surface.SetMaterial(blood_overlay)
	surface.SetDrawColor(255,255,255,255-fade*255)
	surface.DrawTexturedRect( -10, -10, ScrW()+20, ScrH()+20)
	
	if fade2 > 0 then
		if bloodpulse then
			pulse = math.Approach(pulse, 255, math.Clamp(pulse, 1, 50)*FrameTime()*100)
			if pulse >= 255 then bloodpulse = false end
		else
			if pulse <= 0 then bloodpulse = true end
			pulse = math.Approach(pulse, 0, -255*FrameTime())
		end
		surface.SetDrawColor(255,255,255,pulse*fade2)
		surface.DrawTexturedRect( -10, -10, ScrW()+20, ScrH()+20)
	end
end

hook.Add( "HUDShouldDraw", "HideHUD", function( name )
	if name == "CHudHealth" then return !GetConVar("nz_bloodoverlay"):GetBool() end
end )

function nz.Revive.Functions.DrawTombstoneNotify()
	local font = "nz.display.hud.small"
	
	if LocalPlayer():GetDownedWithTombstone() then
		local text = "Hold E to feed the zombies"
		draw.SimpleText(text, font, ScrW()/2, ScrH() - 320, Color(255, 255, 255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

local tombstonetime = nil
local senttombstonerequest = false

function nz.Revive.Functions.DrawTombstoneProgress()
	if LocalPlayer():GetDownedWithTombstone() then
	
		local killtime = 1
		
		if LocalPlayer():KeyDown(IN_USE) then
			if !tombstonetime then
				tombstonetime = CurTime()
			end
			
			local pct = math.Clamp((CurTime()-tombstonetime)/killtime, 0, 1)
			
			surface.SetDrawColor(0,0,0)
			surface.DrawRect(ScrW()/2 - 150, ScrH() - 300, 300, 20)
			
			surface.SetDrawColor(255,255,255)
			surface.DrawRect(ScrW()/2 - 145, ScrH() - 295, 290 * pct, 10)
			if pct >= 1 and !senttombstonerequest then
				net.Start("nz_TombstoneSuicide")
				net.SendToServer()
				senttombstonerequest = true
			end
		else
			tombstonetime = nil
			senttombstonerequest = false
		end
	end
end

local whoswhoactive = false
net.Receive("nz_WhosWhoActive", function()
	whoswhoactive = net.ReadBool()
end)
local whoswhomat = "models/shadertest/shader4"

function nz.Revive.Functions.DrawWhosWhoOverlay()
	if !whoswhoactive then return end
	DrawMaterialOverlay(whoswhomat, 0.03)
end

//Hooks
hook.Add("CalcView", "CalcDownedView", nz.Revive.Functions.CalcDownView )
hook.Add("CalcViewModelView", "CalcDownedViewmodelView", nz.Revive.Functions.CalcDownViewmodelView )
hook.Add("RenderScreenspaceEffects", "DrawColorModulation", nz.Revive.Functions.DrawColorModulation)
hook.Add("HUDPaint", "DrawDamageOverlay", nz.Revive.Functions.DrawDamagedOverlay)
hook.Add("HUDPaint", "DrawDownedPlayers", nz.Revive.Functions.DrawDownedPlayers )
hook.Add("HUDPaint", "DrawDownedNotify", nz.Revive.Functions.DrawDownedNotify )
hook.Add("HUDPaint", "DrawRevivalProgress", nz.Revive.Functions.DrawRevivalProgress )
hook.Add("HUDPaint", "DrawDownedPlayersNotify", nz.Revive.Functions.DrawDownedHeadsUp )
hook.Add("HUDPaint", "DrawTombstoneNotify", nz.Revive.Functions.DrawTombstoneNotify )
hook.Add("HUDPaint", "DrawTombstoneProgress", nz.Revive.Functions.DrawTombstoneProgress )
hook.Add("RenderScreenspaceEffects", "DrawWhosWhoOverlay", nz.Revive.Functions.DrawWhosWhoOverlay )
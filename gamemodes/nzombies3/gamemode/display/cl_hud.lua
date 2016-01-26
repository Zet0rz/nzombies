//

local bloodline_points = Material("bloodline_score.png", "unlitgeneric smooth")

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
	if nz.Rounds.Data.CurrentState == ROUND_PREP or nz.Rounds.Data.CurrentState == ROUND_PROG or nz.Rounds.Data.CurrentState == ROUND_INIT then
		for k,v in pairs(player.GetAll()) do
			local hp = v:Health()
			if hp == 0 then hp = "Dead" elseif nz.Revive.Data.Players[v] then hp = "Downed" else hp = hp .. " HP"  end
			if v:GetPoints() >= 0 then 
				surface.SetMaterial(bloodline_points)
				surface.SetDrawColor(255,255,255)
				surface.DrawTexturedRect(ScrW() - 325 - #v:Nick()*10, ScrH() - 265 + (30*k), 250 + #v:Nick()*10, 35)
				draw.SimpleText(v:GetPoints().." - "..v:Nick().." (" .. hp ..  ")", "nz.display.hud.small", ScrW() - 100, ScrH() - 250 + (30*k), Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
				v.PointsSpawnPosition = {x = ScrW() - 325 - #v:Nick()*10, y = ScrH() - 250 + (30*k)}
			end
		end
	end
	if LocalPlayer():GetActiveWeapon():IsValid() and nz.Rounds.Data.CurrentState == ROUND_CREATE then
		draw.SimpleText(LocalPlayer():GetActiveWeapon():GetClass(), "nz.display.hud.small", ScrW() * 0.8, ScrH() - 70, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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

//Hooks
hook.Add("HUDPaint", "roundHUD", nz.Display.Functions.StatesHud )
hook.Add("HUDPaint", "scoreHUD", nz.Display.Functions.ScoreHud )
hook.Add("HUDPaint", "powerupHUD", nz.Display.Functions.PowerUpsHud )
hook.Add("HUDPaint", "pointsNotifcationHUD", nz.Display.Functions.DrawPointsNotification )
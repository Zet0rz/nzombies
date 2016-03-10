//

local traceents = {
	["wall_buys"] = function(ent)
		local wepclass = ent:GetEntName()
		local price = ent:GetPrice()
		local wep = weapons.Get(wepclass)
		if !wep then return "INVALID WEAPON" end
		local name = wep.PrintName
		local ammo_price = math.Round((price - (price % 10))/2)
		local text = ""
		
		if !LocalPlayer():HasWeapon( wepclass ) then
			text = "Press E to buy " .. name .." for " .. price .. " points."
		elseif LocalPlayer():GetWeapon( wepclass ).pap then
			text = "Press E to buy " .. wep.Primary.Ammo .."  Ammo refill for " .. 4500 .. " points."
		else
			text = "Press E to buy " .. wep.Primary.Ammo .."  Ammo refill for " .. ammo_price .. " points."
		end
		
		return text
	end,
	["breakable_entry"] = function(ent)
		if ent:GetNumPlanks() < nz.Config.MaxPlanks then
			local text = "Hold E to rebuild the barricade."
			return text
		end
	end,
	["random_box"] = function(ent)
		if !ent:GetOpen() then
			local text = nz.PowerUps.Functions.IsPowerupActive("firesale") and "Press E to buy a random weapon for 10 points." or "Press E to buy a random weapon for 950 points."
			return text
		end
	end,
	["random_box_windup"] = function(ent)
		if !ent:GetWinding() and ent:GetWepClass() != "nz_box_teddy" then
			local wepclass = ent:GetWepClass()
			local wep = weapons.Get(wepclass)
			local name = "UNKNOWN"
			if wep != nil then
				name = wep.PrintName
			end
			if name == nil then name = wepclass end
			name = "Press E to take " .. name .. " from the box."
			
			return name
		end
	end,
	["perk_machine"] = function(ent)
		local text = ""
		if !ent:IsOn() then
			text = "No Power."
		elseif ent:GetBeingUsed() then
			text = "Currently in use."
		else
			local perkData = nz.Perks.Functions.Get(ent:GetPerkID())
			-- Its on
			text = "Press E to buy " .. perkData.name .. " for " .. perkData.price .. " points."
			-- Check if they already own it
			if LocalPlayer():HasPerk(ent:GetPerkID()) then
				text = "You already own this perk."
			end
		end
		
		return text
	end,
	["player_spawns"] = function() if Round:InState( ROUND_CREATE ) then return "Player Spawn" end end,
	["zed_spawns"] = function() if Round:InState( ROUND_CREATE ) then return "Zombie Spawn" end end,
	["pap_weapon_trigger"] = function(ent)
		local wepclass = ent:GetWepClass()
		local wep = weapons.Get(wepclass)
		local name = "UNKNOWN"
		if wep != nil then
			name = nz.Display_PaPNames[wepclass] or nz.Display_PaPNames[name] or "Upgraded "..wep.PrintName
		end
		name = "Press E to take " .. name .. " from the machine."
		
		return name
	end,
}

local function GetTarget()
	local tr =  {
		start = EyePos(),
		endpos = EyePos() + LocalPlayer():GetAimVector()*150,
		filter = LocalPlayer(),
	}
	local trace = util.TraceLine( tr )
	if (!trace.Hit) then return end
	if (!trace.HitNonWorld) then return end

	--print(trace.Entity:GetClass())
	return trace.Entity
end

local function GetDoorText( ent )
	local door_data = ent:GetDoorData()
	local text = ""
	
	if door_data and tonumber(door_data.buyable) == 1 then
		local price = tonumber(door_data.price)
		local req_elec = tobool(door_data.elec)
		local link = door_data.link
		
		if ent:IsLocked() then
			if req_elec and !IsElec() then
				text = "You must turn on the electricity first!"
			elseif door_data.text then
				text = door_data.text
			elseif price != 0 then
				--print("Still here", nz.Doors.Data.OpenedLinks[tonumber(link)])
				text = "Press E to open for " .. price .. " points."
			end
		end
	elseif door_data and tonumber(door_data.buyable) != 1 and Round:InState( ROUND_CREATE ) then
		text = "This door is locked and cannot be bought in-game."
		--PrintTable(door_data)
	end
	
	return text
end

local function GetText( ent )

	local class = ent:GetClass()
	local text = ""

	if ent:IsPlayer() then
		if ent:GetNotDowned() then
			text = ent:Nick() .. " - " .. ent:Health() .. " HP"
		else
			text = "Hold E to revive "..ent:Nick()
		end
	elseif ent:IsDoor() or ent:IsButton() or ent:GetClass() == "class C_BaseEntity" or ent:IsBuyableProp() then
		text = GetDoorText(ent)
	else
		text = traceents[class] and traceents[class](ent)
	end

	return text
end

local function GetMapScriptEntityText()
	local text = ""
	
	for k,v in pairs(ents.FindByClass("nz_triggerzone")) do
		local dist = v:NearestPoint(EyePos()):Distance(EyePos())
		if dist <= 1 then
			text = GetDoorText(v)
			break
		end
	end
	
	return text
end

local function DrawTargetID( text )

	local font = "nz.display.hud.small"
	surface.SetFont( font )
	local w, h = surface.GetTextSize( text )

	local MouseX, MouseY = gui.MousePos()

	if ( MouseX == 0 && MouseY == 0 ) then

		MouseX = ScrW() / 2
		MouseY = ScrH() / 2

	end

	local x = MouseX
	local y = MouseY

	x = x - w / 2
	y = y + 30

	-- The fonts internal drop shadow looks lousy with AA on
	draw.SimpleText( text, font, x+1, y+1, Color(255,255,255,255) )
end


function GM:HUDDrawTargetID()

	local ent = GetTarget()

	if ent != nil then
		DrawTargetID(GetText(ent))
	else
		DrawTargetID(GetMapScriptEntityText())
	end

end

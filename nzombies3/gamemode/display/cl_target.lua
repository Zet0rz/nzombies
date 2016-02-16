//

local traceents = {
	["wall_buys"] = true,
	["breakable_entry"] = true,
	["random_box"] = true,
	["random_box_windup"] = true,
	["perk_machine"] = true,
	["player_spawns"] = true,
	["zed_spawns"] = true,
	["pap_weapon_fly"] = true,
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

local function GetText( ent )

	local class = ent:GetClass()
	local text = ""

	if ent:IsPlayer() then
		if ent:GetNotDowned() then
			text = ent:Nick() .. " - " .. ent:Health() .. " HP"
		else
			text = "Hold E to revive "..ent:Nick()
		end
	end

	if class == "whoswho_downed_clone" then
		text = "Hold E to revive "..ent:GetPerkOwner():Nick()
	end

	if class == "wall_buys" then
		local wepclass = ent:GetEntName()
		local price = ent:GetPrice()
		local wep = weapons.Get(wepclass)
		local name = wep.PrintName
		local ammo_price = math.Round((price - (price % 10))/2)
		
		if !LocalPlayer():HasWeapon( wepclass ) then
			text = "Press E to buy " .. name .." for " .. price .. " points."
		elseif LocalPlayer():GetWeapon( wepclass ).pap then
			text = "Press E to buy " .. wep.Primary.Ammo .."  Ammo refill for " .. 4500 .. " points."
		else
			text = "Press E to buy " .. wep.Primary.Ammo .."  Ammo refill for " .. ammo_price .. " points."
		end
	end

	if class == "breakable_entry" then
		if ent:GetNumPlanks() < nz.Config.MaxPlanks then
			text = "Hold E to rebuild the barricade."
		end
	end

	if class == "random_box" then
		if !ent:GetOpen() then
			text = nz.PowerUps.Functions.IsPowerupActive("firesale") and "Press E to buy a random weapon for 10 points." or "Press E to buy a random weapon for 950 points."
		end
	end

	if class == "random_box_windup" then
		if !ent:GetWinding() and ent:GetWepClass() != "nz_box_teddy" then
			local wepclass = ent:GetWepClass()
			local wep = weapons.Get(wepclass)
			local name = "UNKNOWN"
			if wep != nil then
				name = wep.PrintName
			end
			if name == nil then name = wepclass end
			text = "Press E to take " .. name .. " from the box."
		end
	end

	if class == "pap_weapon_trigger" then
		local wepclass = ent:GetWepClass()
		local wep = weapons.Get(wepclass)
		local name = "UNKNOWN"
		if wep != nil then
			name = wep.PrintName
		end
		if name == nil then name = wepclass end
		text = "Press E to take " .. name .. " from the machine."
	end

	if class == "perk_machine" then
		if !ent:IsOn() then
			text = "No Power."
		elseif ent:GetBeingUsed() then
			text = "Currently in use."
		else
			local perkData = nz.Perks.Functions.Get(ent:GetPerkID())
			//Its on
			text = "Press E to buy " .. perkData.name .. " for " .. perkData.price .. " points."
			//Check if they already own it
			if LocalPlayer():HasPerk(ent:GetPerkID()) then
				text = "You already own this perk."
			end
		end
	end

	local door_data = nil

	if ent:IsDoor() or ent:IsButton() or ent:GetClass() == "class C_BaseEntity" or ent:IsBuyableProp() then
		-- Door data
		door_data = ent:GetDoorData()
	end

	//If we have door data - Don't draw target ID if the door can't even be bought
	if door_data != nil and tonumber(door_data.buyable) == 1 then
		local price = door_data.price
		local req_elec = door_data.elec
		local link = door_data.link
		if req_elec == "1" and !IsElec() then
			text = "You must turn on the electricity first!"
		else
			if ent:IsLocked() then
				if price != "0" then
					--print("Still here", nz.Doors.Data.OpenedLinks[tonumber(link)])
					text = "Press E to open for " .. price .. " points."
				end
			end
		end
	elseif door_data != nil and tonumber(door_data.buyable) != 1 and Round:InState( ROUND_CREATE ) then
		text = "This door is locked and cannot be bought in-game."
		--PrintTable(door_data)
	end

	//Create Only
	if Round:InState( ROUND_CREATE ) then
		if class == "player_spawns" then
			text = "Player Spawn"
		end

		if class == "player_handler" then
			text = "Player Handler"
		end

		if class == "random_box_handler" then
			text = "Random Box Weapons Handler"
		end

		if class == "zed_spawns" then
			text = "Zombie Spawn"
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
	end

end

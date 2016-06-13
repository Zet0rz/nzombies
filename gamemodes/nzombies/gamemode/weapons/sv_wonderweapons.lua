local wonderweapons = {}

-- Wonder Weapon system does NOT apply to weapons like Monkey Bombs or Ray Gun
-- ONLY to those that you can only have 1 of at a time

function nzWeps:AddWonderWeapon(class)
	wonderweapons[class] = true
end

function nzWeps:RemoveWonderWeapon(class)
	wonderweapons[class] = nil
end

function nzWeps:IsWonderWeapon(class)
	return wonderweapons[class] or false
end

function nzWeps:GetHeldWonderWeapons(ply) -- No arguments means all players
	local tbl = {}
	if IsValid(ply) and ply:IsPlayer() then
		for k,v in pairs(ply:GetWeapons()) do
			if wonderweapons[v:GetClass()] then
				table.insert(tbl, v:GetClass())
			end
		end
	else
		for k,v in pairs(player.GetAll()) do
			for k2,v2 in pairs(v:GetWeapons()) do
				if wonderweapons[v2:GetClass()] then
					table.insert(tbl, v2:GetClass())
				end
			end
		end
	end
	
	return tbl
end

function nzWeps:IsWonderWeaponOut(class, ignorewonder)
	if (wonderweapons[class] or ignorewonder) then
		for k,v in pairs(player.GetAll()) do
			for k2,v2 in pairs(v:GetWeapons()) do
				local vclass = v2:GetClass()
				if vclass == class then
					return true
				end
			end
		end
		
		for k,v in pairs(ents.FindByClass("random_box_windup")) do -- We also gotta check active random boxes
			if v:GetWepClass() == class then
				return true
			end
		end
	end
	return false
end

-- Now let's add some!
nzWeps:AddWonderWeapon("freeze_gun")
nzWeps:AddWonderWeapon("wunderwaffe")
nzWeps:AddWonderWeapon("weapon_hoff_thundergun")
nzWeps:AddWonderWeapon("weapon_teslagun")

-- We can also add all weapons which have SWEP.NZWonderWeapon = true set in their files
hook.Add("InitPostEntity", "nzRegisterWonderWeaponsByKey", function()
	for k,v in pairs(weapons.GetList()) do
		-- Add Wonder Weapons to the list
		if v.NZWonderWeapon then nzWeps:AddWonderWeapon(v.ClassName) end
		-- If it has a PaP replacement, blacklist that weapon so it can't be gotten in the box
		if v.NZPaPReplacement then nzConfig.AddWeaponToBlacklist(v.NZPaPReplacement) end
		-- Total blacklisted weapons also need to be added to the box blacklist
		if v.NZTotalBlacklist then nzConfig.AddWeaponToBlacklist(v.ClassName) end
	end	
end)

-- More wonder weapons should be added by map scripts for their map - if you think you have one that should officially apply to all maps, add me
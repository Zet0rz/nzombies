if not ConVarExists("nz_papattachments") then CreateConVar("nz_papattachments", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Whether Pack-a-Punching a CW2.0 weapon will attach random attachments for each category. Will also strip players of attachments at the beginning of the game.") end

hook.Add("PlayerSpawn", "RemoveCW2Attachments", function(ply)
	if GetConVar("nz_papattachments"):GetBool() and CustomizableWeaponry then
		for k,v in pairs(ply.CWAttachments) do
			CustomizableWeaponry:removeAttachment(ply, k)
		end
	end
end)

function GetPriorityWeaponSlot(ply)
	-- Create some variables to use
	local maxnum = ply:HasPerk("mulekick") and 3 or 2
	local tbl = {}
	local first
	
	-- Loop through weapons
	for k,v in pairs(ply:GetWeapons()) do
		local slot = v:GetNWInt("SwitchSlot")
		-- Mark this slot as being used
		tbl[slot] = true
		-- Also save whichever weapon has slot 1 in case the activeweapon doesnt have a slot
		if slot == 1 then first = v end
	end
	-- Now loop through the maxnumber we can have
	for i = 1, maxnum do
		-- If this slot hasn't been taken, return it
		if !tbl[i] then return i end
	end
	-- If we didn't return before (all slots taken), check the activeweapon
	local activewep = ply:GetActiveWeapon()
	local id = activewep:GetNWInt("SwitchSlot")
	-- Only replace it if it has an ID (default is 0)
	if id > 0 then
		return id, activewep
	end
	-- Else we should return the weapon stored in slot 1, if nothing at all just return slot 1 alone
	if first then return 1, first else return 1 end
end

local function OnWeaponAdded( weapon )

	if !weapon:IsSpecial() then
		weapon.Weight = 10000
		-- 0 seconds timer for the next tick, where the weapon's owner will be valid
		timer.Simple(0, function()
			local ply = weapon:GetOwner()
			if !nzRound:InState( ROUND_CREATE ) then
				local slot, exists = GetPriorityWeaponSlot(ply)
				if IsValid(exists) then ply:StripWeapon( exists:GetClass() ) end
				
				weapon:SetNWInt( "SwitchSlot", slot )
				local oldammo = weapon.Primary.Ammo
				local newammo = weapon:GetPrimaryAmmoType() -- Get the ammo ID used for this weapon slot
				weapon.Primary.Ammo = game.GetAmmoName(newammo) -- Set ammo type to the ammo type designated by this slot!
				weapon.Primary.OldAmmo = oldammo -- Save the old ammo (just in case)
				--weapon:GiveMaxAmmo() We can't do this! PaP should NOT give ammo when rerolling!
				
				weapon.Weight = 10000
				ply:SelectWeapon(weapon:GetClass())
				timer.Simple(0, function()
					if IsValid(ply) then
						if ply:HasPerk("speed") then
							weapon:ApplyNZModifier("speed")
						end
						if ply:HasPerk("dtap") or ply:HasPerk("dtap2") then
							weapon:ApplyNZModifier("dtap")
						end
						if !weapon.NoSpawnAmmo then
							weapon:GiveMaxAmmo()
						end
						ply:SelectWeapon(weapon:GetClass())
					end
					weapon.Weight = 0
				end)
			end
			if weapon.NearWallEnabled then weapon.NearWallEnabled = false end
			if weapon:IsFAS2() then weapon.NoNearWall = true end
			
			weapon:ApplyNZModifier("equip")
		end)
	end
	
end

--Hooks
hook.Add("WeaponEquip", "nzOnWeaponAdded", OnWeaponAdded)

hook.Add("PlayerCanPickupWeapon", "PreventWhosWhoWeapons", function(ply, wep)
	if IsValid(wep:GetOwner()) and wep:GetOwner():GetClass() == "whoswho_downed_clone" then return false end
end)

-- Meta stuff
local meta = FindMetaTable("Player")
function meta:GiveNoAmmo(class)
	local wep = self:Give(class)
	if IsValid(wep) then wep.NoSpawnAmmo = true end
	return wep
end
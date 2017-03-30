nzSpecialWeapons.Modifiers = nzSpecialWeapons.Modifiers or {}

function nzSpecialWeapons:RegisterModifier(id, func, defaultdata)
	nzSpecialWeapons.Modifiers[id] = {func, defaultdata}
end

function nzSpecialWeapons:ModifyWeapon(wep, id, data)
	local tbl = nzSpecialWeapons.Modifiers[id]
	if !tbl then return end
	
	local pass = {}
	local default = tbl[2]
	
	if !data then pass = default else
		for k,v in pairs(default) do
			if data[k] != nil then -- ONLY if nil (not passed)
				pass[k] = data[k]
			else
				pass[k] = v
			end
		end
	end
	
	local bool = tbl[1](wep, pass) -- Run the function with the data, return whether it worked or not
	if bool then
		wep.NZSpecialWeaponData = pass
		wep.NZSpecialCategory = id -- Mark as special from now on
		
		if isentity(wep) then -- Reregister it on the player if it is currently being carried
			wep:SetNWInt( "SwitchSlot", nil ) -- Reset weapon slot
			local ply = wep:GetOwner()
			if IsValid(ply) then
				hook.Run("WeaponEquip", wep) -- Rerun weapon equip logic (resets slots etc)
				ply:EquipPreviousWeapon() -- Equip previous weapon
			end
		end
	end
	
	return bool
end

nzSpecialWeapons:RegisterModifier("knife", function(wep, data)
	if wep then
		local attackholstertime = data.AttackHolsterTime
		local drawholstertime = data.DrawHolsterTime
	
		local oldattack = wep.PrimaryAttack
		function wep:PrimaryAttack()
			if self.nzCanAttack then
				oldattack(self)
				self.nzCanAttack = false
			end
		end
		
		--local olddeploy = wep.Deploy
		wep.EquipDraw = wep.Deploy
		
		function wep:Deploy()
			local ct = CurTime()
			if !self.nzIsDrawing then
				self.nzCanAttack = true
				self.nzHolsterTime = ct + attackholstertime
				self:SendWeaponAnim(ACT_VM_IDLE)
				self:SetNextPrimaryFire(0)
				
				if self.SetStatus then
					self:SetStatus(TFA.Enum.STATUS_IDLE)
				end
				
				self:PrimaryAttack()
			else
				self.nzHolsterTime = ct + drawholstertime
			end
			self.nzIsDrawing = nil
		end
	
		local oldthink = wep.Think
		function wep:Think()
			local ct = CurTime()
			
			--[[if self.nzAttackTime and ct > self.nzAttackTime then
				self:PrimaryAttack()
				self.nzAttackTime = nil
			end]]
			
			if self.nzHolsterTime and ct > self.nzHolsterTime and !self.Owner.nzSpecialButtonDown then
				self:Holster()
				self.Owner:SetUsingSpecialWeapon(false)
				self.Owner:EquipPreviousWeapon()
				self.nzHolsterTime = nil
			end
			
			oldthink(self)
		end
		
		local oldholster = wep.Holster
		function wep:Holster( wep2 )
			if SERVER then self.Owner:SetUsingSpecialWeapon(false) end
			return oldholster(self, wep2)
		end
		return true
	end
end, { -- Every field that isn't supplied from the data arg is taken from here instead
	AttackHolsterTime = 0.65,
	DrawHolsterTime = 1.5,
	DrawOnEquip = true,
})

nzSpecialWeapons:RegisterModifier("grenade", function(wep, data)
	if wep then
		local drawact = data.DrawAct
		local throwtime = data.ThrowTime
		local throwfunc = data.ThrowFunction
		local holstertime = data.HolsterTime
	
		wep.EquipDraw = wep.Deploy
		
		function wep:Deploy()
			local ct = CurTime()
			self.nzThrowTime = ct + throwtime
			
			if !drawact then
				self:EquipDraw() -- Use normal draw animation/function for not specifying throw act
			else
				self:SendWeaponAnim(drawact) -- Otherwise play the act (preferably pull pin act)
			end
			
		end
	
		local oldthink = wep.Think
		
		if !throwfunc then
			local primary = wep.PrimaryAttack
			throwfunc = function(self)
				primary(self)
				self.Owner:SetAmmo(self.Owner:GetAmmoCount(GetNZAmmoID("grenade")) - 1, GetNZAmmoID("grenade"))
			end
		end
		
		function wep:Think()
			local ct = CurTime()
			
			if self.nzThrowTime and ct > self.nzThrowTime and (!self.Owner.nzSpecialButtonDown or !self.Owner:GetNotDowned()) then
				self.nzThrowTime = nil
				self.nzHolsterTime = ct + holstertime
				throwfunc(self) -- If a function was specified (e.g. to run a certain func on the weapon), then do that
				-- The above function needs to subtract the grenade ammo (unless they're going for something special)
			end
			
			if self.nzHolsterTime and ct > self.nzHolsterTime then
				self.nzHolsterTime = nil
				self.Owner:SetUsingSpecialWeapon(false)
				self:Holster()
				self.Owner:EquipPreviousWeapon()
			end
			
			oldthink(self)
		end
		
		function wep:PrimaryAttack() end
		return true
	end
end, {
	MaxAmmo = 4,
	AmmoType = "nz_grenade",
	DrawAct = false, -- False/nil makes default
	ThrowTime = 0.85,
	ThrowFunction = false, -- False/nil uses default PrimaryAttack function
	HolsterTime = 0.4,
})

nzSpecialWeapons:RegisterModifier("specialgrenade", function(wep, data)
	if wep then
		local drawact = data.DrawAct
		local throwtime = data.ThrowTime
		local throwfunc = data.ThrowFunction
		local holstertime = data.HolsterTime
	
		wep.EquipDraw = wep.Deploy
		
		function wep:Deploy()
			local ct = CurTime()
			
			if !drawact then
				self:EquipDraw() -- Use normal draw animation/function for not specifying throw act
			else
				self:SendWeaponAnim(drawact) -- Otherwise play the act (preferably pull pin act)
			end
			self.nzThrowTime = ct + throwtime
		end
	
		local oldthink = wep.Think
		
		if !throwfunc then
			local primary = wep.PrimaryAttack
			throwfunc = function(self)
				primary(self)
				self.Owner:SetAmmo(self.Owner:GetAmmoCount(GetNZAmmoID("specialgrenade")) - 1, GetNZAmmoID("specialgrenade"))
			end
		end
		
		function wep:Think()
			local ct = CurTime()
			
			if self.nzThrowTime and ct > self.nzThrowTime and (!self.Owner.nzSpecialButtonDown or !self.Owner:GetNotDowned()) then
				self.nzThrowTime = nil
				self.nzHolsterTime = ct + holstertime
				throwfunc(self)
			end
			
			if self.nzHolsterTime and ct > self.nzHolsterTime then
				self.nzHolsterTime = nil
				self.Owner:SetUsingSpecialWeapon(false)
				self:Holster()
				self.Owner:EquipPreviousWeapon()
			end
			
			oldthink(self)
		end
		
		function wep:PrimaryAttack() end
		return true
	end
end, {
	MaxAmmo = 3,
	AmmoType = "nz_specialgrenade",
	DrawAct = false, -- False/nil makes default
	ThrowTime = 1.2,
	ThrowFunction = false, -- False/nil uses default PrimaryAttack function
	HolsterTime = 0.4,
})

nzSpecialWeapons:RegisterModifier("display", function(wep, data)
	if wep then
		local drawfunc = data.DrawFunction
		local returnfunc = data.ToHolsterFunction
	
		wep.EquipDraw = wep.Deploy
		
		if drawfunc then
			function wep:Deploy()
				local ct = CurTime()
				drawfunc(self) -- Drawfunc specified, overwrite deploy with this function
				self.nzDeployTime = ct -- Time when it was equipped, can be used for time comparisons
			end
		else
			function wep:Deploy()
				local ct = CurTime()
				self:EquipDraw() -- Not specified, use deploy function
				self.nzDeployTime = ct -- Time when it was equipped, can be used for time comparisons
			end
		end
	
		local oldthink = wep.Think
		
		function wep:Think()
			if returnfunc(self) then
				if SERVER then
					self.Owner:SetUsingSpecialWeapon(false)
				end
				self:Holster()
				self.Owner:EquipPreviousWeapon()
				if SERVER then
					self.Owner:StripWeapon(self:GetClass()) -- Always stripped when done with use
				end
			end
			
			oldthink(self)
		end
		return true
	end
end, {
	DrawFunction = false,
	ToHolsterFunction = function(wep)
		return SERVER and CurTime() > wep.nzDeployTime + 2.5 -- Default delay 2.5 seconds
	end,
})

-- Hardcodes the weapon by re-registering the weapon table after it's passed through normal modifications
function nzSpecialWeapons:AddKnife( class, drawonequip, attackholstertime, drawholstertime )
	local wep = weapons.Get(class)
	if wep then
		if nzSpecialWeapons:ModifyWeapon(wep, "knife", {AttackHolsterTime = attackholstertime, DrawHolsterTime = drawholstertime, DrawOnEquip = drawonequip}) then
			weapons.Register(wep, class)
		end
	end
end

function nzSpecialWeapons:AddGrenade( class, ammo, drawact, throwtime, throwfunc, holstertime )
	local wep = weapons.Get(class)
	if wep then
		if nzSpecialWeapons:ModifyWeapon(wep, "grenade", {MaxAmmo = ammo, DrawAct = drawact, ThrowTime = throwtime, ThrowFunction = throwfunc, HolsterTime = holstertime}) then
			weapons.Register(wep, class)
		end
	end
end

function nzSpecialWeapons:AddSpecialGrenade( class, ammo, drawact, throwtime, throwfunc, holstertime )
	local wep = weapons.Get(class)
	if wep then
		if nzSpecialWeapons:ModifyWeapon(wep, "specialgrenade", {MaxAmmo = ammo, DrawAct = drawact, ThrowTime = throwtime, ThrowFunction = throwfunc, HolsterTime = holstertime}) then
			weapons.Register(wep, class)
		end
	end
end

function nzSpecialWeapons:AddDisplay( class, drawfunc, returnfunc )
	local wep = weapons.Get(class)
	if wep then
		if nzSpecialWeapons:ModifyWeapon(wep, "display", {DrawFunction = drawfunc, ToHolsterFunction = returnfunc}) then
			weapons.Register(wep, class)
		end
	end
end

if CLIENT then
	CreateClientConVar("nz_key_knife", KEY_V, true, true, "Sets the key that triggers Knife. Uses numbers from gmod's KEY_ enums: http://wiki.garrysmod.com/page/Enums/KEY")
	CreateClientConVar("nz_key_grenade", KEY_G, true, true, "Sets the key that throws Grenades. Uses numbers from gmod's KEY_ enums: http://wiki.garrysmod.com/page/Enums/KEY")
	CreateClientConVar("nz_key_specialgrenade", KEY_B, true, true, "Sets the key that throws Special Grenades. Uses numbers from gmod's KEY_ enums: http://wiki.garrysmod.com/page/Enums/KEY")
	
	local defaultkeys = nzSpecialWeapons.Keys
	
	function GetSpecialWeaponIDFromInput()
		local ply = LocalPlayer()
		if !ply.NZSpecialWeapons then return end
		
		local id
		local wep
		
		for k,v in pairs(ply.NZSpecialWeapons) do
			local key = input.IsKeyDown(ply:GetInfoNum("nz_key_"..k, defaultkeys[k] or -1))
			if key then
				id = k
				wep = v
				break
			end
		end
		
		return id, wep
	end
	
	hook.Add("CreateMove", "nzSpecialWeaponSelect", function( cmd )
		if vgui.CursorVisible() then return end
		local ply = LocalPlayer()
		local id, wep = GetSpecialWeaponIDFromInput()
		if id and (ply:GetNotDowned() or id == "knife") and !ply:GetUsingSpecialWeapon() then
			local ammo = GetNZAmmoID(id)
			if !ammo or ply:GetAmmoCount(ammo) >= 1 then
				--local wep = ply:GetSpecialWeaponFromCategory( id )
				if IsValid(wep) then
					ply:SelectWeapon(wep:GetClass())
				end
			end
		end
	end)
	
	hook.Add("HUDWeaponPickedUp", "nzSpecialWeaponAddClient", function(wep)
		local ply = LocalPlayer()
		local id = IsValid(wep) and wep:IsSpecial() and wep:GetSpecialCategory()
		if !ply.NZSpecialWeapons then ply.NZSpecialWeapons = {} end
		if id and !IsValid(ply.NZSpecialWeapons[id]) then
			ply.NZSpecialWeapons[id] = wep
		end
	end)
end

hook.Add("PlayerButtonDown", "nzSpecialWeaponsHandler", function(ply, but)
	if but == ply:GetInfoNum("nz_key_knife", KEY_V) or
	but == ply:GetInfoNum("nz_key_grenade", KEY_G) or
	but == ply:GetInfoNum("nz_key_specialgrenade", KEY_B) then
		ply.nzSpecialButtonDown = true
	end
	
	if id and (ply:GetNotDowned() or id == "knife") and !ply:GetUsingSpecialWeapon() then
		
	end
end)

hook.Add("PlayerButtonUp", "nzSpecialWeaponsThrow", function(ply, but)
	--local id = buttonids[but]
	local id = but == ply:GetInfoNum("nz_key_knife", KEY_V) or but == ply:GetInfoNum("nz_key_grenade", KEY_G) or but == ply:GetInfoNum("nz_key_specialgrenade", KEY_B)
	if id and ply.nzSpecialButtonDown then
		ply.nzSpecialButtonDown = false
	end
end)

local wep = FindMetaTable("Weapon")
local ply = FindMetaTable("Player")

function wep:IsSpecial()
	return self.NZSpecialCategory and true or false
end

function wep:GetSpecialCategory()
	return self.NZSpecialCategory
end

function ply:GetSpecialWeaponFromCategory( id )
	if !self.NZSpecialWeapons then self.NZSpecialWeapons = {} end
	return self.NZSpecialWeapons[id] or nil
end

function ply:EquipPreviousWeapon()
	if IsValid(self.NZPrevWep) then -- If the previously used weapon is valid, use that
		if SERVER then
			self:SetActiveWeapon(nil)
		end
		self:SelectWeapon(self.NZPrevWep:GetClass())
	else
		for k,v in pairs(self:GetWeapons()) do -- And pick the first one that isn't special
			if !v:IsSpecial() then
				if SERVER then
					self:SetActiveWeapon(nil)
				end
				self:SelectWeapon(v:GetClass())
				return
			end
		end
		if SERVER then
			self:SetActiveWeapon(nil)
		end
	end
end

if SERVER then
	function ply:AddSpecialWeapon(wep)
		if !self.NZSpecialWeapons then self.NZSpecialWeapons = {} end
		local id = wep:GetSpecialCategory()
		self.NZSpecialWeapons[id] = wep
		nzSpecialWeapons:SendSpecialWeaponAdded(self, wep, id)
		
		local data = wep.NZSpecialWeaponData
		
		if !data then return end -- No nothing more if it doesn't have data supplied (e.g. specially added thingies)
		
		local ammo = GetNZAmmoID(id)
		local maxammo = data.maxammo
		if ammo and maxammo then
			self:SetAmmo(maxammo, ammo)
		end
		
		if id == "display" then
			self:SetUsingSpecialWeapon(true)
			self:SetActiveWeapon(nil)
			self:SelectWeapon(wep:GetClass())
		elseif data.DrawOnEquip then
			wep.nzIsDrawing = true
			self:SetUsingSpecialWeapon(true)
			self:SetActiveWeapon(nil)
			self:SelectWeapon(wep:GetClass())
			wep:EquipDraw()
		end
	end

	-- This hook only works server-side
	hook.Add("WeaponEquip", "nzSetSpecialWeapons", function(wep)
		if wep:IsSpecial() then
			-- 0 second timer for the next tick where wep's owner is valid
			timer.Simple(0, function()
				local ply = wep:GetOwner()
				if IsValid(ply) then
					local oldwep = ply:GetSpecialWeaponFromCategory( wep:GetSpecialCategory() )
					--print(wep, oldwep)
					if IsValid(oldwep) then
						ply:StripWeapon(oldwep:GetClass())
					end
					ply:AddSpecialWeapon(wep)
				end
			end)
		end
	end)
end

-- Players switching to special weapons can then no longer switch away until its action has been completed
function GM:PlayerSwitchWeapon(ply, oldwep, newwep)
	print(ply, oldwep, newwep)
	if IsValid(oldwep) and IsValid(newwep) then
	
		if !oldwep:IsSpecial() then
			if oldwep != newwep then
				ply.NZPrevWep = oldwep -- Store previous weapon if it's not special and not the same
			end
			ply:SetUsingSpecialWeapon(false)
		end
		
		if ply:GetUsingSpecialWeapon() then
			if oldwep:IsSpecial() then
				if oldwep.NZSpecialHolster then
					local allow = oldwep:NZSpecialHolster(newwep)
					if allow then
						ply:SetUsingSpecialWeapon(false)
					end
					return !allow -- With this function, it determines if we can holster
				else
					return true -- Otherwise we CAN'T get away from this weapon until SetUsingSpecialWeapon is false!
				end
			else -- Switching away from a non-sepcial when we have special set; reset it!
				ply:SetUsingSpecialWeapon(false)
				return false -- Allow
			end
		else -- Not using special weapons
			if newwep:IsSpecial() then -- Switching to a special one, turn Using Special on!
				local ammo = GetNZAmmoID(newwep:GetSpecialCategory())
				if !ammo or ply:GetAmmoCount(ammo) >= 1 then
				
					local holster = oldwep.Holster
					oldwep.Holster = function() return true end -- Allow instant holstering
					timer.Simple(0, function() oldwep.Holster = holster end)
					
					ply:SetUsingSpecialWeapon(true)
					return false -- We allow it when it's either not using ammo or we have enough
				else
					return true -- With ammo and less than 1 left, we don't switch :(
				end
				
			end
		end
		
	end
end
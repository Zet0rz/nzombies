-- Create new ammo types for each weapon slot; that way all 3 weapons have seperate ammo even if they share type
game.AddAmmoType( {
	name = "nz_weapon_ammo_1",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 2000,
	minsplash = 10,
	maxsplash = 5
} )

game.AddAmmoType( {
	name = "nz_weapon_ammo_2",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 2000,
	minsplash = 10,
	maxsplash = 5
} )

-- Third one is pretty much only used with Mule Kick
game.AddAmmoType( {
	name = "nz_weapon_ammo_3",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 2000,
	minsplash = 10,
	maxsplash = 5
} )

game.AddAmmoType( {
	name = "nz_grenade",
} )

game.AddAmmoType( {
	name = "nz_specialgrenade",
} )

NZAmmoIDs = NZAmmoIDs or {} -- It needs to be global to pass through lua refresh
local ammoids = NZAmmoIDs -- Localize it for optimization

function GetNZAmmoID( id )
	return ammoids[id]
end

hook.Add("InitPostEntity", "nzRegisterAmmoIDs", function()
	local id
	for i = 1, 3 do
		id = game.GetAmmoID("nz_weapon_ammo_"..i)
		if id and id != -1 then
			ammoids[i] = id
		end
	end
	
	id = game.GetAmmoID("nz_grenade")
	if id and id != -1 then
		ammoids["grenade"] = id
	else
		ammoids["grenade"] = 1 -- Default to AR2 ammo
	end
	
	id = game.GetAmmoID("nz_specialgrenade")
	if id and id != -1 then
		ammoids["specialgrenade"] = id
	else
		ammoids["specialgrenade"] = 2 -- Default to AR2 alt ammo (combine balls)
	end
end)

if CLIENT then
	net.Receive("nzAmmoTypeSync", function()
		ammoids = net.ReadTable()
		PrintTable(ammoids)
	end)
else
	util.AddNetworkString("nzAmmoTypeSync")
	
	FullSyncModules["AmmoTypes"] = function(ply)
		net.Start("nzAmmoTypeSync")
			net.WriteTable(ammoids)
		net.Broadcast()
	end
end

local wepMeta = FindMetaTable("Weapon")

local oldammotype = wepMeta.GetPrimaryAmmoType
function wepMeta:GetPrimaryAmmoType()
	local id = self:GetNWInt("SwitchSlot", -1)
	if ammoids[id] then return ammoids[id] end -- We have our own special ammo, return that!
	
	local oldammo = oldammotype(self) -- Otherwise get this weapons old ammo
	if SERVER and oldammo and oldammo != -1 and id != -1 then -- Oldammo is a valid ID and the slot isn't -1
		ammoids[id] = oldammo -- This of course only runs if !ammoids[id]
		
		net.Start("nzAmmoTypeSync")
			net.WriteTable(ammoids) -- Resync new ammo types
		net.Broadcast()
	end -- If it exists, store it as our new "ammo for weapons in slot X"
	
	return oldammo -- Return it as well
end
-- Main Tables
nzConfig = nzConfig or {}
-- nzConfig.Functions = {}
-- nzConfig.Data = {}

--  Defaults

if not ConVarExists("nz_randombox_whitelist") then CreateConVar("nz_randombox_whitelist", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}) end
if not ConVarExists("nz_downtime") then CreateConVar("nz_downtime", 45, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}) end
if not ConVarExists("nz_nav_grouptargeting") then CreateConVar("nz_nav_grouptargeting", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}) end
if not ConVarExists("nz_round_special_interval") then CreateConVar("nz_round_special_interval", 6, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}) end
if not ConVarExists("nz_round_prep_time") then CreateConVar("nz_round_prep_time", 10, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}) end
if not ConVarExists("nz_randombox_maplist") then CreateConVar("nz_randombox_maplist", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}) end
if not ConVarExists("nz_round_dropins_allow") then CreateConVar("nz_round_dropins_allow", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}) end
if not ConVarExists("nz_difficulty_zombie_amount_base") then CreateConVar("nz_difficulty_zombie_amount_base", 5, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}) end
if not ConVarExists("nz_difficulty_zombie_amount_scale") then CreateConVar("nz_difficulty_zombie_amount_scale", 1.01, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}) end
if not ConVarExists("nz_difficulty_zombie_health_base") then CreateConVar("nz_difficulty_zombie_health_base", 75, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}) end
if not ConVarExists("nz_difficulty_zombie_health_scale") then CreateConVar("nz_difficulty_zombie_health_scale", 1.1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}) end
if not ConVarExists("nz_difficulty_max_zombies_alive") then CreateConVar("nz_difficulty_max_zombies_alive", 35, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}) end
if not ConVarExists("nz_difficulty_barricade_planks_max") then CreateConVar("nz_difficulty_barricade_planks_max", 6, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}) end
if not ConVarExists("nz_difficulty_powerup_chance") then CreateConVar("nz_difficulty_powerup_chance", 2, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}) end
if not ConVarExists("nz_difficulty_perks_max") then CreateConVar("nz_difficulty_perks_max", 4, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}) end
if not ConVarExists("nz_point_notification_clientside") then CreateConVar("nz_point_notification_clientside", 0, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}) end

if not ConVarExists("nz_test_hellhounds") then CreateConVar("nz_test_hellhounds", 0, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}) end



-- Zombie table - Moved to shared area for client collision prediction (barricades)
nzConfig.ValidEnemies = {
	["nz_zombie_walker"] = {
		-- Set to false to disable the spawning of this zombie
		Valid = true,
		-- Allow you to scale damage on a per-hitgroup basis
		ScaleDMG = function(zombie, hitgroup, dmginfo)
			-- Headshots for double damage
			if hitgroup == HITGROUP_HEAD then dmginfo:ScaleDamage(2) end
		end,
		-- Function runs whenever the zombie is damaged (NOT when killed)
		OnHit = function(zombie, dmginfo, hitgroup)
			local attacker = dmginfo:GetAttacker()
			-- If player is playing and is not downed, give points
			if attacker:IsPlayer() and attacker:GetNotDowned() then
				attacker:GivePoints(10)
			end
		end,
		-- Function is run whenever the zombie is killed
		OnKilled = function(zombie, dmginfo, hitgroup)
			local attacker = dmginfo:GetAttacker()
			if attacker:IsPlayer() and attacker:GetNotDowned() then
				if dmginfo:GetDamageType() == DMG_CLUB then
					attacker:GivePoints(130)
				elseif hitgroup == HITGROUP_HEAD then
					attacker:GivePoints(100)
				else
					attacker:GivePoints(50)
				end
			end
		end
	},
	["nz_zombie_special_burning"] = {
		Valid = true,
		ScaleDMG = function(zombie, hitgroup, dmginfo)
			if hitgroup == HITGROUP_HEAD then dmginfo:ScaleDamage(2) end
		end,
		OnHit = function(zombie, dmginfo, hitgroup)
			local attacker = dmginfo:GetAttacker()
			if attacker:IsPlayer() and attacker:GetNotDowned() then
				attacker:GivePoints(10)
			end
		end,
		OnKilled = function(zombie, dmginfo, hitgroup)
			local attacker = dmginfo:GetAttacker()
			if attacker:IsPlayer() and attacker:GetNotDowned() then
				if dmginfo:GetDamageType() == DMG_CLUB then
					attacker:GivePoints(130)
				elseif hitgroup == HITGROUP_HEAD then
					attacker:GivePoints(100)
				else
					attacker:GivePoints(50)
				end
			end
		end
	},
	["nz_zombie_special_dog"] = {
		Valid = true,
		SpecialSpawn = true,
		ScaleDMG = function(zombie, hitgroup, dmginfo)
			if hitgroup == HITGROUP_HEAD then dmginfo:ScaleDamage(2) end
		end,
		OnHit = function(zombie, dmginfo, hitgroup)
			local attacker = dmginfo:GetAttacker()
			if attacker:IsPlayer() and attacker:GetNotDowned() then
				attacker:GivePoints(10)
			end
		end,
		OnKilled = function(zombie, dmginfo, hitgroup)
			local attacker = dmginfo:GetAttacker()
			if attacker:IsPlayer() and attacker:GetNotDowned() then
				if dmginfo:GetDamageType() == DMG_CLUB then
					attacker:GivePoints(130)
				elseif hitgroup == HITGROUP_HEAD then
					attacker:GivePoints(100)
				else
					attacker:GivePoints(50)
				end
			end
		end
	},
}

-- Random Box

nzConfig.WeaponBlackList = {}
function nzConfig.AddWeaponToBlacklist( class, remove )
	nzConfig.WeaponBlackList[class] = remove and nil or true
end

nzConfig.AddWeaponToBlacklist( "weapon_base" )
nzConfig.AddWeaponToBlacklist( "weapon_fists" )
nzConfig.AddWeaponToBlacklist( "weapon_flechettegun" )
nzConfig.AddWeaponToBlacklist( "weapon_medkit" )
nzConfig.AddWeaponToBlacklist( "weapon_dod_sim_base" )
nzConfig.AddWeaponToBlacklist( "weapon_dod_sim_base_shot" )
nzConfig.AddWeaponToBlacklist( "weapon_dod_sim_base_snip" )
nzConfig.AddWeaponToBlacklist( "weapon_sim_admin" )
nzConfig.AddWeaponToBlacklist( "weapon_sim_spade" )
nzConfig.AddWeaponToBlacklist( "fas2_base" )
nzConfig.AddWeaponToBlacklist( "fas2_ammobox" )
nzConfig.AddWeaponToBlacklist( "fas2_ifak" )
nzConfig.AddWeaponToBlacklist( "nz_multi_tool" )
nzConfig.AddWeaponToBlacklist( "nz_grenade" )
nzConfig.AddWeaponToBlacklist( "nz_perk_bottle" )
nzConfig.AddWeaponToBlacklist( "nz_quickknife_crowbar" )
nzConfig.AddWeaponToBlacklist( "nz_tool_base" )
nzConfig.AddWeaponToBlacklist( "nz_one_inch_punch" ) -- Nope! You gotta give this with special map scripts

nzConfig.AddWeaponToBlacklist( "cw_base" )

nzConfig.WeaponWhiteList = {
	"fas2_", "m9k_", "cw_",
}

if SERVER then

	nzConfig.RoundData = {}
	--nzConfig.RoundData[1] = {["nz_zombie_walker"] = 100}

	--[[
	-- EXAMPLE of a round zombie config:
	nzConfig.RoundData[ROUNDNUMBER] = {
		-- define normal zombies and theri spawn chances
		normalTypes = {
			["nz_zombie_walker"] = {
				chance = 100,
			},
		},
		-- (optional) how many normal zombies will spawn this wil overwrite the default curves
		normalCount = 50,

		-- (optional) modify teh count witha  function ratehr than a fixed amount
		-- if both normalCount and normalCountMod are set the gamemode will ignore normalCount
		normalCountMod = function(original) return orignal / 2 end,

		-- (optional) spawn delay
		-- this will spawn the zombies in a 3 second intervall
		normalDelay = 3,

		-- special zombies (different spawnpoint usually in front of barricades)
		-- this will spawn 10 hellhounds in additon to the normal zombies
		specialTypes = {
			["nz_zombie_special_dog"] = {
				chance = 100,
			},

		},
		-- (optional) not required but recommended if this is not set teh zombie amount will be doubled
		specialCount = 10
		-- (optional) flag this round as special (this will trigger fog etc.)
		special = true
	}
	]]--

	nzConfig.RoundData[1] = {
		normalTypes = {
			["nz_zombie_walker"] = {
				chance = 100,
			},
		},
	}
	nzConfig.RoundData[2] = {
		normalTypes = {
			["nz_zombie_walker"] = {
				chance = 100,
			},
		},
	}
	nzConfig.RoundData[13] = {
		normalTypes = {
			["nz_zombie_walker"] = {
				chance = 80,
			},
			["nz_zombie_special_burning"] = {
				chance = 20,
			},
		},
	}
	nzConfig.RoundData[14] = {
		normalTypes = {
			["nz_zombie_walker"] = {
				chance = 100,
			},
		},
	}
	nzConfig.RoundData[23] = {
		normalTypes = {
			["nz_zombie_walker"] = {
				chance = 90,
			},
			["nz_zombie_special_burning"] = {
				chance = 10,
			},
		},
	}

	-- Player Class
	nzConfig.BaseStartingWeapons = {"fas2_glock20"} -- "fas2_p226", "fas2_ots33", "fas2_glock20" "weapon_pistol"
	-- nzConfig.CustomConfigStartingWeps = true -- If this is set to false, the gamemode will avoid using custom weapons in configs

end

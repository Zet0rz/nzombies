//Main Tables
nz.Config = {}
//nz.Config.Functions = {}
//nz.Config.Data = {}

// Defaults 

//Zombie table - Moved to shared area for client collision prediction (barricades)
nz.Config.ValidEnemies = {
	["nz_zombie_walker"] = {
		//Set to false to disable the spawning of this zombie
		Valid = true,
		//Allow you to scale damage on a per-hitgroup basis
		ScaleDMG = function(zombie, hitgroup, dmginfo)
			//Headshots for double damage
			if hitgroup == HITGROUP_HEAD then dmginfo:ScaleDamage(2) end
		end,
		//Function runs whenever the zombie is damaged (NOT when killed)
		OnHit = function(zombie, dmginfo, hitgroup)
			local attacker = dmginfo:GetAttacker()
			//If player is playing and is not downed, give points
			if attacker:IsPlayer() and attacker:GetNotDowned() then
				attacker:GivePoints(10)
			end
		end,
		//Function is run whenever the zombie is killed
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
	}
}

nz.Config.DownTime = 45 				//How long time in seconds until you die from not being revived while downed

	NZ_POINT_NOTIFCATION_NET = 1 		//Net messages from the server on points gained or lost - More precise but costs net usage
	NZ_POINT_NOTIFCATION_CLIENT = 2		//Calculated client-side per frame - No constant net messages but may stack multiple in 1 frame
	
nz.Config.PointNotifcationMode = NZ_POINT_NOTIFCATION_NET

nz.Config.MaxPerks = 4					//The max perks you can BUY (You can get more in other ways) 

//Random Box

nz.Config.WeaponBlackList = {
"weapon_base", "weapon_fists", "weapon_flechettegun", "weapon_medkit",
"weapon_dod_sim_base", "weapon_dod_sim_base_shot", "weapon_dod_sim_base_snip", "weapon_sim_admin", "weapon_sim_spade",
"fas2_base", "fas2_ammobox", "fas2_ifak", "fas2_base_shotgun",
"nz_tool_base", "nz_tool_barricades", "nz_tool_block_spawns", "nz_tool_door_locker", "nz_tool_elec", "nz_tool_perk_machine", "nz_tool_player_spawns", "nz_tool_prop_modifier", "nz_tool_random_box", "nz_tool_template", "nz_tool_wall_buys", "nz_tool_zed_spawns",
"nz_tool_ee", "nz_tool_random_box_handler", "nz_tool_player_handler", "nz_tool_nav_locker", "nz_multi_tool", "nz_tool_nav_ladder_builder"
}

if SERVER then

	//Zombie path retargeting
	//Whether zombies and spawnpoints will check if Nav Group IDs are the same as their target player's before spawning
	nz.Config.NavGroupTargeting = true
	
	//Curves

	nz.Config.MaxRounds = 100 // How much round data should we load?

	//Spawn Rate Curve
	nz.Config.BaseDifficultySpawnRateCurve = 5
	nz.Config.DifficultySpawnRateCurve = 1.01
	//Health Curve
	nz.Config.BaseDifficultyHealthCurve = 75
	nz.Config.DifficultyHealthCurve = 0.3
	//Speed curve
	nz.Config.BaseDifficultySpeedCurve = 60
	nz.Config.DifficultySpeedCurve = 0.5

	//Display

	//Door_System

	//Electricity

	//Enemies
	nz.Config.EnemyTypes = {}
	--nz.Config.EnemyTypes[1] = {["nz_zombie_walker"] = 100}
	
	nz.Config.EnemyTypes[1] = {["nz_zombie_walker"] = {
		chance = 100,
		speeds = {
			[40] = 80,
			[50] = 20
		},
		special = true
	}}
	nz.Config.EnemyTypes[2] = {["nz_zombie_walker"] = {
		chance = 100,
		speeds = {
			[40] = 30,
			[50] = 50,
			[60] = 20
		}
	}}
	nz.Config.EnemyTypes[3] = {["nz_zombie_walker"] = {
		chance = 100,
		speeds = {
			[40] = 10,
			[50] = 50,
			[60] = 40
		}
	}}
	nz.Config.EnemyTypes[5] = {["nz_zombie_walker"] = {
		chance = 100,
		speeds = {
			[50] = 30,
			[60] = 50,
			[75] = 20
		}
	}}
	nz.Config.EnemyTypes[6] = {["nz_zombie_special_burning"] = {
		chance = 100,
		count = 20,
		speeds = {
			[50] = 10,
			[60] = 80,
			[75] = 10
		}
	}}
	nz.Config.EnemyTypes[7] = {["nz_zombie_walker"] = {
		chance = 100,
		speeds = {
			[50] = 5,
			[80] = 50,
			[100] = 45,
			[150] = 5,
			[160] = 5
		}
	}}
	nz.Config.EnemyTypes[10] = {["nz_zombie_walker"] = {
		chance = 100,
		speeds = {
			[80] = 10,
			[100] = 50,
			[120] = 10,
			[150] = 10,
			[175] = 10
		}
	}}
	nz.Config.EnemyTypes[13] = {["nz_zombie_walker"] = {
		chance = 80,
		speeds = {
			[50] = 5,
			[80] = 40,
			[100] = 45,
			[150] = 20,
			[175] = 30
		}
	}, ["nz_zombie_special_burning"] = {
		chance = 20,
		speeds = {
			[50] = 30,
			[80] = 50,
			[100] = 20,
			[150] = 40,
			[175] = 5,
			[200] = 5
		}
	}}
	nz.Config.EnemyTypes[14] = {["nz_zombie_walker"] = {
		chance = 100,
		speeds = {
			[80] = 5,
			[100] = 10,
			[120] = 20,
			[150] = 40,
			[175] = 20,
			[200] = 30
		}
	}}
	nz.Config.EnemyTypes[18] = {["nz_zombie_walker"] = {
		chance = 100,
		speeds = {
			[80] = 10,
			[100] = 30,
			[120] = 10,
			[150] = 10,
			[175] = 40,
			[200] = 30,
			[250] = 20
		}
	}}
	nz.Config.EnemyTypes[23] = {["nz_zombie_walker"] = {
		chance = 90,
		speeds = {
			[150] = 10,
			[175] = 50,
			[200] = 50,
			[250] = 50
		}
	}, ["nz_zombie_special_burning"] = {
		chance = 10,
		speeds = {
			[150] = 50,
			[175] = 40,
			[200] = 20,
		}
	}}
	
	nz.Config.EnemyTypes[30] = {["nz_zombie_walker"] = {
		chance = 90,
		speeds = {
			[175] = 30,
			[200] = 40,
			[250] = 50,
			[250] = 30,
			[300] = 10
		}
	}, ["nz_zombie_special_burning"] = {
		chance = 10,
		speeds = {
			[175] = 40,
			[200] = 20,
			[250] = 10,
		}
	}}
	
	nz.Config.EnemyTypes[38] = {["nz_zombie_walker"] = {
		chance = 90,
		speeds = {
			[250] = 50,
			[250] = 30,
			[300] = 10
		}
	}, ["nz_zombie_special_burning"] = {
		chance = 10,
		speeds = {
			[200] = 30,
			[250] = 40,
			[300] = 5,
		}
	}}
	
	--[[nz.Config.EnemyTypes[6] = {["nz_zombie_special_burning"] = 100, count = 20}
	nz.Config.EnemyTypes[7] = {["nz_zombie_walker"] = 100}
	nz.Config.EnemyTypes[13] = {["nz_zombie_walker"] = 80, ["nz_zombie_special_burning"] = 20}
	nz.Config.EnemyTypes[18] = {["nz_zombie_special_burning"] = 100}
	nz.Config.EnemyTypes[19] = {["nz_zombie_walker"] = 70, ["nz_zombie_special_burning"] = 30}
	//nz.Config.EnemyTypes[4] = {["hellhounds"] = 100}
	//nz.Config.EnemyTypes[4] = {["nz_zombie_walker"] = 80, ["hellhounds"] = 20}]]

	//Max amount of zombies at the same time
	nz.Config.MaxZombiesSim = 100

	//Interfaces

	//Mapping

	//Misc
	nz.Config.Halos = false

	//Perks

	//Player Class
	nz.Config.BaseStartingWeapons = {"fas2_glock20"} //"fas2_p226", "fas2_ots33", "fas2_glock20" "weapon_pistol"
	//nz.Config.CustomConfigStartingWeps = true -- If this is set to false, the gamemode will avoid using custom weapons in configs

	//Points
	nz.Config.BaseStartingPoints = 500

	//Powerups
	nz.Config.PowerUpChance = 100 // Chance is 1 in X (Default: 1 in 100 chance)

	//Props_Menu

	//Round Handler

	//Time Between rounds
	nz.Config.PrepareTime = 10

	//Spectator

	nz.Config.AllowDropins = true

	//Weapons
	nz.Config.MaxWeps = 2

end

//Shared

//Barricades
nz.Config.MaxPlanks = 6

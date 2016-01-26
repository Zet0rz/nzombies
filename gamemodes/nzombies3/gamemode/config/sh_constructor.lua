//Main Tables
nz.Config = {}
//nz.Config.Functions = {}
//nz.Config.Data = {}

// Defaults 

//Zombie table - Moved to shared area for client collision prediction (barricades)
nz.Config.ValidEnemies = {
	["nut_zombie"] = {
		//Set to false to disable the spawning of this zombie
		Valid = true,
		//Allow you to scale damage on a per-hitgroup basis
		ScaleDMG = function(zombie, hitgroup, dmginfo)
			//Headshots for double damage
			if hitgroup == HITGROUP_HEAD then dmginfo:ScaleDamage(2) end
		end,
		//Function runs whenever the zombie is damaged (NOT when killed)
		OnHit = function(zombie, attacker, hitgroup)
			//If player is playing and is not downed, give points
			if attacker:IsPlayer() and attacker:GetNotDowned() then
				attacker:GivePoints(10)
			end
		end,
		//Function is run whenever the zombie is killed
		OnKilled = function(zombie, attacker, hitgroup)
			if attacker:IsPlayer() and attacker:GetNotDowned() then
				if hitgroup == HITGROUP_HEAD then
					attacker:GivePoints(100)
				else
					attacker:GivePoints(50)
				end
			end
		end
	},
	["nut_zombie_ex"] = {
		Valid = true,
		ScaleDMG = function(zombie, hitgroup, dmginfo)
			if hitgroup == HITGROUP_HEAD then dmginfo:ScaleDamage(2) end
		end,
		OnHit = function(zombie, attacker, hitgroup)
			if attacker:IsPlayer() and attacker:GetNotDowned() then
				attacker:GivePoints(10)
			end
		end,
		OnKilled = function(zombie, attacker, hitgroup)
			if attacker:IsPlayer() and attacker:GetNotDowned() then
				if hitgroup == HITGROUP_HEAD then
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
	nz.Config.DifficultyHealthCurve = 0.2
	//Speed curve
	nz.Config.BaseDifficultySpeedCurve = 60
	nz.Config.DifficultySpeedCurve = 0.5

	//Display

	//Door_System

	//Electricity

	//Enemies
	nz.Config.EnemyTypes = {}
	nz.Config.EnemyTypes[1] = {["nut_zombie"] = 100}
	nz.Config.EnemyTypes[6] = {["nut_zombie_ex"] = 100, count = 20}
	nz.Config.EnemyTypes[7] = {["nut_zombie"] = 100}
	nz.Config.EnemyTypes[13] = {["nut_zombie"] = 80, ["nut_zombie_ex"] = 20}
	nz.Config.EnemyTypes[18] = {["nut_zombie_ex"] = 100}
	nz.Config.EnemyTypes[19] = {["nut_zombie"] = 70, ["nut_zombie_ex"] = 30}
	//nz.Config.EnemyTypes[4] = {["hellhounds"] = 100}
	//nz.Config.EnemyTypes[4] = {["nut_zombie"] = 80, ["hellhounds"] = 20}

	//Max amount of zombies at the same time
	nz.Config.MaxZombiesSim = 100

	//Interfaces

	//Mapping

	//Misc
	nz.Config.Halos = false  // I seem to be getting a lot of lag because of this, so it is disabled here

	//Perks

	//Player Class
	nz.Config.BaseStartingWeapons = {"fas2_glock20"} //"fas2_p226", "fas2_ots33", "fas2_glock20" "weapon_pistol"
	//nz.Config.CustomConfigStartingWeps = true -- If this is set to false, the gamemode will avoid using custom weapons in configs

	//Points
	nz.Config.BaseStartingPoints = 500

	//Powerups
	nz.Config.PowerUpChance = 100 // Chance is 1 in X (Default: 1 in 100 chance)

	//Props_Menu

	//Random Box

	nz.Config.WeaponBlackList = {
	"weapon_base", "weapon_fists", "weapon_flechettegun", "weapon_medkit",
	"weapon_dod_sim_base", "weapon_dod_sim_base_shot", "weapon_dod_sim_base_snip", "weapon_sim_admin", "weapon_sim_spade",
	"fas2_base", "fas2_ammobox", "fas2_ifak", "fas2_base_shotgun",
	"nz_tool_base", "nz_tool_barricades", "nz_tool_block_spawns", "nz_tool_door_locker", "nz_tool_elec", "nz_tool_perk_machine", "nz_tool_player_spawns", "nz_tool_prop_modifier", "nz_tool_random_box", "nz_tool_template", "nz_tool_wall_buys", "nz_tool_zed_spawns",
	"nz_tool_ee", "nz_tool_random_box_handler", "nz_tool_player_handler", "nz_tool_nav_locker"
	}

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

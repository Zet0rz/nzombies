DEFINE_BASECLASS( "player_default" )

local PLAYER = {}

--
-- See gamemodes/base/player_class/player_default.lua for all overridable variables
--
PLAYER.WalkSpeed 			= 200
PLAYER.RunSpeed				= 300
PLAYER.CanUseFlashlight     = true

function PLAYER:SetupDataTables()
	self.Player:NetworkVar("Bool", 0, "UsingSpecialWeapon")
end

function PLAYER:Init()
	-- Don't forget Colours
	-- This runs when the player is first brought into the game and when they die during a round and are brought back

end

if not ConVarExists("nz_failsafe_preventgrenades") then CreateConVar("nz_failsafe_preventgrenades", 0, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_NOTIFY}) end

function PLAYER:Loadout()
	-- Give ammo and guns

	if nzMapping.Settings.startwep then
		self.Player:Give( nzMapping.Settings.startwep )
	else
		-- A setting does not exist, give default starting weapons
		for k,v in pairs(nzConfig.BaseStartingWeapons) do
			self.Player:Give( v )
		end
	end
	self.Player:GiveMaxAmmo()

	if !GetConVar("nz_papattachments"):GetBool() and FAS2_Attachments != nil then
		for k,v in pairs(FAS2_Attachments) do
			self.Player:FAS2_PickUpAttachment(v.key)
		end
	end
	self.Player:Give("nz_quickknife_crowbar")
	
	-- We need this to disable the grenades for those that it causes problems with until they've been remade :(
	if !GetConVar("nz_failsafe_preventgrenades"):GetBool() then
		self.Player:Give("nz_grenade")
	end

end
function PLAYER:Spawn()

	if nzMapping.Settings.startpoints then
		if !self.Player:CanAfford(nzMapping.Settings.startpoints) then
			self.Player:SetPoints(nzMapping.Settings.startpoints)
		end
	else
		if !self.Player:CanAfford(500) then -- Has less than 500 points
			-- Poor guy has no money, lets start him off
			self.Player:SetPoints(500)
		end
	end

	-- Reset their perks
	self.Player:RemovePerks()

	-- activate zombie targeting
	self.Player:SetTargetPriority(TARGET_PRIORITY_PLAYER)

	local spawns = ents.FindByClass("player_spawns")
	-- Get player number
	for k,v in pairs(player.GetAll()) do
		if v == self.Player then
			if IsValid(spawns[k]) then
				v:SetPos(spawns[k]:GetPos())
			else
				print("No spawn set for player: " .. v:Nick())
			end
		end
	end
	
	self.Player:SetUsingSpecialWeapon(false)
end

player_manager.RegisterClass( "player_ingame", PLAYER, "player_default" )

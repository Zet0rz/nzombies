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

function PLAYER:Loadout()
	-- Give ammo and guns

	if Mapping.Settings.startwep then
		self.Player:Give( Mapping.Settings.startwep )
	else
		-- A setting does not exist, give default starting weapons
		for k,v in pairs(nz.Config.BaseStartingWeapons) do
			self.Player:Give( v )
		end
	end
	nz.Weps.Functions.GiveMaxAmmo(self.Player)

	if !GetConVar("nz_papattachments"):GetBool() and FAS2_Attachments != nil then
		for k,v in pairs(FAS2_Attachments) do
			self.Player:FAS2_PickUpAttachment(v.key)
		end
	end
	self.Player:Give("nz_quickknife_crowbar")
	self.Player:Give("nz_grenade")

end
function PLAYER:Spawn()

	if Mapping.Settings.startpoints then
		if !self.Player:CanAfford(Mapping.Settings.startpoints) then
			self.Player:SetPoints(Mapping.Settings.startpoints)
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

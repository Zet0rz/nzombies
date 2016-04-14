DEFINE_BASECLASS( "player_default" )

local PLAYER = {}

--
-- See gamemodes/base/player_class/player_default.lua for all overridable variables
--
PLAYER.WalkSpeed 			= 300
PLAYER.RunSpeed				= 600
PLAYER.CanUseFlashlight     = true

function PLAYER:SetupDataTables()
	self.Player:NetworkVar("Bool", 0, "UsingSpecialWeapon")
end

function PLAYER:Init()
	-- Don't forget Colours
	-- This runs when the player is first brought into the game
	-- print("create")
end

function PLAYER:Loadout()

	-- Creation Tools
	self.Player:Give( "weapon_physgun" )
	self.Player:Give( "nz_multi_tool" )

end

function PLAYER:Spawn()
	-- if we are in create or debuging make zombies target us
	if Round:InState(ROUND_CREATE) or GetConVar( "nz_zombie_debug" ):GetBool() then --TODO this is bullshit?
		self.Player:SetTargetPriority(TARGET_PRIORITY_PLAYER)
	end
	self.Player:SetUsingSpecialWeapon(false)
end

player_manager.RegisterClass( "player_create", PLAYER, "player_default" )

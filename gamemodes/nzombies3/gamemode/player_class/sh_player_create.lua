DEFINE_BASECLASS( "player_default" )

local PLAYER = {} 

--
-- See gamemodes/base/player_class/player_default.lua for all overridable variables
--
PLAYER.WalkSpeed 			= 300
PLAYER.RunSpeed				= 600
PLAYER.CanUseFlashlight     = true

function PLAYER:Init()
	//Don't forget Colours
	//This runs when the player is first brought into the game
	//print("create")
end

function PLAYER:Loadout()

	//Creation Tools
	self.Player:Give( "weapon_physgun" )
	self.Player:Give( "nz_tool_zed_spawns" )
	self.Player:Give( "nz_tool_player_spawns" )
	self.Player:Give( "nz_tool_wall_buys" )
	self.Player:Give( "nz_tool_prop_modifier" )
	self.Player:Give( "nz_tool_door_locker" )
	self.Player:Give( "nz_tool_elec" )
	self.Player:Give( "nz_tool_block_spawns" )
	self.Player:Give( "nz_tool_random_box" )
	self.Player:Give( "nz_tool_random_box_handler" )
	self.Player:Give( "nz_tool_player_handler" )
	self.Player:Give( "nz_tool_perk_machine" )
	self.Player:Give( "nz_tool_barricades" )
	self.Player:Give( "nz_tool_ee" )
	self.Player:Give( "nz_tool_nav_locker" )
	
end

player_manager.RegisterClass( "player_create", PLAYER, "player_default" )
nZombies
========

A GM13 Nazi Zombies style (WIP) gamemode

place in gamemodes/nzombies/

This is an edited version featuring these changes:

- Revival System & Health
	- You get downed by losing all HP
	- CalcView low angle for being downed, screen slowly fades to black until you die
	- Hold E on a downed friend to revive, 45 seconds without revival kills the downed player
	- Quick Revive now works; 5 seconds to revive without, 2 seconds with
	- Zombies ignore downed players
	- Downed players also count as 'dead' towards ending the game
	- Upon being downed, you equip a pistol if available
		-(Planned: If no pistol, give starting pistol for the duration of being downed)
	- Zombies now deal 50-70 damage, but you have health regen on your side!
	- Revival progress bar

- Navigation Locker Tool
	- Lock Navmeshes or link them to doors!
		- Zombies will not be able to pathfind through locked navmeshes
		- Opening a linked door will unlock the navmesh it was tied to
		- You need to be in a local server with sv_cheats to 1 to visualize them, however they still work without
		- Only normal zombies can, but you can copy-paste the pathfinding check to any other NPC if needed
	- Create NavGroups!
		- Zombies cannot target players in different NavGroups than themselves (unless either one is in no group)
		- If no players can be targeted, will target a spawnpoint marked with "Respawn from?" and respawn from it on arrival

- Additional Content
	- More Powerups
		- Carpenter
		- Fire Sale
	- More sounds
		- Buy sound
		- Barrier repair sounds
		- Random Box moving sounds
	- More effects
		- Damaged blood pulse overlay
		- Better HUD elements and scoreboard
	- Better editing
		- Undo system
		- Context Menu to quickly edit properties without equipping tool (Hold C)
		- Many more props, light effects, sky/fog/sun editors, fire entites, and more ...

- Better Zombie AI
	- Zombies can now jump (Thanks lolle!)
	- Zombies now know which navmeshes are locked to doors and won't path through them
	- Zombies can now know if there are players in the same area as them
	- Zombies can now go back to respawn if they can't get to any players
	
- Random Box Handler Tool (For Create mode)
	- Decide which weapons the box can spawn
	- If no Random Box Handler entity exists, it will assume normal behaviour
		
- Weapon Carrying
	- Max number weapons you can carry
	- You swap weapons if the max has been reached
	- You automatically equip newly gotten weapons
	
- Player Handler Tool + Entity (For Create mode)
	- Decide starting weapon
	- Decide starting points
	- Decide max number of weapons carried
	- Takes a YouTube URL which plays when all easter eggs have been activated
		
- Door Changes
	- func_* doors now actually trigger with E!
	- Doors that still close with triggers or buttons will unlock and open again
		- The only way to keep these doors open
		- Otherwise Triggers will close it again and because we locked it, we can't reopen
	- You can now lock buttons with a price (Say to trigger doors or elevators, or maybe even traps)
	- Doors only lock if they have a price; doors without will force themselves to stay open when they try to close
	
- Misc changes
	- Wall Buy tool weapon selection is a dropdown of all available weapons instead of text field
	- Sleight of Hand renamed to Speed Cola
	- Set the prices of the perks to what they are in the real zombies game
	- Enabled the Start Round sound on every round, like in the real game
	- Random Box weapons float up with the right angle to match the box
	- Random Box Weapons can now be picked up even with wierd models
	- Zombies now correctly give 50 points for a kill and 100 for a headshot kill
	- Point distribution works on hooks now, making it work for any NPC you add to ValidEnemies
	- ValidEnemies table setup changed to allow more customizability
	- Power Ups now just rotate and are golden
	- Pack-a-Punch now a global hook, will work on all weapons
	- Zombie Spawnpoints can now be disabled so they don't spawn any zombies using "Spawnable at?"


- To-do list:
	- Invisible blockers to have blocking filters
	- Try to work around a way for Speed Cola and Double Tap (Double Tap v2?) to work on all weapons
	- Add Black Ops and Black Ops 2 perks?
	- Fix random downing of players (Prop collision?)
	- Modify curves to be better
	- Fix Zombies getting stuck on corners a lot (plz)
	- Zombies to walk back to a spawnpoint and respawn if there's no valid paths to players (Nav Mesh Grouping WIP)
	- Support for free buttons/doors with custom text
	- Tools to save config and apply on LMB instead of having to re-enter it every time
	- Pack-a-Punch weapon animation and material overlay and sounds
	- Change round handler function to not run every second; instead just on events
	- General optimizations
	- Real Nazi Zombie models and sounds for the zombies?
	- Perk Bottle view model animations built-in?
	- More Wonder Weapons built-in?
	- Fix some entities not saving properly (mainly Player Handler and RBox Handler)
	- Fix Music Easter Egg not properly playing/preloading

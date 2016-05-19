nZombies
========

A GM13 Nazi Zombies style (WIP) Gamemode

Download folder and place it in garrysmod/garrysmod/addons
Make sure the structure has a path to addon.json like this: garrysmod/garrysmod/addons/nzombies/addon.json

Get the content pack with all models and materials here:
http://steamcommunity.com/sharedfiles/filedetails/?id=675138912

Get the collection of weapon packs used by the official configs here:
http://steamcommunity.com/sharedfiles/filedetails/?id=673266588

If you have bugs, suggestions, or general improvements, open up an issue with the issue button at the top. If you want to help, feel free to create pull requests with your changes. If you have questions, add me on Steam :)

This is an edited version from Alig's original featuring these changes:

- Revival System & Health
	- You get downed by losing all HP
	- "CalcView" used to determine low angle for being downed, screen slowly fades to black until you die
	- Hold E on a downed friend to revive, 45 seconds without revival actually kills the downed player
	- "Quick Revive" now works; 5 seconds to revive without, 2 seconds with
	- Zombies ignore downed players
	- Downed players also count as 'dead' towards ending the game if not revived before then
	- Upon being downed, you equip a pistol if available
		-(Planned: If no pistol, give starting pistol for the duration of being downed)
	- Zombies now deal 50-70 damage, but you have health regeneration on your side!
	- Revival progress bar

- Navigation Locker Tool
	- Lock Navmeshes or link them to doors!
		- Zombies will not be able to pathfind through locked navmeshes
		- Opening a linked door will unlock the navmesh it was linked to
		- You need to be in a local server with __sv_cheats__ to 1 to visualize them, however they still work without
		- Only normal zombies can, but you can copy-and-paste the pathfinding check to any other NPC if needed
	- Create NavGroups!
		- Zombies cannot target players in different NavGroups than themselves (unless either one is in no group)
		- If no players can be targeted, the zombie(s) will target a spawnpoint marked with "Respawn from?" and respawn from it upon the player's arrival
	- A tool for generating ladders in edit mode!

- Additional Content
	- All perks up until Black Ops 2; all DLC working!
	- A proper HUD!
	- More Powerups
		- "Carpenter"
		- "Fire Sale"
	- More sounds
		- Buy sound
		- Barrier repairing sounds
		- "Random Box" moving sounds
		- "Pack-a-Punched" gun shooting sounds
		- Perk Machine jingles
	- More effects
		- On taking damage, a blood pulse overlay appears
		- Pack-a-Punch weapon animations
		- Perk Bottle Drinking animation
		- Hellhound lightning aura
	- Better editing
		- Undo system
		- Context Menu to quickly edit properties without equipping tool (Hold C)
		- Many more props, light effects, sky/fog/sun editors, fire entities, and more ...

- Map Settings tool!
	- Decide which weapons the random box can spawn
	- Set a SoundCloud link to a song to play upon finding an Easter Egg
	- Decide the starting weapon and the starting amount of points

- Better Zombie AI (Thanks Lolle!)
	- Zombies can now jump
	- Zombies now know which navmeshes are locked to doors and won't path through them
	- Zombies can now know if there are players in the same area as them
	- Zombies can now go back to respawn if they can't get to any players

- Easy Mismatch Correction System
	- Loading configs using weapons you may not have installed creates an easy menu to replace them with another or no  weapon
	- Applies to wall buys, random box list, perks (if scripted in), and more as new stuff is added
		
- Weapon Carrying
	- Maximum number weapons you can carry
	- You swap weapons if the max has been reached
	- You automatically equip newly gotten weapons
		
- Door Changes
	- "func_*" doors now actually open/trigger with E!
	- Doors that still close with triggers or buttons will unlock and open again
		- This is the only way to keep these doors open
		- Otherwise Triggers will close it again and because we locked it, we can't reopen
	- You can now lock buttons with a price (Say to trigger doors or elevators, or maybe even traps)
	- Doors only lock if they have a price; doors without will force themselves to stay open when they try to close
	- Doors can be set to "Repurchasable" which will make them not lock (E.g. to use on Elevator buttons)
	- Doors have "Purchasable" option to completely disable E input (E.g. to use on doors that shouldn't lock but open by button)
	
- Misc changes
	- "Speed Cola" and "Double Tap" now work on all weapons!
	- "Wall Buy tool" weapon selection is a dropdown of all available weapons instead of text field
	- "Sleight of Hand" renamed to "Speed Cola"
	- Set the prices of the perks to what they are in the real zombies game
	- Enabled the 'Start Round' sound on every round, like in the real game
	- "Random Box" weapons float up at the same angle as the box
	- "Random Box" Weapons can now be picked up even with wierd models
	- Zombies now correctly give 50 points for a kill and 100 for a headshot kill
	- Point distribution works on hooks now, making it work for any NPC you add to "ValidEnemies"
	- "ValidEnemies" table setup changed to allow more customizability
	- "Power Ups" now rotate and are golden
	- "Pack-a-Punch" is now a global hook, will work on all weapons
	- Prop Search menu


- Workshop Release To-do list:
	Check the Issues tab with the "Workshop Release" milestone. Feel free to discuss your opinion about the things in there, it would help greatly.

//

--[[ Stuff Added

	- Revival System
		You get downed by losing all HP
		CalcView low angle for being downed, screen slowly fades to black until you die
		Hold E on a downed friend to revive, 45 seconds without revival kills the downed player
		Quick Revive now works; 5 seconds to revive without, 2 seconds with
		Zombies ignore downed players
		Downed players also count as 'dead' towards ending the game
		Upon being downed, you equip a pistol if available
		(Planned: If no pistol, give starting pistol for the duration of being downed)
	
	- Random Box Handler Tool (For Create mode)
		Decide which weapons the box can spawn
		If no Random Box Handler entity exists, it will assume normal behaviour
		
	- Weapon Carrying
		Max number weapons you can carry
		You swap weapons if the max has been reached
		You automatically equip newly gotten weapons
		If no Player Handler entity exists, this won't be active
	
	- Player Handler Tool + Entity (For Create mode)
		Decide starting weapon
		Decide starting points
		Decide max number of weapons carried
		
	- Door Changes
		func_* doors now actually trigger with E!
		Doors that still close with triggers or buttons will unlock and open again
			The only way to keep these doors open
			Otherwise Triggers will close it again and because we locked it, we can't reopen
		You can now lock buttons with a price (Say to trigger doors or elevators, or maybe even traps)
		Doors only lock if they have a price; doors without will force themselves to stay open when they try to close
	
	- Misc changes
		Wall Buy tool weapon selection is a dropdown of all available weapons instead of text field
		Sleight of Hand renamed to Speed Cola
		Set the prices of the perks to what they are in the real zombies game
		Enabled the Start Round sound on every round, like in the real game
		Random Box weapons float up with the right angle to match the box
		
PLANNED STUFF:

	- Make Speed Cola work on non-FAS2 weapons
		(Overwrite their reload function? SetClip1(max clip size)?)
	
	
	
	
	
	
	]]
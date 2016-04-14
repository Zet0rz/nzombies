local mapscript = {}

-- Any function added to this table will automatically get hooked to the hook with the same name
function mapscript.RoundInit()
	-- E.g. this function will run with the RoundInit hook
	print(mapscript.TestPrint)
end

-- This one will be called at the start of each round
function mapscript.RoundStart()

end

-- Will be called every second if a round is in progress (zombies are alive)
function mapscript.RoundThink()

end

-- Will be called after each round
function mapscript.RoundEnd()

end

-- Only functions will be hooked, meaning you can safely store data as well
mapscript.TestPrint = "v0.0"
local testprint2 = "This is cool" -- You can also store the data locally

-- Always return the mapscript table. This gives it on to the gamemode so it can use it.
return mapscript

//

function nz.EE.Functions.Reset()
	//Reset the counter of eggs
	nz.EE.Data.EggCount = 0
	nz.EE.Data.MaxEggCount = 0

	//Reset all easter eggs
	for k,v in pairs(ents.FindByClass("easter_egg")) do
		v.Used = false
	end
	hook.Call("nz.EE.EasterEggStop")
end

function nz.EE.Functions.ActivateEgg( ent )

	ent.Used = true
	ent:EmitSound("WeaponDissolve.Dissolve", 100, 100)

	nz.EE.Data.EggCount = nz.EE.Data.EggCount + 1

	if nz.EE.Data.MaxEggCount == 0 then
		nz.EE.Data.MaxEggCount = #ents.FindByClass("easter_egg")
	end

	//What we should do when we have all the eggs
	if nz.EE.Data.EggCount == nz.EE.Data.MaxEggCount then
		print("All easter eggs found yay!")
		hook.Call( "nz.EE.EasterEgg" )
	end
end

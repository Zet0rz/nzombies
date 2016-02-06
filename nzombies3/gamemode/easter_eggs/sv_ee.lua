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

util.AddNetworkString("EasterEggSong")
util.AddNetworkString("EasterEggSongPreload")
util.AddNetworkString("EasterEggSongStop")

hook.Add("nz.EE.EasterEgg", "PlayEESong", function()
	net.Start("EasterEggSong")
	net.Broadcast()
end)

hook.Add("nz.EE.EasterEggStop", "StopEESong", function()
	net.Start("EasterEggSongStop")
	net.Broadcast()
end)

hook.Add("PlayerInitialSpawn", "PreloadEESongSpawn", function(ply)
	//Send players the map settings - this will trigger the preload client-side
	net.Start("nz.Mapping.SyncSettings")
		net.WriteTable(nz.Mapping.MapSettings)
	net.Send(ply)
end)
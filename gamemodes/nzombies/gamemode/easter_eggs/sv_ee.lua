//

function nzEE:Reset()
	-- Reset the counter of eggs
	self.Data.EggCount = 0
	self.Data.MaxEggCount = 0

	-- Reset all easter eggs
	for k,v in pairs(ents.FindByClass("easter_egg")) do
		v.Used = false
	end
	hook.Call("nz.EE.EasterEggStop")
end

function nzEE:ActivateEgg( ent, ply )

	ent.Used = true
	ent:EmitSound("WeaponDissolve.Dissolve", 100, 100)

	self.Data.EggCount = self.Data.EggCount + 1

	if self.Data.MaxEggCount == 0 then
		self.Data.MaxEggCount = #ents.FindByClass("easter_egg")
	end

	-- What we should do when we have all the eggs
	if self.Data.EggCount == self.Data.MaxEggCount then
		print("All easter eggs found yay!")
		hook.Call( "nz.EE.EasterEgg", nil, ply )
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

hook.Add("PlayerFullyInitialized", "PreloadEESongSpawn", function(ply)
	-- Send players the map settings - this will trigger the preload client-side
	net.Start("nzMapping.SyncSettings")
		net.WriteTable(nzMapping.Settings)
	net.Send(ply)
end)

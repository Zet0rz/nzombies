function nz.Mapping.Functions.CleanUpMap()
	game.CleanUpMap()
end
net.Receive("nzCleanUp", nz.Mapping.Functions.CleanUpMap)
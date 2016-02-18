if SERVER then
	util.AddNetworkString("nz_PlayerInit")
	net.Receive("nz_PlayerInit", function(len, ply)
		hook.Call("PlayerFullyInitialized", nil, ply)
	end)
else
	hook.Add("InitPostEntity", "PlayerFullyInitialized", function()
		net.Start("nz_PlayerInit")
		net.SendToServer()
	end)

end
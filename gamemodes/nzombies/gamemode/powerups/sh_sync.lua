//Client Server Syncing

if SERVER then

	//Server to client (Server)
	util.AddNetworkString( "nzPowerUps.Sync" )
	util.AddNetworkString( "nzPowerUps.SyncPlayer" )
	util.AddNetworkString( "nzPowerUps.Nuke" ) -- See the nuke function in sv_powerups
	
	function nzPowerUps:SendSync(receiver)
		local data = table.Copy(self.ActivePowerUps)
		
		net.Start( "nzPowerUps.Sync" )
			net.WriteTable( data )
		return IsValid(receiver) and net.Send(receiver) or net.Broadcast()
	end
	
	function nzPowerUps:SendPlayerSync(ply, receiver)
		if !self.ActivePlayerPowerUps[ply] then self.ActivePlayerPowerUps[ply] = {} end
		local data = table.Copy(self.ActivePlayerPowerUps[ply])
		
		net.Start( "nzPowerUps.SyncPlayer" )
			net.WriteEntity(ply)
			net.WriteTable( data )
		return IsValid(receiver) and net.Send(receiver) or net.Broadcast()
	end
	
	FullSyncModules["PowerUps"] = function(ply)
		nzPowerUps:SendSync(ply)
		for k,v in pairs(player.GetAll()) do
			nzPowerUps:SendPlayerSync(v, ply)
		end
	end

end

if CLIENT then
	
	//Server to client (Client)
	local function ReceivePowerupSync( length )
		print("Received PowerUps Sync")
		nzPowerUps.ActivePowerUps = net.ReadTable()
		PrintTable(nzPowerUps.ActivePowerUps)
	end
	
	local function ReceivePowerupPlayerSync( length )
		print("Received PowerUps Player Sync")
		local ply = net.ReadEntity()
		nzPowerUps.ActivePlayerPowerUps[ply] = net.ReadTable()
		PrintTable(nzPowerUps.ActivePlayerPowerUps)
	end
	
	local function ReceiveNukeEffect()
		local fade = 0
		local rising = true
		hook.Add("RenderScreenspaceEffects", "DrawNukeEffect", function()
			if rising then
				fade = fade + 2000*FrameTime()
				if fade >= 1000 then 
					fade = 255
					rising = false
				end
			else
				fade = fade - 100*FrameTime()
				if fade <= 0 then
					hook.Remove("RenderScreenspaceEffects", "DrawNukeEffect")
				end
			end
			surface.SetDrawColor(255,255,255,fade)
			surface.DrawRect(-ScrW(),-ScrH(),ScrW()*2,ScrH()*2)
		end)
	end
	
	//Receivers 
	net.Receive( "nzPowerUps.Sync", ReceivePowerupSync )
	net.Receive( "nzPowerUps.SyncPlayer", ReceivePowerupPlayerSync )
	net.Receive( "nzPowerUps.Nuke", ReceiveNukeEffect )
end
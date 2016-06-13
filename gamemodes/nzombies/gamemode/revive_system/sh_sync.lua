//Client Server Syncing

if SERVER then

	util.AddNetworkString( "nzRevivePlayerFull" )
	util.AddNetworkString( "nzRevivePlayerDowned" )
	util.AddNetworkString( "nzRevivePlayerRevived" )
	util.AddNetworkString( "nzRevivePlayerBeingRevived" )
	util.AddNetworkString( "nzRevivePlayerKilled" )


	function Revive:SendPlayerFullData(ply, receiver)
		local data = table.Copy(self.Players[ply:EntIndex()])

		net.Start( "nzRevivePlayerFull" )
			net.WriteInt(ply:EntIndex(), 13)
			net.WriteTable( data )
		return receiver and net.Send(receiver) or net.Broadcast()
	end

	function Revive:SendPlayerDowned(ply, receiver, attdata)
		attdata = attdata or {}
		net.Start( "nzRevivePlayerDowned" )
			net.WriteInt(ply:EntIndex(), 13)
			net.WriteTable(attdata)
		return receiver and net.Send(receiver) or net.Broadcast()
	end

	function Revive:SendPlayerRevived(ply, receiver)
		net.Start( "nzRevivePlayerRevived" )
			net.WriteInt(ply:EntIndex(), 13)
		return receiver and net.Send(receiver) or net.Broadcast()
	end

	function Revive:SendPlayerBeingRevived(ply, revivor, receiver)
		net.Start( "nzRevivePlayerBeingRevived" )
			net.WriteInt(ply:EntIndex(), 13)
			if IsValid(revivor) then
				net.WriteBool(true)
				net.WriteInt(revivor:EntIndex(), 13)
			else -- No valid revivor means the player stopped being revived
				net.WriteBool(false)
			end
		return receiver and net.Send(receiver) or net.Broadcast()
	end

	function Revive:SendPlayerKilled(ply, receiver)
		net.Start( "nzRevivePlayerKilled" )
			net.WriteInt(ply:EntIndex(), 13)
		return receiver and net.Send(receiver) or net.Broadcast()
	end

	FullSyncModules["Revive"] = function(ply)
		for k,v in pairs(player.GetAll()) do
			if !v:GetNotDowned() then -- Player needs to be downed
				Revive:SendPlayerFullData(v, ply)
			end
		end
	end
end

if CLIENT then

	local function ReceivePlayerDowned()
		local id = net.ReadInt(13)
		local attached = net.ReadTable()
		
		Revive.Players[id] = Revive.Players[id] or {}
		Revive.Players[id].DownTime = CurTime()
		
		for k,v in pairs(attached) do
			print(k,v)
			Revive.Players[id][k] = v
		end
		
		local ply = Entity(id)
		if IsValid(ply) and ply:IsPlayer() then
			ply:AnimRestartGesture(GESTURE_SLOT_GRENADE, ACT_HL2MP_SIT_PISTOL)
			Revive:DownedHeadsUp(ply, "needs to be revived!")
		end
	end

	local function ReceivePlayerRevived()
		local id = net.ReadInt(13)
		Revive.Players[id] = nil
		local ply = Entity(id)
		if IsValid(ply) and ply:IsPlayer() then
			ply:AnimResetGestureSlot(GESTURE_SLOT_GRENADE)
			if ply == LocalPlayer() then Revive:ResetColorFade() end
			Revive:DownedHeadsUp(ply, "has been revived!")
		end
	end

	local function ReceivePlayerBeingRevived()
		local id = net.ReadInt(13)
		local bool = net.ReadBool()
		if bool then
			local revivor = Entity(net.ReadInt(13))
			Revive.Players[id] = Revive.Players[id] or {}
			if !Revive.Players[id].ReviveTime then
				Revive.Players[id].ReviveTime = CurTime()
				Revive.Players[id].RevivePlayer = revivor
			end
		else
			Revive.Players[id] = Revive.Players[id] or {}
			Revive.Players[id].ReviveTime = nil
			Revive.Players[id].RevivePlayer = nil
		end
	end

	local function ReceivePlayerKilled()
		local id = net.ReadInt(13)
		Revive.Players[id] = nil
		local ply = Entity(id)
		if IsValid(ply) and ply:IsPlayer() then
			ply:AnimResetGestureSlot(GESTURE_SLOT_GRENADE)
			if ply == LocalPlayer() then Revive:ResetColorFade() end
			Revive:DownedHeadsUp(ply, "has died!")
		end
	end

	local function ReceiveFullPlayerSync()
		local id = net.ReadInt(13)
		local data = net.ReadTable()
		Revive.Players[id] = data
		local ply = Entity(id)
		if IsValid(ply) and ply:IsPlayer() then
			ply:AnimRestartGesture(GESTURE_SLOT_GRENADE, ACT_HL2MP_SIT_PISTOL)
			Revive:DownedHeadsUp(ply, "has been downed!")
		end
	end

	//Receivers
	net.Receive( "nzRevivePlayerDowned", ReceivePlayerDowned )
	net.Receive( "nzRevivePlayerRevived", ReceivePlayerRevived )
	net.Receive( "nzRevivePlayerBeingRevived", ReceivePlayerBeingRevived )
	net.Receive( "nzRevivePlayerKilled", ReceivePlayerKilled )
	net.Receive( "nzRevivePlayerFull", ReceiveFullPlayerSync )
end

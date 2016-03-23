//
if SERVER then
	hook.Add("Think", "CheckDownedPlayersTime", function()
		for k,v in pairs(Revive.Players) do
			//The time it takes for a downed player to die - Prevent dying if being revived
			if CurTime() - v.DownTime >= nz.Config.DownTime and !v.ReviveTime then
				Entity(k):KillDownedPlayer()
			end
		end
	end)
end

function Revive.HandleRevive(ply, ent)
	--print(ply, ent)
	
	//Make sure other downed players can't revive other downed players next to them
	if !Revive.Players[ply:EntIndex()] then
	
		local tr = util.QuickTrace(ply:EyePos(), ply:GetAimVector()*100, ply)
		local dply = tr.Entity
		--print(dply)
		
		if IsValid(dply) and (dply:IsPlayer() or dply:GetClass() == "whoswho_downed_clone") then
			local id = dply:EntIndex()
			if Revive.Players[id] then
				if !Revive.Players[id].RevivePlayer then
					dply:StartRevive(ply)
				end
				
				-- print(CurTime() - Revive.Players[id].ReviveTime)
				
				if ply:HasPerk("revive") and CurTime() - Revive.Players[id].ReviveTime >= 2 //With quick-revive
				or CurTime() - Revive.Players[id].ReviveTime >= 5 then	//5 is the time it takes to revive
					dply:RevivePlayer()
					ply.Reviving = nil
				end
			end
		else
			if IsValid(ply.Reviving) and ply.Reviving != dply then -- Holding E on another player or no player
				local id = ply.Reviving:EntIndex()
				if Revive.Players[id] then 
					if Revive.Players[id].ReviveTime then 
						Revive.Players[id].ReviveTime = nil
						Revive.Players[id].RevivePlayer = nil
						--ply:SetMoveType(MOVETYPE_WALK)
						ply.Reviving:StopRevive()
						ply.Reviving = nil
					end
				end
			end
		end
		
		-- When a player stops reviving
		if !ply:KeyDown(IN_USE) then -- If you have an old revival target
			if IsValid(ply.Reviving) and (ply.Reviving:IsPlayer() or ply.Reviving:GetClass() == "whoswho_downed_clone") then
				local id = ply.Reviving:EntIndex()
				if Revive.Players[id] then 
					if Revive.Players[id].ReviveTime then 
						Revive.Players[id].ReviveTime = nil
						Revive.Players[id].RevivePlayer = nil
						--ply:SetMoveType(MOVETYPE_WALK)
						ply.Reviving:StopRevive()
						ply.Reviving = nil
						--nz.Revive.Functions.SendSync()
					end
				end
			end
		end
	
	end
end

//Hooks
hook.Add("FindUseEntity", "CheckRevive", Revive.HandleRevive)

if SERVER then
	util.AddNetworkString("nz_TombstoneSuicide")
	
	net.Receive("nz_TombstoneSuicide", function(len, ply)
		if ply:GetDownedWithTombstone() then
			local tombstone = ents.Create("drop_tombstone")
			tombstone:SetPos(ply:GetPos() + Vector(0,0,50))
			tombstone:Spawn()
			local weps = {}
			for k,v in pairs(ply:GetWeapons()) do
				table.insert(weps, {class = v:GetClass(), pap = v.pap})
			end
			local perks = ply.OldPerks
			
			tombstone.OwnerData.weps = weps
			tombstone.OwnerData.perks = perks
			
			ply:KillDownedPlayer()
			tombstone:SetPerkOwner(ply)
		end
	end)
end

if SERVER then
	util.AddNetworkString("nz_WhosWhoActive")
end

function Revive:CreateWhosWhoClone(ply, pos)
	local pos = pos or ply:GetPos()
	
	local wep = IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() != "nz_perk_bottle" and ply:GetActiveWeapon():GetClass() or ply.oldwep or nil
	
	local who = ents.Create("whoswho_downed_clone")
	who:SetPos(pos)
	who:SetAngles(ply:GetAngles())
	who:Spawn()
	who:GiveWeapon(wep)
	who:SetPerkOwner(ply)
	who:SetModel(ply:GetModel())
	who.OwnerData.perks = ply.OldPerks or ply:GetPerks()
	local weps = {}
	for k,v in pairs(ply:GetWeapons()) do
		table.insert(weps, {class = v:GetClass(), pap = v.pap, speed = v.speed, dtap = v.dtap})
	end
	who.OwnerData.weps = weps
	
	timer.Simple(0.1, function()
		if IsValid(who) then
			local id = who:EntIndex()
			self.Players[id] = {}
			self.Players[id].DownTime = CurTime()
			
			hook.Call("PlayerDowned", Revive, who)
		end
	end)
	
	ply.WhosWhoClone = who
	ply.WhosWhoMoney = 0
	
	net.Start("nz_WhosWhoActive")
		net.WriteBool(true)
	net.Send(ply)
end

function Revive:RespawnWithWhosWho(ply, pos)
	local pos = pos or nil
	
	if !pos then
		local areas = {}
		local plypos = ply:GetPos()
		for k,v in pairs(navmesh.Find(plypos, 1250, 100, 100)) do
			if nz.Nav.Functions.IsPosInSameNavGroup(plypos, v:GetCenter()) then
				table.insert(areas, v:GetID())
			end
		end
		for k,v in pairs(navmesh.Find(plypos, 750, 100, 100)) do
			if table.HasValue(areas, v:GetID()) then
				table.RemoveByValue(areas, v:GetID())
			end
		end
		
		pos = navmesh.GetNavAreaByID(table.Random(areas)):GetRandomPoint() + Vector(0,0,20)
	end
	ply:RevivePlayer()
	ply:StripWeapons()
	
	-- Give starting weapons
	if Mapping.Settings.startwep then
		ply:Give( Mapping.Settings.startwep )
	elseif IsValid(ents.FindByClass("player_handler")[1]) then
		local ent = ents.FindByClass("player_handler")[1]
		ply:Give( ent:GetStartWep() )
	else
		for k,v in pairs(nz.Config.BaseStartingWeapons) do
			ply:Give( v )
		end
	end
	nz.Weps.Functions.GiveMaxAmmo(ply)
	
	ply:SetPos(pos)

end
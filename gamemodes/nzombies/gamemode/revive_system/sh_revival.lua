--
local revivefailtime = 0.2

if SERVER then
	hook.Add("Think", "CheckDownedPlayersTime", function()
		for k,v in pairs(nzRevive.Players) do
			-- The time it takes for a downed player to die - Prevent dying if being revived
			if CurTime() - v.DownTime >= GetConVar("nz_downtime"):GetFloat() and !v.ReviveTime then
				local ent = Entity(k)
				if ent.KillDownedPlayer then
					ent:KillDownedPlayer()
				else
					-- If it's a non-player entity, do the same thing just to clean up the table
					local revivor = v.RevivePlayer
					if IsValid(revivor) then
						revivor:StripWeapon("nz_revive_morphine")
					end
					nzRevive.Players[k] = nil
				end
			end
		end
	end)
end

function nzRevive.HandleRevive(ply, ent)
	--print(ply, ent)

	-- Make sure other downed players can't revive other downed players next to them
	if !nzRevive.Players[ply:EntIndex()] then

		local tr = util.QuickTrace(ply:EyePos(), ply:GetAimVector()*100, ply)
		local dply = tr.Entity
		local ct = CurTime()
		--print(dply)

		if IsValid(dply) and (dply:IsPlayer() or dply:GetClass() == "whoswho_downed_clone") then
			local id = dply:EntIndex()
			if nzRevive.Players[id] then
				if !nzRevive.Players[id].RevivePlayer then
					dply:StartRevive(ply)
				end

				-- print(CurTime() - nzRevive.Players[id].ReviveTime)

				if ply:HasPerk("revive") and ct - nzRevive.Players[id].ReviveTime >= 2 -- With quick-revive
				or ct - nzRevive.Players[id].ReviveTime >= 4 then	-- 4 is the time it takes to revive
					dply:RevivePlayer(ply)
					ply.Reviving = nil
				end
			end
		elseif IsValid(ply.Reviving) and ply.Reviving != dply -- Holding E on another player or no player
		and ct > ply.LastReviveTime + revivefailtime then -- and for longer than fail time window
			local id = ply.Reviving:EntIndex()
			if nzRevive.Players[id] then
				if nzRevive.Players[id].ReviveTime then
					--ply:SetMoveType(MOVETYPE_WALK)
					ply.Reviving:StopRevive()
					ply.Reviving = nil
				end
			end
		end

		-- When a player stops reviving
		if !ply:KeyDown(IN_USE) then -- If you have an old revival target
			if IsValid(ply.Reviving) and (ply.Reviving:IsPlayer() or ply.Reviving:GetClass() == "whoswho_downed_clone") then
				local id = ply.Reviving:EntIndex()
				if nzRevive.Players[id] then
					if nzRevive.Players[id].ReviveTime then
						--ply:SetMoveType(MOVETYPE_WALK)
						ply.Reviving:StopRevive()
						ply.Reviving = nil
						--nz.nzRevive.Functions.SendSync()
					end
				end
			end
		end

	end
end

-- Hooks
hook.Add("FindUseEntity", "CheckRevive", nzRevive.HandleRevive)

if SERVER then
	util.AddNetworkString("nz_TombstoneSuicide")

	net.Receive("nz_TombstoneSuicide", function(len, ply)
		if ply:GetDownedWithTombstone() then
			local tombstone = ents.Create("drop_tombstone")
			tombstone:SetPos(ply:GetPos() + Vector(0,0,50))
			tombstone:Spawn()
			local weps = {}
			for k,v in pairs(ply:GetWeapons()) do
				table.insert(weps, {class = v:GetClass(), pap = v:HasNZModifier("pap")})
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

function nzRevive:CreateWhosWhoClone(ply, pos)
	local pos = pos or ply:GetPos()

	local wep = IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() != "nz_perk_bottle" and ply:GetActiveWeapon():GetClass() or ply.oldwep or nil

	local who = ents.Create("whoswho_downed_clone")
	who:SetPos(pos + Vector(0,0,10))
	who:SetAngles(ply:GetAngles())
	who:Spawn()
	who:GiveWeapon(wep)
	who:SetPerkOwner(ply)
	who:SetModel(ply:GetModel())
	who.OwnerData.perks = ply.OldPerks or ply:GetPerks()
	local weps = {}
	for k,v in pairs(ply:GetWeapons()) do
		table.insert(weps, {class = v:GetClass(), pap = v:HasNZModifier("pap"), speed = v:HasNZModifier("speed"), dtap = v:HasNZModifier("dtap")})
	end
	who.OwnerData.weps = weps

	timer.Simple(0.1, function()
		if IsValid(who) then
			local id = who:EntIndex()
			self.Players[id] = {}
			self.Players[id].DownTime = CurTime()

			hook.Call("PlayerDowned", nzRevive, who)
		end
	end)

	ply.WhosWhoClone = who
	ply.WhosWhoMoney = 0

	net.Start("nz_WhosWhoActive")
		net.WriteBool(true)
	net.Send(ply)
end

function nzRevive:RespawnWithWhosWho(ply, pos)
	local pos = pos or nil

	if !pos then
		local spawns = {}
		local plypos = ply:GetPos()
		local maxdist = 1500^2
		local mindist = 500^2

		local available = ents.FindByClass("nz_spawn_zombie_special")
		if IsValid(available[1]) then
			for k,v in pairs(available) do
				local dist = plypos:DistToSqr(v:GetPos())
				if v.link == nil or nzDoors:IsLinkOpened( v.link ) then -- Only for rooms that are opened (using links)
					if dist < maxdist and dist > mindist then -- Within the range we set above
						if v:IsSuitable() then -- And nothing is blocking it
							table.insert(spawns, v)
						end
					end
				end
			end
			if !IsValid(spawns[1]) then
				for k,v in pairs(available) do -- Retry, but without the range check (just use all of them)
					local dist = plypos:DistToSqr(v:GetPos())
					if v.link == nil or nzDoors:IsLinkOpened( v.link ) then
						if v:IsSuitable() then
							table.insert(spawns, v)
						end
					end
				end
			end
			if !IsValid(spawns[1]) then -- Still no open linked ones?! Spawn at a random player spawnpoint
				local pspawns = ents.FindByClass("player_spawns")
				if !IsValid(pspawns[1]) then
					ply:Spawn()
				else
					pos = pspawns[math.random(#pspawns)]:GetPos()
				end
			else
				pos = spawns[math.random(#spawns)]:GetPos()
			end
		else
			-- There exists no special spawnpoints - Use regular player spawns
			local pspawns = ents.FindByClass("player_spawns")
			if !IsValid(pspawns[1]) then
				ply:Spawn()
			else
				pos = pspawns[math.random(#pspawns)]:GetPos()
			end
		end
	end
	ply:RevivePlayer()
	ply:StripWeapons()
	player_manager.RunClass(ply, "Loadout") -- Rearm them

	if pos then ply:SetPos(pos) end

end

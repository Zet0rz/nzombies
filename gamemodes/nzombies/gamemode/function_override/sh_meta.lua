local playerMeta = FindMetaTable("Player")
local wepMeta = FindMetaTable("Weapon")

if SERVER then
	
	function ReplaceReloadFunction(wep)
		-- Either not a weapon, doesn't have a reload function, or is FAS2
		if wep:NZPerkSpecialTreatment() then return end
		local oldreload = wep.Reload
		if !oldreload then return end
		
		--print("Weapon reload modified")
		
		wep.Reload = function()
			if wep.ReloadFinish and wep.ReloadFinish > CurTime() then return end
			local ply = wep.Owner
			if ply:HasPerk("speed") then
				--print("Hasd perk")
				local cur = wep:Clip1()
				if cur >= wep:GetMaxClip1() then return end
				local give = wep:GetMaxClip1() - cur
				if give > ply:GetAmmoCount(wep:GetPrimaryAmmoType()) then
					give = ply:GetAmmoCount(wep:GetPrimaryAmmoType())
				end
				if give <= 0 then return end
				--print(give)
				
				wep:SendWeaponAnim(ACT_VM_RELOAD)
				oldreload(wep)
				local rtime = wep:SequenceDuration(wep:SelectWeightedSequence(ACT_VM_RELOAD))/2
				wep:SetPlaybackRate(2)
				ply:GetViewModel():SetPlaybackRate(2)

				local nexttime = CurTime() + rtime

				wep:SetNextPrimaryFire(nexttime)
				wep:SetNextSecondaryFire(nexttime)
				wep.ReloadFinish = nexttime
				
				timer.Simple(rtime, function()
					if IsValid(wep) and ply:GetActiveWeapon() == wep then
						wep:SetPlaybackRate(1)
						ply:GetViewModel():SetPlaybackRate(1)
						wep:SendWeaponAnim(ACT_VM_IDLE)
						wep:SetClip1(give + cur)
						ply:RemoveAmmo(give, wep:GetPrimaryAmmoType())
						wep:SetNextPrimaryFire(0)
						wep:SetNextSecondaryFire(0)
					end
				end)
			else
				oldreload(wep)
			end
		end
	end
	hook.Add("WeaponEquip", "nzModifyWeaponReloads", ReplaceReloadFunction)
	
	function ReplacePrimaryFireCooldown(wep)
		local oldfire = wep.PrimaryAttack
		if !oldfire then return end
		
		--print("Weapon fire modified")
		
		wep.PrimaryAttack = function()
			oldfire(wep)
			
			-- FAS2 weapons have built-in DTap functionality
			if wep:IsFAS2() then return end
			-- With double tap, reduce the delay for next primary fire to 2/3
			if wep.Owner:HasPerk("dtap") or wep.Owner:HasPerk("dtap2") then
				local delay = (wep:GetNextPrimaryFire() - CurTime())*0.80
				wep:SetNextPrimaryFire(CurTime() + delay)
			end
		end
	end
	hook.Add("WeaponEquip", "nzModifyWeaponNextFires", ReplacePrimaryFireCooldown)
	
	function ReplaceAimDownSight(wep)
		local oldfire = wep.SecondaryAttack
		if !oldfire then return end
		
		--print("Weapon fire modified")
		
		wep.SecondaryAttack = function()
			oldfire(wep)
			-- With deadshot, aim at the head of the entity aimed at
			if wep.Owner:HasPerk("deadshot") then
				local tr = wep.Owner:GetEyeTrace()
				local ent = tr.Entity
				if IsValid(ent) and nzConfig.ValidEnemies[ent:GetClass()] then
					local head = ent:LookupBone("ValveBiped.Bip01_Neck1")
					if head then
						local headpos,headang = ent:GetBonePosition(head)
						wep.Owner:SetEyeAngles((headpos - wep.Owner:GetShootPos()):Angle())
					end
				end
			end
		end
	end
	hook.Add("WeaponEquip", "nzModifyAimDownSights", ReplaceAimDownSight)
	
	hook.Add("DoAnimationEvent", "nzReloadCherry", function(ply, event, data)
		--print(ply, event, data)
		if event == PLAYERANIMEVENT_RELOAD then
			if ply:HasPerk("cherry") then
				local wep = ply:GetActiveWeapon()
				if IsValid(wep) and wep:Clip1() < wep:GetMaxClip1() then
					local pct = 1 - (wep:Clip1()/wep:GetMaxClip1())
					local pos, ang = ply:GetPos() + ply:GetAimVector()*10 + Vector(0,0,50), ply:GetAimVector()
					nzEffects:Tesla( {
						pos = ply:GetPos() + Vector(0,0,50),
						ent = ply,
						turnOn = true,
						dieTime = 1,
						lifetimeMin = 0.05*pct,
						lifetimeMax = 0.1*pct,
						intervalMin = 0.01,
						intervalMax = 0.02,
					})
					--print(pct)
					local zombies = ents.FindInSphere(ply:GetPos(), 250*pct)
					local d = DamageInfo()
					d:SetDamage( 100*pct )
					d:SetDamageType( DMG_SHOCK )
					d:SetAttacker(ply)
					d:SetInflictor(ply)
					
					for k,v in pairs(zombies) do
						if nzConfig.ValidEnemies[v:GetClass()] then
							v:TakeDamageInfo(d)
						end
					end
				end
			end
		end
	end)
	
	function GM:GetFallDamage( ply, speed )
		local dmg = speed / 10
		if ply:HasPerk("phd") and dmg >= 50 then
			if ply:Crouching() then
				local zombies = ents.FindInSphere(ply:GetPos(), 250)
				for k,v in pairs(zombies) do
					if nzConfig.ValidEnemies[v:GetClass()] then
						v:TakeDamage(150, ply, ply)
					end
				end
				local pos = ply:GetPos()
				local effectdata = EffectData()
				effectdata:SetOrigin( pos )
				util.Effect( "HelicopterMegaBomb", effectdata )
				ply:EmitSound("phx/explode0"..math.random(0, 6)..".wav")
			end
			return 0
		end
		return ( dmg )
	end
	
	local oldsetwep = playerMeta.SetActiveWeapon
	function playerMeta:SetActiveWeapon(wep)
		local oldwep = self:GetActiveWeapon()
		if IsValid(oldwep) and !oldwep:IsSpecial() then
			self.NZPrevWep = oldwep
		end
		oldsetwep(self, wep)
	end
	
else
	
	--[[ Manual speedup of the reload function on FAS2 weapons - seemed like the original solution broke along the way
	function ReplaceReloadFunction(wep)
		print(wep, "HUKDAHD1")
		if wep:IsFAS2() then
			print(wep, "HUKDAHD2")
			local oldreload = wep.Reload
			if !oldreload then return end
			print(wep, "HUKDAHD3")
			wep.Reload = function()
				print(wep, "HUKDAHD4")
				oldreload(wep)
				if LocalPlayer():HasPerk("speed") then
					wep.Wep:SetPlaybackRate(2)
				end
			end
			print(wep, "HUKDAHD5")
		end
	end
	hook.Add("HUDWeaponPickedUp", "ModifyFAS2WeaponReloads", ReplaceReloadFunction)]]
	
end

local olddefreload = wepMeta.DefaultReload
function wepMeta:DefaultReload(act)
	if IsValid(self.Owner) and self.Owner:HasPerk("speed") then return end
	olddefreload(self, act)
end

local ghosttraceentities = {
	["wall_block"] = true,
	["invis_wall"] = true,
	["player"] = true,
}

function GM:EntityFireBullets(ent, data)

	-- Fire the PaP shooting sound if the weapon is PaP'd
	--print(wep, wep:HasNZModifier("pap"))
	if ent:IsPlayer() and IsValid(ent:GetActiveWeapon()) and ent:GetActiveWeapon():HasNZModifier("pap") then
		ent:EmitSound("nz/effects/pap_shoot_glock20.wav", 60, 100, 0.7)
	end

	-- Perform a trace that filters out entities from the table above
	local tr = util.TraceLine({
		start = data.Src,
		endpos = data.Src + (data.Dir*data.Distance),
		filter = function(ent) 
			if ghosttraceentities[ent:GetClass()] then
				return false
			else
				return true
			end 
		end
	})
	
	--PrintTable(tr)
	
	-- If we hit anything, move the source of the bullets up to that point
	if tr.Hit and tr.HitPos then
		data.Src = tr.HitPos - data.Dir*5
		if ent:IsPlayer() and ent:HasPerk("dtap2") then
			data.Num = data.Num * 2
		end
		return true
	elseif ent:IsPlayer() and ent:HasPerk("dtap2") then
		data.Num = data.Num * 2
	end
end

-- This is so awkward ._.
-- game.AddAmmoType doesn't take duplicates into account and has a hardcoded limit of 128
-- which means our ammo types won't exist if we pass that limit with the countless duplicates :(
local oldaddammo = game.AddAmmoType
local alreadyexist = alreadyexist or {}
function game.AddAmmoType( tbl ) -- Let's prevent that!
	if tbl.name and !alreadyexist[tbl.name] then -- Only if the ammo doesn't already exist!
		oldaddammo(tbl) -- THEN we can proceed with normal procedure!
		alreadyexist[tbl.name] = true
	end
end
-- This doesn't work for lua scripts run before the gamemode, but should help for weapons adding ammo types on-the-fly!
-- This will also prevent some ammo types from being added - that's fine. Our gamemode doesn't need them.
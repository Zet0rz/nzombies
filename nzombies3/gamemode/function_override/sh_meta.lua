local playerMeta = FindMetaTable("Player")
local wepMeta = FindMetaTable("Weapon")

if SERVER then
	
	function ReplaceReloadFunction(wep)
		//Either not a weapon, doesn't have a reload function, or is FAS2
		if nz.Weps.Functions.IsFAS2(wep) then return end
		local oldreload = wep.Reload
		
		--print("Weapon reload modified")
		
		wep.Reload = function()
			if wep.ReloadFinish and wep.ReloadFinish > CurTime() then return end
			local ply = wep.Owner
			if ply:HasPerk("speed") then
				--print("Hasd perk")
				local cur = wep:Clip1()
				if cur >= wep:GetMaxClip1() then return end
				
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
						wep:SetClip1(wep:GetMaxClip1())
						ply:RemoveAmmo(wep:GetMaxClip1() - cur, wep:GetPrimaryAmmoType())
						wep:SetNextPrimaryFire(0)
						wep:SetNextSecondaryFire(0)
					end
				end)
			else
				oldreload(wep)
			end
		end
	end
	hook.Add("WeaponEquip", "ModifyWeaponReloads", ReplaceReloadFunction)
	
	function ReplacePrimaryFireCooldown(wep)
		local oldfire = wep.PrimaryAttack
		
		--print("Weapon fire modified")
		
		wep.PrimaryAttack = function()
			oldfire(wep)
			
			//FAS2 weapons have built-in DTap functionality
			if nz.Weps.Functions.IsFAS2(wep) then return end
			//With double tap, reduce the delay for next primary fire to 2/3
			if wep.Owner:HasPerk("dtap") or wep.Owner:HasPerk("dtap2") then
				local delay = (wep:GetNextPrimaryFire() - CurTime())*0.66
				wep:SetNextPrimaryFire(CurTime() + delay)
			end
		end
	end
	hook.Add("WeaponEquip", "ModifyWeaponNextFires", ReplacePrimaryFireCooldown)
	
	function ReplacePrimaryFireCooldown(wep)
		local oldfire = wep.SecondaryAttack
		
		--print("Weapon fire modified")
		
		wep.SecondaryAttack = function()
			oldfire(wep)
			//With deadshot, aim at the head of the entity aimed at
			if wep.Owner:HasPerk("deadshot") then
				local tr = wep.Owner:GetEyeTrace()
				local ent = tr.Entity
				if IsValid(ent) and nz.Config.ValidEnemies[ent:GetClass()] then
					local head = ent:LookupBone("ValveBiped.Bip01_Neck1")
					local headpos,headang = ent:GetBonePosition(head)
					wep.Owner:SetEyeAngles((headpos - wep.Owner:GetShootPos()):Angle())
				end
			end
		end
	end
	hook.Add("WeaponEquip", "ModifyWeaponNextFires", ReplacePrimaryFireCooldown)
	
	hook.Add("DoAnimationEvent", "ReloadCherry", function(ply, event, data)
		--print(ply, event, data)
		if event == PLAYERANIMEVENT_RELOAD then
			if ply:HasPerk("cherry") then
				local wep = ply:GetActiveWeapon()
				if IsValid(wep) and wep:Clip1() < wep:GetMaxClip1() then
					local pct = 1 - (wep:Clip1()/wep:GetMaxClip1())
					local pos, ang = ply:GetPos() + ply:GetAimVector()*10 + Vector(0,0,50), ply:GetAimVector()
					timer.Create("Cherry"..ply:EntIndex(), 0.1, 5, function()
						if IsValid(ply) then
							--print("effect here")
							local effectdata = EffectData()
							effectdata:SetOrigin( pos )
							effectdata:SetNormal( ang )
							effectdata:SetMagnitude( 8 )
							effectdata:SetScale( 1 )
							effectdata:SetRadius( 16 )
							util.Effect( "TeslaHitBoxes", effectdata )
						end
					end)
					print(pct)
					local zombies = ents.FindInSphere(ply:GetPos(), 200*pct)
					for k,v in pairs(zombies) do
						if nz.Config.ValidEnemies[v:GetClass()] then
							v:TakeDamage(100*pct, ply, ply)
							--[[timer.Create("Cherry"..v:EntIndex(), 0.1, 5, function()
								if IsValid(v) then
									print("effect here")
									local effectdata = EffectData()
									effectdata:SetOrigin( v:GetPos() )
									effectdata:SetNormal( v:GetAimVector() )
									effectdata:SetMagnitude( 8 )
									effectdata:SetScale( 1 )
									effectdata:SetRadius( 16 )
									util.Effect( "TeslaHitBoxes", effectdata )
								end
							end)]]
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
				local zombies = ents.FindInSphere(ply:GetPos(), 200)
				for k,v in pairs(zombies) do
					if nz.Config.ValidEnemies[v:GetClass()] then
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
	
else
	
	-- Manual speedup of the reload function on FAS2 weapons - seemed like the original solution broke along the way
	function ReplaceReloadFunction(wep)
		if wep.Category == "FA:S 2 Weapons" then
			local oldreload = wep.Reload
			wep.Reload = function()
				oldreload(wep)
				if LocalPlayer():HasPerk("speed") then
					wep.Wep:SetPlaybackRate(2)
				end
			end
		end
	end
	hook.Add("HUDWeaponPickedUp", "ModifyFAS2WeaponReloads", ReplaceReloadFunction)
	
end

local olddefreload = wepMeta.DefaultReload
function wepMeta:DefaultReload(act)
	if IsValid(self.Owner) and self.Owner:HasPerk("speed") then return end
	olddefreload(self, act)
end

function GM:EntityFireBullets(ent, data)

	//Fire the PaP shooting sound if the weapon is PaP'd
	--print(wep, wep.pap)
	if ent:IsPlayer() and IsValid(ent:GetActiveWeapon()) and ent:GetActiveWeapon().pap then
		wep:EmitSound("nz/effects/pap_shoot_glock20.wav", 105, 100)
	end

	//Perform a trace that filters out wall blocks
	local tr = util.TraceLine({
		start = data.Src,
		endpos = data.Src + (data.Dir*data.Distance),
		filter = function(ent) 
			if ent:GetClass() == "wall_block" then
				return false
			else
				return true
			end 
		end
	})
	
	--PrintTable(tr)
	
	//If we hit anything, move the source of the bullets up to that point
	if tr.Hit and tr.HitPos then
		data.Src = tr.HitPos - data.Dir
		if ent:HasPerk("dtap2") and !ent.dtap2 then
			local data2 = table.Copy(data)
			data2.Spread = Vector(0.2, 0.2, 0)
			ent.dtap2 = true
			ent:FireBullets(data2)
			ent.dtap2 = nil
		end
		return true
	elseif ent:HasPerk("dtap2") and !ent.dtap2 then
		local data2 = table.Copy(data)
		data2.Spread = Vector(0.2, 0.2, 0)
		ent.dtap2 = true
		ent:FireBullets(data2)
		ent.dtap2 = nil
	end
end
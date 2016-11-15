
local function RegisterDefaultSpecialWeps()
	nzSpecialWeapons:AddKnife( "nz_quickknife_crowbar", false, 0.65 )
	nzSpecialWeapons:AddKnife( "nz_bowie_knife", true, 0.65, 2.5 )
	nzSpecialWeapons:AddKnife( "nz_one_inch_punch", true, 0.75, 1.5 )
	
	nzSpecialWeapons:AddGrenade( "nz_grenade", 4, nil, 0.85, nil, 0.4 )
	nzSpecialWeapons:AddSpecialGrenade( "nz_monkey_bomb", 3, nil, 3, nil, 0.4 )
	
	nzSpecialWeapons:AddDisplay( "nz_revive_morphine", nil, function(wep)
		return !IsValid(wep.Owner:GetPlayerReviving())
	end)
	
	nzSpecialWeapons:AddDisplay( "nz_perk_bottle", nil, function(wep)
		return SERVER and CurTime() > wep.nzDeployTime + 3.1
	end)
	
	nzSpecialWeapons:AddDisplay( "nz_packapunch_arms", nil, function(wep)
		return SERVER and CurTime() > wep.nzDeployTime + 2.5
	end)
end

hook.Add("InitPostEntity", "nzRegisterSpecialWeps", RegisterDefaultSpecialWeps)
--hook.Add("OnReloaded", "nzRegisterSpecialWeps", RegisterDefaultSpecialWeps)
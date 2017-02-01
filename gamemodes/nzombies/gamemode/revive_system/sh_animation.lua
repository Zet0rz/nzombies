
local function HandlePlayerDowned(ply, vel)
	if !ply:GetNotDowned() then
	
		ply.CalcIdeal = ACT_HL2MP_SWIM_REVOLVER
		
		local len = vel:Length2D()
		if ( len <= 1 ) then
			ply.CalcIdeal = ACT_HL2MP_SWIM_PISTOL
		end
		
		return ply.CalcIdeal, ply.CalcSeqOverride
	end
end
hook.Add("CalcMainActivity", "nzPlayerDownedAnims", HandlePlayerDowned)

local function PlayerDownedParameters(ply, vel, seqspeed)
	if !ply:GetNotDowned() then
		local len = vel:Length2D()
		local movement = 0

		if ( len > 1 ) then
			movement = ( len / seqspeed )
		elseif math.Round(ply:GetCycle(), 1) != 0.7 then
			movement = 5
		end

		local rate = math.min( movement, 1 )
		
		ply:SetPoseParameter("move_x", -1)
		ply:SetPlaybackRate( movement )
		
		if !ply.NZDownedAnim then
			ply:SetHull(Vector(-16,-16,25), Vector(16,16,97))
			ply.NZDownedAnim = true
		end

		--ply:SetNetworkOrigin(ply:GetPos() - Vector(0,0,20))
		--
		return true
	elseif ply.NZDownedAnim then
		--ply:SetPos(ply:GetPos() + Vector(0,0,25))
		ply:ResetHull()
		ply.NZDownedAnim = false
	end
end
hook.Add("UpdateAnimation", "nzPlayerDownedAnims", PlayerDownedParameters)

if CLIENT then
	local function RenderDownedPlayers(ply)
		if !ply:GetNotDowned() then
			ply:SetRenderOrigin(ply:GetPos() - Vector(0,0,50))
			local ang = ply:GetAngles()
			ply:SetRenderAngles(Angle(-30,ang[2],ang[3]))
			ply:InvalidateBoneCache()
			
			local wep = ply:GetActiveWeapon()
			if IsValid(wep) then wep:InvalidateBoneCache() end
		end
	end
	hook.Add("PrePlayerDraw", "nzPlayerDownedAnims", RenderDownedPlayers)
end
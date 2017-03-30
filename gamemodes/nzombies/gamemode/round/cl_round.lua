function nzRound:GetEndTime()
	return GetGlobalFloat( "gwEndTime", 0 )
end

local states = {
	[ROUND_INIT] = "OnRoundInit",
	[ROUND_PREP] = "OnRoundPreparation",
	[ROUND_PROG] = "OnRoundStart",
	[ROUND_GO] = "OnRoundEnd",
	[ROUND_CREATE] = "OnRoundCreative",
}

function nzRound:StateChange( old, new )
	if new == ROUND_WAITING then
		nzRound:EnableSpecialFog( false )
		hook.Call( "OnRoundWating", nzRound )
	else
		hook.Call( states[new], nzRound )
	end
	hook.Call( "OnRoundChangeState", nzRound, new, old )
end

function nzRound:OnRoundPreperation()
	if !self:IsSpecial() then
		self:EnableSpecialFog(false)
	end
end

function nzRound:OnRoundStart()
	if self:IsSpecial() then
		self:EnableSpecialFog(true)
	else
		self:EnableSpecialFog(false)
	end
end

net.Receive("nz_hellhoundround", function()
	if net.ReadBool() then
		hook.Call( "OnSpecialRoundStart" )
		surface.PlaySound("nz/round/dog_start.wav")
	end
end)
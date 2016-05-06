function nzRound:GetEndTime()
	return GetGlobalFloat( "gwEndTime", 0 )
end

function nzRound:StateChange( old, new )
	if new == ROUND_WAITING then
		nzRound:EnableSpecialFog( false )
		hook.Call( "OnRoundWating", nzRound )
	elseif new == ROUND_INIT then
		hook.Call( "OnRoundInit", nzRound )
	elseif new == ROUND_PREP then
		hook.Call( "OnRoundPreperation", nzRound )
	elseif new == ROUND_PROG then
		hook.Call( "OnRoundStart", nzRound )
	elseif new == ROUND_GO then
		hook.Call( "OnRoundEnd", nzRound )
	end
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
		surface.PlaySound("nz/round/dog_start.wav")
	end
end)
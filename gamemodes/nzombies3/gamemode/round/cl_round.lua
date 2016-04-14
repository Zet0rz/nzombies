function Round:GetEndTime()
	return GetGlobalFloat( "gwEndTime", 0 )
end

function Round:StateChange( old, new )
	if new == ROUND_WAITING then
		hook.Call( "OnRoundWating", Round )
	elseif new == ROUND_INIT then
		hook.Call( "OnRoundInit", Round )
	elseif new == ROUND_PREP then
		hook.Call( "OnRoundPreperation", Round )
	elseif new == ROUND_PROG then
		hook.Call( "OnRoundStart", Round )
	elseif new == ROUND_GO then
		hook.Call( "OnRoundEnd", Round )
	end
end

function Round:OnRoundPreperation()
	if !self:IsSpecial() then
		self:EnableSpecialFog(false)
	end
end

function Round:OnRoundStart()
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
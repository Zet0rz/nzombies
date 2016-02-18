function Round:GetState() return self.State end
function Round:SetState( state ) self.State = state end

function Round:GetNumber() return self.Number or 0 end
function Round:SetNumber( num ) self.Number = num end

function Round:IsSpecial() return self.SpecialRound or false end
function Round:SetSpecial( bool ) self.SpecialRound = bool end

function Round:InState( state )
	return Round:GetState() == state
end

function Round:InProgress()
	return Round:GetState() == ROUND_PREP or Round:GetState() == ROUND_PROG
end
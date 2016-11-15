-- Main Tables
nzElec = nzElec or AddNZModule("Elec")

-- Variables
nzElec.Active = false

function nzElec.IsOn()
	return nzElec.Active
end

IsElec = nzElec.IsOn

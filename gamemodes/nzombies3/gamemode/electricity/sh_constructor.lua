//Main Tables
nzElec = {}
Elec = nzElec

//_ Variables
Elec.Active = false

function Elec.IsOn()
	return Elec.Active
end

IsElec = Elec.IsOn
//Main Tables
nz.Elec = {}
nz.Elec.Functions = {}
nz.Elec.Data = {}

//_ Variables
nz.Elec.Data.Active = false

function nz.Elec.Functions.IsElec()
	return nz.Elec.Data.Active
end

IsElec = nz.Elec.Functions.IsElec
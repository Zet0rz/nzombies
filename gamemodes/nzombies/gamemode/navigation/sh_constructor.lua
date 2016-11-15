-- Main Tables
nzNav = nzNav or AddNZModule("Nav")
nzNav.Locks = nzNav.Locks or {}

function IsNavApplicable(ent)
	-- All classes that can be linked with navigation
	if !IsValid(ent) then return false end
	if (ent:IsDoor() or ent:IsBuyableProp() or ent:IsButton()) and ent:GetDoorData().link then
		return true
	else
		return false
	end
end

function nzNav.FlushAllNavModifications()
	nzNav.Locks = {}
end
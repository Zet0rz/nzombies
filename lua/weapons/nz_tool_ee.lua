SWEP.PrintName	= "Easter Egg Tool"
SWEP.Author		= "Alig96"
SWEP.Slot		= 5
SWEP.SlotPos	= 8
SWEP.Base 		= "nz_tool_base"

if SERVER then

	function SWEP:OnPrimaryAttack( trace )
		nz.Mapping.Functions.EasterEgg(trace.HitPos, Angle(0,0,0), "models/props_lab/huladoll.mdl", self.Owner)
	end

	function SWEP:OnSecondaryAttack( trace )
		if trace.Entity:GetClass() == "easter_egg" then
			trace.Entity:Remove()
		end
	end
end

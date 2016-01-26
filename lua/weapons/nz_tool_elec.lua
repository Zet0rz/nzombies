SWEP.PrintName	= "Electric Placer Tool"	
SWEP.Author		= "Alig96"		
SWEP.Slot		= 5
SWEP.SlotPos	= 9
SWEP.Base 		= "nz_tool_base"

if SERVER then
	function SWEP:OnPrimaryAttack( trace )
		nz.Mapping.Functions.Electric(trace.HitPos, trace.HitNormal:Angle() - Angle( 270, 0, 0 ), nil, self.Owner)
	end

	function SWEP:OnSecondaryAttack( trace )
		
	end
end
SWEP.PrintName	= "Tool Name"	
SWEP.Author		= "UserName"		
SWEP.Slot		= 0	
SWEP.SlotPos	= 10
SWEP.Base 		= "nz_tool_base"

if SERVER then
	function SWEP:OnPrimaryAttack( trace )
		PrintTable(trace)
	end

	function SWEP:OnSecondaryAttack( trace )
		PrintTable(trace)
	end
	function SWEP:OnReload( trace )
		print(trace)
	end
end
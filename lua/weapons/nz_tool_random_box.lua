SWEP.PrintName	= "Random Box Tool"	
SWEP.Author		= "Alig96"		
SWEP.Slot		= 5	
SWEP.SlotPos	= 10
SWEP.Base 		= "nz_tool_base"

if SERVER then
	function SWEP:OnPrimaryAttack( trace )
		nz.Mapping.Functions.BoxSpawn(trace.HitPos,Angle(0,0,0), self.Owner)
	end

	function SWEP:OnSecondaryAttack( trace )
		if trace.Entity:GetClass() == "random_box_spawns" then
			trace.Entity:Remove()
		end
	end	
end
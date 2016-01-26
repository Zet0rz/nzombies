SWEP.PrintName	= "Perk Machine Spawn Placer Tool"
SWEP.Author		= "Alig96"
SWEP.Slot		= 5
SWEP.SlotPos	= 8
SWEP.Base 		= "nz_tool_base"

if SERVER then

	function SWEP:OnPrimaryAttack( trace )
		nz.Mapping.Functions.PerkMachine(trace.HitPos, Angle(0,0,0), "jugg", self.Owner)
	end

	function SWEP:OnSecondaryAttack( trace )
		if trace.Entity:GetClass() == "perk_machine" then
			trace.Entity:Remove()
		end
	end

	function SWEP:OnReload( trace )
		if trace.Entity:GetClass() == "perk_machine" then
			nz.Interfaces.Functions.SendInterface(self.Owner, "PerkMachine", {ent = trace.Entity})
		end
	end

end

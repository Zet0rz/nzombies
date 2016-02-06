SWEP.PrintName	= "Zombie Spawn Placer Tool"
SWEP.Author		= "Alig96"
SWEP.Slot		= 1
SWEP.SlotPos	= 10
SWEP.Base 		= "nz_tool_base"
 
if SERVER then
	function SWEP:OnPrimaryAttack( trace )
		nz.Mapping.Functions.ZedSpawn(trace.HitPos, nil, nil, self.Owner)
	end

	function SWEP:OnSecondaryAttack( trace )
		if trace.Entity:GetClass() == "zed_spawns" then
			trace.Entity:Remove()
		end
	end

	function SWEP:OnReload( trace )
		if trace.Entity:GetClass() == "zed_spawns" then
			nz.Interfaces.Functions.SendInterface(self.Owner, "ZombLink", {ent = trace.Entity, link = trace.Entity.link, spawnable = trace.Entity.spawnable, respawnable = trace.Entity.respawnable})
		end
	end
end

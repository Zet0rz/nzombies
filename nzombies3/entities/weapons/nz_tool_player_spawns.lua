SWEP.PrintName	= "Player Spawn Placer Tool"	
SWEP.Author		= "Alig96"		
SWEP.Slot		= 1	
SWEP.SlotPos	= 9
SWEP.Base 		= "nz_tool_base"

if SERVER then
	function SWEP:OnPrimaryAttack( trace )
		nz.Mapping.Functions.PlayerSpawn(trace.HitPos, self.Owner)
	end

	function SWEP:OnSecondaryAttack( trace )
		if trace.Entity:GetClass() == "player_spawns" then
			trace.Entity:Remove()
		end
	end
end
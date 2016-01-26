SWEP.PrintName	= "Player Data Handler"
SWEP.Author		= "Alig96"
SWEP.Slot		= 1
SWEP.SlotPos	= 12
SWEP.Base 		= "nz_tool_base"

if SERVER then
	function SWEP:OnPrimaryAttack( trace )
		nz.Interfaces.Functions.SendInterface(self.Owner, "PlayerHandler", {vec = trace.HitPos, ang = Angle(0,0,0)})
	end

	function SWEP:OnSecondaryAttack( trace )
		if trace.Entity:GetClass() == "player_handler" then
			trace.Entity:Remove()
		end
	end
	function SWEP:OnReload( trace )
		if trace.Entity:GetClass() == "player_handler" then
			nz.Interfaces.Functions.SendInterface(self.Owner, "PlayerHandler", {vec = trace.HitPos, ang = Angle(0,0,0), keep = true})
		end
	end
end

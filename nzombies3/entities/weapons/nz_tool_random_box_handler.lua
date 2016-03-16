SWEP.PrintName	= "Random Box Handler"
SWEP.Author		= "Alig96"
SWEP.Slot		= 5
SWEP.SlotPos	= 11
SWEP.Base 		= "nz_tool_base"

if SERVER then
	function SWEP:OnPrimaryAttack( trace )
		//nz.Mapping.Functions.WallBuy(trace.HitPos, "fas2_ak47", 100, trace.HitNormal:Angle()+Angle(0,270,0))
		nz.Interfaces.Functions.SendInterface(self.Owner, "RBoxHandler", {vec = trace.HitPos, ang = Angle(0,0,0)})
	end

	function SWEP:OnSecondaryAttack( trace )
		if trace.Entity:GetClass() == "random_box_handler" then
			trace.Entity:Remove()
		end
	end
	function SWEP:OnReload( trace )
		if trace.Entity:GetClass() == "random_box_handler" then
			nz.Interfaces.Functions.SendInterface(self.Owner, "RBoxHandler", {vec = trace.HitPos, ang = Angle(0,0,0), keep = true})
		end
	end
end

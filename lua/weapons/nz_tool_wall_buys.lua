SWEP.PrintName	= "Weapon Placer Tool"
SWEP.Author		= "Alig96"
SWEP.Slot		= 2
SWEP.SlotPos	= 10
SWEP.Base 		= "nz_tool_base"

if SERVER then
	function SWEP:OnPrimaryAttack( trace )
		//nz.Mapping.Functions.WallBuy(trace.HitPos, "fas2_ak47", 100, trace.HitNormal:Angle()+Angle(0,270,0))
		nz.Interfaces.Functions.SendInterface(self.Owner, "WepBuy", {vec = trace.HitPos, ang = trace.HitNormal:Angle()+Angle(0,270,0)})
	end

	function SWEP:OnSecondaryAttack( trace )
		if trace.Entity:GetClass() == "wall_buys" then
			trace.Entity:Remove()
		end
	end
	function SWEP:OnReload( trace )
		if trace.Entity:GetClass() == "wall_buys" then
			trace.Entity:SetAngles(trace.Entity:GetAngles()+Angle(0,90,0))
		end
	end
end

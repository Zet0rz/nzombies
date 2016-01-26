SWEP.PrintName	= "Door Locker Tool"
SWEP.Author		= "Alig96"
SWEP.Slot		= 3
SWEP.SlotPos	= 10
SWEP.Base 		= "nz_tool_base"

if SERVER then
	function SWEP:OnPrimaryAttack( trace )
		if trace.Entity:IsDoor() or trace.Entity:IsBuyableProp() or trace.Entity:IsButton() then
			//nz.Doors.Functions.CreateLink( trace.Entity, "price=500,elec=0,link=1" )
			nz.Interfaces.Functions.SendInterface(self.Owner, "DoorProps", {door = trace.Entity})
		else
			print("Not a door.")
		end
		print(trace.Entity)
	end

	function SWEP:OnSecondaryAttack( trace )
		if trace.Entity:IsDoor() or trace.Entity:IsBuyableProp() or trace.Entity:IsButton() then
			nz.Doors.Functions.RemoveLink( trace.Entity )
		else
			print("Not a door.")
		end
	end
	//Display Links
	function SWEP:OnReload( trace )
		if trace.Entity:IsDoor() or trace.Entity:IsBuyableProp() or trace.Entity:IsButton() then
			nz.Doors.Functions.DisplayDoorLinks( trace.Entity )
		end
	end
end

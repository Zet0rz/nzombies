SWEP.PrintName	= "Nav Ladder Creator"
SWEP.Author		= "Lolle"
SWEP.Slot		= 0
SWEP.SlotPos	= 12
SWEP.Base 		= "nz_tool_base"

if SERVER then
	function SWEP:OnPrimaryAttack( trace )
		self.Owner:ConCommand( "nav_build_ladder" )
	end
end

function SWEP:Deploy()
	if SERVER then
		self.Owner:ChatPrint("Look at a ladder and press LeftClick to add this ladder to the navmesh.")
		if self.Owner:IsListenServerHost() and GetConVar("sv_cheats"):GetBool() then
			RunConsoleCommand("nav_edit", 1)
		else
			self.Owner:ChatPrint("You need to be hosting a singleplayer/local server with sv_cheats set to 1 to visualize the Navmeshes.")
		end
	end
end

function SWEP:Holster()
	if SERVER and self.Owner:IsListenServerHost() and GetConVar("sv_cheats"):GetBool() then
		RunConsoleCommand("nav_edit", 0)
	end
	return true
end

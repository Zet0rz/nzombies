
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )
include( "ai_translations.lua" )

SWEP.Weight				= 0
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

/*---------------------------------------------------------
   Name: OnDrop
   Desc: Weapon was dropped
---------------------------------------------------------*/
function SWEP:OnDrop()

	if ( IsValid( self.Weapon ) ) then
		// self.Weapon:Remove()
	end

end


hook.Add( "HUDShouldDraw", "HideHUD", function( name )
	if name == "CHudHealth" then return !GetConVar("nz_bloodoverlay"):GetBool() end
	if name == "CHudAmmo" then return false end
	if name == "CHudBattery" then return false end
	if name == "CHudWeaponSelection" then return !Round:InProgress() end
end )

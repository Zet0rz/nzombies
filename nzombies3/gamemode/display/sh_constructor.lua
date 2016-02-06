//Main Tables
nz.Display = {}
nz.Display.Functions = {}
nz.Display.Data = {}

if CLIENT then
	nz.Display.Data.PointsNotifications = {}
	function GM:ContextMenuOpen()
		return nz.Rounds.Data.CurrentState == ROUND_CREATE and LocalPlayer():IsAdmin()
	end
	function GM:PopulateMenuBar(panel)
		panel:Remove()
		return false
	end
	function GM:OnUndo( name, strCustomString )
		if ( !strCustomString ) then
			notification.AddLegacy( "Undone "..name, NOTIFY_UNDO, 2 )
		else	
			notification.AddLegacy( strCustomString, NOTIFY_UNDO, 2 )
		end
		surface.PlaySound( "buttons/button15.wav" )
	end
end

//_ Variables

surface.CreateFont( "korolev_large", {
	font = "Korolev Medium",
	size = 36,
	antialias = true,
} )

surface.CreateFont( "korolev_medium", {
	font = "Korolev Medium",
	size = 18,
	antialias = true,
} )

surface.CreateFont( "korolev_small", {
	font = "Korolev Medium",
	size = 14,
	antialias = true,
} )

local MenuFrame = {}

AccessorFunc( MenuFrame, "fLastSpawnSwitch", "LastSpawnSwitch", FORCE_NUMBER )

function MenuFrame:Init()
    self:SetSize(ScrW(), ScrH())
    self:SetPos( 0, 0 )
    gui.EnableScreenClicker( true )

    self.ToolBar = vgui.Create( "NZMainMenuToolBar", self )
    self.Content = vgui.Create( "NZMainMenuContent", self )

    self.CameraPos = LocalPlayer():GetPos() + Vector( 30, 30, 30 )
	self:SetLastSpawnSwitch( CurTime() )

end

function MenuFrame:Think()
    local ply = LocalPlayer()
	if ply:Alive() then return end
	if self:GetLastSpawnSwitch() + 15 < CurTime() then
		local sPoints = ents.FindByClass( "player_spawns" )
		if sPoints then
			local sPoint = sPoints[ math.random( #sPoints ) ]
			if IsValid( sPoint ) then
				ply:SetPos( sPoint:GetPos() )
				self.CameraPos = LocalPlayer():GetPos() + Vector( 20, 20, 40 )
				self:SetLastSpawnSwitch( CurTime() )
			end
		end
	end
    local vec1 = self.CameraPos
    local vec2 = ply:GetPos() + Vector( 0, 0, 20 )
    local ang = ( vec2 - vec1 ):Angle()
    ang:RotateAroundAxis( Vector( 0, 0, 1), math.sin( CurTime()/20 ) * 360 )
    ply:SetEyeAngles( ang )
end

function MenuFrame:Paint()
    --Derma_DrawBackgroundBlur( self, self.startTime )
    return
end

--It's not actually a frame but whatever
vgui.Register( "NZMainMenuFrame", MenuFrame, "DPanel")


local MenuToolBar = {}

function MenuToolBar:Init()
    self:SetSize( ScrW(), 80 )
    self:SetPos( 0, 0 )

	self.Logo = vgui.Create( "DLabel", self )
	self.Logo:SetPos( 14, 14 )
	self.Logo:SetFont( "nz.display.hud.main" )
	self.Logo:SetColor( Color( 255, 255, 255 ) )
	self.Logo:SetText( "NZombies" )
	self.Logo:SizeToContents()

    self.Entries = {}

    local ready = self:AddEntry( "READY", "large", "say", "/ready" )
	function ready:Think()
		if nz.Rounds.Data.CurrentState == ROUND_PROG or nz.Rounds.Data.CurrentState == ROUND_PREP then
			if LocalPlayer():Alive()  then
				self:SetText( "DROPOUT" )
				self:SetConsoleCommand( "say", "/dropout" )
			else
				self:SetText( "DROPIN" )
				self:SetConsoleCommand( "say", "/dropin" )
			end
		else
			self:SetText( "READY" )
			self.DoClick = function()
				RunConsoleCommand( "say", "/ready" )
				RunConsoleCommand( "nz_settings" )
			end
		end
	end

	local spectate = self:AddEntry( "SPECTATE", "medium", "say", "/spectate" )
	function spectate:Think()
		if LocalPlayer():Team() == TEAM_SPEC then
			spectate:SetText( "UNSPECTATE" )
		else
			spectate:SetText( "SPECTATE" )
		end
	end
	self:AddEntry( "WORKSHOP PAGE", "medium", function() gui.OpenURL( "http://steamcommunity.com" ) end )

	--Settings Button / Close button
	if LocalPlayer():IsSuperAdmin() then
		self.SettingsButton = vgui.Create( "DImageButton", self )
		self.SettingsButton:SetImage( "icon_settings.png" )
		self.SettingsButton:SetPos( ScrW() - 60, 20 )
		self.SettingsButton:SetSize( 40, 40 )
		self.SettingsButton:SetContentAlignment( 5 )
		function self.SettingsButton:Paint( w, h )

		end

		AccessorFunc( self.SettingsButton, "bSettingsMenuOpen", "SettingsMenuOpen", FORCE_BOOL )

		function self.SettingsButton:DoClick()
			if !self:GetSettingsMenuOpen() then
				self.SettingsMenu = vgui.Create( "NZMainMenuSettingsPanel", self:GetParent():GetParent() ) --Parent to mainframe
				self:SetSettingsMenuOpen( true )
				self:SetColor( Color( 85, 85, 85, 255 ) )
			else
				self.SettingsMenu:Remove()
				self:SetSettingsMenuOpen( false )
				self:SetColor( Color( 255, 255, 255, 255 ) )
			end
		end

	else
		--Show close icon if user not superadmin
		self.CloseButton = vgui.Create( "DImageButton", self )
		self.CloseButton:SetImage( "icon_close.png" )
		self.CloseButton:SetPos( ScrW() - 60, 20 )
		self.CloseButton:SetSize( 40, 40 )
		self.CloseButton:SetContentAlignment( 5 )
		self.CloseButton:SetConsoleCommand( "nz_settings" )
		function self.CloseButton:Paint( w, h )

		end
	end

end

function MenuToolBar:Paint( w, h )
    draw.RoundedBox( 0, 0, 0, w, h, Color( 130, 45, 45, 255 ) )
	--draw.RoundedBox( 0, 0, h-5, w, 5, Color( 255, 255, 255, 255 ) )
end

function MenuToolBar:Think()
	local nextPos = 320
	local temp = self.Entries
	for i = #self.Entries, 1, -1  do
		self.Entries[i]:SizeToContentsX()
		for j = #self.Entries, i, -1 do
			if i == j then break end
			nextPos = nextPos + self.Entries[j]:GetWide() + 30
		end
		self.Entries[i]:SetPos( nextPos, 0 )
		nextPos = 320
	end
end

function MenuToolBar:AddEntry( lbl, fontSize, cmd, args )
    local entry = vgui.Create( "NZMainMenuToolBarEntry", self )
	if fontSize == "large" then
		entry:SetFont( "korolev_large" )
	elseif fontSize == "medium" then
		entry:SetFont( "korolev_medium" )
	else
		entry:SetFont( "korolev_small" )
	end
	local nextPos = 320
	for _, v in pairs( self.Entries ) do
		nextPos = nextPos + v:GetWide() + 30
	end
    entry:SetPos( nextPos, 0 )
	if isfunction( cmd ) then
    	entry.DoClick = cmd
	elseif isstring( cmd ) then
		entry:SetConsoleCommand( cmd, args )
	end
	entry:SetText( lbl )
	entry:SizeToContentsX()

    table.insert( self.Entries, 1, entry )

	return self.Entries[ 1 ]
end

vgui.Register( "NZMainMenuToolBar", MenuToolBar, "DPanel")


local MenuToolBarEntry = {}

function MenuToolBarEntry:Init()
    self:SetSize( 200, 80 )
    self:SetFont( "korolev_large" )
    self:SetContentAlignment( 5 )
    self:SetTextColor( Color( 255, 255, 255 ) )
end

function MenuToolBarEntry:Paint()

end

vgui.Register( "NZMainMenuToolBarEntry", MenuToolBarEntry, "DButton")


local MenuSettingsPanel = {}

function MenuSettingsPanel:Init()
	self:SetPos( ScrW() - 256, 80 )
	self:SetSize( 256, 256)
	self.List = vgui.Create( "NZMainMenuSettingsList", self )
end

function MenuSettingsPanel:Paint( w, h )
    draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, 255 ) )
end

vgui.Register( "NZMainMenuSettingsPanel", MenuSettingsPanel, "DScrollPanel" )

local MenuSettingsList = {}

function MenuSettingsList:Init()
	self:SetWide( 256 )
	local btnMode = self:AddButton( "Creative Mode", function() RunConsoleCommand( "say", "/create" ) RunConsoleCommand( "nz_settings" ) end )
	function btnMode:Think()
		if player_manager.GetPlayerClass( LocalPlayer() ) == "player_create" then
			self:SetText( "Return to Survival Mode")
		else
			self:SetText( "Creative Mode")
		end
	end
	self:AddButton( "Load Map config", "say", "/load" )
	self:AddButton( "Save Map config", "say", "/save" )
	self:AddButton( "Generate Navmesh", "say", "/generate" )
end

function MenuSettingsList:AddButton( lbl, cmd, args )
	local button = vgui.Create( "DButton", self )
	if isfunction( cmd ) then
    	button.DoClick = cmd
	elseif isstring( cmd ) then
		button:SetConsoleCommand( cmd, args )
	end
	button:SetText( lbl )
	button:SetFont( "korolev_small" )
	button:SetTall( 42 )

	function button:Paint( w, h )

	end

    return self:Add( button )
end

vgui.Register( "NZMainMenuSettingsList", MenuSettingsList, "DListLayout" )


local MenuContent = {}

function MenuContent:Init()
	self.Layouts = {}
	self.ActiveLayout = "main"
    self:SetSize(ScrW(), ScrH() - 80 )
    self:SetPos( 0, 80 )

	--Main Page of the menu
	local mainLayout = vgui.Create( "NZMainMenuContentLayout" )

	self:AddLayout( "main", mainLayout )

	--Set Active page to main on Init
	self:SetActiveLayout( "main" )

end

function MenuContent:SetActiveLayout( name )
	self:GetActiveLayout():SetVisible( false )
	self.ActiveLayout = name
	self:GetActiveLayout():SetVisible( true )
end

function MenuContent:GetActiveLayout()
	return self.Layouts[ self.ActiveLayout ]
end

function MenuContent:Paint()
    return
end

function MenuContent:AddLayout( name, layout )
	layout:SetParent( self )
	self.Layouts[name] = layout
end

vgui.Register( "NZMainMenuContent", MenuContent, "DPanel")


local MenuContentLayout = {}

function MenuContentLayout:Init()
	self.Panels = {}
    self:SetSize( 768, 512 )
    self:SetPos( ScrW() / 2 - 384, ScrH() / 2 - 320 )
	self:SetVisible( false )
end

function MenuContentLayout:GetPanels()
	return self.Panels
end

function MenuContentLayout:Paint()
    return
end

function MenuContentLayout:AddPanel( pnl, startGridX, startGridY, gridSizeX, gridSizeY )
	local gridSize = 128
	pnl:SetParent( self )
	pnl:SetPos( gridSize * ( startGridX - 1 ), gridSize * (startGridY - 1) )
	pnl:SetSize( gridSize * gridSizeX, gridSize * gridSizeY )
	table.insert( self.Panels, pnl )
end

vgui.Register( "NZMainMenuContentLayout", MenuContentLayout, "DPanel")


local function showSettings(ply, cmd, args)
    if ( !IsValid( g_Settings ) ) then
        g_Settings = vgui.Create("NZMainMenuFrame")
        g_Settings:SetVisible(false) -- use the visible bool as toggle indicator
    end

    if ( IsValid( g_Settings ) ) then
        if g_Settings:IsVisible() then
            g_Settings:Hide()
            gui.EnableScreenClicker( false )
            g_Settings:SetVisible(false)
            g_Settings:Remove()
        else
            g_Settings:Show()
            gui.EnableScreenClicker( true )
            g_Settings:SetVisible(true)
        end
    end
end
concommand.Add("nz_settings", showSettings)

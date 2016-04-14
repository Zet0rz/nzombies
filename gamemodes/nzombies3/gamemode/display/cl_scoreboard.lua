
surface.CreateFont( "ScoreboardDefault", {
	font	= "Helvetica",
	size	= 22,
	weight	= 800
} )

surface.CreateFont( "ScoreboardDefaultTitle", {
	font	= "Helvetica",
	size	= 32,
	weight	= 800
} )

local bloodline_scoreboard = Material("bloodline_scoreboard.png", "unlitgeneric smooth")

--
-- This defines a new panel type for the player row. The player row is given a player
-- and then from that point on it pretty much looks after itself. It updates player info
-- in the think function, and removes itself when the player leaves the server.
--
local PLAYER_LINE = {
	Init = function( self )

		self.AvatarButton = self:Add( "DButton" )
		self.AvatarButton:Dock( LEFT )
		self.AvatarButton:SetSize( 32, 32 )
		self.AvatarButton.DoClick = function() self.Player:ShowProfile() end

		self.Avatar = vgui.Create( "AvatarImage", self.AvatarButton )
		self.Avatar:SetSize( 32, 32 )
		self.Avatar:SetMouseInputEnabled( false )

		self.Name = self:Add( "DLabel" )
		self.Name:Dock( FILL )
		self.Name:SetFont( "ScoreboardDefault" )
		self.Name:SetTextColor( self.TextColor or Color(255, 255, 255) )

		self.Mute = self:Add( "DImageButton" )
		self.Mute:SetSize( 32, 32 )
		self.Mute:Dock( RIGHT )

		self.Ping = self:Add( "DLabel" )
		self.Ping:Dock( RIGHT )
		self.Ping:SetWidth( 50 )
		self.Ping:SetFont( "ScoreboardDefault" )
		self.Ping:SetTextColor( Color( 255, 255, 255 ) )
		self.Ping:SetContentAlignment( 5 )

		self.Revives = self:Add( "DLabel" )
		self.Revives:Dock( RIGHT )
		self.Revives:SetWidth( 100 )
		self.Revives:SetFont( "ScoreboardDefault" )
		self.Revives:SetTextColor( self.TextColor or Color(255, 255, 255)  )
		self.Revives:SetContentAlignment( 5 )

		self.Downs = self:Add( "DLabel" )
		self.Downs:Dock( RIGHT )
		self.Downs:SetWidth( 100 )
		self.Downs:SetFont( "ScoreboardDefault" )
		self.Downs:SetTextColor( self.TextColor or Color(255, 255, 255)  )
		self.Downs:SetContentAlignment( 5 )

		self.Kills = self:Add( "DLabel" )
		self.Kills:Dock( RIGHT )
		self.Kills:SetWidth( 100 )
		self.Kills:SetFont( "ScoreboardDefault" )
		self.Kills:SetTextColor( self.TextColor or Color(255, 255, 255)  )
		self.Kills:SetContentAlignment( 5 )

		self.Points = self:Add( "DLabel" )
		self.Points:Dock( RIGHT )
		self.Points:SetWidth( 100 )
		self.Points:SetFont( "ScoreboardDefault" )
		self.Points:SetTextColor( self.TextColor or Color(255, 255, 255) )
		self.Points:SetContentAlignment( 5 )
		
		self.Items = self:Add( "DPanel" )
		self.Items:Dock( RIGHT )
		self.Items:SetWidth( 175 )
		self.Items.Paint = function(pnl)
			surface.SetDrawColor(255, 255, 255)
			local num = 0
			for k,v in pairs(self.Player:GetCarryItems()) do
				local item = ItemCarry.Items[v]
				if item and item.icon and item.icon != "" then
					local x, y = pnl:GetPos()
					surface.SetMaterial(item.icon)
					surface.DrawTexturedRect(x - num*26, y + 6, 24, 24)
					num = num + 1
				end
			end
		end

		self:Dock( TOP )
		self:SetSize( 32, 32)
		self:DockMargin(5,0,5,0)

	end,

	Setup = function( self, pl )

		self.Player = pl

		self.Avatar:SetPlayer( pl )

		self:Think( self )

		--local friend = self.Player:GetFriendStatus()
		--MsgN( pl, " Friend: ", friend )

	end,

	Think = function( self )

		if ( !IsValid( self.Player ) ) then
			self:SetZPos( 9999 ) -- Causes a rebuild
			self:Remove()
			return
		end

		if ( self.TextColor == nil || self.TextColor != player.GetColorByIndex( self.Player:EntIndex() ) ) then
			self.TextColor = player.GetColorByIndex( self.Player:EntIndex() )
			self.Name:SetTextColor( self.TextColor )
			self.Points:SetTextColor( self.TextColor )
			self.Revives:SetTextColor( self.TextColor )
			self.Ping:SetTextColor( self.TextColor )
			self.Downs:SetTextColor( self.TextColor  )
			self.Kills:SetTextColor( self.TextColor )
		end

		if ( self.ZombieKills == nil || self.ZombieKills != self.Player:GetTotalKills() ) then
			self.ZombieKills = self.Player:GetTotalKills()
			self.Kills:SetText( self.ZombieKills )
		end

		if ( self.NumDowns == nil || self.Downs != self.Player:GetTotalDowns() ) then
			self.NumDowns = self.Player:GetTotalDowns()
			self.Downs:SetText( self.NumDowns )
		end

		if ( self.NumRevives == nil || self.NumRevives != self.Player:GetTotalRevives() ) then
			self.NumRevives = self.Player:GetTotalRevives()
			self.Revives:SetText( self.NumRevives )
		end

		if ( self.PName == nil || self.PName != self.Player:Nick() ) then
			self.PName = self.Player:Nick()
			self.Name:SetText( self.PName )
		end

		if ( self.NumPoints == nil || self.NumPoints != self.Player:GetPoints() ) then
			self.NumPoints = self.Player:GetPoints()
			self.Points:SetText( self.NumPoints )
		end

		if ( self.NumPing == nil || self.NumPing != self.Player:Ping() ) then
			self.NumPing = self.Player:Ping()
			self.Ping:SetText( self.NumPing )
		end

		--
		-- Change the icon of the mute button based on state
		--
		if ( self.Muted == nil || self.Muted != self.Player:IsMuted() ) then

			self.Muted = self.Player:IsMuted()
			if ( self.Muted ) then
				self.Mute:SetImage( "icon32/muted.png" )
			else
				self.Mute:SetImage( "icon32/unmuted.png" )
			end

			self.Mute.DoClick = function() self.Player:SetMuted( !self.Muted ) end

		end

		--
		-- Connecting players go at the very bottom
		--
		if ( self.Player:Team() == TEAM_CONNECTING ) then
			self:SetZPos( 2000 + self.Player:EntIndex() )
			return
		end

		--
		-- This is what sorts the list. The panels are docked in the z order,
		-- so if we set the z order according to kills they'll be ordered that way!
		-- Careful though, it's a signed short internally, so needs to range between -32,768k and +32,767
		--
		self:SetZPos( ( self.NumPoints * -50 ) + self.NumPoints + self.Player:EntIndex() )

	end,

	Paint = function( self, w, h )

		if ( !IsValid( self.Player ) ) then
			return
		end

		--
		-- We draw our background a different colour based on the status of the player
		--

		--if ( !self.Player:Alive() ) then
			--draw.RoundedBox( 4, 0, 0, w, h, Color( pColor[1] * 150, pColor[2] * 150, pColor[3] * 150, 255 ) )
			--return
		--end

		--draw.RoundedBox( 4, 0, 0, w, h, Color( pColor[1] * 100 + 155, pColor[2] * 100 + 155, pColor[3] * 100 + 155, 255 ) )

		surface.SetMaterial(player.GetBloodByIndex(self.Player:EntIndex()))
		surface.SetDrawColor(200,200,200)
		surface.DrawTexturedRect(0, 0, w, h)

	end
}

--
-- Convert it from a normal table into a Panel Table based on DPanel
--
PLAYER_LINE = vgui.RegisterTable( PLAYER_LINE, "DPanel" )

--
-- Here we define a new panel table for the scoreboard. It basically consists
-- of a header and a scrollpanel - into which the player lines are placed.
--

local SCORE_BOARD = {
	Init = function( self )

		self.Header = self:Add( "Panel" )
		self.Header:Dock( TOP )
		self.Header:SetHeight( 100 )

		self.Name = self.Header:Add( "DLabel" )
		self.Name:SetFont( "nz.display.hud.main" )
		self.Name:SetTextColor( Color( 255, 255, 255, 255 ) )
		self.Name:Dock( TOP )
		self.Name:SetHeight( 40 )
		self.Name:SetContentAlignment( 5 )

		self.Key = self:Add( "DPanel" )
		self.Key:Dock( TOP )
		self.Key:SetContentAlignment( 6 )
		self.Key:SetHeight( 20 )
		self.Key.Paint = function() end

		self.Mute = self.Key:Add( "DLabel" )
		self.Mute:Dock( RIGHT )
		self.Mute:SetWidth( 32 )
		self.Mute:SetFont( "ScoreboardDefault" )
		self.Mute:SetTextColor( Color( 255, 255, 255 ) )
		self.Mute:SetContentAlignment( 5 )
		self.Mute:SetText("")

		self.Ping = self.Key:Add( "DLabel" )
		self.Ping:Dock( RIGHT )
		self.Ping:SetWidth( 50 )
		self.Ping:SetFont( "ScoreboardDefault" )
		self.Ping:SetTextColor( Color( 255, 255, 255 ) )
		self.Ping:SetContentAlignment( 5 )
		self.Ping:SetText("Ping")

		self.Revives = self.Key:Add( "DLabel" )
		self.Revives:Dock( RIGHT )
		self.Revives:SetWidth( 100 )
		self.Revives:SetFont( "ScoreboardDefault" )
		self.Revives:SetTextColor( Color(255, 255, 255)  )
		self.Revives:SetContentAlignment( 5 )
		self.Revives:SetText("Revives")

		self.Downs = self.Key:Add( "DLabel" )
		self.Downs:Dock( RIGHT )
		self.Downs:SetWidth( 100 )
		self.Downs:SetFont( "ScoreboardDefault" )
		self.Downs:SetTextColor( Color(255, 255, 255)  )
		self.Downs:SetContentAlignment( 5 )
		self.Downs:SetText("Downs")

		self.Kills = self.Key:Add( "DLabel" )
		self.Kills:Dock( RIGHT )
		self.Kills:SetWidth( 100 )
		self.Kills:SetFont( "ScoreboardDefault" )
		self.Kills:SetTextColor( Color( 255, 255, 255, 255 ) )
		self.Kills:SetContentAlignment( 5 )
		self.Kills:SetText("Kills")

		self.Points = self.Key:Add( "DLabel" )
		self.Points:Dock( RIGHT )
		self.Points:SetWidth( 100 )
		self.Points:SetFont( "ScoreboardDefault" )
		self.Points:SetTextColor( Color( 255, 255, 255, 255 ) )
		self.Points:SetContentAlignment( 5 )
		self.Points:SetText("Points")



		--self.NumPlayers = self.Header:Add( "DLabel" )
		--self.NumPlayers:SetFont( "ScoreboardDefault" )
		--self.NumPlayers:SetTextColor( Color( 255, 255, 255, 255 ) )
		--self.NumPlayers:SetPos( 0, 100 - 30 )
		--self.NumPlayers:SetSize( 300, 30 )
		--self.NumPlayers:SetContentAlignment( 4 )

		self.Scores = self:Add( "DScrollPanel" )
		self.Scores:Dock( FILL )

	end,

	PerformLayout = function( self )

		self:SetSize( 800, ScrH() - 200 )
		self:SetPos( ScrW() / 2 - 400, 100 )

	end,

	Paint = function( self, w, h )

		--DrawBlurRect( 0, 0, w, h )

	end,

	Think = function( self, w, h )

		self.Name:SetText( GetHostName() )

		--
		-- Loop through each player, and if one doesn't have a score entry - create it.
		--
		local plyrs = player.GetAll()
		for id, pl in pairs( plyrs ) do

			if ( IsValid( pl.ScoreEntry ) ) then continue end

			pl.ScoreEntry = vgui.CreateFromTable( PLAYER_LINE, pl.ScoreEntry )
			pl.ScoreEntry:Setup( pl )

			self.Scores:AddItem( pl.ScoreEntry )

		end

	end
}

SCORE_BOARD = vgui.RegisterTable( SCORE_BOARD, "EditablePanel" )

--[[---------------------------------------------------------
	Name: gamemode:ScoreboardShow( )
	Desc: Sets the scoreboard to visible
-----------------------------------------------------------]]
function GM:ScoreboardShow()

	if ( !IsValid( g_Scoreboard ) ) then
		g_Scoreboard = vgui.CreateFromTable( SCORE_BOARD )
	end

	if ( IsValid( g_Scoreboard ) ) then
		g_Scoreboard:Show()
		g_Scoreboard:MakePopup()
		g_Scoreboard:SetKeyboardInputEnabled( false )
	end

end

--[[---------------------------------------------------------
	Name: gamemode:ScoreboardHide( )
	Desc: Hides the scoreboard
-----------------------------------------------------------]]
function GM:ScoreboardHide()

	if ( IsValid( g_Scoreboard ) ) then
		g_Scoreboard:Hide()
	end

end

--[[---------------------------------------------------------
	Name: gamemode:HUDDrawScoreBoard( )
	Desc: If you prefer to draw your scoreboard the stupid way (without vgui)
-----------------------------------------------------------]]
function GM:HUDDrawScoreBoard()
end

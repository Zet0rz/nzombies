//Main Text
surface.CreateFont( "nz.display.hud.main", {
	font = "DK Umbilical Noose", //Avenir Next
	size = 48, 
	weight = 300, 
	blursize = 0, 
	scanlines = 0, 
	antialias = true, 
	underline = false, 
	italic = false, 
	strikeout = false, 
	symbol = false, 
	rotary = false, 
	shadow = false, 
	additive = false, 
	outline = false, 
} )

surface.CreateFont( "nz.display.hud.small", {
	font = "DK Umbilical Noose", //Avenir Next
	size = 28, 
	weight = 300, 
	blursize = 0, 
	scanlines = 0, 
	antialias = true, 
	underline = false, 
	italic = false, 
	strikeout = false, 
	symbol = false, 
	rotary = false, 
	shadow = false, 
	additive = false, 
	outline = false, 
} )

surface.CreateFont( "nz.display.hud.points", {
	font = "Default",
	size = 20,
	weight = 5000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "nz.display.hud.ammo", {
	font = "Calibri",
	size = 60,
	weight = 50,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "nz.display.hud.ammo2", {
	font = "Calibri",
	size = 40,
	weight = 50,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "nz.display.hud.smaller", {
	font = "DK Umbilical Noose", //Avenir Next
	size = 18, 
	weight = 300, 
	blursize = 0, 
	scanlines = 0, 
	antialias = true, 
	underline = false, 
	italic = false, 
	strikeout = false, 
	symbol = false, 
	rotary = false, 
	shadow = false, 
	additive = false, 
	outline = false, 
} )

surface.CreateFont( "nz.display.hud.rounds", {
	font = "DK Umbilical Noose", //Avenir Next
	size = 400, 
	weight = 30, 
	blursize = 0, 
	scanlines = 0, 
	antialias = true, 
	underline = false, 
	italic = false, 
	strikeout = false, 
	symbol = false, 
	rotary = false, 
	shadow = false, 
	additive = false, 
	outline = false, 
} )

-- Rotated text function, as taken from the gmod wiki
local matscale = Vector(1,1,1)
function draw.TextRotatedScaled( text, x, y, color, font, ang, scaleX, scaleY )
	render.PushFilterMag( TEXFILTER.ANISOTROPIC )
	render.PushFilterMin( TEXFILTER.ANISOTROPIC )
	surface.SetFont( font )
	surface.SetTextColor( color )
	surface.SetTextPos( 0, 0 )
	local textWidth, textHeight = surface.GetTextSize( text )
	local rad = -math.rad( ang )
	x = x - ( math.cos( rad ) * textWidth / 2 + math.sin( rad ) * textHeight / 2 )
	y = y + ( math.sin( rad ) * textWidth / 2 + math.cos( rad ) * textHeight / 2 )
	local m = Matrix()
	m:SetAngles( Angle( 0, ang, 0 ) )
	m:SetTranslation( Vector( x, y, 0 ) )
	matscale.x = scaleX
	matscale.y = scaleY
	m:Scale(matscale)
	cam.PushModelMatrix( m )
		surface.DrawText( text )
	cam.PopModelMatrix()
	render.PopFilterMag()
	render.PopFilterMin()
end
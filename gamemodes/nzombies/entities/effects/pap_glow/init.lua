--Name: Lightning strike using midpoint displacement
--Author: Lolle

--EFFECT.MatCenter = Material( "lightning.png", "unlitgeneric smooth" )
EFFECT.MatEdge = Material( "effects/tool_tracer" )
EFFECT.MatCenter = Material( "sprites/physbeama" )
EFFECT.MatGlow1 = Material( "sprites/physg_glow1" )
EFFECT.MatGlow2 = Material( "sprites/physg_glow2" )
EFFECT.MatGlowCenter = Material( "sprites/glow04_noz" )

--[[---------------------------------------------------------
   Init( data table )
-----------------------------------------------------------]]
function EFFECT:Init( data )

	self.Parent = data:GetEntity()
	self.Pos = self.Parent:GetPos()
	self.Offset = data:GetOrigin() - self.Pos
	self.DieTime = 1
	self.Duration = data:GetMagnitude() or 2
	self.Count = self.Duration * 40
	self.Radius = 30

	self.Alpha = 1
	self.Life = 0

	self:SetRenderBoundsWS( self.Pos, self.Pos, Vector(100,100,100) )

	--sound.Play("nz/hellhound/spawn/prespawn.wav", self.Pos, 100, 100, 1)

end

--[[---------------------------------------------------------
   THINK
-----------------------------------------------------------]]
function EFFECT:Think()

	if IsValid(self.Parent) then
		self.Pos = self.Parent:GetPos() + self.Offset
	end

	self.Life = self.Life + FrameTime()
	if self.Life > self.Duration then
		self.Alpha = 1 - (self.Life - self.Duration)/self.DieTime
	end

	return ( self.Life < self.Duration + self.DieTime )
end

--[[---------------------------------------------------------
   Draw the effect
-----------------------------------------------------------]]
function EFFECT:Render()

	if ( self.Alpha <= 0 ) then return end
	
	local dir = self.Offset:Angle():Right()
	
	
	local col = Color(255,255,255,math.random(100,255) * self.Alpha)
	local col2 = Color(255,255,255,math.random(230,255) * self.Alpha)
	
	render.SetMaterial( self.MatGlow1 )
	render.DrawSprite( self.Pos, math.random(50,100), math.random(50,100), col)
	render.DrawSprite( self.Pos + dir*10, math.random(50,100), math.random(50,100), col)
	render.DrawSprite( self.Pos - dir*10, math.random(50,100), math.random(50,100), col)
	render.DrawSprite( self.Pos + dir*20, math.random(50,100), math.random(50,100), col)
	render.DrawSprite( self.Pos - dir*20, math.random(50,100), math.random(50,100), col)
	
	if math.random(0,10) == 0 then
		render.SetMaterial( self.MatGlow2 )
		render.DrawSprite( self.Pos, math.random(50,100), math.random(50,100), col)
		render.DrawSprite( self.Pos + dir*10, math.random(50,100), math.random(50,100), col)
		render.DrawSprite( self.Pos - dir*10, math.random(50,100), math.random(50,100), col)
		render.DrawSprite( self.Pos + dir*20, math.random(50,100), math.random(50,100), col)
		render.DrawSprite( self.Pos - dir*20, math.random(50,100), math.random(50,100), col)
	end
	
	render.SetMaterial( self.MatGlowCenter )
	render.DrawSprite( self.Pos, math.random(50,75), math.random(50,75), col2)
	render.DrawSprite( self.Pos + dir*10, math.random(50,75), math.random(50,75), col2)
	render.DrawSprite( self.Pos - dir*10, math.random(50,75), math.random(50,75), col2)
	render.DrawSprite( self.Pos + dir*20, math.random(50,75), math.random(50,75), col2)
	render.DrawSprite( self.Pos - dir*20, math.random(50,75), math.random(50,75), col2)
	
end

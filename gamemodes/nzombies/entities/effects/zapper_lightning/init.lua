--Name: Lightning strike using midpoint displacement
--Author: Lolle

--EFFECT.MatCenter = Material( "lightning.png", "unlitgeneric smooth" )
EFFECT.MatTracer = Material( "effects/tool_tracer" )

--[[---------------------------------------------------------
   Init( data table )
-----------------------------------------------------------]]
function EFFECT:Init( data )

	self.StartPos = data:GetStart()
	self.EndPos = data:GetOrigin()
	self.Duration = data:GetMagnitude() or 10

	self.Flash = DynamicLight( LocalPlayer():EntIndex() )

	self.Flash.pos = self.StartPos
	self.Flash.r = 255
	self.Flash.g = 255
	self.Flash.b = 255
	self.Flash.brightness = 1
	self.Flash.Decay = 200
	self.Flash.Size = 200
	self.Flash.style = 6
	self.Flash.DieTime = CurTime() + self.Duration

	self.Life = 0

	self:SetRenderBoundsWS( self.StartPos, self.EndPos )
end

function EFFECT:Think()
	self.Life = self.Life + FrameTime()
	--self.Alpha = 255 * ( 1 - self.Life )

	return ( self.Life < self.Duration )
end

function EFFECT:Render()
	local texcoord = math.Rand( 0, 1 )

	render.SetMaterial(self.MatTracer)

	render.DrawBeam(
		self.StartPos,
		self.EndPos,
		12,
		texcoord,
		texcoord + ((self.StartPos - self.EndPos):Length() / 128),
		Color(math.random(200, 255), math.random(220, 255), math.random(150, 200))
	)
end

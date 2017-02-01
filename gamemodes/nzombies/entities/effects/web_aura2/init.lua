
local stringdeathtime = 1
local stringmat = Material( "trails/physbeam" )
local stringspeed = 2
local stringmax = 10
local color = Color(255,255,255)
local downspeed = Vector(0,0,10)

--[[---------------------------------------------------------
   Init( data table )
-----------------------------------------------------------]]
function EFFECT:Init( data )

	self.Size = data:GetScale() or 1
	self.Parent = data:GetEntity()
	self.Frequency = data:GetMagnitude() or 2
	self.Pos = self.Parent:GetPos()
	self.Hitbox = data:GetHitBox() or 0
	self.Bone = self.Parent:GetHitBoxBone(self.Hitbox, self.Hitbox)
	
	if IsValid(self.Parent.WebAuraEffect) then
		self.Parent.WebAuraEffect.KILL = true
	end
	
	local scale = data:GetScale()
	if scale then
		if scale >= 0 then
			self.Parent.WebAura = CurTime() + scale
		else
			self.Parent.WebAura = true
		end
	else
		self.Parent.WebAura = CurTime() + 20 -- Default time for this effect
	end

	self:SetRenderBounds( Vector(0,0,0), Vector(0,0,0), Vector(50,50,50) )
	self.MoveSpeed = 50
	self.NextParticle = CurTime()
	self.Emitter = ParticleEmitter( self.Pos )
	
	self.Parent.WebAuraEffect = self
	self.WebPoints = {}
	self.DeadWebs = {}
end

--[[---------------------------------------------------------
   THINK
-----------------------------------------------------------]]

function EFFECT:Think( )
	if self.KILL then return false end
	local ct = CurTime()
	
	if self.AutoKillTimer and ct >= self.AutoKillTimer then
		return false
	end
	
	if IsValid(self.Parent) then
		if !self.AutoKillTimer and ((type(self.Parent.WebAura) == "number" and ct > self.Parent.WebAura) or !self.Parent.WebAura) then
			self.Parent.WebAura = nil
			self.Parent.WebAuraEffect = nil
			
			-- Kill all current webs rotating
			for k,v in pairs(self.WebPoints) do
				
			end
			self.AutoKillTimer = ct + 2
			
			return true
		else
			self:SetPos( self.Parent:GetPos() )
			return true
		end
	else
		return false
	end
end

--[[---------------------------------------------------------
   Draw the effect
-----------------------------------------------------------]]
function EFFECT:Render()

	local ent = self.Parent
	local min,max = ent:GetHitBoxBounds(self.Hitbox, self.Hitbox)
	local pos,ang = ent:GetBonePosition(self.Bone)
	
	local forward = ang:Forward()
	local right = ang:Right()*(max.y + 5)
	local up = ang:Up()*(max.x + 5)
	
	local ct = CurTime()
	
	if ct >= self.NextParticle and !self.AutoKillTimer then
		local tbl = {}
		tbl.time = ct
		tbl.z = math.random(-10,10)
		tbl.pointcount = math.random(2,4)
		tbl.points = {}
		local offset = math.Rand(-math.pi,math.pi) -- Full circular offset
		local timeoffset = 0
		for i = 1, tbl.pointcount do
			local new = math.Rand(0.3, 1)
			offset = offset + new
			timeoffset = timeoffset + new
			tbl.points[i] = {offset = offset, falltime = stringdeathtime + math.Rand(0,0.2) + timeoffset}
		end
		
		table.insert(self.WebPoints, tbl)
		self.NextParticle = ct + 0.5
	end
	
	render.SetMaterial( stringmat )
	local count = table.Count(self.WebPoints)
	for k,v in pairs(self.WebPoints) do
		local diff = ct - v.time
		
		local pcount = #v.points
		for k2,v2 in pairs(v.points) do
			if pcount <= 1 then
				table.remove(self.WebPoints, k)
				break
			end
		
			local pdiff = diff - v2.offset
			local rotate = pdiff*stringspeed
			local epos
			
			if diff <= v2.falltime then
				epos = pos + math.cos(rotate)*up + math.sin(rotate)*right + v.z*forward
			else
				if !v2.deadtime then 
					v2.deaddur = math.Rand(1.8,2.5)
					v2.deadtime = pdiff + v2.deaddur
				end
				if pdiff >= v2.deadtime then
					table.remove(v.points, k2)
					break
				else
					if v2.pos then
						epos = v2.pos - downspeed*FrameTime()
					else
						epos = pos
					end
				end
			end
			v2.pos = epos
			
			local new = v.points[k2+1]
			if new then
				local pos1 = v2.pos
				local pos2 = new.pos
				if pos1 and pos2 then
					local fade = v2.deadtime and (v2.deadtime - pdiff)/v2.deaddur * 255
					color.a = fade or 255
					render.DrawBeam(
						pos1,
						pos2,
						3,
						0,
						((pos1 - pos2):Length() / 128),
						color
					)
				end
			end
		end		
	end
		
end
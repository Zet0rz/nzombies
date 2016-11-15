
AddCSLuaFile()

local BounceSound = Sound( "garrysmod/balloon_pop_cute.wav" )

DEFINE_BASECLASS( "base_anim" )

ENT.PrintName		= "You Touched it Last Bouncy Ball"
ENT.Author			= "Zet0r"
ENT.Information		= "A bouncy ball that kill zombies! What could be better?! :D"

ENT.Spawnable		= false
ENT.AdminOnly		= false
ENT.RenderGroup		= RENDERGROUP_BOTH

function ENT:SetupDataTables()

	self:NetworkVar( "Int", 0, "MaxKills" )
	self:NetworkVar( "Int", 1, "CurKills" )
	self:NetworkVar( "Entity", 0, "BallOwner" )
	self:NetworkVar( "Bool", 0, "Fragment" )
	self:NetworkVar( "Int", 2, "BallColor" )

end

--[[---------------------------------------------------------
   Name: Initialize
-----------------------------------------------------------]]
function ENT:Initialize()

	if ( SERVER ) then

		local size = self:GetFragment() and 2 or 10
	
		-- Use the helibomb model just for the shadow (because it's about the same size)
		self:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
		
		-- Don't use the model's physics - create a sphere instead
		self:PhysicsInitSphere( size, "metal_bouncy" )
		
		-- Wake the physics object up. It's time to have fun!
		local phys = self:GetPhysicsObject()
		if ( IsValid( phys ) ) then
			phys:Wake()
		end
		
		-- Set collision bounds exactly
		self:SetCollisionBounds( Vector( -size, -size, -size ), Vector( size, size, size ) )
		
	else 
	
		self.LightColor = Vector( 0, 0, 0 )
	
	end
	
end

if ( CLIENT ) then

	local mat = Material( "sprites/sent_ball" )
	function ENT:Draw()
		local pos = self:GetPos()
		--local vel = self:GetVelocity()
		local size = self:GetFragment() and 4 or 20
		local pct = self:GetCurKills() / self:GetMaxKills()
		
		render.SetMaterial( mat )
		local c = self:GetBallColor()
		local color = HSVToColor(self:GetBallColor(), 1 - pct, 1)
		render.DrawSprite( pos, size, size, color )
	end

end


--[[---------------------------------------------------------
   Name: PhysicsCollide
-----------------------------------------------------------]]
function ENT:PhysicsCollide( data, physobj )
	
	-- Play sound on bounce
	if ( data.Speed > 60 && data.DeltaTime > 0.2 ) then

		local size = self:GetFragment() and 4 or 20
		local pitch = 32 + 128 - size
		self:EmitSound( BounceSound, 75, math.random( pitch - 10, pitch + 10 ) )

	end
	
	-- Bounce like a crazy bitch
	local LastSpeed = math.max( data.OurOldVelocity:Length(), data.Speed )
	local NewVelocity = physobj:GetVelocity()
	NewVelocity:Normalize()
	
	LastSpeed = math.max( NewVelocity:Length(), LastSpeed )
	
	local TargetVelocity = NewVelocity * LastSpeed * 0.7
	
	physobj:SetVelocity( TargetVelocity )
	
	if self.pap and !self.exploded then
		local numfragments = math.Round((self:GetMaxKills() - self:GetCurKills())/2)
		for i = 1, numfragments do
			local dir = Angle(0, -180 + (360/numfragments)*i + math.random(-10, 10), -50):Forward()
		
			local frag = ents.Create("nz_ytil_ball")
			frag:SetFragment(true)
			frag:SetPos(self:GetPos() + dir * 5)
			frag:SetMaxKills(3)
			frag:SetCurKills(0)
			frag:SetBallColor(self:GetBallColor())
			frag:SetBallOwner(self:GetBallOwner())
			frag:Spawn()
			frag:Activate()
			
			local fragPhys = frag:GetPhysicsObject()
			if IsValid(fragPhys) then
				fragPhys:ApplyForceCenter(dir * math.random(100,250) + TargetVelocity/2)
			end
		end
		
		local pos = self:GetPos()
		local effectdata = EffectData()
		effectdata:SetOrigin( pos )
		util.Effect( "HelicopterMegaBomb", effectdata )
		self.exploded = true
		self:SetCurKills(self:GetCurKills() + math.ceil((self:GetMaxKills() - self:GetCurKills())*0.33))
	end
	
end

--[[---------------------------------------------------------
   Name: OnTakeDamage
-----------------------------------------------------------]]
function ENT:OnTakeDamage( dmginfo )

	-- React physically when shot/getting blown
	self:TakePhysicsDamage( dmginfo )
	
end


--[[---------------------------------------------------------
   Name: Use
-----------------------------------------------------------]]
function ENT:Use( activator, caller )
	
	if IsValid(activator) and self:GetBallOwner() == activator and !self:GetFragment() then
		local wep
		for k,v in pairs(activator:GetWeapons()) do
			if v:GetClass() == "nz_touchedlast" then wep = v break end
		end
		if !IsValid(wep) then return end
		if wep:Clip1() >= 1 then return end
		wep:ReplenishBall(self:GetCurKills())
		self:Remove()
	end

end

--[[---------------------------------------------------------
   Name: StartTouch
-----------------------------------------------------------]]
function ENT:StartTouch( ent )
	
	if IsValid(ent) and nzConfig.ValidEnemies[ent:GetClass()] then
		if self:GetCurKills() < self:GetMaxKills() then
			local insta = DamageInfo()
			insta:SetDamage( 500 )
			insta:SetAttacker( self:GetBallOwner() )
			insta:SetDamageType( DMG_BLAST_SURFACE )
			ent:TakeDamageInfo( insta )
			self:SetCurKills(self:GetCurKills() + 1)
			
			-- If it runs out of kills, we gotta kill it if it doesn't have an owner
			if self:GetCurKills() >= self:GetMaxKills() then
				if !IsValid(self:GetBallOwner()) or self:GetFragment() then
					local pos = self:GetPos()
					local effectdata = EffectData()
					effectdata:SetOrigin( pos )
					util.Effect( "HelicopterMegaBomb", effectdata )
					self:Remove()
				else
					local exists = false
					-- Or if the owner doesn't have a weapon with a free ball slot (max ammo or replaced)
					for k,v in pairs(self:GetBallOwner():GetWeapons()) do
						if v:GetClass() == "nz_touchedlast" then
							if v:Clip1() < 1 then
								exists = true
							end
							break
						end
					end
					if !exists then
						local pos = self:GetPos()
						local effectdata = EffectData()
						effectdata:SetOrigin( pos )
						util.Effect( "HelicopterMegaBomb", effectdata )
						self:Remove()
					end
				end
			end
		end
	end

end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:OnRemove()
	
end
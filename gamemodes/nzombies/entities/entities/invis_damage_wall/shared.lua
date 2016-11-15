AddCSLuaFile( )

ENT.Type = "anim"
 
ENT.PrintName		= "invis_wall"
ENT.Author			= "Zet0r"
ENT.Contact			= "youtube.com/Zet0r"
ENT.Purpose			= ""
ENT.Instructions	= ""

function ENT:SetupDataTables()
	-- Min bound is for now just the position
	--self:NetworkVar("Vector", 0, "MinBound")
	self:NetworkVar("Vector", 0, "MaxBound")
	self:NetworkVar("Bool", 0, "Radiation")
	self:NetworkVar("Bool", 1, "Poison")
	self:NetworkVar("Bool", 2, "Tesla")
	self:NetworkVar("Int", 0, "Damage")
	self:NetworkVar("Float", 0, "Delay")
end

function ENT:Initialize()
	--self:SetMoveType( MOVETYPE_NONE )
	self:DrawShadow( false )
	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
	if self.SetRenderBounds then
		self:SetRenderBounds(Vector(0,0,0), self:GetMaxBound())
	end
	
	if SERVER then
		self.PlayersInside = {}
	else
		self.NextPoisonCloud = 0
	end
	
	self.NextDamage = 0
	
	--self:SetCustomCollisionCheck(true)
	--self:SetFilter(true, true)
end

function ENT:StartTouch(ent)
	if ent:IsPlayer() and ent:GetNotDowned() and !table.HasValue(self.PlayersInside, ent) then
		table.insert(self.PlayersInside, ent)
	end
end

function ENT:Touch(ent)
	--print("Touch", ent)
end

function ENT:EndTouch(ent)
	if table.HasValue(self.PlayersInside, ent) then
		table.RemoveByValue(self.PlayersInside, ent)
	end
end

function ENT:Think()
	local ct = CurTime()
	if ct > self.NextDamage then
	
		if SERVER then
			local dmg = DamageInfo()
			dmg:SetDamage(self:GetDamage())
			dmg:SetAttacker(self)
			dmg:SetDamageType(DMG_RADIATION)
			
			for k,v in ipairs(self.PlayersInside) do
				if !IsValid(v) or !v:GetNotDowned() then
					self:EndTouch(v)
				else
					v:TakeDamageInfo(dmg)
				end
			end
		else
			local e = EffectData()
			e:SetMagnitude(1.1)
			e:SetScale(1.5)
			
			local pos1 = self:GetPos()
			local pos2 = self:GetPos() + self:GetMaxBound()
			OrderVectors(pos1, pos2)
			
			for k,v in pairs(player.GetAll()) do
				if IsValid(v) and v:GetNotDowned() and (v:IsPlaying() or v:IsInCreative()) then
					if v:GetPos():WithinAABox(pos1, pos2) then
						local islocal = v == LocalPlayer()
						if self:GetTesla() then
							if !v.LightningAura or v.LightningAura < ct then
								e:SetEntity(v)
								util.Effect("lightning_aura", e)
							end
							if islocal then
								surface.PlaySound("weapons/physcannon/superphys_small_zap" .. math.random(1,4) .. ".wav")
							end
							v.LightningAura = ct + 1
						end
						if islocal and self:GetRadiation() then
							surface.PlaySound("player/geiger" .. math.random(1,3) .. ".wav")
						end
					end
				end
			end
		end
		
		self.NextDamage = ct + self:GetDelay()
	end
end

local mat = Material("color")
local white = Color(255,0,0,30)

if CLIENT then

	if not ConVarExists("nz_creative_preview") then CreateClientConVar("nz_creative_preview", "0") end
	
	local particles = {
		Model("particle/particle_smokegrenade"),
		Model("particle/particle_noisesphere")
	}

	function ENT:Draw()
		if ConVarExists("nz_creative_preview") and !GetConVar("nz_creative_preview"):GetBool() and nzRound:InState( ROUND_CREATE ) then
			cam.Start3D()
				render.SetMaterial(mat)
				render.DrawBox(self:GetPos(), self:GetAngles(), Vector(0,0,0), self:GetMaxBound(), white, true)
			cam.End3D()
		end
		
		if self:GetPoison() then
			local size = self:GetMaxBound()
			local scale = math.abs(size.x * size.y * size.z)
			
			if !self.PoisonEmitter then
				self.PoisonEmitter = ParticleEmitter(self:GetPos())
			end
			if self.NextPoisonCloud < CurTime() then
				local count = math.Clamp(math.Round(0.00000001 * scale), 1, 100)
				
				for i = 1, count do
					local pos = self:GetPos() + Vector(size.x * math.Rand(0,1), size.y * math.Rand(0,1), size.z * math.Rand(0,1))
					local p = self.PoisonEmitter:Add(particles[math.random(#particles)] , pos)
					p:SetColor(math.random(30,40), math.random(40,70), math.random(0,30))
					p:SetStartAlpha(255)
					p:SetEndAlpha(150)
					p:SetLifeTime(0)
					p:SetDieTime(math.Rand(1, 2.5))
					p:SetStartSize(math.random(45, 50))
					p:SetEndSize(math.random(20, 30))
					p:SetRoll(math.random(-180, 180))
					p:SetRollDelta(math.Rand(-0.1, 0.1))
					p:SetLighting(false)
				end
				self.NextPoisonCloud = CurTime() + 0.1
			end
		end
	end
	
	function ENT:OnRemove()
		if self.PoisonEmitter then self.PoisonEmitter:Finish() end
	end
end

hook.Add("PhysgunPickup", "nzInvisWallDamageNotPickup", function(ply, wall)
	if wall:GetClass() == "invis_damage_wall" then return false end
end)

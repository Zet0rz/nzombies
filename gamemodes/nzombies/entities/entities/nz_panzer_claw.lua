ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Panzer Claw"
ENT.Author = "Zet0r"

ENT.Spawnable = false
ENT.AdminSpawnable = false

if SERVER then
	AddCSLuaFile()
	util.AddNetworkString("nz_panzer_grab")
end

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "Panzer")
end

function ENT:Initialize()
	if SERVER then
		self:SetModel("models/nz_zombie/panzer_claw.mdl") -- Change later
		self:PhysicsInit(SOLID_OBB)
		self:SetSolid(SOLID_NONE)
		self:SetTrigger(true)
		self:UseTriggerBounds(true, 0)
		self:SetMoveType(MOVETYPE_FLY)
		--self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		--self:SetSolid(SOLID_VPHYSICS)
		phys = self:GetPhysicsObject()

		if phys and phys:IsValid() then
			phys:Wake()
		end
	end
end

function ENT:Launch(dir)
	self:SetLocalVelocity(dir * 200)
	self:SetAngles((dir*-1):Angle())
	self:SetSequence(self:LookupSequence("anim_close"))
end

function ENT:Grab(ply, pos) -- Return with player
	if !IsValid(ply) then return end
	
	local panzer = self:GetPanzer()
	local speed = 200
	local pos = pos or panzer:GetAttachment(panzer:LookupAttachment("clawlight")).Pos
	self.plyindex = ply:EntIndex()
	self.GrabbedPlayer = ply
	self.IsReturning = true
	
	local breaktime = CurTime() + 10
	hook.Add("SetupMove", "PanzerGrab"..self.plyindex, function(pl, mv, cmd)
		if !IsValid(ply) then self:Release() end
		if pl == ply then
			local dir = (pos - (pl:GetPos() + Vector(0,0,50))):GetNormalized()
			mv:SetVelocity(dir * speed)
			
			if !IsValid(panzer) or !IsValid(self) then
				hook.Remove("SetupMove", "PanzerGrab"..self.plyindex)
			else
				local dist = (pl:GetPos() + Vector(0,0,50)):Distance(pos)
				if dist < 25 then
					self:Release(pl, true)
				end
			end
			
			if mv:GetVelocity():Length() > 100 then -- Keep a speed over 100
				breaktime = CurTime() + 3 -- Then we keep delaying when to "break" the hook
			elseif CurTime() > breaktime then -- But if you haven't been over 100 speed for the time
				self:Release(ply) -- Break the hook!				
			end
			
			if SERVER then
				self:SetPos(pl:GetPos() + Vector(0,0,50))
			end
			--return
		end
	end)
	
	if SERVER then
		self:SetLocalVelocity(Vector(0,0,0))
		net.Start("nz_panzer_grab")
			net.WriteBool(true)
			net.WriteEntity(self)
			net.WriteVector(pos)
		net.Send(ply)
		
		self:SetSequence(self:LookupSequence("anim_open"))
	end
end

function ENT:Release(ply, catch) -- Release held player and return	
	ply = ply or self.GrabbedPlayer
	local index = self.plyindex or IsValid(self.GrabbedPlayer) and self.GrabbedPlayer:EntIndex()
	
	if index then
		hook.Remove("SetupMove", "PanzerGrab"..index)
	end
	
	if SERVER then
		if IsValid(ply) then
			net.Start("nz_panzer_grab")
				net.WriteBool(false)
				net.WriteEntity(self)
			net.Send(ply)
		end
	
		if !catch then
			self:Return()
		else
			local panzer = self:GetPanzer()
			panzer:GrabPlayer(ply)
			self:Remove()
		end
	end
end

if CLIENT then
	net.Receive("nz_panzer_grab", function()
		local grab = net.ReadBool()
		local ent = net.ReadEntity()
		local pos
		if grab then pos = net.ReadVector() end
		
		if IsValid(ent) then
			if grab then
				ent:Grab(LocalPlayer(), pos)
			else
				ent:Release(LocalPlayer())
			end
		end
	end)
end

function ENT:Return(clean) -- Return without player
	local panzer = self:GetPanzer()
	if !IsValid(panzer) then self:Remove() return end
	
	if clean then panzer:GrabPlayer() return end

	self:SetMoveType(MOVETYPE_FLY)
	self:SetSolid(SOLID_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self:SetNotSolid(true)
	self:SetCollisionBounds(Vector(0,0,0), Vector(0,0,0))
	
	local att = panzer:LookupAttachment("clawlight")
	local pos = att and panzer:GetAttachment(att).Pos or panzer:GetPos()
	self:SetLocalVelocity((pos - self:GetPos()):GetNormalized() * 1000)
	self.IsReturning = true
end

function ENT:StartTouch(ent)
	local panzer = self:GetPanzer()
	if IsValid(panzer) and !self.IsReturning then
		if ent:IsPlayer() and panzer:IsValidTarget(ent) then
			self:Grab(ent)
		elseif !IsValid(self.GrabbedPlayer) then
			--print("Touched something else")
			--self:Remove()
			self:Return()
		end
	else
		self:Remove()
	end
end

function ENT:PhysicsCollide(data, phys)
	--print("Collided!")
	--print(data.HitEntity)
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
	
	local col = Color(255,255,255,255)
	local mat = Material("cable/cable2")
	hook.Add( "PostDrawOpaqueRenderables", "panzer_claw_wires", function()
		for k,v in pairs(ents.FindByClass("nz_panzer_claw")) do
			local panzer = v:GetPanzer()
			if IsValid(panzer) then
				local Vector1 = panzer:GetAttachment(panzer:LookupAttachment("clawlight")).Pos
				local Vector2 = v:GetPos() + v:GetAngles():Forward()*10
				render.SetMaterial( mat )
				render.DrawBeam( Vector1, Vector2, 3, 1, 1, col )
			end
		end
	end )
end


function ENT:Think()
	if SERVER and self.IsReturning then
		local panzer = self:GetPanzer()
		if !IsValid(panzer) then self:Remove() return end
		
		if !IsValid(self.GrabbedPlayer) and self:GetPos():DistToSqr(panzer:GetAttachment(panzer:LookupAttachment("clawlight")).Pos) <= 10000 then
			self:Release()
			panzer:GrabPlayer()
			self:Remove()
		end
		
		if IsValid(panzer) and self.GrabbedPlayer and !panzer:IsValidTarget(self.GrabbedPlayer) then
			self:Release(self.GrabbedPlayer)
		end
	end
end

function ENT:OnRemove()
	self:Release()
end
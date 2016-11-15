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
	self:SetLocalVelocity(dir * 1000)
	self:SetAngles((dir*-1):Angle())
	self:SetSequence(self:LookupSequence("anim_close"))
	
	self.AutoReturnTime = CurTime() + 5
end

function ENT:Grab(ply, pos) -- Pos is used for clients who may not have the Panzer valid yet
	if !IsValid(ply) then return end
	
	self.HasGrabbed = true
	
	local panzer = self:GetPanzer()
	local speed = 200
	local pos = pos or IsValid(panzer) and panzer:GetAttachment(panzer:LookupAttachment("clawlight")).Pos
	
	self.GrabbedPlayer = ply
	local breaktime = CurTime() + 10
	local index = self:EntIndex()
	
	hook.Add("SetupMove", "PanzerGrab"..index, function(pl, mv, cmd)
		if !IsValid(ply) then self:Release() end
		
		if pl == ply then
			local dir = (pos - (pl:GetPos() + Vector(0,0,50))):GetNormalized()
			mv:SetVelocity(dir * speed)
			
			if !IsValid(panzer) or !IsValid(Entity(index)) then
				hook.Remove("SetupMove", "PanzerGrab"..index)
			else
				local dist = (pl:GetPos() + Vector(0,0,50)):Distance(pos)
				if dist < 25 then
					self:Reattach()
				end
			end
			
			if mv:GetVelocity():Length() > 100 then -- Keep a speed over 100
				breaktime = CurTime() + 3 -- Then we keep delaying when to "break" the hook
			elseif CurTime() > breaktime then -- But if you haven't been over 100 speed for the time
				self:Release() -- Break the hook!				
			end
			
			if SERVER then
				self:SetPos(pl:GetPos() + Vector(0,0,50))
			end
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

function ENT:Release()
	if IsValid(self.GrabbedPlayer) then
		hook.Remove("SetupMove", "PanzerGrab"..self:EntIndex())
		
		if SERVER then
			net.Start("nz_panzer_grab")
				net.WriteBool(false)
				net.WriteEntity(self)
			net.Send(self.GrabbedPlayer)
			
			self:SetSequence(self:LookupSequence("anim_open"))
			self:Return()
		end
	else
		if SERVER then
			net.Start("nz_panzer_grab")
				net.WriteBool(false)
				net.WriteEntity(self)
			net.Broadcast()
		end
	end
	self.GrabbedPlayer = nil
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
				ent:Release()
			end
		end
	end)
end

function ENT:Return() -- Emptyhanded return - Grab is with player
	self.HasGrabbed = true

	local panzer = self:GetPanzer()
	if !IsValid(panzer) then self:Remove() return end

	self:SetMoveType(MOVETYPE_FLY)
	self:SetSolid(SOLID_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self:SetNotSolid(true)
	self:SetCollisionBounds(Vector(0,0,0), Vector(0,0,0))
	
	local att = panzer:LookupAttachment("clawlight")
	local pos = att and panzer:GetAttachment(att).Pos or panzer:GetPos()
	self:SetLocalVelocity((pos - self:GetPos()):GetNormalized() * 1500)
end

function ENT:Reattach(removed)
	if !removed then self:Remove() end
	
	local panzer = self:GetPanzer()
	if !IsValid(panzer) then return end
	
	panzer:GrabPlayer(self.GrabbedPlayer)
end

function ENT:StartTouch(ent)
	local panzer = self:GetPanzer()
	if IsValid(panzer) and !self.HasGrabbed then
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
	if SERVER then
		if self.HasGrabbed then
			local panzer = self:GetPanzer()
			if !IsValid(panzer) then self:Remove() return end
			
			if !IsValid(self.GrabbedPlayer) and self:GetPos():DistToSqr(panzer:GetAttachment(panzer:LookupAttachment("clawlight")).Pos) <= 10000 then
				self:Reattach()
			end
			
			if IsValid(panzer) and self.GrabbedPlayer and !panzer:IsValidTarget(self.GrabbedPlayer) then
				self:Release()
			end
		elseif CurTime() > self.AutoReturnTime then 
			self:Return()
		end
	end
end

function ENT:OnRemove()
	self:Release()
	self:Reattach(true)
end
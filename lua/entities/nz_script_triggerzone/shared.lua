AddCSLuaFile( )

ENT.Type = "anim"
 
ENT.PrintName		= "triggerzone"
ENT.Author			= "Zet0r"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
	if SERVER then
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_NONE )
		self:DrawShadow( false )
		self:SetUseType( SIMPLE_USE )
		self.Boundone,self.Boundtwo = self:GetCollisionBounds()
		self:SetBuyFunction( function() print(self, "was bought but has no buy function") end )
	end
	self:SetRenderMode( RENDERMODE_TRANSALPHA )
	self:SetColor( Color(255,200,100,150) )
end


function ENT:OnRemove()
	if SERVER then
		nzDoors:RemoveLink( self )
	else
		self:SetLocked(false)
	end
end

function ENT:CreateZoneBuy(data)
	if IsValid(self) then
		self:SetDoorData(data)
		self:SetLocked(true)
		hook.Call("OnPropDoorLinkCreated", Doors, self, data)
	end
end

function ENT:SetBuyFunction(func)
	self.BuyFunction = func
end

function ENT:SetBounds(w, l, h)
	self:SetSolid( SOLID_BBOX )
	self:SetCollisionBounds( Vector(-w/2, -l/2, -h/2), Vector(w/2, l/2, h/2) )
end

if CLIENT then
	function ENT:Draw() 
		if nzRound:InState( ROUND_CREATE ) then
			self:DrawModel()
		end
	end
end

concommand.Add("nz_testbrush2", function(ply)
	local ent = ents.Create("nz_triggerzone")
	ent:SetPos(ply:GetPos())
	ent:SetBounds(1000,10,10)
	ent:SetMaterial("debugtools/toolswhite")
	ent:SetModel("models/hunter/blocks/cube4x4x4.mdl")
	ent:Spawn()
	ent:SetBuyFunction( function(ent)
		ent:ChatPrint("Bought!")
	end )
	
	undo.Create( "Test Brush 2" )
		undo.SetPlayer( ply )
		undo.AddEntity( ent )
	undo.Finish( "Effect (" .. tostring( model ) .. ")" )
	
	print(ent)
end)

concommand.Add("nz_testbrush5", function(ply)
	local t = SysTime() 
	for k,v in pairs(ents.FindByClass("nz_triggerzone_2")) do
		if v:NearestPoint(Entity(1):GetPos()):DistToSqr(Entity(1):GetPos()) <= 1 then
			print("Found", v) 
			break 
		end 
	end
	local time = SysTime() - t
	print("Time for FindByClass", time)
	
	local o = SysTime() 
	for k,v in pairs(ents.FindInSphere(Entity(1):GetPos(), 1)) do
		if v:GetClass() == "nz_triggerzone_2" then
			print("Found", v)
			break
		end
	end
	local time2 = SysTime()-o
	print("Time for FindInSphere", time2)
	
	print(time2 < time and "Sphere is fastest" or "Class is fastest")
end)


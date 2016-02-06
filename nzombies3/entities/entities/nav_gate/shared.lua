AddCSLuaFile( )

ENT.Type = "anim"
 
ENT.PrintName		= "nav_gate"
ENT.Author			= "Zet0r"
ENT.Contact			= "Allow zombies to navigate through player-placed doors"
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

local navdoormodels = {
	Model("models/hunter/plates/plate1x1.mdl"),
	Model("models/hunter/plates/plate1x2.mdl"),
	Model("models/hunter/plates/plate1x3.mdl"),
	Model("models/hunter/plates/plate1x6.mdl"),
	Model("models/hunter/plates/plate1x8.mdl"),
	Model("models/hunter/plates/plate2x3.mdl"),
	Model("models/hunter/plates/plate5x5.mdl"),
	Model("models/hunter/plates/plate8x8.mdl")
}
ENT.CurModelNum = 1

function ENT:SetupDataTables()

	--self:NetworkVar( "Bool", 0, "Locked" )
	
end

function ENT:Initialize()
	if SERVER then
		self:SetRenderMode(RENDERMODE_TRANSCOLOR)
		self:SetModel(navdoormodels[self.CurModelNum])
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetTrigger( true )
		self:PhysWake( )
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
		--self:SetNotSolid( true )
		self:DrawShadow( false )
		self:SetColor( Color(0, 100, 100, 225) )
	end
end

function ENT:CycleModel(num)
	if num then
		self.CurModelNum = num
	else
		self.CurModelNum = self.CurModelNum + 1
		if self.CurModelNum > #navdoormodels then self.CurModelNum = 1 end
	end
	self:SetModel(navdoormodels[self.CurModelNum])
end

function ENT:EndTouch(ent)
	local oldroom = ent.CurrentRoom
	ent.CurrentRoom = self.OwnerRoom
	--print(self, ent, ent.CurrentRoom)
	
	//We only need zombies to renavigate if the room is a new one
	if oldroom != ent.CurrentRoom then
		hook.Call("nz_EntityChangedRoom", nil, ent, oldroom, ent.CurrentRoom, self)
		--print("HOOK INFO AT GATE", ent, oldroom, ent.CurrentRoom, self)
	end
end

function ENT:OpenNavGate()
	self.Locked = false
end

function ENT:CloseNavGate()
	self.Locked = true
end

if CLIENT then
	function ENT:Draw()
		if nz.Rounds.Data.CurrentState == ROUND_CREATE then
			self:DrawModel()
		end
	end
end
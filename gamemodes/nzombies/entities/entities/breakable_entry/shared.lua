AddCSLuaFile( )

ENT.Type = "anim"

ENT.PrintName		= "breakable_entry"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""
//models/props_interiors/elevatorshaft_door01a.mdl
//models/props_debris/wood_board02a.mdl
function ENT:Initialize()

	self:SetModel("models/props_c17/fence01b.mdl")
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )

	--self:SetHealth(0)
	self:SetCustomCollisionCheck(true)
	self.NextPlank = CurTime()

	self.Planks = {}

	if SERVER then
		self:ResetPlanks(true)
	end
end

function ENT:SetupDataTables()

	self:NetworkVar( "Int", 0, "NumPlanks" )
	self:NetworkVar( "Bool", 0, "HasPlanks" )
	self:NetworkVar( "Bool", 1, "TriggerJumps" )

end

function ENT:AddPlank(nosound)
	if !self:GetHasPlanks() then return end
	self:SpawnPlank()
	self:SetNumPlanks( (self:GetNumPlanks() or 0) + 1 )
	if !nosound then
		self:EmitSound("nz/effects/board_slam_0"..math.random(0,5)..".wav")
	end
end

function ENT:RemovePlank()

	local plank = table.Random(self.Planks)
	if plank != nil then
		table.RemoveByValue(self.Planks, plank)
		self:SetNumPlanks( self:GetNumPlanks() - 1 )
		--self:SetHealth(self:Health()-10)

		//Drop off
		plank:SetParent(nil)
		plank:PhysicsInit(SOLID_VPHYSICS)
		local entphys = plank:GetPhysicsObject()
		if entphys:IsValid() then
			 entphys:EnableGravity(true)
			 entphys:Wake()
		end
		plank:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
		//Remove
		timer.Simple(2, function() plank:Remove() end)
	end
end

function ENT:ResetPlanks(nosoundoverride)
	for i=1, GetConVar("nz_difficulty_barricade_planks_max"):GetInt() do
		self:RemovePlank()
	end
	if self:GetHasPlanks() then
		for i=1, GetConVar("nz_difficulty_barricade_planks_max"):GetInt() do
			self:AddPlank(!nosoundoverride)
		end
	end
end

function ENT:Use( activator, caller )
	if CurTime() > self.NextPlank then
		if self:GetHasPlanks() and self:GetNumPlanks() < GetConVar("nz_difficulty_barricade_planks_max"):GetInt() then
			self:AddPlank()
                  activator:GivePoints(10)
				  activator:EmitSound("nz/effects/repair_ching.wav")
			self.NextPlank = CurTime() + 1
		end
	end
end

function ENT:SpawnPlank()
	//Spawn
	local angs = {-60,-70,60,70}
	local plank = ents.Create("breakable_entry_plank")
	local min = self:GetTriggerJumps() and 0 or -45
	plank:SetPos( self:GetPos()+Vector(0,0, math.random( min, 45 )) )
	plank:SetAngles( Angle(0,self:GetAngles().y, table.Random(angs)) )
	plank:Spawn()
	plank:SetParent(self)
	plank:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	table.insert(self.Planks, plank)
end

function ENT:Touch(ent)
	if self:GetTriggerJumps() and self:GetNumPlanks() == 0 then
		if ent.TriggerBarricadeJump then ent:TriggerBarricadeJump() end
	end
end

hook.Add("ShouldCollide", "zCollisionHook", function(ent1, ent2)
	if ent1:GetClass() == "breakable_entry" and (nzConfig.ValidEnemies[ent2:GetClass()]) then
		if IsValid(ent1) and !ent1:GetTriggerJumps() and ent1:GetNumPlanks() == 0 then
			ent1:SetSolid(SOLID_NONE)
			timer.Simple(0.1, function() if ent1:IsValid() then ent1:SetSolid(SOLID_VPHYSICS) end end)
		end
		return false
	end
	if ent2:GetClass() == "breakable_entry" and (nzConfig.ValidEnemies[ent1:GetClass()]) then
		if IsValid(ent2) and !ent2:GetTriggerJumps() and ent2:GetNumPlanks() == 0 then
			ent2:SetSolid(SOLID_NONE)
			timer.Simple(0.1, function() if ent2:IsValid() then ent2:SetSolid(SOLID_VPHYSICS) end end)
		end
		return false
	end
end)

if CLIENT then
	function ENT:Draw()
		if nzRound:InState( ROUND_CREATE ) then
			self:DrawModel()
		end
	end
end

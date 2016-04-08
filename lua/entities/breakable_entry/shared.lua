AddCSLuaFile( )
-- Defining what type of entity this is
ENT.Type = "anim"

-- Defining what to call it by, the author, how to contact him/her, the purpose, and instructions on how to use it
ENT.PrintName		= "breakable_entry"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

-- Loading models to use
//models/props_interiors/elevatorshaft_door01a.mdl
//models/props_debris/wood_board02a.mdl

function ENT:Initialize()
	
	-- Setting the model for the plank
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
-- End of INIT section

-- Creating data tables
function ENT:SetupDataTables()

	-- Defining a network variable to decide how many placks to use later on
	self:NetworkVar( "Int", 0, "NumPlanks" )

end


function ENT:AddPlank(nosound)
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
	for i=1, GetConVar("nz_difficulty_barricade_planks_max"):GetInt() do
		self:AddPlank(!nosoundoverride)
	end
end

-- Function that gives the player points after fixing the planks/barricade
function ENT:Use( activator, caller )
	if CurTime() > self.NextPlank then
		if self:GetNumPlanks() < GetConVar("nz_difficulty_barricade_planks_max"):GetInt() then
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
	plank:SetPos( self:GetPos()+Vector(0,0, math.random( -45, 45 )) )
	plank:SetAngles( Angle(0,self:GetAngles().y, table.Random(angs)) )
	plank:Spawn()
	plank:SetParent(self)
	plank:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	table.insert(self.Planks, plank)
end

-- Defining that zombies should collide with the barricade rather than go through them
hook.Add("ShouldCollide", "zCollisionHook", function(ent1, ent2)
	if ent1:GetClass() == "breakable_entry" and (nz.Config.ValidEnemies[ent2:GetClass()]) then
		if ent1:IsValid() and ent1:GetNumPlanks() == 0 then
			ent1:SetSolid(SOLID_NONE)
			timer.Simple(0.1, function() if ent1:IsValid() then ent1:SetSolid(SOLID_VPHYSICS) end end)
		end
		return false
	end
	if ent2:GetClass() == "breakable_entry" and (nz.Config.ValidEnemies[ent1:GetClass()]) then
		if ent2:IsValid() and ent2:GetNumPlanks() == 0 then
			ent2:SetSolid(SOLID_NONE)
			timer.Simple(0.1, function() if ent2:IsValid() then ent2:SetSolid(SOLID_VPHYSICS) end end)
		end
		return false
	end
end)

-- Client side operations to draw board models
if CLIENT then
	function ENT:Draw()
		if Round:InState( ROUND_CREATE ) then
			self:DrawModel()
		end
	end
end

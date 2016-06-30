AddCSLuaFile( )

ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.PrintName		= "nz_spawn_zombie"

AccessorFunc(ENT, "iSpawnWeight", "SpawnWeight", FORCE_NUMBER)
AccessorFunc(ENT, "tZombieData", "ZombieData")
AccessorFunc(ENT, "iZombiesToSpawn", "ZombiesToSpawn", FORCE_NUMBER)
AccessorFunc(ENT, "hSpawner", "Spawner")
AccessorFunc(ENT, "dNextSpawn", "NextSpawn", FORCE_NUMBER)

function ENT:DecrementZombiesToSpawn()
	self:SetZombiesToSpawn( self:GetZombiesToSpawn() - 1 )
end

function ENT:SetupDataTables()

	self:NetworkVar( "String", 0, "Link" )

end

function ENT:Initialize()
	self:SetModel( "models/player/odessa.mdl" )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self:SetColor(Color(0, 255, 0))
	self:DrawShadow( false )
	self:SetSpawnWeight(0)
	self:SetZombiesToSpawn(0)
	self:SetNextSpawn(CurTime())
end

function ENT:IsSuitable()
	local tr = util.TraceHull( {
		start = self:GetPos(),
		endpos = self:GetPos(),
		filter = self,
		mins = Vector( -20, -20, 0 ),
		maxs = Vector( 20, 20, 70 ),
		ignoreworld = true,
		mask = MASK_NPCSOLID
	} )

	return not tr.Hit
end

function ENT:Think()
	if SERVER then
	    if nzRound:InState( ROUND_PROG ) and self:GetZombiesToSpawn() > 0 then
			if self:GetSpawner() and self:GetSpawner():GetNextSpawn() < CurTime() and self:GetNextSpawn() < CurTime() then
				if self:IsSuitable() and nzEnemies:TotalAlive() < GetConVar("nz_difficulty_max_zombies_alive"):GetInt() then
					local class = nzMisc.WeightedRandom(self:GetZombieData(), "chance")
					local zombie = ents.Create(class)
					zombie:SetPos(self:GetPos())
					zombie:Spawn()
					-- make a reference to the spawner object used for "respawning"
					zombie:SetSpawner(self:GetSpawner())
					zombie:Activate()
					-- reduce zombies in queue on self and spawner object
					self:GetSpawner():DecrementZombiesToSpawn()
					self:DecrementZombiesToSpawn()
				end
				self:GetSpawner():SetNextSpawn(CurTime() + self:GetSpawner():GetDelay())
				-- this will prevent one spawner from becoming dominant
				self:SetNextSpawn(CurTime() + self:GetSpawner():GetDelay() * 2 + math.Rand(0,0.1))
			end
		end
	end
end

if CLIENT then
	function ENT:Draw()
		if ConVarExists("nz_creative_preview") and !GetConVar("nz_creative_preview"):GetBool() and nzRound:InState( ROUND_CREATE ) then
			self:DrawModel()
		end
	end
end

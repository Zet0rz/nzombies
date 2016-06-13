AddCSLuaFile( )

ENT.Type = "anim"
 
ENT.PrintName		= "wall_block"
ENT.Author			= "Alig96 & Zet0r"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

--[[function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "BlockPlayers")
	self:NetworkVar("Bool", 1, "BlockZombies")
end

function ENT:SetFilter(players, zombies)
	if players and zombies then
		self:SetBlockPlayers(true)
		self:SetBlockZombies(true)
		self:SetCustomCollisionCheck(false)
		self:SetColor(Color(255,255,255))
	elseif players and !zombies then
		self:SetBlockPlayers(true)
		self:SetBlockZombies(false)
		self:SetCustomCollisionCheck(true)
		self:SetColor(Color(100,100,255))
	elseif !players and zombies then
		self:SetBlockPlayers(false)
		self:SetBlockZombies(true)
		self:SetCustomCollisionCheck(true)
		self:SetColor(Color(255,100,100))
	end
end

hook.Add("ShouldCollide", "nzdsadwa_InvisibleBlockFilter", function(ent1, ent2)
	if ent1:GetClass() == "wall_block" then
		if ent2:IsPlayer() then
			if ent1:GetBlockPlayers() then
				return true
			else
				return false
			end
		elseif nzConfig.ValidEnemies[ent2:GetClass()] then
			if ent1:GetBlockZombies() then
				return true
			else
				return false
			end
		end
	elseif ent2:GetClass() == "wall_block" then
		if ent1:IsPlayer() then
			if ent2:GetBlockPlayers() then
				return true
			else
				return false
			end
		elseif nzConfig.ValidEnemies[ent1:GetClass()] then
			if ent2:GetBlockZombies() then
				return true
			else
				return false
			end
		end
	end
end)]]

function ENT:Initialize()
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	self:DrawShadow( false )
	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
	--self:SetCustomCollisionCheck(true)
	--self:SetFilter(true, true)
end

-- Doesn't work? :(
--[[function ENT:TestCollision(startpos, delta, isbox, bounds)
	--if !nzRound:InState( ROUND_CREATE ) then return end -- Makes traces ignore this entity
	print("HDUIAHD", startpos, delta, isbox, bounds)
	return
end]]

if CLIENT then
	function ENT:Draw()
		if ConVarExists("nz_creative_preview") and !GetConVar("nz_creative_preview"):GetBool() and nzRound:InState( ROUND_CREATE ) then
			self:DrawModel()
		end
	end
end
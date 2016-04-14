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
end

function ENT:Initialize()
	--self:SetMoveType( MOVETYPE_NONE )
	self:DrawShadow( false )
	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
	--self:SetCustomCollisionCheck(true)
	--self:SetFilter(true, true)
end


if CLIENT then
	function ENT:Draw()
		-- Drawn together in the hook below
	end
end

local mat = Material("color")
local white = Color(255,150,0,30)

if not ConVarExists("nz_drawinviswalls") then CreateClientConVar("nz_drawinviswalls", "1") end

if engine.ActiveGamemode() == "nzombies3" then 
	hook.Add("PostDrawOpaqueRenderables", "DrawInvisWalls", function()
		if ConVarExists("nz_drawinviswalls") and GetConVar("nz_drawinviswalls"):GetBool() and Round:InState( ROUND_CREATE ) then
			cam.Start3D()
				render.SetMaterial(mat)
				for k,v in pairs(ents.FindByClass("invis_wall")) do
					render.DrawBox(v:GetPos(), v:GetAngles(), Vector(0,0,0), v:GetMaxBound(), white, true)
				end
			cam.End3D()
		end
	end)
end
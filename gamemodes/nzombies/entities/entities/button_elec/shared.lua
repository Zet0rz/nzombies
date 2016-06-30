AddCSLuaFile( )

ENT.Type = "anim"
 
ENT.PrintName		= "button_elec"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

function ENT:SetupDataTables()

	self:NetworkVar( "Bool", 0, "Switch" )
	
end

function ENT:Initialize()
	if SERVER then
		self:SetModel( "models/MaxOfS2D/button_01.mdl" )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetUseType( ONOFF_USE )
		self:SetSwitch(false)
	else
		self.PosePosition = 0
	end
end

function ENT:Use( activator )

	if ( !activator:IsPlayer() ) then return end
	if !IsElec() and nzRound:InProgress() then
		self:SetSwitch(true)
		nz.nzElec.Functions.Activate()
	end

end
	
if CLIENT then

	function ENT:Think()

		local TargetPos = 0.0;
		
		if ( self:GetSwitch() ) then TargetPos = 1.0; end
		
		self.PosePosition = math.Approach( self.PosePosition, TargetPos, FrameTime() * 5.0 )	
		
		self:SetPoseParameter( "switch", self.PosePosition )
		self:InvalidateBoneCache()

	end
	
	function ENT:Draw()
		self:DrawModel()
	end
end
AddCSLuaFile( )

-- Defining entity type
ENT.Type = "anim"
 
-- Defining name to call it by, the author, the contact information, the purpose of this entity, and instructions on how to use this
ENT.PrintName		= "button_elec"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

-- Creating data tables
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


-- Defining what happens when a playrer presses E on the switch entity
function ENT:Use( activator )

	if ( !activator:IsPlayer() ) then return end
	if !IsElec() and Round:InProgress() then
		self:SetSwitch(true)
		nz.Elec.Functions.Activate()
	end

end

-- Client side operations to render the switch and activate the switch
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

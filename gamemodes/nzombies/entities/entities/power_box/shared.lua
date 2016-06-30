AddCSLuaFile( )

ENT.Type = "anim"
 
ENT.PrintName		= "Zombies Power"
ENT.Author			= "Zet0r"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

function ENT:SetupDataTables()

	self:NetworkVar( "Bool", 0, "Switch" )
	self:NetworkVar( "Entity", 0, "PowerHandle")
	
end

function ENT:Initialize()
	if SERVER then
		self:SetModel( "models/nzprops/zombies_power_lever.mdl" )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetUseType( ONOFF_USE )
		self:SetSwitch(false)
		
		self.Handle = ents.Create("nz_prop_effect_attachment")
		self.Handle:SetModel("models/nzprops/zombies_power_lever_handle.mdl")
		self.Handle:SetAngles( self:GetAngles() )
		self.Handle:SetPos(self:GetPos() + self:GetAngles():Up()*46 + self:GetAngles():Forward()*7)
		self.Handle:Spawn()
		self.Handle:SetParent(self)
		self:SetPowerHandle(self.Handle)
		
		self:DeleteOnRemove( self.Handle )
	else
		self.Switched = false
	end
end

function ENT:Use( activator )

	if ( !activator:IsPlayer() ) then return end
	if !IsElec() and nzRound:InProgress() then
		self:SetSwitch(true)
		self.Switched = 0
		nzElec:Activate()
	end

end
	
if CLIENT then

	local offang = Angle(0,0,0)
	local onang = Angle(-90,0,0)

	function ENT:Think()
		local handle = self:GetPowerHandle()
		if self:GetSwitch() != self.Switched then
			self.Switching = math.Approach( self.Switching or 0, 1, FrameTime() * 2 )
			local ang = self:GetAngles()
			if self:GetSwitch() then
				handle:SetRenderAngles(LerpAngle(self.Switching, self:LocalToWorldAngles(offang), self:LocalToWorldAngles(onang)))
			else
				handle:SetRenderAngles(LerpAngle(self.Switching, self:LocalToWorldAngles(onang), self:LocalToWorldAngles(offang)))
			end
			
			if self.Switching >= 1 then
				self.Switched = self:GetSwitch()
				self.Switching = nil
			end
		end
	end
	
	function ENT:Draw()
		self:DrawModel()
	end
end
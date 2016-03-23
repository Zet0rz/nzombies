AddCSLuaFile( )

ENT.Type = "anim"

ENT.PrintName		= "random_box_windup"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

function ENT:SetupDataTables()

	self:NetworkVar( "Bool", 0, "Winding" )
	self:NetworkVar( "String", 0, "WepClass")
	self:NetworkVar( "Bool", 1, "IsTeddy" )

end

function ENT:Initialize()

	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_OBB )
	self:DrawShadow( false )

	self:SetWinding(true)
	self:SetIsTeddy(false)
	self.c = 0
	self.s = -20
	self.t = 0
	self:SetModel("models/weapons/w_rif_ak47.mdl")
	--self:SetAngles(self:GetParent():GetAngles())

	if SERVER then
		//Stop winding up
		timer.Simple(5, function() 
			self:SetWinding(false)
			if self:GetWepClass() == "nz_box_teddy" then
				print("Model here")
				self:SetModel("models/hoff/props/teddy_bear/teddy_bear.mdl")
				self:SetAngles( self:GetParent():GetAngles() + Angle(-90,90,0) )
				nz.Notifications.Functions.PlaySound("nz/randombox/teddy_bear_laugh.wav", 0)
				self:SetIsTeddy(true)
			else
				self:SetModel(weapons.Get(self:GetWepClass()).WorldModel)
			end
			print(self:GetModel())
		end)
		//If we time out, remove the object
		timer.Simple(18, function() if self:IsValid() then self:GetParent():Close() self:Remove() end end)
	end
end

function ENT:Use( activator, caller )
	if !self:GetWinding() and self:GetWepClass() != "nz_box_teddy" then
		if activator == self.Buyer then
			local class = self:GetWepClass()
			activator:Give(class)
			nz.Weps.Functions.GiveMaxAmmoWep(activator, class)
			self:GetParent():Close()
			self:Remove()
		else
			if self.Buyer:IsValid() then
				activator:PrintMessage( HUD_PRINTTALK, "This is " .. self.Buyer:Nick() .. "'s gun. You cannot take it." )
			end
		end
	end
end

function ENT:WindUp( )
	local gun = table.Random(weapons.GetList())
	if gun.WorldModel != nil then
		self:SetModel(gun.WorldModel)
	end
	self.c = self.c + 1.3
	if self.c > 7 then
		self.c = 7
	end
	self:SetPos(Vector(self:GetPos().X, self:GetPos().Y, self:GetPos().Z + 0.1*self.c))
end

function ENT:TeddyFlyUp( )
	self.t = self.t + 1
	if self.t > 25 then
		self:GetParent():Close()
		self:GetParent():MoveAway()
		self:Remove()
		self.t = 25
	end
	self:SetPos(Vector(self:GetPos().X, self:GetPos().Y, self:GetPos().Z + 1*self.t))
end

function ENT:WindDown( )
	self.s = self.s + 1
	
	if self.s > 7 then
		self.s = 7
	end
	if self.s >= 0 then
		self:SetPos(Vector(self:GetPos().X, self:GetPos().Y, self:GetPos().Z - 0.1*self.s))
	end
end

function ENT:Think()
	if SERVER then
		if self:GetIsTeddy() then
			self:TeddyFlyUp()
		elseif self:GetWinding() then
			self:WindUp()
		else
			self:WindDown()
		end
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end

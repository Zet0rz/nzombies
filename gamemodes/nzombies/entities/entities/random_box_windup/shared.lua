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

	self:SetMoveType(MOVETYPE_NOCLIP)
	self:SetLocalVelocity(self:GetAngles():Up() * 4)

	self:SetSolid( SOLID_OBB )
	self:DrawShadow( false )

	self:SetWinding(true)
	self:SetIsTeddy(false)
	self.c = 0
	self.s = -20
	self.t = 0
	self:SetModel("models/weapons/w_rif_ak47.mdl")
	--self:SetAngles(self.Box:GetAngles())
	local box = self.Box -- self.Box

	if SERVER then
		//Stop winding up
		timer.Simple(5, function()
			self:SetWinding(false)
			if self:GetWepClass() == "nz_box_teddy" then
				self:SetModel("models/hoff/props/teddy_bear/teddy_bear.mdl")
				self:SetAngles( self.Box:GetAngles() + Angle(-90,90,0) )
				self:SetLocalVelocity(self.Box:GetAngles():Up()*30)
				nz.Notifications.Functions.PlaySound("nz/randombox/teddy_bear_laugh.wav", 0)
				self:SetIsTeddy(true)
				if IsValid(self.Buyer) then self.Buyer:GivePoints(950) end -- Refund please
			else
				local wep = weapons.Get(self:GetWepClass())
				self:SetModel(wep.WM or wep.WorldModel)
				self:SetLocalVelocity(Vector(0,0,0)) -- Stop
			end
			--print(self:GetModel())
		end)
		-- If we time out, remove the object
		timer.Simple(15, function() if IsValid(self) then self:SetLocalVelocity(self:GetAngles():Up()*-2) end end)
		-- If we time out, remove the object
		timer.Simple(25, function() if IsValid(self) then self.Box:Close() self:Remove() end end)
	else
		local wep = weapons.Get(self:GetWepClass())
		if wep.DrawWorldModel then self.WorldModelFunc = wep.DrawWorldModel end
	end
end

function ENT:Use( activator, caller )
	if !self:GetWinding() and self:GetWepClass() != "nz_box_teddy" then
		if activator == self.Buyer then
			local class = self:GetWepClass()
			activator:Give(class)
			nzWeps:GiveMaxAmmoWep(activator, class)
			self.Box:Close()
			self:Remove()
		else
			if IsValid(self.Buyer) then
				activator:PrintMessage( HUD_PRINTTALK, "This is " .. self.Buyer:Nick() .. "'s gun. You cannot take it." )
			end
		end
	end
end

function ENT:WindUp( )
	local gun
	if nzMapping.Settings.rboxweps then
		gun = weapons.Get(nzMapping.Settings.rboxweps[math.random(#nzMapping.Settings.rboxweps)])
	else
		gun = table.Random(weapons.GetList())
	end

	if gun and gun.WorldModel != nil then
		self:SetModel(gun.WM or gun.WorldModel)
	end
	--[[self.c = self.c + 1.3
	if self.c > 7 then
		self.c = 7
	end
	self:SetPos(Vector(self:GetPos().X, self:GetPos().Y, self:GetPos().Z + 0.1*self.c))]]
end

function ENT:TeddyFlyUp( )
	self.t = self.t + 1
	if self.t > 25 then
		self.Box:Close()
		self.Box:MoveAway()
		self:Remove()
		self.t = 25
	end
	--self:SetPos(Vector(self:GetPos().X, self:GetPos().Y, self:GetPos().Z + 1*self.t))
end

function ENT:WindDown( )
	--[[self.s = self.s + 1

	if self.s > 7 then
		self.s = 7
	end
	if self.s >= 0 then
		self:SetPos(Vector(self:GetPos().X, self:GetPos().Y, self:GetPos().Z - 0.1*self.s))
	end]]
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
		-- If we've stopped winding
		if !self:GetWinding() then
			-- We can use the stored world model draw function from the original weapon, but if it doesn't exist or causes errors, then just draw model
			if !self.WorldModelFunc or !pcall(self.WorldModelFunc, self) then self:DrawModel() end
		else
			self:DrawModel()
		end
	end
end

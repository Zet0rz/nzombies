AddCSLuaFile( )

ENT.Type = "anim"

ENT.PrintName		= "buy_gun_area"
ENT.Author			= "Alig96 & Zet0r"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

function ENT:SetupDataTables()
	self:NetworkVar( "String", 0, "WepClass" )
	self:NetworkVar( "String", 1, "Price" )
	self:NetworkVar( "Bool", 0, "Bought" )
	self:NetworkVar( "Bool", 1, "Flipped" )
end

local flipscale = Vector(1.5, 0.01, 1.5) 	-- Decides on which axis it flattens the outline
local normalscale = Vector(0.01, 1.5, 1.5) 	-- based on the bool self:GetFlipped()

CreateClientConVar("nz_outlinedetail", "4") -- Controls the outline creation

chalkmaterial = Material("chalk.png", "unlitgeneric smooth")

function ENT:Initialize()
	if SERVER then
		self:SetMoveType( MOVETYPE_NONE )
		--self:SetSolid( SOLID_VPHYSICS )
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
		self:SetUseType(SIMPLE_USE)
		self:SetFlipped(true) -- Apparently makes it work with default orientation?
		self:SetSolid( SOLID_OBB )
		self:PhysicsInit( SOLID_OBB )
	else
		self.Flipped = self:GetFlipped()
		self:RecalculateModelOutlines()
		local wep = weapons.Get(self:GetWepClass())
		util.PrecacheModel(wep.WM or wep.WorldModel)
	end
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:DrawShadow(false)
	--self:SetColor(Color(0,0,0,0))
end

function ENT:OnRemove()
	if CLIENT then
		self:RemoveOutline()
	end
end

function ENT:RecalculateModelOutlines()
	self:RemoveOutline()
	local num = GetConVar("nz_outlinedetail"):GetInt()
	local ang = self:GetAngles()
	local curang = self:GetAngles() -- Modifies offset if flipped
	local curpos = self:GetPos()
	local wep = weapons.Get(self:GetWepClass())
	local model = wep.WM or wep.WorldModel
	
	-- Precache the model whenever it changes, including on spawn
	util.PrecacheModel(wep.WM or wep.WorldModel)
	
	self.modelclass = self:GetWepClass()
	
	if !self.Flipped then
		curang:RotateAroundAxis(curang:Up(), 90)
	end
	--print(curang, "HUDIASHUD", self.Flipped)
	if num >= 1 then
		self.Chalk1 = ClientsideModel(model)
		local offset = curang:Up()*0.5 + curang:Forward()*-0.5 --Vector(0,-0.5,0.5)
		self.Chalk1:SetPos(curpos + offset)
		self.Chalk1:SetAngles(ang)
		self.Chalk1:SetMaterial(chalkmaterial)
		--self.Chalk:SetModelScale(1.7)
			
		local mat = Matrix()
		mat:Scale( self.Flipped and flipscale or normalscale )
			
		self.Chalk1:EnableMatrix( "RenderMultiply", mat )
		self.Chalk1:SetNoDraw(true)
		self.Chalk1:SetParent(self)
	end
		
	if num >= 2 then
		self.Chalk2 = ClientsideModel(model)
		offset = curang:Up()*-0.5 + curang:Forward()*0.5
		self.Chalk2:SetPos(curpos + offset)
		self.Chalk2:SetAngles(ang)
		self.Chalk2:SetMaterial(chalkmaterial)
		--self.Chalk:SetModelScale(1.7)
			
		mat = Matrix()
		mat:Scale( self.Flipped and flipscale or normalscale )
			
		self.Chalk2:EnableMatrix( "RenderMultiply", mat )
		self.Chalk2:SetNoDraw(true)
		self.Chalk2:SetParent(self)
	end
		
	if num >= 3 then
		self.Chalk3 = ClientsideModel(model)
		offset = curang:Up()*0.5 + curang:Forward()*0.5
		self.Chalk3:SetPos(curpos + offset)
		self.Chalk3:SetAngles(ang)
		self.Chalk3:SetMaterial(chalkmaterial)
		--self.Chalk:SetModelScale(1.7)
			
		mat = Matrix()
		mat:Scale( self.Flipped and flipscale or normalscale )
			
		self.Chalk3:EnableMatrix( "RenderMultiply", mat )
		self.Chalk3:SetNoDraw(true)
		self.Chalk3:SetParent(self)
	end
		
	if num >= 4 then
		self.Chalk4 = ClientsideModel(model)
		offset = curang:Up()*-0.5 + curang:Forward()*-0.5
		self.Chalk4:SetPos(curpos + offset)
		self.Chalk4:SetAngles(ang)
		self.Chalk4:SetMaterial(chalkmaterial)
		--self.Chalk:SetModelScale(1.7)
			
		mat = Matrix()
		mat:Scale( self.Flipped and flipscale or normalscale )
			
		self.Chalk4:EnableMatrix( "RenderMultiply", mat )
		self.Chalk4:SetNoDraw(true)
		self.Chalk4:SetParent(self)
	end
		
	if num >= 1 then
		self.ChalkCenter = ClientsideModel(model)
		self.ChalkCenter:SetPos(curpos)
		self.ChalkCenter:SetAngles(ang)
		self.ChalkCenter:SetMaterial(chalkmaterial)
			
		mat = Matrix()
		mat:Scale( self.Flipped and flipscale or normalscale )
			
		self.ChalkCenter:EnableMatrix( "RenderMultiply", mat )
		self.ChalkCenter:SetNoDraw(true)
		self.ChalkCenter:SetParent(self)
	end
end

function ENT:RemoveOutline()
	if IsValid(self.Chalk1) then
		self.Chalk1:Remove()
	end
	if IsValid(self.Chalk2) then
		self.Chalk2:Remove()
	end
	if IsValid(self.Chalk3) then
		self.Chalk3:Remove()
	end
	if IsValid(self.Chalk4) then
		self.Chalk4:Remove()
	end
	if IsValid(self.ChalkCenter) then
		self.ChalkCenter:Remove()
	end
end

if SERVER then

	function ENT:SetWeapon(weapon, price)
		//Add a special check for FAS weps
		local wep = weapons.Get(weapon)
		local model
		if !wep then
			model = "models/weapons/w_crowbar.mdl"
		else
			model = wep.WM or wep.WorldModel
			--self:SetFlipped(false)
		end
		self:SetModel(model)
		self:SetModelScale( 1.5, 0 )
		self.WeaponGive = weapon
		self.Price = price
		self:SetWepClass(weapon)
		self:SetPrice(price)
	end
	
	function ENT:ToggleRotate()
		local ang = self:GetAngles()
		self:SetFlipped(!self:GetFlipped())
		--self:SetAngles(self:GetAngles() + Angle(0,90,0))
		ang:RotateAroundAxis(ang:Up(), 90)
		self:SetAngles(ang)
		--print(self:GetFlipped())
	end

	function ENT:Use( activator, caller )
		local price = self.Price
		local ammo_type = weapons.Get(self.WeaponGive).Primary.Ammo
		local ammo_price = math.ceil((price - (price % 10))/2)
		local ammo_price_pap = 4500
		local curr_ammo = activator:GetAmmoCount( ammo_type )
		local give_ammo = nz.Weps.Functions.CalculateMaxAmmo(self.WeaponGive) - curr_ammo


		if !activator:HasWeapon( self.WeaponGive ) then
			if activator:CanAfford(price) then
				activator:TakePoints(price)
				activator.LastUsedSWEP = activator:GetActiveWeapon()
				activator:Give(self.WeaponGive)
				nz.Weps.Functions.GiveMaxAmmoWep(activator, self.WeaponGive)
				self:SetBought(true)
				--activator:EmitSound("nz/effects/buy.wav")
			else
				print("Can't afford!")
			end
		elseif string.lower(ammo_type) != "none" then
			if activator:GetWeapon(self.WeaponGive).pap then
				if activator:CanAfford(ammo_price_pap) then
					if give_ammo != 0 then
						activator:TakePoints(ammo_price_pap)
						nz.Weps.Functions.GiveMaxAmmoWep(activator, self.WeaponGive)
						--activator:EmitSound("nz/effects/buy.wav")
					else
						print("Max Clip!")
					end
				else
					print("Can't afford!")
				end
			else	// Refill ammo
				if activator:CanAfford(ammo_price) then
					if give_ammo != 0 then
						activator:TakePoints(ammo_price)
						nz.Weps.Functions.GiveMaxAmmoWep(activator, self.WeaponGive)
						--activator:EmitSound("nz/effects/buy.wav")
					else
						print("Max Clip!")
					end
				else
					print("Can't afford!")
				end
			end
		end
		return
	end
end


if CLIENT then

	function ENT:Think()
		if self.Flipped != self:GetFlipped() then
			self.Flipped = self:GetFlipped()
			self:RecalculateModelOutlines()
			--print(self.Flipped)
		end
		if self.modelclass != self:GetWepClass() then
			self.modelclass = self:GetWepClass()
			self:RecalculateModelOutlines()
			--print(self.Flipped)
		end
	end

	local glow = Material ( "sprites/glow04_noz" )
	local white = Color(0,200,255,50)
	function ENT:Draw()
		--self:DrawModel()
		local num = math.Clamp(GetConVar("nz_outlinedetail"):GetInt(), 0, 4)
		if num < 1 or (self.OutlineGiveUp and self.OutlineGiveUp > 5) then
			self:DrawModel()
		else
			local pos = LocalPlayer():EyePos()+LocalPlayer():EyeAngles():Forward()*10
			local ang = LocalPlayer():EyeAngles()
			ang = Angle(ang.p+90,ang.y,0)
			if halo.RenderedEntity() != self then
				render.ClearStencil()
				render.SetStencilEnable(true)
					render.SetStencilWriteMask(255)
					render.SetStencilTestMask(255)
					render.SetStencilReferenceValue(15)
					render.SetStencilFailOperation(STENCILOPERATION_KEEP)
					render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
					render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
					render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
					render.SetBlend(0)
					
						for i = 1, num do
							-- If it isn't valid (NULL ENTITY), attempt to recreate
							if !IsValid(self["Chalk"..i]) then 
								self:RecalculateModelOutlines()
								-- Log how many tries we did, we'll give up after 5 and just draw the model :(
								self.OutlineGiveUp = self.OutlineGiveUp and self.OutlineGiveUp + 1 or 1
								break 
							end
							self["Chalk"..i]:DrawModel()
						end
						
					render.SetStencilPassOperation(STENCILOPERATION_ZERO) -- Make it deselect the center model
					self.ChalkCenter:DrawModel()
						
					render.SetBlend(1)
					render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
					cam.Start3D2D(pos,ang,1)
						--surface.SetDrawColor(0,0,0)
						surface.SetDrawColor(255,255,255)
						surface.DrawRect(-ScrW(),-ScrH(),ScrW()*2,ScrH()*2)
						surface.SetMaterial(chalkmaterial)
						surface.DrawTexturedRect(-ScrW(),-ScrH(),ScrW()*2,ScrH()*2)
					cam.End3D2D()
				render.SetStencilEnable(false)
			end
			local spritepos = self:WorldSpaceCenter()
			cam.Start3D()
				render.SetMaterial( glow )
				render.DrawSprite( spritepos + (pos-spritepos):GetNormalized()*5, 200, 100, white)
			cam.End3D()
			if self:GetBought() then
				self:DrawModel()
			end
		end
	end
	
end

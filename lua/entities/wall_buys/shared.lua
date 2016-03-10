AddCSLuaFile( )

ENT.Type = "anim"

ENT.PrintName		= "buy_gun_area"
ENT.Author			= "Alig96 & Zet0r"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

function ENT:SetupDataTables()
	self:NetworkVar( "String", 0, "EntName" )
	self:NetworkVar( "String", 1, "Price" )
	self:NetworkVar( "Bool", 0, "Bought" )
	self:NetworkVar( "Bool", 1, "Flipped" )
end

local normalscale = Vector(1.5, 0.01, 1.5) 	-- Decides on which axis it flattens the outline
local flipscale = Vector(0.01, 1.5, 1.5) 	-- based on the bool self:GetFlipped()

CreateClientConVar("nz_outlinedetail", "4") -- Controls the outline creation

chalkmaterial = Material("chalk.png", "unlitgeneric smooth")

function ENT:Initialize()
	if SERVER then
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetUseType(SIMPLE_USE)
		self:SetFlipped(true) -- Apparently makes it work with default orientation?
		--self:SetSolid( SOLID_OBB )
	else
		self:RecalculateModelOutlines()
		self.Flipped = self:GetFlipped()
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
	local curang = self:GetAngles()
	local curpos = self:GetPos()
	local model = self:GetModel()
	if self.Flipped then
		curang:RotateAroundAxis(curang:Right(), 90)
	end
	print(ang)
	if num >= 1 then
		self.Chalk1 = ClientsideModel(model)
		local offset = Vector(0,-0.5,0.5)
		offset:Rotate(ang)
		self.Chalk1:SetPos(curpos + offset)
		self.Chalk1:SetAngles(curang)
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
		offset = Vector(0,0.5,-0.5)
		offset:Rotate(ang)
		self.Chalk2:SetPos(curpos + offset)
		self.Chalk2:SetAngles(curang)
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
		offset = Vector(0,0.5,0.5)
		offset:Rotate(ang)
		self.Chalk3:SetPos(curpos + offset)
		self.Chalk3:SetAngles(curang)
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
		offset = Vector(0,-0.5,-0.5)
		offset:Rotate(ang)
		self.Chalk4:SetPos(curpos + offset)
		self.Chalk4:SetAngles(curang)
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
		self.ChalkCenter:SetAngles(curang)
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
		if !wep then
			self:SetModel( "models/weapons/w_crowbar.mdl" )
		else
			if weapons.Get(weapon).Category == "FA:S 2 Weapons" then
				//self:SetModel( weapons.Get(weapon).WM )
				self:SetModel( weapons.Get(weapon).WorldModel )
			else
				self:SetModel( weapons.Get(weapon).WorldModel )
			end
			self:SetFlipped(false)
		end
		self:SetModelScale( 1.5, 0 )
		self.WeaponGive = weapon
		self.Price = price
		self:SetEntName(weapon)
		self:SetPrice(price)
	end
	
	function ENT:ToggleRotate()
		self:SetFlipped(!self:GetFlipped())
		self:SetAngles(self:GetAngles() + Angle(0,90,0))
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
				activator:Give(self.WeaponGive)
				nz.Weps.Functions.GiveMaxAmmoWep(activator, self.WeaponGive)
				self:SetBought(true)
				--activator:EmitSound("nz/effects/buy.wav")
			else
				print("Can't afford!")
			end
		elseif activator:GetWeapon(self.WeaponGive).pap then
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
		return
	end
end


if CLIENT then

	function ENT:Think()
		if self.Flipped != self:GetFlipped() then
			self:RecalculateModelOutlines()
			self.Flipped = self:GetFlipped()
			--print(self.Flipped)
		end
	end

	local glow = Material ( "sprites/glow04_noz" )
	local white = Color(0,200,255,50)
	function ENT:Draw()
		local num = math.Clamp(GetConVar("nz_outlinedetail"):GetInt(), 0, 4)
		if num < 1 then
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

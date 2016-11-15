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
		local wep = weapons.Get(self:GetWepClass())
		if wep then
			if wep.DrawWorldModel then self.WorldModelFunc = wep.DrawWorldModel end
			
			-- Forced precaching!
			local model = ClientsideModel("models/hoff/props/teddy_bear/teddy_bear.mdl")
			util.PrecacheModel(wep.VM or wep.ViewModel)
			model:SetModel(wep.ViewModel)
			if wep.VM then model:SetModel(wep.VM) end
			model:Remove()
			
			self:RecalculateModelOutlines()
		end
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
	if !wep then self:RemoveOutline() return end
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
		-- Add a special check for FAS weps
		local price = price or self:GetPrice()
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
		
		local wep
		for k,v in pairs(activator:GetWeapons()) do
			if v:GetClass() == self.WeaponGive then wep = v break end
		end
		if !wep then wep = weapons.Get(self.WeaponGive) end
		if !wep then return end
		local ammo_type = wep.GetPrimaryAmmoType and wep:GetPrimaryAmmoType() or wep.Primary.Ammo

		local ammo_price = math.ceil((price - (price % 10))/2)
		local ammo_price_pap = 4500
		local curr_ammo = activator:GetAmmoCount( ammo_type )
		local give_ammo = nzWeps:CalculateMaxAmmo(self.WeaponGive) - curr_ammo
		
		--print(ammo_type, curr_ammo, give_ammo)

		if !activator:HasWeapon( self.WeaponGive ) then
			activator:Buy(price, self, function()
				--activator:TakePoints(price)
				activator:Give(self.WeaponGive)
				nzWeps:GiveMaxAmmoWep(activator, self.WeaponGive)
				self:SetBought(true)
				return true
				--activator:EmitSound("nz/effects/buy.wav")
			end)
		elseif string.lower(ammo_type) != "none" and ammo_type != -1 then
			if activator:GetWeapon(self.WeaponGive):HasNZModifier("pap") then
				activator:Buy(ammo_price_pap, self, function()
					if give_ammo != 0 then
						--activator:TakePoints(ammo_price_pap)
						nzWeps:GiveMaxAmmoWep(activator, self.WeaponGive)
						--activator:EmitSound("nz/effects/buy.wav")
						return true
					else
						print("Max Clip!")
						return false -- Didn't work, don't take points!
					end
				end)
			else	-- Refill ammo
				activator:Buy(ammo_price, self, function()
					if give_ammo != 0 then
						--activator:TakePoints(ammo_price)
						nzWeps:GiveMaxAmmoWep(activator, self.WeaponGive)
						--activator:EmitSound("nz/effects/buy.wav")
						return true
					else
						print("Max Clip!")
						return false
					end
				end)
			end
		end
		return
	end
end


if CLIENT then

	function ENT:Update()
		local wep = weapons.Get(self:GetWepClass())
		if wep then
			if wep.DrawWorldModel then self.WorldModelFunc = wep.DrawWorldModel end
			util.PrecacheModel(wep.WM or wep.WorldModel)
			self:RecalculateModelOutlines()
		end
		self.OutlineGiveUp = 0
	end

	function ENT:Think()
		if self.Flipped != self:GetFlipped() then
			self.Flipped = self:GetFlipped()
			self:RecalculateModelOutlines()
			--print(self.Flipped)
		end
		if self.modelclass != self:GetWepClass() then
			self.modelclass = self:GetWepClass()
			self:Update()
			--print(self.Flipped)
		end
	end

	local glow = Material( "sprites/light_ignorez" )
	local white = Color(0,200,255,50)
	
	function ENT:Draw()
		--self:DrawModel()
		local num = math.Clamp(GetConVar("nz_outlinedetail"):GetInt(), 0, 4)
		if num < 1 or (self.OutlineGiveUp and self.OutlineGiveUp > 5) then
			-- If we don't have a function or it errors, call default DrawModel
			if !self.WorldModelFunc or !pcall(self.WorldModelFunc, self) then self:DrawModel() end
			--self:DrawModel()
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
					if !IsValid(self["ChalkCenter"]) then 
						self:RecalculateModelOutlines()
						self.OutlineGiveUp = self.OutlineGiveUp and self.OutlineGiveUp + 1 or 1
					else
						self.ChalkCenter:DrawModel()
					end
						
					render.SetBlend(1)
					render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
					cam.Start3D2D(pos,ang,1)
						--surface.SetDrawColor(0,0,0)
						surface.SetDrawColor(255,255,255)
						surface.DrawRect(-ScrW(),-ScrH(),ScrW()*2,ScrH()*2)
						--surface.SetMaterial(chalkmaterial)
						--surface.DrawTexturedRect(-ScrW(),-ScrH(),ScrW()*2,ScrH()*2)
					cam.End3D2D()
				render.SetStencilEnable(false)
			end
			
			local wsc = self:WorldSpaceCenter()
			local wsp = self:GetPos()
			
			local spritepos = self:GetFlipped() and Vector(wsp.x, wsc.y, wsc.z) or Vector(wsc.x, wsp.y, wsc.z)
			local spriteang = self:GetFlipped() and self:GetAngles() + Angle(180,10,-90) or self:GetAngles() + Angle(0,90,90)
			--[[cam.Start3D()
				render.SetMaterial( glow )
				render.DrawSprite( spritepos + (pos-spritepos):GetNormalized()*5, 200, 100, white)
			cam.End3D()]]
			
			cam.Start3D2D(spritepos, spriteang, 1)
				surface.SetMaterial(glow)
				surface.SetDrawColor(white)
				--surface.DrawTexturedRect(-50,-25,100,50)
				surface.DrawTexturedRectUV(-50,-25,50,50,0,0,0.5,1)
			cam.End3D2D()
			
			debugoverlay.Line(spritepos, spritepos + spriteang:Forward()*15, 1, Color(0,255,0))
			debugoverlay.Line(spritepos, spritepos + spriteang:Right()*5, 1, Color(0,255,0))
			
			spriteang:RotateAroundAxis(spriteang:Right(),20)
			
			debugoverlay.Line(spritepos, spritepos + spriteang:Forward()*15, 1, Color(255,0,0))
			debugoverlay.Line(spritepos, spritepos + spriteang:Right()*5, 1, Color(255,0,0))
		
			cam.Start3D2D(spritepos, spriteang, 1)
				surface.SetMaterial(glow)
				surface.SetDrawColor(white)
				--surface.DrawTexturedRect(-50,-25,100,50)
				surface.DrawTexturedRectUV(0,-25,50,50,0.5,0,1,1)
			cam.End3D2D()
			
			if self:GetBought() then
				if !self.WorldModelFunc or !pcall(self.WorldModelFunc, self) then self:DrawModel() end
			end
		end
	end
	
end

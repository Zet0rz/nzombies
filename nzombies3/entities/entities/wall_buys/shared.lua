AddCSLuaFile( )

ENT.Type = "anim"

ENT.PrintName		= "buy_gun_area"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

function ENT:SetupDataTables()

	self:NetworkVar( "String", 0, "EntName" )
	self:NetworkVar( "String", 1, "Price" )
end

if SERVER then
	function ENT:Initialize()
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetUseType(SIMPLE_USE)
	end

	function ENT:SetWeapon(weapon, price)
		//Add a special check for FAS weps
		if weapons.Get(weapon).Category == "FA:S 2 Weapons" then
			//self:SetModel( weapons.Get(weapon).WM )
			self:SetModel( weapons.Get(weapon).WorldModel )
		else
			self:SetModel( weapons.Get(weapon).WorldModel )
		end
		self:SetModelScale( 1.5, 0 )
		self.WeaponGive = weapon
		self.Price = price
		self:SetEntName(weapon)
		self:SetPrice(price)
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
	function ENT:Draw()
		self:DrawModel()
	end
end

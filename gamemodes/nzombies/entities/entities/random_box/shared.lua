AddCSLuaFile( )

ENT.Type = "anim"

ENT.PrintName		= "random_box"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

function ENT:SetupDataTables()

	self:NetworkVar( "Bool", 0, "Open" )

end

function ENT:Initialize()

	self:SetModel( "models/hoff/props/mysterybox/box.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )

	--[[local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end]]

	self:DrawShadow( false )
	self:AddEffects( EF_ITEM_BLINK )
	self:SetOpen(false)
	self.Moving = false
	self:Activate()
	if SERVER then
		self:SetUseType( SIMPLE_USE )
	end
	
	if CLIENT then
		self.Light = ClientsideModel("models/effects/vol_light128x512.mdl")
		local ang = self:GetAngles()
		self.Light:SetAngles(Angle(0, ang[2], 180))
		self.Light:SetPos(self:GetPos() - Vector(0,0,50))
		--self.Light:SetParent(self)
		self.Light:SetColor(Color(150,200,255))
		self.Light:DrawShadow(false)
		local min, max = self.Light:GetRenderBounds()
		self.Light:SetRenderBounds(Vector(min.x, min.y, min.z), Vector(max.x, max.y, max.z*10))
		
		local scale = Vector( 1, 1, 5 )
		local mat = Matrix()
		mat:Scale( scale )
		self.Light:EnableMatrix( "RenderMultiply", mat )
		
		self.Light:Spawn()
	end
end

function ENT:Use( activator, caller )
	if self:GetOpen() == true or self.Moving then return end
	self:BuyWeapon(activator)
	-- timer.Simple(5,function() self:MoveAway() end)
end

function ENT:BuyWeapon(ply)
	ply:Buy(nzPowerUps:IsPowerupActive("firesale") and 10 or 950, self, function()
        local class = nzRandomBox.DecideWep(ply)
        if class != nil then
      		--ply:TakePoints(nzPowerUps:IsPowerupActive("firesale") and 10 or 950)
      		self:Open()
      		local wep = self:SpawnWeapon( ply, class )
			wep.Buyer = ply
			return true
        else
            ply:PrintMessage( HUD_PRINTTALK, "No available weapons left!")
			return false
        end
	end)
end


function ENT:Open()
	local sequence = self:LookupSequence("Close")
	self:ResetSequence(sequence)
	self:RemoveEffects( EF_ITEM_BLINK )

	self:SetOpen(true)
end

function ENT:Close()
	local sequence = self:LookupSequence("Open")
	self:ResetSequence(sequence)
	self:AddEffects( EF_ITEM_BLINK )

	self:SetOpen(false)
end

function ENT:SpawnWeapon(activator, class)
	local wep = ents.Create("random_box_windup")
	local ang = self:GetAngles()
	wep:SetAngles( ang )
	wep:SetPos( self:GetPos() + ang:Up()*10 )
	wep:SetWepClass(class)
	wep:Spawn()
	wep.Buyer = activator
	--wep:SetParent( self )
	wep.Box = self
	--wep:SetAngles( self:GetAngles() )
	self:EmitSound("nz/randombox/random_box_jingle.wav")

	return wep
end

function ENT:Think()
	self:NextThink(CurTime())
	
	if self.MarkedForRemoval and !self:GetOpen() then
		self:Remove()
	end
	
	return true
end

function ENT:MoveAway()
	nzNotifications:PlaySound("nz/randombox/Announcer_Teddy_Zombies.wav", 0)
	self.Moving = true
	self:SetSolid(SOLID_NONE)
	local s = 0
	local ang = self:GetAngles()
	-- Shake Effect
	timer.Create( "shake", 0.1, 300, function()
		if s < 23 then
			if s % 2 == 0 then
				if self:IsValid() then
					self:SetAngles(ang + Angle(10, 0, 0))
				end
			else
				if self:IsValid() then
					self:SetAngles(ang + Angle(-10, 0, 0))
				end
			end
		else
			self:SetAngles(ang)
			timer.Destroy("shake")
		end
		s = s + 1
	end)

	-- Move Up
	timer.Simple( 1, function()
		timer.Create( "moveAway", 5, 1, function()
			self.Moving = false
			timer.Destroy("moveAway")
			timer.Destroy("shake")

			self.SpawnPoint.Box = nil
			--self.SpawnPoint:SetBodygroup(1,0)
			self:MoveToNewSpot(self.SpawnPoint)
			self:EmitSound("nz/randombox/poof.wav")
			self:Remove()
		end)
		--print(self:GetMoveType())
		self:SetMoveType(MOVETYPE_FLY)
		self:SetGravity(0.1)
		self:SetNotSolid(true)
		self:SetCollisionBounds(Vector(0,0,0), Vector(0,0,0))
		self:GetPhysicsObject():SetDamping(100, 0)
		self:CollisionRulesChanged()
		self:SetLocalVelocity(ang:Up()*100)
		timer.Simple(1.5, function()
			self:SetLocalVelocity( Vector(0,0,0) )
			self:SetVelocity( Vector(0,0,0) )
			self:SetMoveType(MOVETYPE_FLY)
			self:Open()
			self:SetLocalAngularVelocity( Angle(0, 0, 250) )
			timer.Simple(0.5, function()
				self:SetLocalAngularVelocity( Angle(0, 0, 500) )
				timer.Simple(0.5, function()
					self:SetLocalAngularVelocity( Angle(0, 0, 750) )
					timer.Simple(0.2, function()
						self:SetLocalAngularVelocity( Angle(0, 0, 1000) )
						timer.Simple(0.2, function()
							self:SetLocalAngularVelocity( Angle(0, 0, 2000) )
						end)
					end)
				end)
			end)
		end)
	end)
end

function ENT:MoveToNewSpot(oldspot)
	-- Calls mapping function excluding the current spot
	nzRandomBox.Spawn(oldspot)
end

function ENT:MarkForRemoval()
	self.MarkedForRemoval = true
	--[[if !self:GetOpen() then
		self:Remove()
	else
		hook.Add("Think", "RemoveBox"..self:EntIndex(), function()
			if !IsValid(self) or !self:GetOpen() then
				hook.Remove("Think", "RemoveBox"..self:EntIndex())
				self:Remove()
			end
		end)
	end]]
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end

	--[[hook.Add( "PostDrawOpaqueRenderables", "random_box_beam", function()
		for k,v in pairs(ents.FindByClass("random_box")) do
			if ( LocalPlayer():GetPos():Distance( v:GetPos() ) ) > 750 then
				local Vector1 = v:GetPos() + Vector( 0, 0, -200 )
				local Vector2 = v:GetPos() + Vector( 0, 0, 5000 )
				render.SetMaterial( Material( "cable/redlaser" ) )
				render.DrawBeam( Vector1, Vector2, 300, 1, 1, Color( 255, 255, 255, 255 ) )
			end
		end
	end )]]

end

function ENT:OnRemove()
	if CLIENT then
		if IsValid(self.Light) then
			self.Light:Remove()
		end
	else
		if IsValid(self.SpawnPoint) then
			--self.SpawnPoint.Box = nil
			self.SpawnPoint:SetBodygroup(1,0)
		end
	end
end

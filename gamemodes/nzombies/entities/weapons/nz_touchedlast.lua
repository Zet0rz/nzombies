if SERVER then
	AddCSLuaFile()
	SWEP.Weight			= 5
	SWEP.AutoSwitchTo	= true
	SWEP.AutoSwitchFrom	= false	
	
	util.AddNetworkString("ThrowBall")
	util.AddNetworkString("ThrowBallCancel")
end

if CLIENT then

	SWEP.PrintName     	    = "Weaponized YTi-L4"
	SWEP.Slot				= 1
	SWEP.SlotPos			= 1
	SWEP.DrawAmmo			= false
	SWEP.DrawCrosshair		= true

end

local ballmat = Material( "sprites/sent_ball" )
local charger = 2

SWEP.NZPreventBox = true
SWEP.NZPaPName = "Fragmentized YTi-L4 XP"
SWEP.NZTotalBlacklist = true
SWEP.NZRePaPText = "Reroll Color" -- It automatically adds "Press E to" and "for 2000 points"

SWEP.Author			= "Zet0r"
SWEP.Contact		= "youtube.com/Zet0r"
SWEP.Purpose		= "You Touched it Last weapon ;)"
SWEP.Instructions	= "Throw balls at zombies"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.HoldType = "normal"

SWEP.ViewModel	= "models/weapons/c_grenade.mdl"
SWEP.WorldModel	= "models/Combine_Helicopter/helicopter_bomb01.mdl"
SWEP.UseHands = true

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "XBowBolt"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.BallKillRecoverTime 	= 5 -- Time in seconds for each "kill" to be added to the ball

--[[if SERVER then 
	util.AddNetworkString("HasBall")
	util.AddNetworkString("ThrowBall")
	util.AddNetworkString("ActiveBall")
end]]

function SWEP:SetupDataTables()

	self:NetworkVar( "Int", 0, "CurKills" )
	self:NetworkVar( "Int", 1, "BallColor" )

end

function SWEP:NZMaxAmmo()
	self:ReplenishBall(0)
end

function SWEP:Initialize()

	self:SetHoldType( self.HoldType )
	self:SetCurKills(0)
	self.Charge = 0
	self:SetBallColor(math.random(0,360))

end

function SWEP:Deploy()

	if self:Clip1() >= 1 then
		if IsValid(self.Owner:GetViewModel()) then self.Owner:GetViewModel():SetNoDraw(false) end
		self:SendWeaponAnim(ACT_VM_DRAW)
	else
		if IsValid(self.Owner:GetViewModel()) then self.Owner:GetViewModel():SetNoDraw(true) end
		self:SendWeaponAnim(ACT_VM_THROW)
	end
	
end

function SWEP:PrimaryAttack()

	if game.SinglePlayer() then self:CallOnClient("PrimaryAttack") end

	if self:Clip1() >= 1 then
		self:SetHoldType( "grenade" )
		
		if CLIENT then 
			hook.Add("Tick", "ChargeUp"..self.Owner:EntIndex(), function() self:ChargeUp() end)
			hook.Add("HUDPaint", "debugDrawCharge", function()
				draw.SimpleText(self.Charge, "DebugFixed", ScrW() / 2, ScrH() / 4 * 3, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end)
		end
	end
	
	--[[if self:Clip1() >= 1 then
		self:ThrowBall(1000)
		self:SetClip1(0)
	end]]
	
end

function SWEP:ChargeUp()
	
	self.Charge = self.Charge + charger
	if self.Charge >= 100 then
		charger = -2
	elseif self.Charge <= 0 then
		charger = 2
	end
	
	if input.IsMouseDown(MOUSE_RIGHT) then
		hook.Remove("Tick", "ChargeUp"..self.Owner:EntIndex())
		hook.Remove("HUDPaint", "debugDrawCharge")
		self.Charge = 0
		charger = 2
		net.Start("ThrowBallCancel")
		net.SendToServer()
		return false
	end
	
	if !input.IsMouseDown(MOUSE_LEFT) then
		hook.Remove("Tick", "ChargeUp"..self.Owner:EntIndex())
		hook.Remove("HUDPaint", "debugDrawCharge")
		net.Start("ThrowBall")
			net.WriteInt(self.Charge, 8)
		net.SendToServer()
		self.Charge = 0
		charger = 2
		self.Owner.HasBall = false
		return true
	end

end

function SWEP:ThrowBall(force)

	if self:Clip1() < 1 then return end
	self:SetClip1(0)

	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:SendWeaponAnim(ACT_VM_THROW)

	timer.Simple(0.7, function()
		if IsValid(self) then self:SetHoldType( self.HoldType ) end
	end)
	timer.Simple(0.3, function()
		if IsValid(self) then self.Owner:GetViewModel():SetNoDraw(true) end
	end)
	
	local ball = ents.Create("nz_ytil_ball")
	ball:SetBallColor(self:GetBallColor())
	ball:SetBallOwner(self.Owner)
	ball:SetFragment(false)
	ball:SetMaxKills(self.pap and 20 or 10)
	ball:SetCurKills(self:GetCurKills())
	
	ball:SetPos(self.Owner:EyePos() + (self.Owner:GetAimVector() * 40))
	ball:Spawn()
	ball:Activate()
	ball.pap = self.pap
	
	local ballPhys = ball:GetPhysicsObject()
	if IsValid(ballPhys) then
		ballPhys:ApplyForceCenter(self.Owner:GetAimVector():GetNormalized() * force * 10)
	end
	
	self:SetCurKills(-1)
	self:SetHoldType( "normal" )

end

function SWEP:ReplenishBall(charge)
	self:SetCurKills(charge)
	self:SetClip1(1)
	if IsValid(self.Owner:GetActiveWeapon()) and self.Owner:GetActiveWeapon():GetClass() == "nz_touchedlast" then
		if IsValid(self.Owner:GetViewModel()) then self.Owner:GetViewModel():SetNoDraw(false) end
		self:SendWeaponAnim(ACT_VM_DRAW)
	end
	if self.pap then
		self.NextRecover = CurTime() + (self.BallKillRecoverTime/2)
	else
		self.NextRecover = CurTime() + self.BallKillRecoverTime
	end
end

net.Receive("ThrowBall", function(len, ply)
	if ply:Alive() and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():Clip1() >= 1 then
		ply:GetActiveWeapon():ThrowBall(net.ReadInt(8))
	end
end)

net.Receive("ThrowBallCancel", function(len, ply)
	if ply:Alive() and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "nz_touchedlast" then
		ply:GetActiveWeapon():SetHoldType("normal")
	end
end)

function SWEP:SecondaryAttack()
	
end

function SWEP:Think()
	if SERVER then
		if self.pap then
			if self:GetCurKills() > 0 and CurTime() >= self.NextRecover then
				self:SetCurKills(self:GetCurKills() - 1)
				self.NextRecover = CurTime() + (self.BallKillRecoverTime/2)
			end
		else
			if self:GetCurKills() > 0 and CurTime() >= self.NextRecover then
				self:SetCurKills(self:GetCurKills() - 1)
				self.NextRecover = CurTime() + (self.BallKillRecoverTime)
			end
		end
	end
end

function SWEP:DrawHUD()

	

end

local defcolor = Color(255,0,0)
function SWEP:DrawWorldModel()
	if self:GetClass() != "nz_touchedlast" then
		-- For wall buys and other entities
		local pos = self:GetPos()
		local size = 20
		
		render.SetMaterial( ballmat )
		local color = defcolor
		render.DrawSprite( pos, size, size, color )
	else
		if self:GetCurKills() == -1 then return end
		local pos = IsValid(self.Owner) and self.Owner:GetBonePosition(self.Owner:LookupBone("ValveBiped.Bip01_R_Hand")) or self:GetPos()
		local size = 20
		
		render.SetMaterial( ballmat )
		local color = HSVToColor(self:GetBallColor(), 1, 1)
		render.DrawSprite( pos, size, size, color )
	end
end

function SWEP:OnRemove()
	if CLIENT then
		hook.Remove("Tick", "ChargeUp"..self.Owner:EntIndex())
		LocalPlayer().charge = 0
		charger = 2
	end
end

function SWEP:PreDrawViewModel(vm, ply, wep)
end

function SWEP:PostDrawViewModel(vm, wep, ply)

	local hands = LocalPlayer():GetHands()
	if ( IsValid( hands ) ) then hands:DrawModel() end
	
	-- Draw the ball over the grenade
	if self:Clip1() >= 1 then
		local maxkills = self.pap and 20 or 10
		local ballColor = HSVToColor(self:GetBallColor(), 1 - (self:GetCurKills()/maxkills), 1)
		render.SetMaterial( ballmat )
		render.DrawSprite(
			LocalPlayer():GetViewModel():GetBonePosition( LocalPlayer():GetViewModel():LookupBone( "ValveBiped.Grenade_body" ) )
			+ LocalPlayer():EyeAngles():Forward()*-1 + LocalPlayer():EyeAngles():Right()*-4
			+ LocalPlayer():EyeAngles():Up()*1,
			10, 10,
			ballColor
		)
	end
	
	-- Hide the grenade bone
	LocalPlayer():GetViewModel():ManipulateBoneScale(  LocalPlayer():GetViewModel():LookupBone( "ValveBiped.Grenade_body" ), Vector(0,0,0) )
	LocalPlayer():GetViewModel():ManipulateBoneScale(  LocalPlayer():GetViewModel():LookupBone( "ValveBiped.Pin" ), Vector(0,0,0) )

end

function SWEP:OnPaP()
	self.pap = true
	return true
end

function SWEP:OnRePaP()
	-- We return true to not modify attachments or anything
	-- However re-pap'ing rerolls the color and having this function allows re-pap'ing
	-- so that's what that is for (expensive for 2000 huh ;) )
	return true
end
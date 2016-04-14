AddCSLuaFile()

ENT.Base = "base_nextbot"
ENT.PrintName = "Faked downed player"
ENT.Category = "Brainz"
ENT.Author = "Lolle & Zet0r"

function ENT:Initialize()
    --change those after creation
    self:SetModel( "models/player/kleiner.mdl" )
	self.OwnerData = {}
    if SERVER then self:GiveWeapon( "weapon_pistol" ) end
end

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "PerkOwner")
end

function ENT:BodyUpdate()
    if self:GetActivity() != ACT_HL2MP_SIT_PISTOL then self:StartActivity( ACT_HL2MP_SIT_PISTOL ) end
end

function ENT:Use( act, call, type, value )
    --revive here?
end

function ENT:RunBehaviour()
	while (true) do
        coroutine.wait(60)
    end
end

function ENT:GiveWeapon( wepclass )
	if !wepclass then return end

	if IsValid(self.Weapon) then
		self.Weapon:Remove()
	end

    self.Weapon = ents.Create( wepclass )
    if !IsValid(self.Weapon) then
        return
    end
    self.Weapon:SetOwner(self)
    self.Weapon:SetParent(self)
    self.Weapon:SetPos( self:GetAttachment(self:LookupAttachment("anim_attachment_RH")).Pos )
    self.Weapon:Spawn()
    self.Weapon:SetSolid(SOLID_NONE)
    self.Weapon:AddEffects(EF_BONEMERGE)
    self.Weapon:Fire( "SetParentAttachment", "anim_attachment_LH" )

end


local mat = Material("Models/effects/comball_tape")
function ENT:Draw()
	
	self:DrawModel()
	render.MaterialOverride(mat)
	self:DrawModel()
	render.MaterialOverride(nil)

end

-- FAS2 weapons seem to want this function
function ENT:InVehicle()
	return false
end

function ENT:RevivePlayer()
	local ply = self:GetPerkOwner()
	print(self:GetPerkOwner())
	PrintTable(self.OwnerData)
	
	if (IsValid(ply) and ply:IsPlayer()) then
		if ply:Alive() then
			if !ply:GetNotDowned() then
				ply:RevivePlayer()
			end
		else
			ply:Spawn()
		end
		
		ply:SetPos(self:GetPos())
		ply:SetEyeAngles(self:GetAngles())
		
		-- Yeah no, Who's Who doesn't actually let you keep your clone's perks or weapons
		ply:RemovePerks()
		ply:StripWeapons()
		
		for k,v in pairs(self.OwnerData.weps) do
			local wep = ply:Give(v.class)
			if v.pap then
				nz.Weps.Functions.ApplyPaP( ply, wep )
			end
		end
		for k,v in pairs(self.OwnerData.perks) do
			if v != "whoswho" then
				ply:GivePerk(v)
			end
		end
		nz.Weps.Functions.GiveMaxAmmo(ply)
	end
	
	-- Everything bought as the clone will be refunded, even doors
	ply:GivePoints(ply.WhosWhoMoney)
	
	local revivor = Revive.Players[id] and Revive.Players[id].RevivePlayer or nil
	if IsValid(revivor) and revivor:IsPlayer() then
		if self.DownPoints then
			revivor:GivePoints(self.DownPoints)
		end
		revivor:StripWeapon("nz_revive_morphine") -- Remove the viewmodel again
	end
	
	self:Remove()
end

function ENT:StartRevive(revivor, nosync)
	local id = self:EntIndex()
	if !Revive.Players[id] then return end -- Not even downed
	if Revive.Players[id].ReviveTime then return end -- Already being revived
		
	Revive.Players[id].ReviveTime = CurTime()
	Revive.Players[id].RevivePlayer = revivor
	revivor.Reviving = self
	
	revivor:Give("nz_revive_morphine") -- Give them the viewmodel

	if !nosync then hook.Call("PlayerBeingRevived", Revive, self, revivor) end
end
	
function ENT:StopRevive(nosync)
	local id = self:EntIndex()
	if !Revive.Players[id] then return end -- Not even downed
	
	local revivor = Revive.Players[id].RevivePlayer
	if IsValid(revivor) then
		revivor:StripWeapon("nz_revive_morphine") -- Remove the revivors viewmodel
	end
		
	Revive.Players[id].ReviveTime = nil
	Revive.Players[id].RevivePlayer = nil
	
	if !nosync then hook.Call("PlayerNoLongerBeingRevived", Revive, self) end
end

function ENT:KillDownedPlayer()
	self:Remove()
end

function ENT:OnRemove()
	local ply = self:GetPerkOwner()
	if (IsValid(ply) and ply:IsPlayer()) then
		-- No more refunds for you once you become your clone mate!
		ply.WhosWhoMoney = nil
	end
	
	local revivor = Revive.Players[id] and Revive.Players[id].RevivePlayer or nil
	if IsValid(revivor) then -- This shouldn't happen as players can't die if they are currently being revived
		revivor:StripWeapon("nz_revive_morphine") -- Remove the revivors if someone was reviving viewmodel
	end
	
	Revive.Players[self:EntIndex()] = nil
	
	if SERVER then
		net.Start("nz_WhosWhoActive")
			net.WriteBool(false)
		net.Send(ply)
		hook.Call("PlayerRevived", Revive, self)
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end
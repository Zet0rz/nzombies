-- We remake the Traitor Button so it can be given a price and triggered in nZombies
-- If it has no price, it will not be usable - A price of 0 will make it usable for free

ENT.Type = "anim"
ENT.Base = "base_anim"

function ENT:SetupDataTables()
   self:NetworkVar("Float", 0, "Delay")
   self:NetworkVar("Float", 1, "NextUseTime")
   self:NetworkVar("Bool", 0, "TTTLocked")
   self:NetworkVar("String", 0, "Description")
   self:NetworkVar("Int", 0, "UsableRange", {KeyName = "UsableRange"})
end

function ENT:IsUsable()
   return (not self:GetTTTLocked()) and self:GetNextUseTime() < CurTime() and self:GetDoorData()
end

if CLIENT then
	local mat = Material( "icon16/exclamation.png" )
	function ENT:Draw()
		if !nzRound:InState( ROUND_CREATE ) then return end

		render.SetMaterial( mat )
		render.DrawSprite( self:GetPos(), 4, 4, color_white )
	end
	
	-- Handling of buttons (copied from TTT Code)
	
	
end
local playerMeta = FindMetaTable("Player")

function playerMeta:SetNZToolData( data )
	self.NZToolData = nil
	if data then
		self.NZToolData = data
	end
end

function playerMeta:SetActiveNZTool( tool )
	local wep = self:GetActiveWeapon()
	if IsValid(wep) and wep:GetClass() == "nz_multi_tool" then
		wep.ToolMode = tool
	end
end
local playerMeta = FindMetaTable("Player")
if SERVER then

	function playerMeta:GivePerk(id)
		local perkData = nz.Perks.Functions.Get(id)
		if perkData == nil then return end
		
		local given = perkData.func(id, self)
		
		if given then
			if nz.Perks.Data.Players[self] == nil then nz.Perks.Data.Players[self] = {} end
			table.insert(nz.Perks.Data.Players[self], id)
			
			nz.Perks.Functions.SendSync()
		else
			//We didn't want to give them the perk for some reason, so lets back out and refund them.
			self:GivePoints(perkData.price)
		end
	end
	
	function playerMeta:RemovePerk(id)
		local perkData = nz.Perks.Functions.Get(id)
		if perkData == nil then return end
	
		if nz.Perks.Data.Players[self] == nil then nz.Perks.Data.Players[self] = {} end
		if self:HasPerk(id) then
			table.RemoveByValue( nz.Perks.Data.Players[self], id )
		end
		nz.Perks.Functions.SendSync()
	end
	
	function playerMeta:RemovePerks()
		nz.Perks.Data.Players[self] = {}
		nz.Perks.Functions.SendSync()
	end
	
end

function playerMeta:HasPerk(id)
	if nz.Perks.Data.Players[self] == nil then nz.Perks.Data.Players[self] = {} end
	if table.HasValue(nz.Perks.Data.Players[self], id) then
		return true
	end
	return false
end

function playerMeta:GetPerks(id)
	if nz.Perks.Data.Players[self] == nil then nz.Perks.Data.Players[self] = {} end
	if (self.Perks) then
		return self.Perks
	end
	return false
end
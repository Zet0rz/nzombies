local playerMeta = FindMetaTable("Player")
if SERVER then

	function playerMeta:GivePerk(id, machine)
		local perkData = nz.Perks.Functions.Get(id)
		if perkData == nil then return false end
		
		local given = perkData.func(id, self, machine)
		
		if given then
			if nz.Perks.Data.Players[self] == nil then nz.Perks.Data.Players[self] = {} end
			table.insert(nz.Perks.Data.Players[self], id)
			
			nz.Perks.Functions.SendSync()
		else
			//We didn't want to give them the perk for some reason, so lets back out and refund them.
			--self:GivePoints(perkData.price)
		end
		
		return given
	end
	
	function playerMeta:RemovePerk(id)
		local perkData = nz.Perks.Functions.Get(id)
		if perkData == nil then return end
	
		if nz.Perks.Data.Players[self] == nil then nz.Perks.Data.Players[self] = {} end
		if self:HasPerk(id) then
			perkData.lostfunc(id, self)
			table.RemoveByValue( nz.Perks.Data.Players[self], id )
		end
		nz.Perks.Functions.SendSync()
	end
	
	function playerMeta:RemovePerks()
		if nz.Perks.Data.Players[self] then
			for k,v in pairs(nz.Perks.Data.Players[self]) do
				local perkData = nz.Perks.Functions.Get(v)
				if perkData then perkData.lostfunc(v, self) end
			end
		end
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

function playerMeta:GetPerks()
	if nz.Perks.Data.Players[self] == nil then nz.Perks.Data.Players[self] = {} end
	local tbl = table.Copy(nz.Perks.Data.Players[self])
	if table.HasValue(tbl, "pap") then table.RemoveByValue(tbl, "pap") end
	return tbl
end
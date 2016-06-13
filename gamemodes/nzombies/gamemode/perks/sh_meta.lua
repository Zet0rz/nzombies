local playerMeta = FindMetaTable("Player")
if SERVER then

	function playerMeta:GivePerk(id, machine)
		if self:HasPerk(id) then return end
		local perkData = nzPerks:Get(id)
		if perkData == nil then return false end
		
		local given = perkData.func(id, self, machine)
		
		-- Blockget blocks the networking and storing of the perk
		if given and !perkData.blockget then
			if nzPerks.Players[self] == nil then nzPerks.Players[self] = {} end
			table.insert(nzPerks.Players[self], id)
			
			nzPerks:SendSync(self)
		else
			//We didn't want to give them the perk for some reason, so lets back out and refund them.
			--self:GivePoints(perkData.price)
		end
		
		return given
	end
	
	local exceptionperks = {
		["whoswho"] = true,
	}
	
	function playerMeta:RemovePerk(id, forced)
		if self.PreventPerkLoss and !exceptionperks[id] and !forced then return end
		local perkData = nzPerks:Get(id)
		if perkData == nil then return end
	
		if nzPerks.Players[self] == nil then nzPerks.Players[self] = {} end
		if self:HasPerk(id) then
			perkData.lostfunc(id, self)
			table.RemoveByValue( nzPerks.Players[self], id )
		end
		nzPerks:SendSync(self)
	end
	
	function playerMeta:RemovePerks()
		if self.PreventPerkLoss then
			if nzPerks.Players[self] then
				for k,v in pairs(nzPerks.Players[self]) do
					if exceptionperks[v] then
						self:RemovePerk(v)
					end
				end
			end
		else
			if nzPerks.Players[self] then
				for k,v in pairs(nzPerks.Players[self]) do
					local perkData = nzPerks:Get(v)
					if perkData then perkData.lostfunc(v, self) end
				end
			end
			nzPerks.Players[self] = {}
		end
		nzPerks:SendSync(self)
	end
	
	function playerMeta:GiveRandomPerk(maponly)
		local tbl = {}
		for k,v in pairs(nzPerks.Data) do
			if !self:HasPerk(k) and !v.blockget and k != "pap" then
				if maponly then
					for k2,v2 in pairs(ents.FindByClass("perk_machine")) do
						if v2:GetPerkID() == k then
							table.insert(tbl, k)
							break
						end
					end
				else
					table.insert(tbl, k)
				end
			end
		end
		--PrintTable(tbl)
		if tbl[1] then
			self:GivePerk(table.Random(tbl))
		end
	end
	
	function playerMeta:SetPreventPerkLoss(bool)
		self.PreventPerkLoss = bool
	end
	
	function playerMeta:GivePermaPerks()
		self:SetPreventPerkLoss(true)
		for k,v in pairs(nzPerks:GetList()) do
			self:GivePerk(k)
		end
	end
end

function playerMeta:HasPerk(id)
	if nzPerks.Players[self] == nil then nzPerks.Players[self] = {} end
	if table.HasValue(nzPerks.Players[self], id) then
		return true
	end
	return false
end

function playerMeta:GetPerks()
	if nzPerks.Players[self] == nil then nzPerks.Players[self] = {} end
	local tbl = table.Copy(nzPerks.Players[self])
	if table.HasValue(tbl, "pap") then table.RemoveByValue(tbl, "pap") end
	return tbl
end
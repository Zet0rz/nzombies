local playerMeta = FindMetaTable("Player")
if SERVER then

	function playerMeta:GiveCarryItem(id, alloverride)
		if !ItemCarry.Players[self] then ItemCarry.Players[self] = {} end
		if ItemCarry.Items[id].shared and !alloverride then -- If shared, give to all players
			for k,v in pairs(player.GetAllPlaying()) do
				if !table.HasValue(ItemCarry.Players[v], id) then
					table.insert(ItemCarry.Players[v], id)
				end
			end
			ItemCarry:SendPlayerItem()
		else
			if !table.HasValue(ItemCarry.Players[self], id) then
				table.insert(ItemCarry.Players[self], id)
				ItemCarry:SendPlayerItem(self)
			end
		end
	end
	
	function playerMeta:RemoveCarryItem(id, alloverride)
		if !ItemCarry.Players[self] then ItemCarry.Players[self] = {} end
		if ItemCarry.Items[id].shared and !alloverride then -- If shared, remove from all players
			for k,v in pairs(player.GetAllPlaying()) do
				if table.HasValue(ItemCarry.Players[v], id) then
					table.RemoveByValue(ItemCarry.Players[v], id)
				end
			end
			ItemCarry:SendPlayerItem()
		else
			if table.HasValue(ItemCarry.Players[self], id) then
				table.RemoveByValue(ItemCarry.Players[self], id)
				ItemCarry:SendPlayerItem(self)
			end
		end
	end
	
end

function playerMeta:HasCarryItem(id)
	if !ItemCarry.Players[self] then ItemCarry.Players[self] = {} end
	return table.HasValue(ItemCarry.Players[self], id)
end

function playerMeta:GetCarryItems()
	if !ItemCarry.Players[self] then ItemCarry.Players[self] = {} end
	return ItemCarry.Players[self]
end

-- On player downed
hook.Add("PlayerDowned", "nzDropCarryItems", function(ply)
	for k,v in pairs(ply:GetCarryItems()) do
		local item = ItemCarry.Items[v]
		if item.dropondowned and item.dropfunction then
			item:dropfunction(ply)
			ply:RemoveCarryItem(v)
		end
	end
end)

-- Players disconnecting/dropping out need to reset the item so it isn't lost forever
hook.Add("OnPlayerDropOut", "nzResetCarryItems", function(ply)
	for k,v in pairs(ply:GetCarryItems()) do
		local item = ItemCarry.Items[v]
		if item.dropondowned and item.dropfunction then
			item:dropfunction(ply)
		else
			item:resetfunction()
		end
	end
	ItemCarry.Players[ply] = nil
	ItemCarry:SendPlayerItem() -- No arguments for full sync, cleans the table of this disconnected player
end)
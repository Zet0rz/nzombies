
function nzItemCarry.OnPlayerPickItemUp( ply, ent )
	-- Downed players can't pick up anything!
	if !ply:GetNotDowned() then return false end
	
	-- Players can't pick stuff up while using special weapons! (Perk bottles, knives, etc)
	if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():IsSpecial() then return false end
	
	-- Used in map scripting
	if ent.OnUsed and type(ent.OnUsed) == "function" then
		ent:OnUsed(ply)
	end
	
	local category = ent:GetNWString("NZItemCategory")
	if category != "" then
		local item = nzItemCarry.Items[category]
		if item.pickupfunction and item:condition(ply) then -- If it has a pickup function and it is allowed in this case
			--print("allowed")
			item:pickupfunction(ply, ent)
		end
	end
end
hook.Add( "PlayerUse", "nzPlayerPickupItems", nzItemCarry.OnPlayerPickItemUp )

function nzItemCarry.RemoveItemsOnRemoved( ent )
	local item = nzItemCarry.Items[ent:GetNWString("NZItemCategory")]
	if item and item.items and table.HasValue(item.items, ent) then
		table.RemoveByValue(item.items, ent)
	end
end
hook.Add( "EntityRemoved", "nzItemCarryRemoveItems", nzItemCarry.RemoveItemsOnRemoved )
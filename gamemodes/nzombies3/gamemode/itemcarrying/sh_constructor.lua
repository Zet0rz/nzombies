//Main Tables
nzItemCarry = nzItemCarry or {}
ItemCarry = nzItemCarry
ItemCarry.Items = ItemCarry.Items or {}
ItemCarry.Players = ItemCarry.Players or {}

if SERVER then
	local baseitem = {
		id = nil,
		items = {},
		text = nil, -- Nil makes default texts
		hastext = nil,
		icon = "",
		shared = false,
		dropondowned = true,
		dropfunction = function(self, ply)
			--if ply:IsCarryingItem(
		end,
		resetfunction = function() end,
		condition = function(self, ply)
			return true
		end,
		pickupfunction = function(self, ply, ent)
			ply:GiveCarryItem(self.id)
			ent:Remove()
		end,
	}

	-- Functions to call during runtime
	local nzItemMeta = {
		-- Adds an entity so it can be picked up
		RegisterEntity = function(self, ent)
			if !table.HasValue(self.items, ent) then
				-- First check if it already belongs somewhere
				local id = ent:GetNWString("NZItemCategory")
				if id != "" then
					local item = ItemCarry.Items[id]
					-- If so, remove it from there
					if item and item.items and table.HasValue(item.items, ent) then
						table.RemoveByValue(item.items, ent)
					end
				end
				-- Now add it to the new category
				ent:SetNWString("NZItemCategory", self.id)
				table.insert(self.items, ent)
			end
		end,
		-- Sets the text displayed when looking at an entity with this
		SetText = function(self, text)
			self.text = text
		end,
		-- Sets the text to be displayed when looking at it while you already have it
		SetHasText = function(self, text)
			self.hastext = text
		end,
		-- Sets the icon displayed on the HUD and scoreboard
		SetIcon = function(self, iconpath)
			self.icon = iconpath
		end,
		-- Sets whether all players "has" the item when it is picked up
		SetShared = function(self, bool)
			self.shared = bool
		end,
		-- Sets whether to run the Drop Function when a player is downed with the item
		SetDropOnDowned = function(self, bool)
			self.dropondowned = bool
		end,
		-- Sets the function to run when downed; has 1 argument: The player getting downed
		SetDropFunction = function(self, func)
			self.dropfunction = func
		end,
		-- Sets the function to run to reset; happens when a player disconnects without Drop On Downed on or when self:Reset() is called
		SetResetFunction = function(self, func)
			self.resetfunction = func
		end,
		-- Sets the function to determine if a player can pick it up; return true to allow
		-- It will always be blocked if the player is already carrying this category
		SetCondition = function(self, func)
			self.condition = func
		end,
		-- Sets the function to be run when picked up; has 2 arguments: The player picking it up, the entity being used
		SetPickupFunction = function(self, func)
			self.pickupfunction = func
		end,
		-- Sets the function to reset the item(s). Typically used to respawn them back at the original spot
		Reset = function(self)
			self:resetfunction()
		end,
		-- Returns a table of all entities registered in this category
		GetEntities = function(self)
			return self.items
		end,
		-- Call this to send the info to clients; do this after all changes
		Update = function(self)
			ItemCarry:SendObjectCreated(self.id)
		end,
	}
	nzItemMeta.__index = nzItemMeta

	function ItemCarry:CreateCategory(id)
		local tbl = table.Copy(baseitem)
		tbl.id = id
		setmetatable(tbl, nzItemMeta)
		self.Items[id] = tbl
		
		return self.Items[id]
	end
end
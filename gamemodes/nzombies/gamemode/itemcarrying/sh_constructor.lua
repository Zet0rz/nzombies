-- Main Tables
nzItemCarry = nzItemCarry or AddNZModule("ItemCarry")
nzItemCarry.Items = nzItemCarry.Items or {}
nzItemCarry.Players = nzItemCarry.Players or {}

if SERVER then
	local baseitem = {
		id = nil,
		items = {},
		text = nil, -- Nil makes default texts
		hastext = nil,
		icon = "", -- Icon, if model is set this is drawn on top in the corner, otherwise just this
		model = nil, -- Model of the spawnicon, if not set the icon takes its place
		shared = false,
		dropondowned = true,
		dropfunction = function(self, ply)
			--if ply:IsCarryingItem(
		end,
		resetfunction = function() end,
		condition = function(self, ply)
			return !ply:HasCarryItem(self.id)
		end,
		pickupfunction = function(self, ply, ent)
			ply:GiveCarryItem(self.id)
			ent:Remove()
		end,
		notif = true,
	}

	-- Functions to call during runtime
	local nzItemMeta = {
		-- Adds an entity so it can be picked up
		RegisterEntity = function(self, ent)
			if !table.HasValue(self.items, ent) then
				-- First check if it already belongs somewhere
				local id = ent:GetNWString("NZItemCategory")
				if id != "" then
					local item = nzItemCarry.Items[id]
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
		-- Sets the icon displayed in the corner of the spawnicon, or fully if no model was provided
		SetIcon = function(self, iconpath)
			self.icon = iconpath
		end,
		-- Sets the model displayed the spawnicon for on HUD and scoreboard
		SetModel = function(self, model)
			self.model = model and string.StripExtension(model) or nil
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
		-- Sets whether this item will display a notification to all players when picked up
		SetShowNotification = function(self, bool)
			self.notif = bool
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
			nzItemCarry:SendObjectCreated(self.id)
		end,
	}
	nzItemMeta.__index = nzItemMeta

	function nzItemCarry:CreateCategory(id)
		local tbl = table.Copy(baseitem)
		tbl.id = id
		setmetatable(tbl, nzItemMeta)
		self.Items[id] = tbl

		return self.Items[id]
	end
end

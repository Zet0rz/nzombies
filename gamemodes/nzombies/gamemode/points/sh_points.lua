local _PLAYER = FindMetaTable("Player")

function _PLAYER:GetPoints()
	return self:GetNWInt("points") or 0
end

function _PLAYER:HasPoints(amount)
	return self:GetPoints() >= amount
end

function _PLAYER:CanAfford(amount)
	return (self:GetPoints() - amount) >= 0
end


if (SERVER) then
	util.AddNetworkString("nz_points_notification")
	-- Sets the character's amount of currency to a specific value.
	function _PLAYER:SetPoints(amount)
		amount = math.Round(amount, 2)
		if !GetConVar("nz_point_notification_clientside"):GetBool() then
			local num = amount - self:GetPoints()
			if num != 0 then -- 0 points doesn't get sent
				net.Start("nz_points_notification")
					net.WriteInt(num, 20)
					net.WriteEntity(self)
				net.Broadcast()
			end
		end
		self:SetNWInt("points", amount)
	end

	-- Quick function to set the money to the current amount plus an amount specified.
	function _PLAYER:GivePoints(amount, ignoredp)
		-- If double points is on.
		if nzPowerUps:IsPowerupActive("dp") and !ignoredp then
			amount = amount * 2
		end
		amount = hook.Call("OnPlayerGetPoints", nil, self, amount) or amount
		self:SetPoints(self:GetPoints() + amount)
	end

	-- Takes away a certain amount by inverting the amount specified.
	function _PLAYER:TakePoints(amount, nosound)
		-- Changed to prevent double points from removing double the points. - Don't even think of changing this back Ali, Love Ali.
		amount = hook.Call("OnPlayerLosePoints", nil, self, amount) or amount
		self:SetPoints(self:GetPoints() - amount)
		
		if !nosound then
			self:EmitSound("nz/effects/buy.wav")
		end

		-- If you have a clone like this, it tracks money spent which will be refunded on revival
		if self.WhosWhoMoney then self.WhosWhoMoney = self.WhosWhoMoney + amount end
	end
	
	function _PLAYER:Buy(amount, ent, func)
		local new = hook.Call("OnPlayerBuy", nil, self, amount, ent, func) or amount
		if type(new) == "number" then
			if self:CanAfford(new) then
				local success = func()
				if success then
					self:TakePoints(new)
					hook.Call("OnPlayerBought", nil, self, new, ent)
					return true -- If the buy was successfull, this function also returns true
				end
			else
				return false -- Return false if we can't afford
			end
		else
			return false -- And return false if the hook blocked the event by returning true
		end
	end

end

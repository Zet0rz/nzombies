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
		if nz.Config.PointNotifcationMode == NZ_POINT_NOTIFCATION_NET then
			net.Start("nz_points_notification")
				net.WriteInt(amount - self:GetPoints(), 20)
				net.WriteEntity(self)
			net.Broadcast()
		end
		self:SetNWInt("points", amount)
	end

	-- Quick function to set the money to the current amount plus an amount specified.
	function _PLAYER:GivePoints(amount)
		//If double points is on.
		if nz.PowerUps.Functions.IsPowerupActive("dp") then
			amount = amount * 2
		end
		self:SetPoints(self:GetPoints() + amount)
	end

	-- Takes away a certain amount by inverting the amount specified.
	function _PLAYER:TakePoints(amount, nosound)
		//Changed to prevent double points from removing double the points. - Don't even think of changing this back Ali, Love Ali.
		self:SetPoints(self:GetPoints() - amount)
		if !nosound then
			self:EmitSound("nz/effects/buy.wav")
		end
		
		-- If you have a clone like this, it tracks money spent which will be refunded on revival
		if self.WhosWhoMoney then self.WhosWhoMoney = self.WhosWhoMoney + amount end
	end
	
end
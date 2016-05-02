local meta = FindMetaTable("Player")

function meta:GetTotalKills()
	return self:GetNWInt("iZombiesKilled", 0)
end

function meta:SetTotalKills(value)
	self:SetNWInt("iZombiesKilled", value)
end

function meta:IncrementTotalKills()
	self:SetTotalKills(self:GetTotalKills() + 1)
end

function meta:GetTotalDowns()
	return self:GetNWInt("iTotalDowns", 0)
end

function meta:SetTotalDowns(value)
	self:SetNWInt("iTotalDowns", value)
end

function meta:IncrementTotalDowns()
	self:SetTotalDowns(self:GetTotalDowns() + 1)
end

function meta:GetTotalRevives()
	return self:GetNWInt("iTotalRevieves", 0)
end

function meta:SetTotalRevives(value)
	self:SetNWInt("iTotalRevieves", value)
end

function meta:IncrementTotalRevives()
	self:SetTotalRevives(self:GetTotalRevives() + 1)
end

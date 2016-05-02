TARGET_PRIORITY_NONE = 0
TARGET_PRIORITY_PLAYER = 1
TARGET_PRIORITY_SPECIAL = 2
TARGET_PRIORITY_MAX = 2
-- Someone could add a new priority level by doing this:
-- TARGET_PRIORITY_CUSTOM = TARGET_PRIORITY_MAX + 1
-- TARGET_PRIORITY_MAX = TARGET_PRIORITY_MAX + 1
-- would be limited to 7 custom levels before overwritting TARGET_PRIORITY_ALWAYS, which shoiuld be enough.
TARGET_PRIORITY_ALWAYS = 10 --make this entity a global target (not recommended)

--WARNING HTIS IS ONLY PARTIALLY SHARED its not recommended to use it clientside.

local meta = FindMetaTable("Entity")

function meta:GetTargetPriority()
	return self.iTargetPriority or TARGET_PRIORITY_NONE
end

function meta:SetTargetPriority(value)
	self.iTargetPriority = value
end

function meta:SetDefaultTargetPriority()
	if self:IsPlayer() then
		if self:GetNotDowned() and self:IsPlaying() then
			self:SetTargetPriority(TARGET_PRIORITY_PLAYER)
		else
			self:SetTargetPriority(TARGET_PRIORITY_NONE)
		end
	else
		self:SetTargetPriority(TARGET_PRIORITY_NONE) -- By default all entities are non-targetable
	end
end

if SERVER then
	function UpdateAllZombieTargets(target)
		if IsValid(target) then
			for k,v in pairs(ents.GetAll()) do
				if nzConfig.ValidEnemies[v:GetClass()] then
					v:SetTarget(target)
				end
			end
		end
	end
end
AddCSLuaFile( )

ENT.Type = "anim"

ENT.PrintName		= "buildable_table"
ENT.Author			= "Zet0r"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.TablesBeingCrafted = {} -- Shared between all entities of this type!

-- models/props_interiors/elevatorshaft_door01a.mdl
-- models/props_debris/wood_board02a.mdl
function ENT:Initialize()

	self:SetModel("models/props_interiors/table_kitchen.mdl")
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	if SERVER then
		self:SetUseType( SIMPLE_USE )
	end
	
	self.Craftables = self.Craftables or {}
	self.ValidItems = self.ValidItems or {}
	self.Crafting = self.Crafting

end

function ENT:SetupDataTables()

	self:NetworkVar( "Bool", 0, "Completed" )
	self:NetworkVar( "Bool", 1, "WIP" ) -- When just 1 part has been added
	self:NetworkVar( "String", 0, "CraftingID" )
	self:NetworkVar( "String", 1, "CompletedText" )

end

--[[ Format for craft table:
	{
		model = "model/of/finished/item.mdl",
		pos = Vector(), -- (Relative to tables own pos)
		ang = Angle(), -- (Relative too)
		parts = {
			[id1] = {submaterials}, -- Submaterials to "unhide" when this part is added
			[id2] = {submaterials}, -- id's are ItemCarry object IDs
			[id3] = {submaterials},
			-- You can have as many as you want
		},
		partadded = function(table, id, ply) -- When a part is added (optional)
		
		end,
		finishfunc = function(table) -- When all parts have been added (optional)
			
		end,
		usefunc = function(table, ply) -- When it's completed and a player presses E (optional)
			
		end,
		text = "String" -- Text to display when player is looking (after finished) (optional)
	}		
]]

function ENT:AddValidCraft(id, tbl)
	if !self.Craftables then self.Craftables = {} end
	if !self.ValidItems then self.ValidItems = {} end
	if id then
		if tbl and tbl.parts then
			self.Craftables[id] = tbl
			for k,v in pairs(tbl.parts) do
				self.ValidItems[k] = id
			end
		else
			self.Craftables[id] = nil -- Removes it
		end
	end
end

function ENT:CanPlayerCraft(ply)
	if !self.ValidItems then self.ValidItems = {} end
	for k,v in pairs(ply:GetCarryItems()) do
		local id = self.ValidItems[v]
		local tbl = self.TablesBeingCrafted[id] -- The table that this item is being worked on
		if id and (!IsValid(tbl) or tbl == self) then -- No other tables are being worked on with this!
			return id, v
		end
	end
end

function ENT:IsValidCraftingPart(id)
	return self.ValidItems[id]
end

function ENT:SetCraftedItem(id)
	self.Crafting = id
	self.TablesBeingCrafted[id] = self
	self:SetCraftingID(id)
	for k,v in pairs(self.ValidItems) do
		if v != id then
			self.ValidItems[k] = nil -- Remove all non-valids now
		end
	end
	
	if IsValid(self.CraftedModel) then self.CraftedModel:Remove() end
	
	local tbl = self:GetCraftTable(id)
	if tbl and tbl.model then
		self.CraftedModel = ents.Create("buildable_table_prop")
		self.CraftedModel:SetWorkbench(self)
		self.CraftedModel:SetModel(tbl.model)
		self.CraftedModel:SetPos(self:GetPos() + tbl.pos)
		self.CraftedModel:SetAngles(self:GetAngles() + tbl.ang)
		for i = 0, (#self.CraftedModel:GetMaterials()-1) do
			self.CraftedModel:SetSubMaterial(i, "color") -- Invisible
		end
		self.CraftedModel:SetMoveType(MOVETYPE_NONE)
		self.CraftedModel:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
		self.CraftedModel:Spawn()
		self:SetCompletedText(tbl.text or "Workbench")
	end
end

function ENT:AddPart(item, ply)
	if !self.Crafting then
		self:SetCraftedItem(self.ValidItems[item]) -- Set targeted ID to what this item belongs to
		self:SetWIP(true)
	end
	local tbl = self:GetCraftTable()
	local part = tbl.parts[item]
	if part then
		for k,v in pairs(part) do
			self.CraftedModel:SetSubMaterial(v, "") -- Visible again
		end
		if tbl.partadded then tbl.partadded(self, item, ply) end
		self.ValidItems[item] = nil -- No longer valid here!
	end
	if table.Count(self.ValidItems) <= 0 then
		self:FinishCrafting()
	end
end

function ENT:FinishCrafting()
	self:SetWIP(false)
	self:SetCompleted(true)
	
	local tbl = self:GetCraftTable()
	if tbl.finishfunc then tbl.finishfunc(self) end
end

function ENT:GetCraftTable(id)
	if !self.Craftables then self.Craftables = {} end
	return id and self.Craftables[id] or self.Craftables[self.Crafting]
end

function ENT:StartTimedUse(ply) -- This function makes the entity use progress-based using instead of normal
	if IsValid(ply) then
		if self:GetCompleted() then
			local tbl = self:GetCraftTable()
			if tbl and tbl.usefunc then
				tbl.usefunc(self, ply) -- Here it doesn't return a time; it becomes instant use
			end
		else
			local id, item = self:CanPlayerCraft(ply)
			if id and item then
				ply:Give("nz_packapunch_arms") -- For the animation
				return 2.5 -- We only return here, other cases it doesn't even use time
			end
		end
	end
	-- In no case there's no time either; instant use (doing nothing)
end
function ENT:StopTimedUse(ply)
	ply:SetUsingSpecialWeapon(false)
	ply:StripWeapon("nz_packapunch_arms")
	ply:EquipPreviousWeapon()
end
function ENT:FinishTimedUse(ply)
	if IsValid(ply) then
		if !self:GetCompleted() then -- We do nothing if he can no longer craft
			local id, item = self:CanPlayerCraft(ply)
			if id and item then
				self:AddPart(item)
				ply:RemoveCarryItem(item)
			end
		end
	end
end

if CLIENT then
	
	function ENT:GetNZTargetText()
		if self:GetCompleted() then
			return self:GetCompletedText()
		elseif self:GetWIP() then
			return "Workbench ("..self:GetCraftingID()..")"
		else
			return "Workbench"
		end
	end
	
end

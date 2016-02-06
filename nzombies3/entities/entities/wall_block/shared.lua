AddCSLuaFile( )

ENT.Type = "anim"
 
ENT.PrintName		= "wall_block"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

local modelvalids = {
	--[[Format:
	
	[Z] = {
		[Y] = {X,X,X,X...},
		[Y] = {X,X,X,X...},
		[Y] = {X,X,X,X...},
		...
	},
	...
	
	]]
	[0] = {
		[1] = {1},
		[2] = {1,2},
		[3] = {1,2,3},
		[4] = {1,2,3,4},
		[5] = {1,2,3,4,5},
		[6] = {1,2,3,4,5,6},
		[7] = {1,2,3,4,5,6,7},
		[8] = {1,2,3,4,5,6,7,8},
	},
	[0.25] = {
		[0.25] = {0.25},
		[0.5] = {0.25,0.5},
		[0.75] = {0.25,0.5,0.75},
		[1] = {0.25,0.5,0.75,1},
		[2] = {0.25,0.5,0.75,1,2},
		[3] = {0.25,0.5,0.75,1,2,3},
		[4] = {0.25,0.5,0.75,1,2,3,4},
		[5] = {0.25,0.5,1},
		[6] = {0.25,0.5,0.75,1,2,3,4,6},
		[7] = {0.25,0.5,1},
		[8] = {0.25,0.5,0.75,1,2,3,4,8},
	},
	[0.5] = {
		[0.5] = {0.5},
		[1] = {0.5,1},
		[2] = {0.5,1,2},
		[3] = {0.5,3},
		[4] = {0.5,1,2,4},
		[5] = {0.5},
		[6] = {0.5,1,2,4,6},
		[7] = {0.5},
		[8] = {0.5,1,2,4,6,8},
	},
	[0.75] = {
		[0.75] = {0.75},
		[1] = {0.75},
		[2] = {0.75},
		[3] = {0.75},
		[4] = {0.75},
		[5] = {0.75},
		[6] = {0.75},
		[7] = {0.75},
		[8] = {0.75},
	},
	[1] = {
		[1] = {0.75,1,2},
		[2] = {0.75,1,2},
		[3] = {0.75,1},
		[4] = {1,2,4},
		[6] = {1,2,4,6},
		[8] = {1,2,4,6,8},
	},
	[2] = {
		[2] = {2},
		[4] = {4},
		[6] = {4,6},
		[8] = {6,8},
	},
	[4] = {
		[4] = {4},
		[6] = {4},
		[8] = {8},
	},
	[6] = {
		[6] = {4,6},
	},
	[8] = {
		[8] = {8},
	},
}
ENT.CurModelX = 2
ENT.CurModelY = 2
ENT.CurModelZ = 0

function GetNearestTableValue(tbl, val, keybool)
	//Keybool means whether we look for a key instead of a value
	if !isnumber(val) then print("GetNearestTableValue called without a numeric input value!") return end
	
	local diffs = {}
	if keybool then
		for k,v in pairs(tbl) do
			if isnumber(k) then
				table.insert(diffs, {diff = math.abs(val - k), val = k})
			else
				print("GetNearestTableValue: "..tostring(k).." is not a numeric value, skipping...")
			end
		end
	else
		for k,v in pairs(tbl) do
			if isnumber(v) then
				table.insert(diffs, {diff = math.abs(val - v), val = v})
			else
				print("GetNearestTableValue: "..tostring(v).." is not a numeric value, skipping...")
			end
		end
	end
	
	--PrintTable(diffs)
	
	if !diffs[1] then
		print("GetNearestTableValue: There were no numeric values in the given table!")
		return
	end
	
	table.SortByMember(diffs, "diff", true)
	--PrintTable(diffs)
	return diffs[1].val
end

function FindNextTableEntry(tbl, val, key)
	//Copy-paste of the official one as that one is deprecated
	//Key means whether to look at they keys instead of the values
	local bfound = false
	if key then
		tbl = table.GetKeys(tbl)
		table.sort(tbl)
	end
	--print("looking for value after value "..val)
	--PrintTable(tbl)
	for k, v in pairs( tbl ) do
		print("Looking at value with the index "..k)
		if ( bfound ) then return v end
		if ( val == v ) then bfound = true end
	end
	return nil
end

function FindPreviousTableEntry(tbl, val, key)
	//Copy-paste of the official one as that one is deprecated
	local last
	if key then
		tbl = table.GetKeys(tbl)
		table.sort(tbl)
	end
	--print("looking for value after value "..val)
	--PrintTable(tbl)
	for k, v in pairs( tbl ) do
		if ( val == v ) then return last end
		last = v
	end
	return last
end

function ENT:Initialize()
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	self:DrawShadow( false )
	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
end

function ENT:IncreaseXModel(caller)
	local new = FindNextTableEntry(modelvalids[self.CurModelZ][self.CurModelY], self.CurModelX)
	if !new then caller:ChatPrint("X can go no higher than this!") return end
	self.CurModelX = new
	self:ReloadModel()
	--caller:ChatPrint("X increased.")
end

function ENT:DecreaseXModel(caller)
	local new = FindPreviousTableEntry(modelvalids[self.CurModelZ][self.CurModelY], self.CurModelX)
	if !new then caller:ChatPrint("X can go no lower than this!") return end
	self.CurModelX = new
	self:ReloadModel()
	--caller:ChatPrint("X decreased.")
end

function ENT:IncreaseYModel(caller)
	local new = FindNextTableEntry(modelvalids[self.CurModelZ], self.CurModelY, true)
	if !new then caller:ChatPrint("Y can go no higher than this!") return end
	self.CurModelY = new
	self.CurModelX = GetNearestTableValue(modelvalids[self.CurModelZ][self.CurModelY], self.CurModelX)
	self:ReloadModel()
end

function ENT:DecreaseYModel(caller)
	local new = FindPreviousTableEntry(modelvalids[self.CurModelZ], self.CurModelY, true)
	if !new then caller:ChatPrint("Y can go no lower than this!") return end
	self.CurModelY = new
	self.CurModelX = GetNearestTableValue(modelvalids[self.CurModelZ][self.CurModelY], self.CurModelX)
	self:ReloadModel()
end

function ENT:IncreaseZModel(caller)
	local new = FindNextTableEntry(modelvalids, self.CurModelZ, true)
	if !new then caller:ChatPrint("Z can go no higher than this!") return end
	self.CurModelZ = new
	self.CurModelY = GetNearestTableValue(modelvalids[self.CurModelZ], self.CurModelY, true)
	self.CurModelX = GetNearestTableValue(modelvalids[self.CurModelZ][self.CurModelY], self.CurModelX)
	self:ReloadModel()
end

function ENT:DecreaseZModel(caller)
	local new = FindPreviousTableEntry(modelvalids, self.CurModelZ, true)
	if !new then caller:ChatPrint("Z can go no lower than this!") return end
	self.CurModelZ = new
	self.CurModelY = GetNearestTableValue(modelvalids[self.CurModelZ], self.CurModelY, true)
	self.CurModelX = GetNearestTableValue(modelvalids[self.CurModelZ][self.CurModelY], self.CurModelX)
	self:ReloadModel()
end

function ENT:ReloadModel()
	local x = string.Replace(tostring(self.CurModelX), ".", "")
	local y = string.Replace(tostring(self.CurModelY), ".", "")
	local z = string.Replace(tostring(self.CurModelZ), ".", "")
	
	--print(x, y, z)
	--print(self.CurModelX, self.CurModelY, self.CurModelZ)
	
	if self.CurModelZ == 0 then
		self:SetModel("models/hunter/plates/plate"..x.."x"..y..".mdl")
		if !util.IsValidModel("models/hunter/plates/plate"..x.."x"..y..".mdl") then
			print("Wall block has been set to an invalid model! Removing")
			self:Remove()
			return
		end
		--print("Set model to "..self:GetModel())
	else
		self:SetModel("models/hunter/blocks/cube"..x.."x"..y.."x"..z..".mdl")
		if !util.IsValidModel("models/hunter/blocks/cube"..x.."x"..y.."x"..z..".mdl") then
			print("Wall block has been set to an invalid model! Removing")
			self:Remove()
			return
		end
	end
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	self:DrawShadow( false )
	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
end

if CLIENT then
	function ENT:Draw()
		if nz.Rounds.Data.CurrentState == ROUND_CREATE then
			self:DrawModel()
		end
	end
end
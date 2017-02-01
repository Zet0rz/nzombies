-- Setup round module
nzTraps = nzTraps or AddNZModule("Traps")
nzLogic = nzLogic or AddNZModule("Logic")

nzTraps.Registry = nzTraps.Registry or {}
nzLogic.Registry = nzLogic.Registry or {}

local function register (tbl, classname)
	table.insert(tbl, classname)
end

function nzTraps:Register(classname)
	if !table.HasValue(self.Registry, classname) then
		register(self.Registry, classname)
	end
end

function nzLogic:Register(classname)
	if !table.HasValue(self.Registry, classname) then
		register(self.Registry, classname)
	end
end

function nzTraps:GetAll()
	return self.Registry
end

function nzLogic:GetAll()
	return self.Registry
end

if SERVER then
	nzMapping:AddSaveModule("TrapsLogic", {
		savefunc = function()
			local traps_logic = {}
			local classes = nzTraps:GetAll()
			table.Add(classes, nzLogic:GetAll())
			for k, class in pairs(classes) do
				for _, ent in pairs(ents.FindByClass(class)) do
					table.insert(traps_logic, duplicator.CopyEntTable(ent))
				end
			end
			return traps_logic
		end,
		loadfunc = function(data)
			for _, entTable in pairs(data) do
				local ent = duplicator.CreateEntityFromTable(ply, entTable)
				ent:Activate()
				ent:Spawn()

				for k, v in pairs(entTable.DT) do
					if ent["Set" .. k] then
						timer.Simple( 0.1, function() ent["Set" .. k](ent, v) end)
					end
				end
			end
		end,
		cleanents = {"nz_button", "nz_button_and", "nz_trap_turret", "nz_trap_zapper"},
	})
end

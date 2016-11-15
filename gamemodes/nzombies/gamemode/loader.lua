-- Load all our files in to the respective realms

-- Main Tables
nz = nz or {}
function AddNZModule(id)
	local tbl = {}
	--nz[id] = tbl -- Enabling this line will make all tables parented to nz again
	return tbl
end

local gmfolder = "nzombies"

local _,dirs = file.Find( gmfolder.."/gamemode/*", "LUA" )

print("nZombies Loading...")

function AutoInclude(name, dir)

	local sep = string.Explode("_", name)
	name = dir..name

	if sep[1] == "cl" and SERVER then
		print("Sending: "..name)
	else
		print("Including: "..name)
	end

	-- Determine where to load the files
	if sep[1] == "sv" then
		if SERVER then
			include(name)
		end
	elseif sep[1] == "sh" then
		if SERVER then
			AddCSLuaFile(name)
			include(name)
		else
			include(name)
		end
	elseif sep[1] == "cl" then
		if SERVER then
			AddCSLuaFile(name)
		else
			include(name)
		end
	end

end

-- Run this on both client and server
if SERVER then print(" ** Server List **") else print(" ** Client List **") end
for k,v in pairs(dirs) do
	local f2,d2 = file.Find( gmfolder.."/gamemode/"..v.."/*", "LUA" )

	-- Load construction file before everything else
	if table.HasValue(f2, "sh_constructor.lua") then
		print("Constructing: " .. v)
		AutoInclude("sh_constructor.lua", v.."/")
	end

	for k2,v2 in pairs(f2) do
		-- we already loaded the construction file once, so dont load again
		if v2 != "sh_constructor.lua" then
			AutoInclude(v2, v.."/")
		end
	end

end
print(" ** End List **")

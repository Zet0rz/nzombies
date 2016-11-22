--

function nzRandomBox.Spawn(exclude, first)
	--Get all spawns
	local all = ents.FindByClass("random_box_spawns")
	local possible = {}
	for k,v in pairs(all) do
		if (!IsValid(exclude) or exclude != v) and (!first or tobool(v.PossibleSpawn)) then
			table.insert(possible, v)
		end
	end
	-- No points with possible spawn set, we'll just use all then
	if #possible <= 0 then possible = all end

	local rand = possible[ math.random( #possible ) ]

	if rand != nil and !rand.HasBox then
		local box = ents.Create( "random_box" )
		box:SetPos( rand:GetPos() )
		box:SetAngles( rand:GetAngles() )
		box:Spawn()
		--box:PhysicsInit( SOLID_VPHYSICS )
		box.SpawnPoint = rand
		rand.HasBox = true

		local phys = box:GetPhysicsObject()
		if phys:IsValid() then
			phys:EnableMotion(false)
		end
	else
		print("No random box spawns have been set.")
	end
end

function nzRandomBox.Remove()
	--Get all spawns
	local all = ents.FindByClass("random_box")
	--Loop just incase
	for k,v in pairs(all) do
		v.SpawnPoint.HasBox = false
		v:Remove()
	end
end

function nzRandomBox.DecideWep(ply)

	local teddychance = math.random(1, 15)
	if teddychance <= 1 and !nzPowerUps:IsPowerupActive("firesale") and table.Count(ents.FindByClass("random_box_spawns")) > 1 then
		return "nz_box_teddy"
	end

	local guns = {}
	local blacklist = table.Copy(nzConfig.WeaponBlackList)

	--Add all our current guns to the black list
	if IsValid(ply) and ply:IsPlayer() then
		local found
		for k,v in pairs( ply:GetWeapons() ) do
			if v.ClassName then
				blacklist[v.ClassName] = true
				if v.ClassName == "nz_touchedlast" then found = true end
			end
		end
		if !found and ply.nz_InSteamGroup then table.insert(guns, "nz_touchedlast") end
	end

	--Add all guns with no model or wonder weapons that are out to the blacklist
	for k,v in pairs( weapons.GetList() ) do
		if !blacklist[v.ClassName] and !v.NZPreventBox then
			if v.WorldModel == nil or nzWeps:IsWonderWeaponOut(v.ClassName) then
				blacklist[v.ClassName] = true
			end
		end
	end

	if GetConVar("nz_randombox_maplist"):GetBool() and nzMapping.Settings.rboxweps then
		for k,v in pairs(nzMapping.Settings.rboxweps) do
			if !blacklist[v] then
				table.insert(guns, v)
			end
		end
	elseif GetConVar("nz_randombox_whitelist"):GetBool() then
		-- Load only weapons that have a prefix from the whitelist
		for k,v in pairs( weapons.GetList() ) do
			if !blacklist[v.ClassName] and !v.NZPreventBox then
				for k2,v2 in pairs(nzConfig.WeaponWhiteList) do
					if string.sub(v.ClassName, 1, #v2) == v2 then
						table.insert(guns, v.ClassName)
						break
					end
				end
			end
		end
	else
		-- No weapon list and not using whitelist only, add all guns
		for k,v in pairs( weapons.GetList() ) do
			if !blacklist[v.ClassName] and !v.NZPreventBox then
				table.insert(guns, v.ClassName)
			end
		end
	end

	local decision = table.Random(guns)
	hook.Call( "nzPlayerBoughtBox", nil, ply, decision )
	return decision
end

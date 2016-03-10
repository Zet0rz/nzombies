--

function RandomBox:Spawn(exclude)
	--Get all spawns
	local all = ents.FindByClass("random_box_spawns")
	if exclude and IsValid(exclude) then
		table.RemoveByValue(all, exclude)
		print("Excluded ", exclude)
	end

	local rand = all[ math.random( #all ) ]

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

function RandomBox:Remove()
	--Get all spawns
	local all = ents.FindByClass("random_box")
	--Loop just incase
	for k,v in pairs(all) do
		v.SpawnPoint.HasBox = false
		v:Remove()
	end
end

function RandomBox:DecideWep(ply)

	local teddychance = math.random(1, 15)
	if teddychance <= 1 and !nz.PowerUps.Functions.IsPowerupActive("firesale") then
		return "nz_box_teddy"
	end

	local guns = {}
	local blacklist = table.Copy(nz.Config.WeaponBlackList)

	--Add all our current guns to the black list
	if ply:IsValid() then
		for k,v in pairs( ply:GetWeapons() ) do
			blacklist[v.ClassName] = true
		end
	end

	--Add all guns with no model to the blacklist
	for k,v in pairs( weapons.GetList() ) do
		if !blacklist[v.ClassName] then
			if v.WorldModel == nil then
				blacklist[v.ClassName] = true
			end
		end
	end

	if nz.Config.UseMapWeaponList and Mapping.Settings.rboxweps then
		for k,v in pairs(Mapping.Settings.rboxweps) do
			if !blacklist[v] then
				table.insert(guns, v)
			end
		end
	elseif nz.Config.UseWhiteList then
		-- Load only weapons that have a prefix from the whitelist
		for k,v in pairs( weapons.GetList() ) do
			if !blacklist[v.ClassName] then
				for k2,v2 in pairs(nz.Config.WeaponWhiteList) do
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
			if !blacklist[v.ClassName] then
				table.insert(guns, v.ClassName)
			end
		end
	end

	return table.Random(guns)
end

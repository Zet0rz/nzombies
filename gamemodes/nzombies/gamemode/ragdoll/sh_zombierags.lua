
local function cleanrag(ent, ragdoll, time)
	local dTime = math.random( time*0.75, time*1.25 )

	if ent.GetDecapitated and ent:GetDecapitated() then
		local bone = ragdoll:LookupBone("ValveBiped.Bip01_Head1")
		if !bone then bone = ragdoll:LookupBone("j_head") end

		if bone then
			ragdoll:ManipulateBoneScale(bone, Vector(0.00001,0.00001,0.00001))
			--- Y GMOD YYYYYYYY I DONT UNDERSTAND
			ragdoll:ManipulateBoneScale(bone, Vector(0.00001,0.00001,0.00001))
		end
	end

	--[[
	timer.Simple( dTime, function()
		if IsValid(ragdoll) then
			ragdoll:PhysWake()
			ragdoll:SetMoveType(MOVETYPE_NOCLIP)
			ragdoll:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
			-- ragdoll:Fire("EnableMotion")
			PrintTable(debug.getmetatable(ragdoll))
			for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do

				local phys = ragdoll:GetPhysicsObjectNum( i )
				phys:Wake()
				phys:EnableCollisions(false)
				phys:EnableGravity(false)
				phys:SetVelocityInstantaneous( Vector( 0, 0, -15) )

				-- apply another push after dealy
				timer.Simple(2, function() if IsValid(phys) then phys:SetVelocityInstantaneous(Vector( 0, 0, -20)) end end)
			end
			ragdoll:SetVelocity(Vector( 0, 0, -15))
		end
	end)
	]]--
	SafeRemoveEntityDelayed( ragdoll, dTime + 2.5 )
end

if CLIENT then
	if not ConVarExists("nz_client_ragdolltime") then CreateConVar("nz_client_ragdolltime", 30, {FCVAR_ARCHIVE}, "How long clientside Zombie ragdolls will stay in the map.") end

	function GM:CreateClientsideRagdoll( ent, ragdoll )
		local convar = GetConVar("nz_client_ragdolltime"):GetInt()
		cleanrag(ent, ragdoll, convar)
	end
else -- Server ragdolls
	if not ConVarExists("nz_server_ragdolltime") then CreateConVar("nz_server_ragdolltime", 30, {FCVAR_ARCHIVE}, "How long serverside Zombie ragdolls will stay in the map.") end

	function GM:CreateEntityRagdoll( ent, ragdoll )
		local convar = GetConVar("nz_server_ragdolltime"):GetInt()
		cleanrag(ent, ragdoll, convar)
	end
end
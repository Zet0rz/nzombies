if not ConVarExists("nz_ragdolltime") then CreateConVar("nz_ragdolltime", 30, {FCVAR_ARCHIVE}, "How long Zombie ragdolls will stay in the map.") end

function GM:CreateClientsideRagdoll( ent, ragdoll )
	local convar = GetConVar("nz_ragdolltime"):GetInt()
	local dTime = math.random( convar*0.75, convar*1.25 )

	if ent:GetDecapitated() then
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
	
	--print("Client side ragdoll")
end

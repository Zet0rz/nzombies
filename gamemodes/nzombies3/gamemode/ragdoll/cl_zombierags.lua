function GM:CreateClientsideRagdoll( ent, ragdoll )
	local dTime = math.random( 30, 60 )
	timer.Simple( dTime, function()
			if IsValid(ragdoll) then
				ragdoll:SetCollisionGroup(COLLISION_GROUP_NONE)
				ragdoll:SetMoveType( MOVETYPE_NOCLIP )
				timer.Create( "nz.despawn.ragdolll." .. ragdoll:EntIndex(), 0.05, 100, function()
					if IsValid(ragdoll) then
						ragdoll:SetPos( ragdoll:GetPos() - Vector(0,0,0.4) )
					end
				end)
			end
		end)
	SafeRemoveEntityDelayed( ragdoll, dTime + 6 )
end

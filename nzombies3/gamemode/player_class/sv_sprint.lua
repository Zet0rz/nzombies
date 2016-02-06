local plymeta = FindMetaTable( "Player" )

AccessorFunc( plymeta, "fStamina", "Stamina", FORCE_NUMBER )
AccessorFunc( plymeta, "fMaxStamina", "MaxStamina", FORCE_NUMBER )
AccessorFunc( plymeta, "fLastStaminaRecover", "LastStaminaRecover", FORCE_NUMBER )
AccessorFunc( plymeta, "fLastStaminaLoss", "LastStaminaLoss", FORCE_NUMBER )
AccessorFunc( plymeta, "fStaminaLossAmount", "StaminaLossAmount", FORCE_NUMBER )
AccessorFunc( plymeta, "fStaminaRecoverAmount", "StaminaRecoverAmount", FORCE_NUMBER )
AccessorFunc( plymeta, "fMaxRunSpeed", "MaxRunSpeed", FORCE_NUMBER )
AccessorFunc( plymeta, "bSprinting", "Sprinting", FORCE_BOOL )

function plymeta:IsSprinting()
	return self:GetSprinting()
end

hook.Add( "PlayerSpawn", "PlayerSprintSpawn", function( ply )

	ply:SetSprinting( false )
	ply:SetStamina( 100 )
	ply:SetMaxStamina( 100 )

	--The rate is fixed on 0.05 seconds
	ply:SetStaminaLossAmount( 2.5 )
	ply:SetStaminaRecoverAmount( 4 )

	ply:SetLastStaminaLoss( 0 )
	ply:SetLastStaminaRecover( 0 )

	ply:SetMaxRunSpeed( ply:GetRunSpeed() )

end )


hook.Add( "Think", "PlayerSprint", function()
	if nz.Rounds.Data.CurrentState != ROUND_CREATE then
		for _, ply in pairs( player.GetAll() ) do
			if ply:Alive() and ply:GetNotDowned() and ply:IsSprinting() and ply:GetStamina() >= 0 and ply:GetLastStaminaLoss() + 0.05 <= CurTime() then
				ply:SetStamina( math.Clamp( ply:GetStamina() - ply:GetStaminaLossAmount(), 0, ply:GetMaxStamina() ) )
				ply:SetLastStaminaLoss( CurTime() )
				
				-- Delay the recovery a bit, you can't sprint instantly after
				ply:SetLastStaminaRecover( CurTime() + 0.75 )
				
				if ply:GetStamina() == 0 then
					ply:SetRunSpeed( ply:GetWalkSpeed() )
					ply:SetSprinting( false )
				end
			elseif ply:Alive() and ply:GetNotDowned() and !ply:IsSprinting() and ply:GetStamina() < ply:GetMaxStamina() and ply:GetLastStaminaRecover() + 0.05 <= CurTime() then
				ply:SetStamina( math.Clamp( ply:GetStamina() + ply:GetStaminaRecoverAmount(), 0, ply:GetMaxStamina() ) )
				ply:SetLastStaminaRecover( CurTime() )
			end
			--print( ply:GetStamina() )
		end
	end
end )

hook.Add( "KeyPress", "OnSprintKeyPressed", function( ply, key )
	if nz.Rounds.Data.CurrentState != ROUND_CREATE and ( key == IN_SPEED ) then
		ply:SetSprinting( true )
	end
end )

hook.Add( "KeyRelease", "OnSprintKeyReleased", function( ply, key )
	if nz.Rounds.Data.CurrentState != ROUND_CREATE and ( key == IN_SPEED ) then
		ply:SetSprinting( false )
		ply:SetRunSpeed( ply:GetMaxRunSpeed() )
	end
end )

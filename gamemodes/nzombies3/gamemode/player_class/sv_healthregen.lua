local HealthRegen = {
	Amount = 1,
	Delay = 2,
	Rate = 0.05
}

hook.Add( "Think", "RegenHealth", function()
	for k,v in pairs( player.GetAll() ) do

		if v:Alive() and v:GetNotDowned() and v:Health() < v:GetMaxHealth() and (!v.lastregen or CurTime() > v.lastregen + HealthRegen.Rate) and (!v.lasthit or CurTime() > v.lasthit + HealthRegen.Delay) then
			v.lastregen = CurTime()
			v:SetHealth( math.Clamp(v:Health() + HealthRegen.Amount, 0, v:GetMaxHealth() ) )
		end
	end
end )

hook.Add( "EntityTakeDamage", "PreventHealthRegen", function(ent, dmginfo)
	if ent:IsPlayer() and ent:GetNotDowned() then
		ent.lasthit = CurTime()
	end
end)
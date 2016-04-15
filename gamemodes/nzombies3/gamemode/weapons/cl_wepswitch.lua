local plyMeta = FindMetaTable( "Player" )
AccessorFunc( plyMeta, "iLastWeaponSlot", "LastWeaponSlot", FORCE_NUMBER)
AccessorFunc( plyMeta, "iCurrentWeaponSlot", "CurrentWeaponSlot", FORCE_NUMBER)
function plyMeta:SelectWeapon( class )
	if ( !self:HasWeapon( class ) ) then return end
	self.DoWeaponSwitch = self:GetWeapon( class )
	print(self.DoWeaponSwitch)
end

function GM:CreateMove( cmd )
	if ( IsValid( LocalPlayer().DoWeaponSwitch ) ) then
		cmd:SelectWeapon( LocalPlayer().DoWeaponSwitch )

		if ( LocalPlayer():GetActiveWeapon() == LocalPlayer().DoWeaponSwitch ) then
			LocalPlayer():SetCurrentWeaponSlot(LocalPlayer():GetActiveWeapon():GetNWInt("SwitchSlot", 1))
			LocalPlayer().DoWeaponSwitch = nil
		end
	end
end

function GM:PlayerBindPress( ply, bind, pressed )
	if Round:InProgress() then
		if !ply:GetCurrentWeaponSlot() then ply:SetCurrentWeaponSlot(ply:GetActiveWeapon():GetNWInt("SwitchSlot", 1)) end
		local slot
		local curslot = ply:GetCurrentWeaponSlot() or 1
		if ( string.find( bind, "slot1" ) ) then slot = 1 end
		if ( string.find( bind, "slot2" ) ) then slot = 2 end
		if ( string.find( bind, "slot3" ) ) then slot = 3 end
		if ( string.find( bind, "invnext" ) ) then 
			slot = curslot + 1
			if (ply:HasPerk("mulekick") and slot > 3) or (!ply:HasPerk("mulekick") and slot > 2) then
				slot = 1
			end
		end
		if ( string.find( bind, "invprev" ) ) then 
			slot = curslot - 1
			if slot < 1 then
				slot = ply:HasPerk("mulekick") and 3 or 2
			end
		end
		if !Round:InState(ROUND_CREATE) and (bind == "+menu" and pressed ) then slot = ply:GetLastWeaponSlot() or 1 end
		if slot then
			ply:SetLastWeaponSlot( ply:GetActiveWeapon():GetNWInt( "SwitchSlot", 1) )
			if slot == 3 then
				for k,v in pairs( ply:GetWeapons() ) do
					if v:GetNWInt( "SwitchSlot" ) == slot then
						ply:SelectWeapon( v:GetClass() )
						return true
					end
				end
				slot = 1
				for k,v in pairs( ply:GetWeapons() ) do
					if v:GetNWInt( "SwitchSlot" ) == slot then
						ply:SelectWeapon( v:GetClass() )
						return true
					end
				end
			else
				for k,v in pairs( ply:GetWeapons() ) do
					if v:GetNWInt( "SwitchSlot" ) == slot then
						ply:SelectWeapon( v:GetClass() )
						return true
					end
				end
			end
		end
		if ( string.find( bind, "slot" ) ) then return true end
	end
end

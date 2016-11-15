-- Client Server Syncing

if CLIENT then

	-- Client to Server (Client)
	function nzQMenu:Request( model, entity )
		local entity = entity or false
		net.Start( "nzQMenu.Request" )
			net.WriteString( model )
			net.WriteBool( entity )
		net.SendToServer()
	end

end

if SERVER then

	-- Client to Server (Server)
	util.AddNetworkString( "nzQMenu.Request" )

	local function HandleRequest( len, ply )
		local model = net.ReadString()
		local entity = net.ReadBool()
		if nzRound:InState( ROUND_CREATE ) then
			print(ply:Nick() .. " requested prop " .. model)
			if ply:IsInCreative() then
				local tr = util.GetPlayerTrace( ply )
				tr.mask = bit.bor( CONTENTS_SOLID, CONTENTS_MOVEABLE, CONTENTS_MONSTER, CONTENTS_WINDOW, CONTENTS_DEBRIS, CONTENTS_GRATE, CONTENTS_AUX )
				local trace = util.TraceLine( tr )
				if entity then
					nzMapping:SpawnEntity(trace.HitPos, Angle(0,0,0), model, ply)
				else
					if util.IsValidProp(model) then
						nzMapping:PropBuy(trace.HitPos, Angle(0,0,0), model, nil, ply)
					else
						nzMapping:SpawnEffect(trace.HitPos, Angle(0,0,0), model, ply)
					end
				end
				-- Since we're adding a prop, lets switch to the phys gun for convenience
				ply:SelectWeapon( "weapon_physgun" )
			else
				print("Denied request from " .. ply:Nick())
			end
		end
	end

	-- Receivers
	net.Receive( "nzQMenu.Request", HandleRequest )

end

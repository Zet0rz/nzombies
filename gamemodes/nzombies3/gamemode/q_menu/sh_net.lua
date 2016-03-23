//Client Server Syncing

if CLIENT then

	//Client to Server (Client)
	function nz.QMenu.Functions.Request( model, entity )
		local entity = entity or false
		net.Start( "nz.QMenu.Request" )
			net.WriteString( model )
			net.WriteBool( entity )
		net.SendToServer()
	end

end

if SERVER then

	//Client to Server (Server)
	util.AddNetworkString( "nz.QMenu.Request" )

	function nz.QMenu.Functions.HandleRequest( len, ply )
		local model = net.ReadString()
		local entity = net.ReadBool()
		if Round:InState( ROUND_CREATE ) then
			print(ply:Nick() .. " requested prop " .. model)
			if ply:IsSuperAdmin() then
				local tr = util.GetPlayerTrace( ply )
				tr.mask = bit.bor( CONTENTS_SOLID, CONTENTS_MOVEABLE, CONTENTS_MONSTER, CONTENTS_WINDOW, CONTENTS_DEBRIS, CONTENTS_GRATE, CONTENTS_AUX )
				local trace = util.TraceLine( tr )
				if entity then
					Mapping:SpawnEntity(trace.HitPos, Angle(0,0,0), model, ply)
				else
					if util.IsValidProp(model) then
						Mapping:PropBuy(trace.HitPos, Angle(0,0,0), model, nil, ply)
					else
						Mapping:SpawnEffect(trace.HitPos, Angle(0,0,0), model, ply)
					end
				end
				//Since we're adding a prop, lets switch to the phys gun for convenience
				ply:SelectWeapon( "weapon_physgun" )
			else
				print("Denied request from " .. ply:Nick())
			end
		end
	end

	//Receivers
	net.Receive( "nz.QMenu.Request", nz.QMenu.Functions.HandleRequest )

end

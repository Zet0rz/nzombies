//

function nz.Fog.Functions.Enable( bool )
	//Check if we have a fog entity
	if #ents.FindByClass("env_fog_controller") == 0 then
		//If not spawn one.
		local ent =  ents.Create( "env_fog_controller" )
		ent:Spawn()
	end

	nz.Fog.Data.Enabled = bool
	nz.Fog.Functions.SendSync()
end

function nz.Fog.Functions.SetStart( val )
	nz.Fog.Data.Start = val
	nz.Fog.Functions.SendSync()
end

function nz.Fog.Functions.SetEnd( val )
	nz.Fog.Data.End = val
	nz.Fog.Functions.SendSync()
end

function nz.Fog.Functions.SetDensity( val )
	nz.Fog.Data.Density = val
	nz.Fog.Functions.SendSync()
end

function nz.Fog.Functions.SetColor( val )
	nz.Fog.Data.Color = val
	nz.Fog.Functions.SendSync()
end
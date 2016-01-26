function nz.Fog.Functions.RenderFog()
	if nz.Fog.Data.Enabled then
		render.FogMode( 1 )
		render.FogStart( nz.Fog.Data.Start )
		render.FogEnd( nz.Fog.Data.End  )
		render.FogMaxDensity( nz.Fog.Data.Density )
		render.FogColor( nz.Fog.Data.Color.r, nz.Fog.Data.Color.g, nz.Fog.Data.Color.b )

		return true
	end
end

hook.Add( "SetupWorldFog", "nz.Fog", nz.Fog.Functions.RenderFog )
local fade
local fadetime = 3

local fogstart = 10000
local fogend = 10000
local fogdensity = 0
local fogcolor = Vector(0,0,0)

local tfogstart = 10000
local tfogend = 10000
local tfogdensity = 0
local tfogcolor = Vector(0,0,0)

local ofogstart = fogstart
local ofogend = fogend
local ofogdensity = fogdensity
local ofogcolor = fogcolor

local specialfog = false
local foginit = false

function Round:EnableSpecialFog( bool )
	local ent = ents.FindByClass("edit_fog")[1]
	local ent_special = ents.FindByClass("edit_fog_special")[1]
	
	if bool and (!specialfog or !foginit) then
		if IsValid(ent_special) then
			tfogstart = ent_special:GetFogStart()
			tfogend = ent_special:GetFogEnd()
			tfogdensity = ent_special:GetDensity()
			tfogcolor = ent_special:GetFogColor()
		else
			tfogstart = 10000
			tfogend = 10000
			tfogdensity = 0
			tfogcolor = Vector(0,0,0)
		end
		specialfog = true
	elseif specialfog or !foginit then
		if IsValid(ent) then
			tfogstart = ent:GetFogStart()
			tfogend = ent:GetFogEnd()
			tfogdensity = ent:GetDensity()
			tfogcolor = ent:GetFogColor()
		else
			tfogstart = 10000
			tfogend = 10000
			tfogdensity = 0
			tfogcolor = Vector(0,0,0)
		end
		specialfog = false
	end
	if IsValid(ent) or IsValid(ent_special) then
		fade = 0
		ofogstart = fogstart
		ofogend = fogend
		ofogdensity = fogdensity
		ofogcolor = fogcolor
		hook.Add("Think", "nzFogFade", nzFogFade)
		hook.Add("SetupWorldFog", "nzWorldFog", nzSetupWorldFog)
		hook.Add("SetupSkyboxFog", "nzSkyboxFog", nzSetupSkyFog)
		foginit = true
	else
		hook.Remove("SetupWorldFog", "nzWorldFog")
		hook.Remove("SetupSkyboxFog", "nzSkyboxFog")
		foginit = false
	end
end

function nzFogFade()
	fade = math.Approach(fade, 1, FrameTime()/fadetime)
	fogstart = Lerp(fade, fogstart, tfogstart)
	fogend = Lerp(fade, fogend, tfogend)
	fogdensity = Lerp(fade, fogdensity, tfogdensity)
	fogcolor = LerpVector(fade, fogcolor, tfogcolor)
	
	if fade >= 1 then
		hook.Remove("Think", "nzFogFade")
	end
end

function nzSetupWorldFog()

	render.FogMode( 1 ) 
	render.FogStart( fogstart )
	render.FogEnd( fogend )
	render.FogMaxDensity( fogdensity )

	render.FogColor( fogcolor.x * 255, fogcolor.y * 255, fogcolor.z * 255 )

	return true

end

function nzSetupSkyFog( skyboxscale )

	render.FogMode( 1 ) 
	render.FogStart( fogstart * skyboxscale )
	render.FogEnd( fogend * skyboxscale )
	render.FogMaxDensity( fogdensity )

	render.FogColor( fogcolor.x * 255, fogcolor.y * 255, fogcolor.z * 255 )

	return true

end
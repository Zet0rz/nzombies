local fade
local fadetime = 5

local fogstart = fogstart or 50
local fogend = fogend or 1000
local fogdensity = fogdensity or 0
local fogcolor = fogcolor or Vector(0.4,0.7,0.8)

local tfogstart = tfogstart or 50
local tfogend = tfogend or 1000
local tfogdensity = tfogdensity or 0
local tfogcolor = tfogcolor or Vector(0.4,0.7,0.8)

local ofogstart = fogstart
local ofogend = fogend
local ofogdensity = fogdensity
local ofogcolor = fogcolor

local specialfog = false
local foginit = false

function Round:EnableSpecialFog( bool )
	local ent = ents.FindByClass("edit_fog")[1]
	local ent_special = ents.FindByClass("edit_fog_special")[1]
	
	hook.Remove("Think", "nzFogThink")
	
	if bool and (!specialfog or !foginit) then
		if IsValid(ent_special) then
			tfogstart = ent_special:GetFogStart()
			tfogend = ent_special:GetFogEnd()
			tfogdensity = ent_special:GetDensity()
			tfogcolor = ent_special:GetFogColor()
		else
			tfogstart = 50
			tfogend = 1000
			tfogdensity = 0.9
			tfogcolor = Vector(0.4,0.7,0.8)
		end
		specialfog = true
	elseif specialfog or !foginit then
		if IsValid(ent) then
			tfogstart = ent:GetFogStart()
			tfogend = ent:GetFogEnd()
			tfogdensity = ent:GetDensity()
			tfogcolor = ent:GetFogColor()
		else
			tfogstart = 50
			tfogend = 1000
			tfogdensity = 0
			tfogcolor = Vector(0.4,0.7,0.8)
		end
		specialfog = false
	end
	-- Changed to always true because we now have defaults that apply if the entities don't exist
	if true then --IsValid(ent) or IsValid(ent_special) then
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
	fogstart = Lerp(fade, ofogstart, tfogstart)
	fogend = Lerp(fade, ofogend, tfogend)
	fogdensity = Lerp(fade, ofogdensity, tfogdensity)
	fogcolor = LerpVector(fade, ofogcolor, tfogcolor)
	
	if fade >= 1 then
		hook.Remove("Think", "nzFogFade")
		hook.Add("Think", "nzFogThink", nzFogThink)
	end
end

function nzFogThink()
	local ent
	if specialfog then
		ent = ents.FindByClass("edit_fog_special")[1]
	else
		ent = ents.FindByClass("edit_fog")[1]
	end
	--print(ent)
	if IsValid(ent) then
		fogstart = ent:GetFogStart()
		fogend = ent:GetFogEnd()
		fogdensity = ent:GetDensity()
		fogcolor = ent:GetFogColor()
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
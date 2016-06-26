local mapscript = {}

function mapscript.OnGameBegin()
	mapscript.genButton = ents.FindByName("GenButton01")[1]
    mapscript.IsElectricityOn = false
    engine.LightStyle( 0, "d" )
    for k, v in pairs( player.GetAll() ) do
        v:SendLua( "render.RedownloadAllLightmaps()" )
    end
end

function mapscript.RoundStart()
    for k, v in pairs player.GetAll() do
        v:AllowFlashlight( IsElec() )
    end
end

function mapscript.RoundThink()

end

function mapscript.RoundEnd()

end

function mapscript.ElectricityOn()
	mapscript.genButton:Fire("Press")
	mapscript.IsElectricityOn = true
end

function mapscript.ElectricityOff()
    if mapscript.IsElectricityOn then
	    mapscript.genButton:Fire("Press")
        mapscript.IsElectricityOn = false
    end
end

return mapscript
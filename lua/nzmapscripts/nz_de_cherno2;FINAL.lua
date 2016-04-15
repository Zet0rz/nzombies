local mapscript = {}

function mapscript.OnGameBegin()
	mapscript.genButton = ents.FindByName("GenButton01")[1]
    mapscript.IsElectricityOn = false
end

function mapscript.RoundStart()

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

mapscript.TestPrint = "v0.0"
local testprint2 = "This is cool"

return mapscript
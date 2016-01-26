//Halos

//Setup
nz.Display.Data.Halos = {}
nz.Display.Data.Halos.Normal = {}
nz.Display.Data.Halos.Create = {}

//Functions
function nz.Display.Functions.NewHalo(class, colour, createOnly)
	if createOnly == true then
		table.insert(nz.Display.Data.Halos.Create, {class, colour})
	else
		table.insert(nz.Display.Data.Halos.Normal, {class, colour})
	end
	
end

//Hooks
if nz.Config.Halos == true then
	hook.Add( "PreDrawHalos", "nz_halos", function()
		//Create
		if nz.Rounds.Data.CurrentState == ROUND_CREATE then
			for k,v in pairs(nz.Display.Data.Halos.Create) do
				halo.Add( ents.FindByClass( v[1] ), v[2], 0, 0, 0.1, 0, 1 )
			end
		end
		
		//Normals
		for k,v in pairs(nz.Display.Data.Halos.Normal) do
			halo.Add( ents.FindByClass( v[1] ), v[2], 0, 0, 0.1, 0, 1 )
		end
	end )
end

//Quick Function
NewHalo = nz.Display.Functions.NewHalo

//Actual Halos

//Zombie Spawns
NewHalo("zed_spawns", Color(255,0,0), true)
//Player Spawns
NewHalo("player_spawns", Color(0,255,0), true)
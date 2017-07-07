
function nzQMenu.AddNewEntity( ent, icon, name )
	table.insert(nzQMenu.Data.Entities, {ent, icon, name})
end

-- QuickFunctions
PropMenuAddEntity = nzQMenu.AddNewEntity

PropMenuAddEntity("edit_fog", "entities/edit_fog.png", "Base Fog Editor")
PropMenuAddEntity("edit_fog_special", "entities/edit_fog.png", "Special Round Fog Editor")
PropMenuAddEntity("edit_sky", "entities/edit_sky.png", "Sky Editor")
PropMenuAddEntity("edit_sun", "entities/edit_sun.png", "Sun Editor")
PropMenuAddEntity("edit_color", "gmod/demo.png", "Color Correction Editor")
PropMenuAddEntity("nz_fire_effect", "icon16/fire.png", "Fire Effect")
PropMenuAddEntity("edit_dynlight", "icon16/lightbulb.png", "Dynamic Light")
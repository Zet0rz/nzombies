//

function nz.PropsMenu.Functions.AddNewCategory( text, tooltip )
	if tooltip == nil then
		tooltip = true
	end
	nz.PropsMenu.Data.Categories[text] = tooltip
end

function nz.PropsMenu.Functions.AddNewModel( cat, model )
	table.insert(nz.PropsMenu.Data.Models, {cat, model})
end

function nz.PropsMenu.Functions.AddNewEntity( ent, icon )
	table.insert(nz.PropsMenu.Data.Entities, {ent, icon})
end

//QuickFunctions

PropMenuAddCat = nz.PropsMenu.Functions.AddNewCategory
PropMenuAddModel = nz.PropsMenu.Functions.AddNewModel
PropMenuAddEntity = nz.PropsMenu.Functions.AddNewEntity

//Use
PropMenuAddCat("Light Effects")
PropMenuAddModel("Light Effects", "models/effects/vol_light.mdl")
PropMenuAddModel("Light Effects", "models/effects/vol_light01.mdl")
PropMenuAddModel("Light Effects", "models/effects/vol_light02.mdl")
PropMenuAddModel("Light Effects", "models/effects/vol_light128x128.mdl")
PropMenuAddModel("Light Effects", "models/effects/vol_light128x256.mdl")
PropMenuAddModel("Light Effects", "models/effects/vol_light128x384.mdl")
PropMenuAddModel("Light Effects", "models/effects/vol_light128x512.mdl")
PropMenuAddModel("Light Effects", "models/effects/vol_light256x512.mdl")
PropMenuAddModel("Light Effects", "models/effects/vol_light64x128.mdl")
PropMenuAddModel("Light Effects", "models/effects/vol_light64x256.mdl")
PropMenuAddModel("Light Effects", "models/effects/lightshaft/lightshaft_2fortspawnext.mdl")
PropMenuAddModel("Light Effects", "models/effects/lightshaft/lightshaft_window01.mdl")
PropMenuAddModel("Light Effects", "models/lostcoast/effects/vollight_stainedglass.mdl")
PropMenuAddModel("Light Effects", "models/props/cs_militia/bridgelight.mdl")

PropMenuAddCat("Gates")
PropMenuAddModel("Gates", "models/props_c17/fence03a.mdl")
PropMenuAddModel("Gates", "models/props_c17/fence02b.mdl")
PropMenuAddModel("Gates", "models/props_c17/fence01b.mdl")
PropMenuAddModel("Gates", "models/props_c17/gate_door01a.mdl")
PropMenuAddModel("Gates", "models/props_c17/gate_door02a.mdl")
PropMenuAddModel("Gates", "models/props_building_details/Storefront_Template001a_Bars.mdl")
PropMenuAddModel("Gates", "models/props_borealis/borealis_door001a.mdl")
PropMenuAddModel("Gates", "models/props_wasteland/interior_fence001g.mdl")
PropMenuAddModel("Gates", "models/props_wasteland/interior_fence002d.mdl")
PropMenuAddModel("Gates", "models/props_wasteland/wood_fence01a.mdl")
PropMenuAddModel("Gates", "models/props_lab/blastdoor001a.mdl")
PropMenuAddModel("Gates", "models/props_lab/blastdoor001b.mdl")
PropMenuAddModel("Gates", "models/props_lab/blastdoor001c.mdl")
PropMenuAddModel("Gates", "models/props_wasteland/wood_fence02a.mdl")
PropMenuAddModel("Gates", "models/props_wasteland/prison_celldoor001b.mdl")
PropMenuAddModel("Gates", "models/props_interiors/ElevatorShaft_Door01a.mdl")

PropMenuAddModel("Gates", "models/props_debris/metal_panel01a.mdl")
PropMenuAddModel("Gates", "models/props_debris/metal_panel02a.mdl")
PropMenuAddModel("Gates", "models/props_doors/door03_slotted_left.mdl")
PropMenuAddModel("Gates", "models/props_interiors/VendingMachineSoda01a_door.mdl")
PropMenuAddModel("Gates", "models/props_wasteland/interior_fence002e.mdl")
PropMenuAddModel("Gates", "models/props_interiors/refrigeratorDoor01a.mdl")
PropMenuAddModel("Gates", "models/props_c17/door01_left.mdl")
PropMenuAddModel("Gates", "models/props_c17/door02_double.mdl")
PropMenuAddModel("Gates", "models/props_c17/gravestone_coffinpiece001a.mdl")
PropMenuAddModel("Gates", "models/props_c17/gravestone_coffinpiece002a.mdl")
PropMenuAddModel("Gates", "models/props_junk/TrashDumpster02b.mdl")

PropMenuAddCat("Scenery")
PropMenuAddModel("Scenery", "models/props_borealis/bluebarrel001.mdl")
PropMenuAddModel("Scenery", "models/props_interiors/Furniture_shelf01a.mdl")
PropMenuAddModel("Scenery", "models/props_junk/TrashDumpster02.mdl")
PropMenuAddModel("Scenery", "models/props_interiors/VendingMachineSoda01a.mdl")
PropMenuAddModel("Scenery", "models/props_wasteland/laundry_dryer001.mdl")
PropMenuAddModel("Scenery", "models/props_wasteland/laundry_dryer002.mdl")
PropMenuAddModel("Scenery", "models/props_wasteland/kitchen_stove002a.mdl")
PropMenuAddModel("Scenery", "models/props_wasteland/controlroom_storagecloset001b.mdl")
PropMenuAddModel("Scenery", "models/props_wasteland/medbridge_post01.mdl")
PropMenuAddModel("Scenery", "models/props_c17/signpole001.mdl")

PropMenuAddModel("Scenery", "models/props_trainstation/traincar_seats001.mdl")
PropMenuAddModel("Scenery", "models/props_vehicles/carparts_door01a.mdl")
PropMenuAddModel("Scenery", "models/props_lab/securitybank.mdl")
PropMenuAddModel("Scenery", "models/props_lab/reciever_cart.mdl")
PropMenuAddModel("Scenery", "models/props_lab/crematorcase.mdl")
PropMenuAddModel("Scenery", "models/props_lab/corkboard002.mdl")
PropMenuAddModel("Scenery", "models/props_lab/corkboard001.mdl")
PropMenuAddModel("Scenery", "models/props_lab/Cleaver.mdl")
PropMenuAddModel("Scenery", "models/props_lab/cactus.mdl")
PropMenuAddModel("Scenery", "models/props_trainstation/payphone001a.mdl")
PropMenuAddModel("Scenery", "models/props_lab/workspace003.mdl")
PropMenuAddModel("Scenery", "models/props_lab/workspace004.mdl")
PropMenuAddModel("Scenery", "models/props_lab/workspace002.mdl")
PropMenuAddModel("Scenery", "models/props_lab/workspace001.mdl")
PropMenuAddModel("Scenery", "models/props_lab/tpplugholder.mdl")
PropMenuAddModel("Scenery", "models/props_lab/tpplugholder_single.mdl")
PropMenuAddModel("Scenery", "models/props_lab/tpplug.mdl")
PropMenuAddModel("Scenery", "models/props_lab/servers.mdl")
PropMenuAddModel("Scenery", "models/props_vehicles/carparts_tire01a.mdl")
PropMenuAddModel("Scenery", "models/props_combine/combine_monitorbay.mdl")
PropMenuAddModel("Scenery", "models/props_combine/combine_interface001.mdl")
PropMenuAddModel("Scenery", "models/props_combine/combine_intmonitor001.mdl")
PropMenuAddModel("Scenery", "models/props_combine/CombineThumper002.mdl")
PropMenuAddModel("Scenery", "models/props_combine/CombineThumper001a.mdl")
PropMenuAddModel("Scenery", "models/props_combine/breendesk.mdl")
PropMenuAddModel("Scenery", "models/props_combine/combine_barricade_short02a.mdl")
PropMenuAddModel("Scenery", "models/props_combine/combine_bridge_b.mdl")
PropMenuAddModel("Scenery", "models/props_combine/combine_fence01a.mdl")
PropMenuAddModel("Scenery", "models/props_combine/combine_fence01b.mdl")
PropMenuAddModel("Scenery", "models/props_combine/weaponstripper.mdl")

PropMenuAddEntity("edit_fog", "entities/edit_fog.png")
PropMenuAddEntity("edit_sky", "entities/edit_sky.png")
PropMenuAddEntity("edit_sun", "entities/edit_sun.png")
PropMenuAddEntity("nz_fire_effect", "icon16/fire.png")
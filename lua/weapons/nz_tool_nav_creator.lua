SWEP.PrintName	= "Nav Editor Tool"
SWEP.Author		= "Zet0r"
SWEP.Slot		= 0
SWEP.SlotPos	= 10
SWEP.Base 		= "nz_tool_base"

SWEP.Ent1			= nil
SWEP.Ent2			= nil

if CLIENT then
	function OpenNavToolHelp()
		local frame = vgui.Create("DFrame")
		frame:SetSize(700,400)
		frame:SetPos(ScrW()/2 - 350, ScrH()/2 - 200)
		frame:SetDraggable(true)
		frame:SetTitle("Nav Editor Tool Help")
		frame:MakePopup()
		
		local fill = vgui.Create("DPanel", frame)
		fill:Dock( FILL )
		fill:DockMargin( 0, 0, 0, 0 )
		
		local text = vgui.Create( "RichText", fill )
		text:Dock( FILL )
		text:InsertColorChange( 0, 0, 0, 255 )
		text:AppendText( "What can the Nav Editor Tool do?\n" )

		text:InsertColorChange( 100, 100, 100, 255 )
		text:AppendText( "The Nav Editor tool allows you to make the zombies intelligent enough to be able to find routes around closed doors. Since Nav Meshes won't realize there's a door in place, without using the Nav Editor Tool, you will likely run into Zombies trying to walk through closed doors or props you've placed. The Nav Editor tool allows you to designate rooms with Nav Gates linking between them. These gates can be open or closed dependant on the door, and Zombies can only find a route through open links.\n\n" )

		//Config Notice
		text:InsertColorChange( 0, 0, 0, 255 )
		text:AppendText( "CONFIGURING USAGE:\n" )
		text:InsertColorChange( 100, 100, 100, 255 )
		text:AppendText( "Using navigation like this might be expensive. Change the mode by going to 'nzombies3 -> gamemode -> config -> sh_constructor.lua' and set 'nz.Config.NavMode' to whatever you want. Alternatively you can do this in the server console with 'lua_run nz.Config.NavMode = [number]'\n\n" )
		
		//Quick Walktrough
		text:InsertColorChange( 0, 0, 0, 255 )
		text:AppendText( "To set up navigation:\n" )
		
		text:InsertColorChange( 100, 100, 100, 255 )
		text:AppendText( "It is recommended that you first build your map complete with doors and spawnpoints before you proceed. You will first need to designate your 'rooms', then find links between them and set up Nav Gates, then link all of them together. You also want to link all Zombie Spawnpoints and Player Spawns to whatever room they start in.\n\n" )

		//Creating Rooms
		text:InsertColorChange( 0, 0, 0, 255 )
		text:AppendText( "- Create Rooms:\n" )
		
		text:InsertColorChange( 100, 100, 100, 255 )
		text:AppendText( "You don't actually have to do this for all map-based rooms, you should base it on openable doors and props you build your config." )
		text:InsertColorChange( 255, 100, 100, 255 )
		text:AppendText( " The fewer rooms the better." )
		text:InsertColorChange( 100, 100, 100, 255 )
		text:AppendText( " After decided what each nav room covers, " )
		text:InsertColorChange( 255, 100, 100, 255 )
		text:AppendText( "Right-Click on the world" )
		text:InsertColorChange( 100, 100, 100, 255 )
		text:AppendText( " to create a Nav Room Controller Entity. This globe represents your room and is what you want to link to gates and spawnpoints.\n\n" )
		
		//Nav Gates
		text:InsertColorChange( 0, 0, 0, 255 )
		text:AppendText( "- Create Nav Gates:\n" )
		
		text:InsertColorChange( 100, 100, 100, 255 )
		text:AppendText( "Nav Gates are created in pairs by " )
		text:InsertColorChange( 255, 100, 100, 255 )
		text:AppendText( "Left-Click on the world." )
		text:InsertColorChange( 100, 100, 100, 255 )
		text:AppendText( " Move them around with the Phys Gun to cover up the door or walkway." )
		text:InsertColorChange( 255, 100, 100, 255 )
		text:AppendText( " It should be impossible to get to the other side without touching the opposite Nav Gate." )
		text:InsertColorChange( 100, 100, 100, 255 )
		text:AppendText( " You can change the size of the Gate by pressing " )
		text:InsertColorChange( 255, 100, 100, 255 )
		text:AppendText( "Reload" )
		text:InsertColorChange( 100, 100, 100, 255 )
		text:AppendText( " at it. Remove Gates by " )
		text:InsertColorChange( 255, 100, 100, 255 )
		text:AppendText( "Right-Clicking" )
		text:InsertColorChange( 100, 100, 100, 255 )
		text:AppendText( " on them.\n\n" )
		
		//Linking
		text:InsertColorChange( 0, 0, 0, 255 )
		text:AppendText( "- Linking it all together:\n" )
		
		text:InsertColorChange( 100, 100, 100, 255 )
		text:AppendText( "The last part to be done. Simply " )
		text:InsertColorChange( 255, 100, 100, 255 )
		text:AppendText( "Left-Click" )
		text:InsertColorChange( 100, 100, 100, 255 )
		text:AppendText( " on the two entites you want to link. " )
		text:InsertColorChange( 255, 100, 100, 255 )
		text:AppendText( "It is important that you start by linking all Nav Gates to their owner room!" )
		text:InsertColorChange( 100, 100, 100, 255 )
		text:AppendText( " After that, you can link every pair of gates together. Finally, link every Nav Gate tied to a door with that door. This will close the link between the two Nav Gates until that door's link is opened. " )
		text:InsertColorChange( 255, 100, 100, 255 )
		text:AppendText( "You need to do this on both Gates at each side of the door! The door will also need to have a Link set and Use Links on!\n\n" )
		
		//Making sure it's good
		text:InsertColorChange( 0, 0, 0, 255 )
		text:AppendText( "- Making Sure & Errors:\n" )
		
		text:InsertColorChange( 100, 100, 100, 255 )
		text:AppendText( "Should you get an error while linking, it is likely because the Nav Gates you're trying to link hasn't got an Owner Room set. Either way, pressin " )
		text:InsertColorChange( 255, 100, 100, 255 )
		text:AppendText( "Reload" )
		text:InsertColorChange( 100, 100, 100, 255 )
		text:AppendText( " on the ground will clear your marked entities (from Left-Clicking). " )
		text:InsertColorChange( 255, 100, 100, 255 )
		text:AppendText( "Do this if any error should appear!" )
		text:InsertColorChange( 100, 100, 100, 255 )
		text:AppendText( " To make sure you've all set it up correctly and to see the full table of links, press " )
		text:InsertColorChange( 255, 100, 100, 255 )
		text:AppendText( "Crouch+Reload" )
		text:InsertColorChange( 100, 100, 100, 255 )
		text:AppendText( " and look into the Server Console. You will want to not have any NULL Entities except for 'door' on connections that aren't tied to a buyable door.\n\n" )
		
		//Planned Features
		text:InsertColorChange( 0, 0, 0, 255 )
		text:AppendText( "- Things to change:\n" )
		
		text:InsertColorChange( 100, 100, 100, 255 )
		text:AppendText( "This tool is in Beta and changes are planned for later. Here is what will happen eventually:\n" )
		text:AppendText( "- Visually showing links with lasers\n" )
		text:AppendText( "- Making errors reset the tool as a failsafe\n" )
		text:AppendText( "- Not using navigation table if it is faulty\n" )
		text:AppendText( "- Make it possible to close gates without a door, making them one-way\n" )
		text:AppendText( "- Making the config tied to a Config Entity so you don't have to edit files\n" )
		text:AppendText( "- Make a better full guide/video\n" )
	end
	net.Receive("NavToolHelp", OpenNavToolHelp)
else
	util.AddNetworkString("NavToolHelp")
end

function SWEP:OnPrimaryAttack(tr)
	
	local ent = tr.Entity
	if IsNavApplicable(ent) then
		if IsValid(self.Ent1) then
			if self.Ent1:GetClass() == "nav_room_controller" then
				if ent:GetClass() == "nav_gate" then
					//A nav gate is bound, setup default table values
					nz.Nav.Data[self.Ent1][ent] = {open = true, targetroom = NULL, doorlink = 0, navlink = IsValid(ent.navlink) and ent.navlink or NULL}
					ent.OwnerRoom = self.Ent1
				else
					ent.OwnerRoom = self.Ent1
					print("Set", ent, "owner room to", ent.OwnerRoom)
				end
			elseif ent:GetClass() == "nav_room_controller" then
				if self.Ent1:GetClass() == "nav_gate" then
					//A nav gate is bound, setup default table values
					nz.Nav.Data[ent][self.Ent1] = {open = true, targetroom = NULL, doorlink = 0, navlink = IsValid(self.Ent1.navlink) and self.Ent1.navlink or NULL}
					self.Ent1.OwnerRoom = ent
				else
					self.Ent1.OwnerRoom = ent
					print("Set", self.Ent1, "owner room to", self.Ent1.OwnerRoom)
				end
			elseif self.Ent1:GetClass() == "nav_gate" then
				if ent:GetClass() == "nav_gate" then
					//Both are nav-gates, link them!
					print(self.Ent1.OwnerRoom, ent.OwnerRoom)
					nz.Nav.Data[self.Ent1.OwnerRoom][self.Ent1].targetroom = ent.OwnerRoom
					nz.Nav.Data[self.Ent1.OwnerRoom][self.Ent1].navlink = ent
					nz.Nav.Data[ent.OwnerRoom][ent].targetroom = self.Ent1.OwnerRoom
					nz.Nav.Data[ent.OwnerRoom][ent].navlink = self.Ent1
				elseif ent:IsDoor() or ent:IsBuyableProp() or ent:IsButton() then
					//Linking a navgate with a door
					nz.Nav.Data[self.Ent1.OwnerRoom][self.Ent1].doorlink = ent.link
					nz.Nav.Data[self.Ent1.OwnerRoom][self.Ent1].open = false
				end
			elseif ent:GetClass() == "nav_gate" then
				if self.Ent1:IsDoor() or self.Ent1:IsBuyableProp() or self.Ent1:IsButton() then
					//Linking a navgate with a door - the other way around
					nz.Nav.Data[ent.OwnerRoom][ent].doorlink = self.Ent1.link
					nz.Nav.Data[ent.OwnerRoom][ent].open = false
				end
			end
			self.Ent1 = nil
		else
			self.Ent1 = ent
		end
	else
		//Left clicking the world spawns a set of nav gates
		if tr.HitWorld then
			local gate = ents.Create("nav_gate")
			gate:SetAngles( Angle(90,(tr.HitPos - self.Owner:GetPos()):Angle()[2] + 90,90) )
			gate:SetPos(tr.HitPos - (tr.HitPos - self.Owner:GetPos()):GetNormal()*20)
			gate:Spawn()
			
			local gate2 = ents.Create("nav_gate")
			gate2:SetAngles( Angle(90,(tr.HitPos - self.Owner:GetPos()):Angle()[2] + 90,90) )
			gate2:SetPos(tr.HitPos + (tr.HitPos - self.Owner:GetPos()):GetNormal()*20)
			gate2:Spawn()
			
			//Link them for reference when they get linked to room entities
			gate2.navlink = gate
			gate.navlink = gate2
		end
	end
	
	return true
end

function IsNavApplicable(ent)
	// All classes that can be linked with navigation
	if ent:GetClass() == "nav_gate" 
	or ent:GetClass() == "nav_room_controller" 
	or ent:IsDoor() 
	or ent:IsBuyableProp() 
	or ent:GetClass() == "player_spawns" 
	or ent:GetClass() == "zed_spawns" then
		return true
	else
		return false
	end
end

function SWEP:OnReload(tr)

	if self.Owner:KeyDown(IN_SPEED) then
		net.Start("NavToolHelp")
		net.Send(self.Owner)
		return
	end
	if self.Owner:KeyDown(IN_DUCK) then
		PrintTable(nz.Nav.Data)
		return
	end

	if(CLIENT)then return true end
	
	//Reloading on a nav gate cycles its model
	if IsValid(tr.Entity) and tr.Entity:GetClass() == "nav_gate" then
		tr.Entity:CycleModel()
		return true
	end
	
	self.Ropes = {}
	self.Ent1 = nil
	self.Ent2 = nil
	return true
end

function SWEP:Think()
end

function SWEP:OnSecondaryAttack(tr)
	if(!tr.HitPos)then return false end
	
	if(CLIENT)then return true end
	
	--[[
		NavWaypoints = {
			currom = {
				connection1 = {open = true, targetroom = room2, door = room2's door connecting to curroom},
				connection2 = {open = false, targetroom = room2, door = another room2 door to curroom},
				connection3 = {open = false, targetroom = room3, door = door to room3 from curroom},
			}
		}
	]]
	
	local ent = tr.Entity
	
	if tr.HitWorld then
		//Right clicking world creates a room controller
		local room = ents.Create("nav_room_controller")
		room:SetPos(tr.HitPos)
		room:Spawn()
		nz.Nav.Data[room] = {}
		print("Created", room)
	else
		//Right clicking a room controller or gate removes it and unlinks all connections
		if ent:GetClass() == "nav_room_controller" then
			nz.Nav.Data[ent] = nil
			ent:Remove()
		elseif ent:GetClass() == "nav_gate" then
			//Delete linked door's link with this one
			if IsValid(ent.LinkedDoor) then
				if table.HasValue(nz.Nav.LinkedGates[ent.LinkedDoor], ent) then
					table.RemoveByValue(nz.Nav.LinkedGates[ent.LinkedDoor], ent)
				end
			end
			if IsValid(ent.OwnerRoom) then
				if IsValid(nz.Nav.Data[ent.OwnerRoom][ent].door) then
					nz.Nav.Data[nz.Nav.Data[ent.OwnerRoom][ent].door.OwnerRoom][nz.Nav.Data[ent.OwnerRoom][ent].door] = nil
				end
				nz.Nav.Data[ent.OwnerRoom][ent] = nil
			end
			ent:Remove()
		end
	end
	
	--[[if IsValid(self.Ent1) then
		self.Ent2 = tr.Entity
		
		if Entity(1):KeyDown(IN_SPEED) then
			table.insert(NavWaypoints[self.Ent1].connections, self.Ent2)
			if !NavWaypoints[self.Ent2] then 
				NavWaypoints[self.Ent2] = {open = false, connections = {}}
				self.Ent2:SetColor( Color(255, 0, 0) )
			end
			table.insert(NavWaypoints[self.Ent2].connections, self.Ent1)
		else
			table.insert(NavWaypoints[self.Ent1].connections, self.Ent2)
			if !NavWaypoints[self.Ent2] then 
				NavWaypoints[self.Ent2] = {open = true, connections = {}}
				self.Ent2:SetColor( Color(0, 0, 255) )
			end
			table.insert(NavWaypoints[self.Ent2].connections, self.Ent1)
		end
		local rope1, rope2 = constraint.Rope( self.Ent1, self.Ent2, 0, 0, Vector(0,0,50), Vector(0,0,50),( self.Ent1:GetPos() - self.Ent2:GetPos() ):Length(), 0, 0, 20, NavWaypoints[self.Ent1].open and NavWaypoints[self.Ent2].open and "cable/hydra" or "cable/redlaser", false )
		table.insert(self.Ropes, rope1)
		self.Ent1 = nil
		self.Ent2 = nil
		PrintTable(NavWaypoints)
	else
		self.Ent1 = tr.Entity
		if !NavWaypoints[self.Ent1] then
			if Entity(1):KeyDown(IN_SPEED) then
				NavWaypoints[self.Ent1] = {open = false, connections = {}}
				self.Ent1:SetColor( Color(255, 0, 0) )
			else
				NavWaypoints[self.Ent1] = {open = true, connections = {}}
				self.Ent1:SetColor( Color(0, 0, 255) )
			end
		end
	end]]
	
	return true
end

function SWEP:Deploy()
	if CLIENT then
		chat.AddText(Color(150,200,255), "[NZ] Warning: The Nav Editor tool is an ", Color(255,100,100), "Advanced", Color(150,200,255), " tool. It provides little to no visualization yet, but is functional. Press ", Color(100,255,100), "Sprint+Reload", Color(150,200,255), " to get a help menu.")
	end
end
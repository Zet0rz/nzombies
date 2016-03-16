SWEP.PrintName	= "Nav Locker Tool"
SWEP.Author		= "Zet0r"
SWEP.Slot		= 0
SWEP.SlotPos	= 11
SWEP.Base 		= "nz_tool_base"

SWEP.Ent1			= nil

function SWEP:OnPrimaryAttack(tr)
	local pos = tr.HitPos
	if tr.HitWorld or self.Owner:KeyDown(IN_SPEED) then
		if !IsValid(self.Ent1) then self.Owner:ChatPrint("You need to mark a door first to link an area.") return end
		local navarea = navmesh.GetNearestNavArea(pos)
		
		
		
		nz.Nav.Data[navarea:GetID()] = {
			prev = navarea:GetAttributes(),
			locked = true,
			link = self.Ent1.link
		}
		//Purely to visualize, resets when game begins or shuts down
		navarea:SetAttributes(NAV_MESH_STOP)
		
		self.Owner:ChatPrint("Navmesh ["..navarea:GetID().."] locked to door "..self.Ent1:GetClass().."["..self.Ent1:EntIndex().."]!")
		self.Ent1:SetMaterial( "" )
		self.Ent1 = nil
	return end
	
	local ent = tr.Entity
	if !IsNavApplicable(ent) then 
		self.Owner:ChatPrint("Only buyable props, doors, and buyable buttons with LINKS can be linked to navareas.")
	return end
	
	if IsValid(self.Ent1) and self.Ent1 != ent then 
		self.Ent1:SetMaterial( "" )
	end
	
	self.Ent1 = ent
	ent:SetMaterial( "hunter/myplastic.vtf" )
	
	return true
end

if SERVER then
	util.AddNetworkString("nz_NavMeshGrouping")
	util.AddNetworkString("nz_NavMeshGroupRequest")
	
	net.Receive("nz_NavMeshGroupRequest", function(len, ply)
		if !IsValid(ply) or !ply:IsSuperAdmin() then return end
		
		local delete = net.ReadBool()
		local data = net.ReadTable()
		
		//Reselect all areas from the seed provided
		local areas = FloodSelectNavAreas(navmesh.GetNavAreaByID(data.areaid))
			
		if delete then
			for k,v in pairs(areas) do
				//Remove nav area from group - add true to delete the group ID as well
				nz.Nav.Functions.RemoveNavGroupArea(v, true)
			end
		else
			for k,v in pairs(areas) do
				//Set their ID in the table
				nz.Nav.Functions.AddNavGroupIDToArea(v, data.id)
			end
		end
	end)
else
	net.Receive("nz_NavMeshGrouping", function()
	
		local data = net.ReadTable()
		
		local frame = vgui.Create("DFrame")
		frame:SetPos( 100, 100 )
		frame:SetSize( 300, 450 )
		frame:SetTitle( "Nav Mesh Grouping" )
		frame:SetVisible( true )
		frame:SetDraggable( false )
		frame:ShowCloseButton( true )
		frame:MakePopup()
		frame:Center()
		
		local numareas = vgui.Create( "DLabel", frame )
		numareas:SetPos( 10, 30 )
		numareas:SetSize( frame:GetWide() - 10, 10)
		numareas:SetText( data.num.." areas selected" )
		
		local map = vgui.Create("DPanel", frame)
		map:SetPos( 25, 50 )
		map:SetSize( 250, 250 )
		map:SetVisible( true )
		map.Paint = function(self, w, h)
			local posx, posy = frame:GetPos()
			cam.Start2D()
				render.RenderView({
					origin = LocalPlayer():GetPos()+Vector(0,0,7000),
					angles = Angle(90,0,0),
					aspectratio = 1,
					x = posx + 12,
					y = posy + 100, 
					w = 275,
					h = 275,
					dopostprocess = false,
					drawhud = false,
					drawviewmodel = false,
					viewmodelfov = 0,
					fov = 90,
					ortho = false,
					znear = 0,
					zfar = 10000,
				})
			cam.End2D()
		end
		
		local DProperties = vgui.Create( "DProperties", frame )
		DProperties:SetSize( 280, 180 )
		DProperties:SetPos( 10, 50 )

		local Row1 = DProperties:CreateRow( "Nav Group", "ID" )
		Row1:Setup( "Integer" )
		Row1:SetValue( data.id )
		Row1.DataChanged = function( _, val ) data.id = val end
		
		local Submit = vgui.Create( "DButton", frame )
		Submit:SetText( "Submit" )
		Submit:SetPos( 10, 410 )
		Submit:SetSize( 280, 30 )
		Submit.DoClick = function()
			net.Start("nz_NavMeshGroupRequest")
				net.WriteBool(false)
				net.WriteTable(data)
			net.SendToServer()
			frame:Close()
		end
		
		local Delete = vgui.Create( "DButton", frame )
		Delete:SetText( "Delete Group" )
		Delete:SetPos( 10, 380 )
		Delete:SetSize( 280, 20 )
		Delete.DoClick = function()
			net.Start("nz_NavMeshGroupRequest")
				net.WriteBool(true)
				net.WriteTable(data)
			net.SendToServer()
			frame:Close()
		end
	end)
end

function SWEP:OnReload(tr)
	--[[if IsValid(self.Ent1) then
		self.Ent1:SetMaterial( "" )
	end
	self.Ent1 = nil
	if self.Owner:KeyDown(IN_SPEED) then return end]]
	
	local nav = navmesh.GetNearestNavArea(tr.HitPos)
	local areas = FloodSelectNavAreas(nav)
	
	net.Start("nz_NavMeshGrouping")
		net.WriteTable({num = #areas, areaid = nav:GetID(), id = nz.Nav.NavGroups[nav:GetID()] or ""})
	net.Send(self.Owner)
	
end

function SWEP:Think()

end

function SWEP:OnSecondaryAttack(tr)
	if(!tr.HitPos)then return false end
	local pos = tr.HitPos
	local navarea = navmesh.GetNearestNavArea(pos)
	local navid = navarea:GetID()
	
	if nz.Nav.Data[navid] then
		navarea:SetAttributes(nz.Nav.Data[navid].prev)
		self.Owner:ChatPrint("Navmesh ["..navid.."] unlocked!")
		nz.Nav.Data[navid] = nil
	return end
	
	nz.Nav.Data[navid] = {
		prev = navarea:GetAttributes(),
		locked = true,
		link = nil
	}
	
	navarea:SetAttributes(NAV_MESH_AVOID)
	self.Owner:ChatPrint("Navmesh ["..navid.."] locked!")
	
	if(CLIENT)then return true end
	
	return true
end

function SWEP:Deploy()
	if SERVER then
		if self.Owner:IsListenServerHost() and GetConVar("sv_cheats"):GetBool() then
			RunConsoleCommand("nav_edit", 1)
		else
			self.Owner:ChatPrint("You need to be hosting a singleplayer/local server with sv_cheats set to 1 to visualize the Navmeshes.")
		end
	end
end

function SWEP:Holster()
	if SERVER and self.Owner:IsListenServerHost() and GetConVar("sv_cheats"):GetBool() then
		RunConsoleCommand("nav_edit", 0)
	end
	return true
end
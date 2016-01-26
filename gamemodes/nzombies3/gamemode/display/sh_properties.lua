properties.Add( "nz_remove", {
	MenuLabel = "Remove",
	Order = 1000,
	MenuIcon = "icon16/delete.png",

	Filter = function( self, ent, ply ) -- A function that determines whether an entity is valid for this property
		if nz.Rounds.Data.CurrentState != ROUND_CREATE then return false end
		if ( ent:IsPlayer() ) then return false end
		if ( !ply:IsAdmin() ) then return false end

		return true
	end,
	Action = function( self, ent )

		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
		
	end,
	
	Receive = function( self, length, player )
		local ent = net.ReadEntity()
		
		if ( !IsValid( ent ) ) then return false end
		if ( !IsValid( player ) ) then return false end
		if nz.Rounds.Data.CurrentState != ROUND_CREATE then return false end
		if ( !player:IsAdmin() ) then return false end
		if ( ent:IsPlayer() ) then return false end
		if ( !self:Filter( ent, player ) ) then return false end
		
		-- Remove all constraints (this stops ropes from hanging around)
		constraint.RemoveAll( ent )
		
		-- Remove it properly in 1 second
		timer.Simple( 1, function() if ( IsValid( ent ) ) then ent:Remove() print("Removed", ent) end end )
		
		-- Make it non solid
		ent:SetNotSolid( true )
		ent:SetMoveType( MOVETYPE_NONE )
		ent:SetNoDraw( true )
		
		-- Send Effect
		local ed = EffectData()
		ed:SetEntity( ent )
		util.Effect( "entity_remove", ed, true, true )
	end	
} );

properties.Add( "nz_editentity", {
	MenuLabel = "Edit Properties..",
	Order = 90010,
	PrependSpacer = true,
	MenuIcon = "icon16/pencil.png",
	
	Filter = function( self, ent, ply ) 

		if ( !IsValid( ent ) ) then return false end
		if ( !ent.Editable ) then return false end
		if nz.Rounds.Data.CurrentState != ROUND_CREATE then return false end
		if ( ent:IsPlayer() ) then return false end
		if ( !ply:IsAdmin() ) then return false end

		return true 

	end,

	Action = function( self, ent )
	
		local window = g_ContextMenu:Add( "DFrame" )
		window:SetSize( 320, 400 )
		window:SetTitle( tostring( ent ) )
		window:Center()
		window:SetSizable( true )

		local control = window:Add( "DEntityProperties" )
		control:SetEntity( ent )
		control:Dock( FILL )

		control.OnEntityLost = function()

			window:Remove()

		end
	end
} );

properties.Add( "nz_lock", {
	MenuLabel = "Edit Lock..",
	Order = 9001,
	PrependSpacer = true,
	MenuIcon = "icon16/lock_edit.png",
	
	Filter = function( self, ent, ply ) 

		if ( !IsValid( ent ) ) then return false end
		if !( ent:IsDoor() or ent:IsButton() or ent:IsBuyableProp() ) then return false end
		if nz.Rounds.Data.CurrentState != ROUND_CREATE then return false end
		if ( ent:IsPlayer() ) then return false end
		if ( !ply:IsAdmin() ) then return false end

		return true 

	end,

	Action = function( self, ent )
		nz.Interfaces.Functions.DoorProps( {door = ent} )
	end
} );

properties.Add( "nz_unlock", {
	MenuLabel = "Unlock",
	Order = 9002,
	PrependSpacer = false,
	MenuIcon = "icon16/lock_delete.png",
	
	Filter = function( self, ent, ply ) 

		if ( !IsValid( ent ) ) then return false end
		if !( ent:IsDoor() or ent:IsButton() or ent:IsBuyableProp() ) then return false end
		if nz.Rounds.Data.CurrentState != ROUND_CREATE then return false end
		if ( ent:IsPlayer() ) then return false end
		if ( !ply:IsAdmin() ) then return false end
		if ent:IsBuyableProp() then
			if ( !nz.Doors.Data.BuyableProps[ent:EntIndex()] ) then return false end
		else
			if ( !nz.Doors.Data.LinkFlags[ent:doorIndex()] ) then return false end
		end

		return true 

	end,

	Action = function( self, ent )

		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
		
	end,
	
	Receive = function( self, length, player )
		local ent = net.ReadEntity()
		
		if ( !IsValid( ent ) ) then return false end
		if ( !IsValid( player ) ) then return false end
		if nz.Rounds.Data.CurrentState != ROUND_CREATE then return false end
		if ( !player:IsAdmin() ) then return false end
		if ( ent:IsPlayer() ) then return false end
		if ( !self:Filter( ent, player ) ) then return false end
		
		nz.Doors.Functions.RemoveLink( ent )
		
	end	
} );

properties.Add( "nz_editzspawn", {
	MenuLabel = "Edit Spawnpoint..",
	Order = 9003,
	PrependSpacer = true,
	MenuIcon = "icon16/link_edit.png",
	
	Filter = function( self, ent, ply ) 

		if ( !IsValid( ent ) ) then return false end
		if ( ent:GetClass() != "zed_spawns" ) then return false end
		if nz.Rounds.Data.CurrentState != ROUND_CREATE then return false end
		if ( ent:IsPlayer() ) then return false end
		if ( !ply:IsAdmin() ) then return false end

		return true 

	end,

	Action = function( self, ent )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,
	
	Receive = function( self, length, player )
		local ent = net.ReadEntity()
		
		if ( !IsValid( ent ) ) then return false end
		if ( !IsValid( player ) ) then return false end
		if nz.Rounds.Data.CurrentState != ROUND_CREATE then return false end
		if ( !player:IsAdmin() ) then return false end
		if ( ent:IsPlayer() ) then return false end
		if ( !self:Filter( ent, player ) ) then return false end
		
		nz.Interfaces.Functions.SendInterface(player, "ZombLink", {ent = ent, link = ent.link, spawnable = ent.spawnable, respawnable = ent.respawnable})
		
	end
} );

properties.Add( "nz_wepbuy", {
	MenuLabel = "Edit Properties..",
	Order = 9004,
	PrependSpacer = true,
	MenuIcon = "icon16/cart_edit.png",
	
	Filter = function( self, ent, ply ) 

		if ( !IsValid( ent ) ) then return false end
		if ( ent:GetClass() != "wall_buys" ) then return false end
		if nz.Rounds.Data.CurrentState != ROUND_CREATE then return false end
		if ( ent:IsPlayer() ) then return false end
		if ( !ply:IsAdmin() ) then return false end

		return true 

	end,

	Action = function( self, ent )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,
	
	Receive = function( self, length, player )
		local ent = net.ReadEntity()
		
		if ( !IsValid( ent ) ) then return false end
		if ( !IsValid( player ) ) then return false end
		if nz.Rounds.Data.CurrentState != ROUND_CREATE then return false end
		if ( !player:IsAdmin() ) then return false end
		if ( ent:IsPlayer() ) then return false end
		if ( !self:Filter( ent, player ) ) then return false end
		
		nz.Interfaces.Functions.SendInterface(player, "WepBuy", {vec = ent:GetPos(), ang = ent:GetAngles(), ent = ent})
		
	end
} );

properties.Add( "nz_editperk", {
	MenuLabel = "Edit Perk..",
	Order = 9005,
	PrependSpacer = true,
	MenuIcon = "icon16/tag_blue_edit.png",
	
	Filter = function( self, ent, ply ) 

		if ( !IsValid( ent ) ) then return false end
		if ( ent:GetClass() != "perk_machine" ) then return false end
		if nz.Rounds.Data.CurrentState != ROUND_CREATE then return false end
		if ( ent:IsPlayer() ) then return false end
		if ( !ply:IsAdmin() ) then return false end

		return true 

	end,

	Action = function( self, ent )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,
	
	Receive = function( self, length, player )
		local ent = net.ReadEntity()
		
		if ( !IsValid( ent ) ) then return false end
		if ( !IsValid( player ) ) then return false end
		if nz.Rounds.Data.CurrentState != ROUND_CREATE then return false end
		if ( !player:IsAdmin() ) then return false end
		if ( ent:IsPlayer() ) then return false end
		if ( !self:Filter( ent, player ) ) then return false end
		
		nz.Interfaces.Functions.SendInterface(player, "PerkMachine", {ent = ent})
		
	end
} );

properties.Add( "nz_invisblockeditxp", {
	MenuLabel = "Increase X",
	Order = 8001,
	PrependSpacer = true,
	MenuIcon = "icon16/arrow_up.png",
	
	Filter = function( self, ent, ply ) 

		if ( !IsValid( ent ) ) then return false end
		if ( ent:GetClass() != "wall_block" ) then return false end
		if nz.Rounds.Data.CurrentState != ROUND_CREATE then return false end
		if ( ent:IsPlayer() ) then return false end
		if ( !ply:IsAdmin() ) then return false end

		return true 

	end,

	Action = function( self, ent )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,
	
	Receive = function( self, length, player )
		local ent = net.ReadEntity()
		
		if ( !IsValid( ent ) ) then return false end
		if ( !IsValid( player ) ) then return false end
		if nz.Rounds.Data.CurrentState != ROUND_CREATE then return false end
		if ( !player:IsAdmin() ) then return false end
		if ( ent:IsPlayer() ) then return false end
		if ( !self:Filter( ent, player ) ) then return false end
		
		ent:IncreaseXModel(player)
		
	end
} );

properties.Add( "nz_invisblockeditxm", {
	MenuLabel = "Decrease X",
	Order = 8002,
	PrependSpacer = false,
	MenuIcon = "icon16/arrow_down.png",
	
	Filter = function( self, ent, ply ) 

		if ( !IsValid( ent ) ) then return false end
		if ( ent:GetClass() != "wall_block" ) then return false end
		if nz.Rounds.Data.CurrentState != ROUND_CREATE then return false end
		if ( ent:IsPlayer() ) then return false end
		if ( !ply:IsAdmin() ) then return false end

		return true 

	end,

	Action = function( self, ent )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,
	
	Receive = function( self, length, player )
		local ent = net.ReadEntity()
		
		if ( !IsValid( ent ) ) then return false end
		if ( !IsValid( player ) ) then return false end
		if nz.Rounds.Data.CurrentState != ROUND_CREATE then return false end
		if ( !player:IsAdmin() ) then return false end
		if ( ent:IsPlayer() ) then return false end
		if ( !self:Filter( ent, player ) ) then return false end
		
		ent:DecreaseXModel(player)
		
	end
} );

properties.Add( "nz_invisblockedityp", {
	MenuLabel = "Increase Y",
	Order = 8003,
	PrependSpacer = false,
	MenuIcon = "icon16/arrow_right.png",
	
	Filter = function( self, ent, ply ) 

		if ( !IsValid( ent ) ) then return false end
		if ( ent:GetClass() != "wall_block" ) then return false end
		if nz.Rounds.Data.CurrentState != ROUND_CREATE then return false end
		if ( ent:IsPlayer() ) then return false end
		if ( !ply:IsAdmin() ) then return false end

		return true 

	end,

	Action = function( self, ent )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,
	
	Receive = function( self, length, player )
		local ent = net.ReadEntity()
		
		if ( !IsValid( ent ) ) then return false end
		if ( !IsValid( player ) ) then return false end
		if nz.Rounds.Data.CurrentState != ROUND_CREATE then return false end
		if ( !player:IsAdmin() ) then return false end
		if ( ent:IsPlayer() ) then return false end
		if ( !self:Filter( ent, player ) ) then return false end
		
		ent:IncreaseYModel(player)
		
	end
} );

properties.Add( "nz_invisblockeditym", {
	MenuLabel = "Decrease Y",
	Order = 8004,
	PrependSpacer = false,
	MenuIcon = "icon16/arrow_left.png",
	
	Filter = function( self, ent, ply ) 

		if ( !IsValid( ent ) ) then return false end
		if ( ent:GetClass() != "wall_block" ) then return false end
		if nz.Rounds.Data.CurrentState != ROUND_CREATE then return false end
		if ( ent:IsPlayer() ) then return false end
		if ( !ply:IsAdmin() ) then return false end

		return true 

	end,

	Action = function( self, ent )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,
	
	Receive = function( self, length, player )
		local ent = net.ReadEntity()
		
		if ( !IsValid( ent ) ) then return false end
		if ( !IsValid( player ) ) then return false end
		if nz.Rounds.Data.CurrentState != ROUND_CREATE then return false end
		if ( !player:IsAdmin() ) then return false end
		if ( ent:IsPlayer() ) then return false end
		if ( !self:Filter( ent, player ) ) then return false end
		
		ent:DecreaseYModel(player)
		
	end
} );

properties.Add( "nz_invisblockeditzp", {
	MenuLabel = "Increase Z",
	Order = 8005,
	PrependSpacer = false,
	MenuIcon = "icon16/arrow_out.png",
	
	Filter = function( self, ent, ply ) 

		if ( !IsValid( ent ) ) then return false end
		if ( ent:GetClass() != "wall_block" ) then return false end
		if nz.Rounds.Data.CurrentState != ROUND_CREATE then return false end
		if ( ent:IsPlayer() ) then return false end
		if ( !ply:IsAdmin() ) then return false end

		return true 

	end,

	Action = function( self, ent )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,
	
	Receive = function( self, length, player )
		local ent = net.ReadEntity()
		
		if ( !IsValid( ent ) ) then return false end
		if ( !IsValid( player ) ) then return false end
		if nz.Rounds.Data.CurrentState != ROUND_CREATE then return false end
		if ( !player:IsAdmin() ) then return false end
		if ( ent:IsPlayer() ) then return false end
		if ( !self:Filter( ent, player ) ) then return false end
		
		ent:IncreaseZModel(player)
		
	end
} );

properties.Add( "nz_invisblockeditzm", {
	MenuLabel = "Decrease Z",
	Order = 8006,
	PrependSpacer = false,
	MenuIcon = "icon16/arrow_in.png",
	
	Filter = function( self, ent, ply ) 

		if ( !IsValid( ent ) ) then return false end
		if ( ent:GetClass() != "wall_block" ) then return false end
		if nz.Rounds.Data.CurrentState != ROUND_CREATE then return false end
		if ( ent:IsPlayer() ) then return false end
		if ( !ply:IsAdmin() ) then return false end

		return true 

	end,

	Action = function( self, ent )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,
	
	Receive = function( self, length, player )
		local ent = net.ReadEntity()
		
		if ( !IsValid( ent ) ) then return false end
		if ( !IsValid( player ) ) then return false end
		if nz.Rounds.Data.CurrentState != ROUND_CREATE then return false end
		if ( !player:IsAdmin() ) then return false end
		if ( ent:IsPlayer() ) then return false end
		if ( !self:Filter( ent, player ) ) then return false end
		
		ent:DecreaseZModel(player)
		
	end
} );
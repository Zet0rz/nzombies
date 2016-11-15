
ENT.Sound				= {}
ENT.Sound.Blip			= "Grenade.Blip"
ENT.Sound.Explode		= "BaseGrenade.Explode"

ENT.Trail				= {}
ENT.Trail.Color			= Color( 255, 0, 0, 255 )
ENT.Trail.Material		= "sprites/bluelaser1.vmt"
ENT.Trail.StartWidth	= 8.0
ENT.Trail.EndWidth		= 1.0
ENT.Trail.LifeTime		= 0.5

// Nice helper function, this does all the work.

/*---------------------------------------------------------
   Name: DoExplodeEffect
---------------------------------------------------------*/
function ENT:DoExplodeEffect()

	local info = EffectData();
	info:SetEntity( self.Entity );
	info:SetOrigin( self.Entity:GetPos() );

	util.Effect( "Explosion", info );

end

/*---------------------------------------------------------
   Name: OnExplode
   Desc: The grenade has just exploded.
---------------------------------------------------------*/
function ENT:OnExplode( pTrace )

	local Pos1 = pTrace.HitPos + pTrace.HitNormal
	local Pos2 = pTrace.HitPos - pTrace.HitNormal

 	util.Decal( "Scorch", Pos1, Pos2 );

end

/*---------------------------------------------------------
   Name: OnInitialize
---------------------------------------------------------*/
function ENT:OnInitialize()
end

/*---------------------------------------------------------
   Name: StartTouch
---------------------------------------------------------*/
function ENT:StartTouch( entity )
end

/*---------------------------------------------------------
   Name: EndTouch
---------------------------------------------------------*/
function ENT:EndTouch( entity )
end

/*---------------------------------------------------------
   Name: Touch
---------------------------------------------------------*/
function ENT:Touch( entity )
end

/*---------------------------------------------------------
   Name: OnThink
---------------------------------------------------------*/
function ENT:OnThink()
end
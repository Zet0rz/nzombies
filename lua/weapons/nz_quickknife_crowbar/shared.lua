
	-- Weapon base courtesy of CptFuzzies SWEP Bases project
	-- Recoded to do more balanced damage

SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModelFOV	= 54
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/c_crowbar.mdl"
SWEP.WorldModel		= "models/weapons/w_crowbar.mdl"
SWEP.AnimPrefix		= "crowbar"
SWEP.HoldType		= "melee"

SWEP.UseHands = true

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

CROWBAR_RANGE	= 75.0
CROWBAR_REFIRE	= 0.4

SWEP.Primary.Sound			= Sound( "Weapon_Crowbar.Single" )
SWEP.Primary.Hit			= Sound( "Weapon_Crowbar.Melee_Hit" )
SWEP.Primary.Range			= CROWBAR_RANGE
SWEP.Primary.Damage			= 75
SWEP.Primary.DamageType		= DMG_CLUB
SWEP.Primary.Force			= 0.75
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Delay			= CROWBAR_REFIRE
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "None"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "None"



/*---------------------------------------------------------
   Name: SWEP:Initialize( )
   Desc: Called when the weapon is first loaded
---------------------------------------------------------*/
function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
end


/*---------------------------------------------------------
   Name: SWEP:PrimaryAttack( )
   Desc: +attack1 has been pressed
---------------------------------------------------------*/
function SWEP:PrimaryAttack()

	// Only the player fires this way so we can cast
	local pPlayer		= self.Owner;

	if ( !pPlayer ) then
		return;
	end

	// Make sure we can swing first
	if ( !self:CanPrimaryAttack() ) then return end

	local vecSrc		= pPlayer:GetShootPos();
	local vecDirection	= pPlayer:GetAimVector();

	local trace			= {}
		trace.start		= vecSrc
		trace.endpos	= vecSrc + ( vecDirection * self:GetRange() )
		trace.filter	= pPlayer

	local traceHit		= util.TraceLine( trace )

	if ( traceHit.Hit ) then

		self.Weapon:EmitSound( self.Primary.Hit );

		self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER );
		pPlayer:SetAnimation( PLAYER_ATTACK1 );

		self.Weapon:SetNextPrimaryFire( CurTime() + self:GetFireRate() );
		self.Weapon:SetNextSecondaryFire( CurTime() + self.Weapon:SequenceDuration() );

		self:Hit( traceHit, pPlayer );

		return

	end

	self.Weapon:EmitSound( self.Primary.Sound );

	self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER );
	pPlayer:SetAnimation( PLAYER_ATTACK1 );

	self.Weapon:SetNextPrimaryFire( CurTime() + self:GetFireRate() );
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Weapon:SequenceDuration() );

	self:Swing( traceHit, pPlayer );

	return

end


/*---------------------------------------------------------
   Name: SWEP:SecondaryAttack( )
   Desc: +attack2 has been pressed
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
	return false
end

/*---------------------------------------------------------
   Name: SWEP:Reload( )
   Desc: Reload is being pressed
---------------------------------------------------------*/
function SWEP:Reload()
	return false
end

//-----------------------------------------------------------------------------
// Purpose: Get the damage amount for the animation we're doing
// Input  : hitActivity - currently played activity
// Output : Damage amount
//-----------------------------------------------------------------------------
function SWEP:GetDamageForActivity( hitActivity )
	return Round:InProgress() and 30 + (45/Round:GetNumber()) or 75
end

//-----------------------------------------------------------------------------
// Purpose: Add in a view kick for this weapon
//-----------------------------------------------------------------------------
function SWEP:AddViewKick()

	local pPlayer  = self:GetOwner();

	if ( pPlayer == NULL ) then
		return;
	end

	if ( pPlayer:IsNPC() ) then
		return;
	end

	local punchAng = Angle( 0, 0 ,0 );

	punchAng.pitch = math.Rand( 1.0, 2.0 );
	punchAng.yaw   = math.Rand( -2.0, -1.0 );
	punchAng.roll  = 0.0;

	pPlayer:ViewPunch( punchAng );

end


/*---------------------------------------------------------
   Name: SWEP:Deploy( )
   Desc: Whip it out
---------------------------------------------------------*/
function SWEP:Deploy()

	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self:SetDeploySpeed( self.Weapon:SequenceDuration() )

	return true

end


/*---------------------------------------------------------
   Name: SWEP:Hit( )
   Desc: A convenience function to trace impacts
---------------------------------------------------------*/
function SWEP:Hit( traceHit, pPlayer )

	local vecSrc = pPlayer:GetShootPos();

	if ( SERVER ) then
		pPlayer:TraceHullAttack( vecSrc, traceHit.HitPos, Vector( -5, -5, -5 ), Vector( 5, 5, 36 ), self:GetDamageForActivity(), self.Primary.DamageType, self.Primary.Force );
	end

	// self:AddViewKick();

end


/*---------------------------------------------------------
   Name: SWEP:Swing( )
   Desc: A convenience function to trace impacts
---------------------------------------------------------*/
function SWEP:Swing( traceHit, pPlayer )
end


/*---------------------------------------------------------
   Name: SWEP:CanPrimaryAttack( )
   Desc: Helper function for checking for no ammo
---------------------------------------------------------*/
function SWEP:CanPrimaryAttack()
	return true
end


/*---------------------------------------------------------
   Name: SWEP:CanSecondaryAttack( )
   Desc: Helper function for checking for no ammo
---------------------------------------------------------*/
function SWEP:CanSecondaryAttack()
	return false
end


/*---------------------------------------------------------
   Name: SetDeploySpeed
   Desc: Sets the weapon deploy speed.
		 This value needs to match on client and server.
---------------------------------------------------------*/
function SWEP:SetDeploySpeed( speed )

	self.m_WeaponDeploySpeed = tonumber( speed / GetConVarNumber( "phys_timescale" ) )

	self.Weapon:SetNextPrimaryFire( CurTime() + speed )
	self.Weapon:SetNextSecondaryFire( CurTime() + speed )

end



//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
function SWEP:Drop( vecVelocity )
if ( !CLIENT ) then
	self:Remove();
end
end

function SWEP:GetRange()
	return	self.Primary.Range;
end

function SWEP:GetFireRate()
	return	self.Primary.Delay;
end


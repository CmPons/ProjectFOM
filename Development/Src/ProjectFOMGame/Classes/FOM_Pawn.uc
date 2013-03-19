/*
 * This is the base Pawn class for FOM.
 * 
 * Author: Christopher Pons
 */
class FOM_Pawn extends UDKPawn
	HideCategories(Movement, Camera, Object, Mobile, TeamBeacon, Swimming, UDKPawn)
	config(Game);

// Light environment component used by the pawn mesh
var(Pawn) const LightEnvironmentComponent LightEnvironment;
// The maximum ground speed when only strafing
var(Pawn) const int StrafeSpeed;
// The maximum ground speed when BackPedaling
var(Pawn) const int BackPedalSpeed;
// The Pawns ground speed when running forward
var(Pawn) const int PawnGroundSpeed;
// The Pawns accel rate
var(Pawn) const int DefaultAccelRate;

// True if the pawn is currently sliding;
var bool bSliding;

simulated function PostBeginPlay()
{
	if(Role == Role_Authority)
	{
		SetDefaults();
	}
}

function SetDefaults()
{
	GroundSpeed = PawnGroundSpeed;
	AccelRate = DefaultAccelRate;
}

simulated function bool CalcCamera(float DeltaTime, out Vector out_CamLoc, out Rotator out_CamRot, out float out_FOV)
{
	GetActorEyesViewPoint(out_CamLoc, out_CamRot);

	return true;
}

simulated function SetAccelRate(int NewAccelRate)
{
	if(Role < Role_Authority)
	{
		ServerSetAccelRate(NewAccelRate);
	}

	DoSetAccelRate(NewAccelRate);
}

reliable server function ServerSetAccelRate(int NewAccelRate)
{
	DoSetAccelRate(NewAccelRate);
}

simulated function DoSetAccelRate(int NewAccelRate)
{
	AccelRate = NewAccelRate;
}

simulated function SetSliding(bool bNewSliding)
{
	if(Role < Role_Authority)
	{
		ServerSetSliding(bNewSliding);
	}

	DoSetSliding(bNewSliding);
}

reliable server function ServerSetSliding(bool bNewSliding)
{
	DoSetSliding(bNewSliding);
}

simulated function DoSetSliding(bool bNewSliding)
{
	bSliding = bNewSliding;
}

simulated function SetCrouchSpeedPct(float NewCrouchSpeedPct)
{
	if(Role < Role_Authority)
	{
		ServerSetCrouchSpeedPct(NewCrouchSpeedPct);
	}

	DoSetCrouchSpeedPct(NewCrouchSpeedPct);
}

reliable server function ServerSetCrouchSpeedPct(float NewCrouchSpeedPct)
{
	DoSetCrouchSpeedPct(NewCrouchSpeedPct);
}

simulated function 	DoSetCrouchSpeedPct(float NewCrouchSpeedPct)
{
	CrouchedPct = NewCrouchSpeedPct;
}

simulated function FaceRotation(rotator NewRotation, float DeltaTime)
{
	if(bSliding)
	{
		return;
	}

	Super.FaceRotation(NewRotation, DeltaTime);
}


simulated function SetPlayerSpeed()
{
	if(Role < Role_Authority)
	{
		ServerSetPlayerSpeed();
	}

	DoSetPlayerSpeed();
}

unreliable server function ServerSetPlayerSpeed()
{
	DoSetPlayerSpeed();
}

simulated function DoSetPlayerSpeed()
{
	if(IsStrafing() && GroundSpeed != StrafeSpeed)
	{
		GroundSpeed = StrafeSpeed;
	}
	else if(IsBackPedaling() && GroundSpeed != BackPedalSpeed)
	{
		GroundSpeed = BackPedalSpeed;
	}
	else if(IsRunningForward() && GroundSpeed != PawnGroundSpeed)
	{
		GroundSpeed = PawnGroundSpeed;
	}
}

/*
 * This returns true if the playe is currently running forward
 */
simulated function bool IsRunningForward()
{
	return !IsZero(Velocity) && Normal(Velocity) dot Vector(Rotation) > 0.15;
}

/*
 * This returns true if the pawn is currently strafing.
 */
simulated function bool IsStrafing()
{
	local float DotProduct;

	DotProduct = Normal(Velocity) dot Vector(Rotation);

	return !IsZero(Velocity) && DotProduct >= -0.15 && DotProduct <= 0.15;
}

/*
 * This returns true if the pawn is currently backpedaling
 */
simulated function bool IsBackPedaling()
{
	local float DotProduct;

	DotProduct = Normal(Velocity) dot Vector(Rotation);

	return DotProduct < -0.7;
}

/*
* Return the Pawn's viewing location with the current eye height taken into account
* 
* @network              Server and client
*/
simulated event vector GetPawnViewLocation()
{
    if(bUpdateEyeHeight)
    {
        return Location + EyeHeight * vect(0, 0, 1);
    }
    else
    {
        return Location + BaseEyeHeight * vect(0, 0, 1);
    }
}

/*
* If we are the local player, set bUpdateEyeHeight to true so that UpdatEyeHeight gets called
* 
* @param        PC      The PC who owns this pawn
* @network              Server and client
*/
simulated event BecomeViewTarget(PlayerController PC)
{
    super.BecomeViewTarget(PC);
    
    if(LocalPlayer(PC.Player) != none)
    {
        bUpdateEyeHeight = true;
    }
}

/*
* Update the eye height from it's current value (EyeHeight) to the target value BaseEyeHeight over a period of time
* 
* @network              Server
*/
event UpdateEyeHeight(float DeltaTime)
{
    if(bTearOff)
    {
        EyeHeight = default.BaseEyeHeight;
        bUpdateEyeHeight=false;
        return;
    }
    
    EyeHeight = FInterpTo(EyeHeight, BaseEyeHeight, DeltaTime, 10.0);
}

simulated function DisplayDebug(HUD HUd, out float out_YL, out float out_YPos)
{
	local Canvas Canvas;

	Canvas = HUD.Canvas;

	Super.DisplayDebug(HUD, out_YL, out_YPos);

	Canvas.SetDrawColor(255, 255, 255);

	Canvas.DrawText("BackPedaling?" @ IsBackPedaling());
	out_YPos += out_YL;
	Canvas.SetPos(4, out_YPos);

	Canvas.DrawText("Strafing?" @ IsStrafing());
	out_YPos += out_YL;
	Canvas.SetPos(4, out_YPos);

	Canvas.DrawText("Running Forward?" @ IsRunningForward());
	out_YPos += out_YL;
	Canvas.SetPos(4, out_YPos);

	Canvas.DrawText("Velocity Dot Rotation" @ Normal(Velocity) dot Vector(Rotation));
	out_YPos += out_YL;
	Canvas.SetPos(4, out_YPos);

	Canvas.DrawText("GroundSpeed" @ GroundSpeed);
	out_YPos += out_YL;
	Canvas.SetPos(4, out_YPos);
}

DefaultProperties
{
	Components.Remove(Sprite)

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bSynthesizeSHLight=true
		bIsCharacterLightEnvironment=true
		bUseBooleanEnvironmentShadowing=false
		InvisibleUpdateTime=1.f
		MinTimeBetweenFullUpdates=0.2f
	End Object
	LightEnvironment=MyLightEnvironment
	Components.Add(MyLightEnvironment)

	Begin Object Class=SkeletalMeshComponent Name=MySkeletalMeshComponent
		SkeletalMesh=SkeletalMesh'FOM_Game_Resources.DefaultCharacter.SK_DefaultCharacter'
		bCacheAnimSequenceNodes=false
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		CastShadow=true
		BlockRigidBody=true
		bUpdateSkelWhenNotRendered=true
		bIgnoreControllersWhenNotRendered=false
		bUpdateKinematicBonesFromAnimation=true
		bCastDynamicShadow=true
		RBChannel=RBCC_Untitled3
		RBCollideWithChannels=(Untitled3=true)
		LightEnvironment=MyLightEnvironment
		bAcceptsDynamicDecals=false
		bHasPhysicsAssetInstance=true
		TickGroup=TG_PreAsyncWork
		MinDistFactorForKinematicUpdate=0.2f
		bChartDistanceFactor=true
		RBDominanceGroup=20
		bUseOnePassLightingOnTranslucency=true
		bPerBoneMotionBlur=true
		bOwnerNoSee=true
	End Object
	Mesh=MySkeletalMeshComponent
	Components.Add(MySkeletalMeshComponent)

	Begin Object Name=CollisionCylinder
		CollisionRadius=+0021.000000
		CollisionHeight=+0044.000000
	End Object
	CylinderComponent=CollisionCylinder


	WalkingPct=+0.4
	CrouchedPct=+0.4
	BaseEyeHeight=38.0
	EyeHeight=38.0
	GroundSpeed=600.0
	PawnGroundSpeed=600
	DefaultAccelRate=256.0
	StrafeSpeed=200
	BackPedalSpeed=200
	AirSpeed=600.0
	WaterSpeed=440.0
	AccelRate=256.0
	JumpZ=322.0
	CrouchHeight=29.0
	CrouchRadius=21.0
	WalkableFloorZ=0.78

	bCanCrouch=true

	bCollideActors=true
	bBlockActors=true
	bCollideWorld=true
}
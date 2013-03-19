/*
 * This is the base PlayerController class for FOM.
 * 
 * Author: Christopher Pons
 */
class FOM_PlayerController extends PlayerController
	config(Game);

// This is the class which handles the different moves a player can perform
var FOM_MoveManager MoveManagerArchetype;
var FOM_MoveManager MoveManager;
var float StopAccelRate;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	MoveManager = Spawn(MoveManagerArchetype.Class,,,,, MoveManagerArchetype);

	if(MoveManager != none)
	{
		MoveManager.Init(Self);
	}
}

function CheckJumpOrDuck()
{
	if(Pawn == none)
	{
		return;
	}

	Super.CheckJumpOrDuck();

	if(Pawn.Physics != PHYS_Falling && Pawn.bCanCrouch)
	{
		Pawn.ShouldCrouch(bool(bDuck));
	}
}

// This function forwards the NewAction to the MoveManager
function RequestPerformAction(String NewAction)
{
	if(MoveManager != none)
	{
		MoveManager.RequestPerformAction(NewAction);
	}
}

event bool NotifyHitWall(Vector HitNormal, Actor Wall)
{
	if(MoveManager != none)
	{
		MoveManager.NotifyHitWall(HitNormal, Wall);
	}	
	return false;
}

event bool NotifyLanded(Vector HitNormal, Actor FloorActor)
{
	if(MoveManager != none)
	{
		MoveManager.NotifyLanded(HitNormal, FloorActor);
	}	
	return false;
}

event NotifyFallingHitWall(Vector HitNormal, Actor Wall);
event bool NotifyBump(Actor Other, Vector HitNormal);
event NotifyJumpApex();
event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal);

state PlayerWalking
{
	function PlayerMove(float DeltaTime)
	{
		local FOM_Pawn FOMPawn;
		local vector			X,Y,Z, NewAccel;
		local eDoubleClickDir	DoubleClickMove;
		local rotator			OldRotation;
		local bool				bSaveJump;

		FOMPawn = FOM_Pawn(Pawn);

		if( FOMPawn == None )
		{
			GotoState('Dead');
		}
		else
		{
			FOMPawn.SetPlayerSpeed();

			GetAxes(Pawn.Rotation,X,Y,Z);

			if(PlayerInput.aForward != 0)
			{
				StopAccelRate = Pawn.AccelRate;
			}

			NewAccel = PlayerInput.aForward*X + PlayerInput.aStrafe*Y;
			NewAccel.Z	= 0;
			NewAccel = Pawn.AccelRate * Normal(NewAccel);

			if (IsLocalPlayerController())
			{
				AdjustPlayerWalkingMoveAccel(NewAccel);
			}

			DoubleClickMove = PlayerInput.CheckForDoubleClickMove( DeltaTime/WorldInfo.TimeDilation );

			// Update rotation.
			OldRotation = Rotation;
			UpdateRotation( DeltaTime );
			bDoubleJump = false;

			if( bPressedJump && Pawn.CannotJumpNow() )
			{
				bSaveJump = true;
				bPressedJump = false;
			}
			else
			{
				bSaveJump = false;
			}

			if( Role < ROLE_Authority ) // then save this move and replicate it
			{
				ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
			}
			else
			{
				ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
			}
			bPressedJump = bSaveJump;
		}
	}
}

DefaultProperties
{
	MoveManagerArchetype=FOM_MoveManager'FOM_Engine_Resources.MoveSystem.MoveManager'

	InputClass=class'ProjectFOMGame.FOM_PlayerInput'
	bNotifyFallingHitWall=true
	bNotifyApex=true;
	bNotifyPostLanded=true

	MinHitWall=0
}
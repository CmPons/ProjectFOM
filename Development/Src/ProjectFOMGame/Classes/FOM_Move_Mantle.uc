class FOM_Move_Mantle extends FOM_Move;

// This is how close a player needs to be for a mantle request to be valid. This is in unreal units.
var() float MinDistanceToMantleObject;
// This is the maximum height a mantle object can be so that we can move over it. This is in unreal units.
var() float MaxMantleHeight;
// This is the maximum width a mantle object can be. This is in unreal units. 
var() float MaxMantleWidth;

function array< class<FOM_Move> > GetNextMove()
{
	local array< class<FOM_Move> > PossibleMoves;

	if(RequestedAction == NO_ACTION && bMoveJustFinished)
	{
		PossibleMoves.AddItem(ParentMoveClass);
	}

	return PossibleMoves;
}

function bool CanDoMove()
{
	return Super.CanDoMove() && ValidMantleObject() &&  PCOwner.Pawn.Physics != PHYS_Falling;
}

// This function returns true if the pawn can mantle the object
function bool ValidMantleObject()
{
	if(MoveManager == none || PCowner == none || PCOwner.Pawn == none)
	{
		return false;
	}

	return IsCloseEnoughToMantle() && MantleIsCorrectHeightAndWidth();
}

/*
 * This function returns true of the player is close enough to object they want to mantle over
 * @return          True if player is close enough to object to mantle
 */
function bool IsCloseEnoughToMantle()
{
	local Vector X, Y, Z, StartTrace, EndTrace;

	GetAxes(PCOwner.Pawn.Rotation, X, Y, Z);

	StartTrace = PCOwner.Pawn.Location;
	EndTrace = StartTrace + X * MinDistanceToMantleObject;

	MoveManager.DrawDebugLine(StartTrace, EndTrace, 255, 0, 0, true);
	return !MoveManager.DoFastTrace(EndTrace, StartTrace);
}

/*
 * This function checks to make sure that the height and width of the mantle object is correct
 * @return              True if height and with are within allowed limits
 */
function bool MantleIsCorrectHeightAndWidth()
{
	local bool bIsCorrectHeight, bIsCorrectWidth;
	local vector X, Y, Z, StartTrace, EndTrace;
	local Vector PawnEyeLocation, HitLocation, HitNormal;
	local Rotator PawnEyeRotation;
	local int CurrentMantleTraceHeight, MantleHeightTraceOffset, MantleHeightTraceIncrement;
	local int MantleWidthTraceOffset, MantleWidthTraceIncrement;

	MantleHeightTraceIncrement = 4;
	MantleWidthTraceIncrement = 8;
	
	GetAxes(PCOwner.Pawn.Rotation, X, Y, Z);

	// Check the height of the object
	// We will start from the center of the player and work up. We will trace every 4 units up. If the height of the mantle object is higher than our maximum mantle
	// height we will return false. If we fail to hit anything and the mantle object is still within limts we will break out and check the width.
	// For this we assume that since the location of the pawn starts from the center that since the pawn is 96 units high, our trace will start at 48 units off the floor.
	CurrentMantleTraceHeight = 48;
	MantleHeightTraceOffset = 0;
	StartTrace = PCOwner.Pawn.Location;

	// We want to trace one above the MaxMantleHeight to make sure we don't hit anything. If we didn't do this the while loop would exit out after we incremented the variables after
	// we hit the mantle object.
	while( CurrentMantleTraceHeight <= MaxMantleHeight + MantleHeightTraceIncrement )
	{
		StartTrace += Z * MantleHeightTraceOffset;
		EndTrace = StartTrace + X * MinDistanceToMantleObject;

		MoveManager.DrawDebugLine(StartTrace, EndTrace, 255, 0, 0, true);
		// FastTrace returns true if we haven't hit anything
		if(MoveManager.DoFastTrace(EndTrace, StartTrace))
		{
			bIsCorrectHeight = true;
			break;
		}
		// Otherwise we hit something, increment our variables
		MantleHeightTraceOffset += MantleHeightTraceIncrement;
		CurrentMantleTraceHeight += MantleHeightTraceOffset;
	}

	// Check the width of the object
	MantleWidthTraceOffset = 0;

	// To check the mantle object width we start our traces at pawn eye height level directly above the mantle object. We then trace down 48uu. If this trace returns false, indicating
	// we hit world geometry we will trace again 8 units farther away from the pawn. We will continue this until MantleWidthTraceOffset is greater than the MaxMantleWidth or we do not hit 
	// world geometry	
	// Find how far away we are from the mantle object
	PCOwner.Pawn.GetActorEyesViewPoint(PawnEyeLocation, PawnEyeRotation);
	StartTrace = PCOwner.Pawn.Location;
	EndTrace = StartTrace + X * MinDistanceToMantleObject;
	MoveManager.DoTrace(HitLocation, HitNormal, EndTrace, StartTrace);
	MoveManager.DrawDebugLine(StartTrace, EndTrace, 0, 255, 0, true);

	if( !IsZero(HitLocation) )
	{
		while(MantleWidthTraceOffset <= MaxMantleWidth + MantleWidthTraceIncrement)
		{
			StartTrace = PawnEyeLocation + X * (PCOwner.Pawn.Location - HitLocation) + X * MantleWidthTraceOffset;
			EndTrace = HitLocation + X * MantleWidthTraceOffset;

			MoveManager.DrawDebugLine(StartTrace, EndTrace, 255, 0, 0, true);
			
			// Make sure we don't quit out early if our first trace doesn't hit anything
			if(MoveManager.DoFastTrace(EndTrace, StartTrace) && MantleWidthTraceOffset != 0 )
			{
				bIsCorrectWidth = true;
				break;
			}

			MantleWidthTraceOffset += MantleWidthTraceIncrement;
		}
	}

	return bIsCorrectHeight && bIsCorrectWidth;
}

function PrePerformMove();

function PerformMove()
{
	`trace(, `yellow);
	FinishMantle();
}

function FinishMantle()
{
	PostPerformMove();
	NotifyManagerMoveFinished();
}

function PostPerformMove()
{
	RequestedAction = NO_ACTION;
	bMoveJustFinished = true;
}


DefaultProperties
{
	MovePriority=2.0
	MinDistanceToMantleObject=32;
	MaxMantleHeight=48
	MaxMantleWidth=32
}

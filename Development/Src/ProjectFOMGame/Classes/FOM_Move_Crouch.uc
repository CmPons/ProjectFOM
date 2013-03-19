class FOM_Move_Crouch extends FOM_Move;

// This is the maximum speed the pawn can be travelling in order to allow the pawn to crouch
var() int MaximumSpeedToCrouch;
// The percentage of the pawn's ground speed to use when crouched
var float PercentGroundSpeedCrouched;

function array< class<FOM_Move> > GetNextMove()
{
	local array< class<FOM_Move> > PossibleMoves;

	if(RequestedAction == STOP_DOWN_ACTION)
	{
		PostPerformMove();
		PossibleMoves.AddItem(ParentMoveClass);
	}

	return PossibleMoves;
}


function bool CanDoMove()
{
	return Super.CanDoMove() && PCOwner.Pawn.Physics != PHYS_Falling && VSize(PCOwner.Pawn.Velocity) <= MaximumSpeedToCrouch;
}

function PrePerformMove()
{
	local FOM_Pawn FOMPawn;

	FOMPawn = FOM_Pawn(PCOwner.Pawn);

	if(FOMPawn != none)
	{
		FOMPawn.SetCrouchSpeedPct(PercentGroundSpeedCrouched);
	}
}

function PerformMove()
{
	`trace(, `yellow);
	if(PCOwner != none && PCOwner.Pawn != none && PCOwner.Pawn.Physics != PHYS_Falling)
	{
		PCOwner.bDuck = 1;
	}
}

function PostPerformMove()
{
	bMoveJustFinished = true;
	PCOwner.bDuck = 0;
}


DefaultProperties
{
	PercentGroundSpeedCrouched=0.4
	MaximumSpeedToCrouch=0
}

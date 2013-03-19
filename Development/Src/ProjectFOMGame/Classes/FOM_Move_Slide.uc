class FOM_Move_Slide extends FOM_Move;

// This is the minimum speed the pawn should be traveling in order to be able to slide. THIS MUST BE GREATER THAN MaximumSpeedToCrouch in FOM_Move_Crouch.
var() int MinimumSpeedToSlide;
// The duration of the slide in second;
var() float SlideDuration;

// The percentage of the ground speed to use when sliding
var float PercentGroundSpeedSliding;

var FOM_Move_Timer SlideTimer;

function Init(FOM_PlayerController NewOwner)
{
	Super.Init(NewOwner);
	if(MoveManager != none)
	{
		SlideTimer = MoveManager.SpawnNewTimer();
	}
}

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
	return Super.CanDoMove() && PCOwner.Pawn.Physics != PHYS_Falling && VSize(PCOwner.Pawn.Velocity) >= MinimumSpeedToSlide;
}

function PrePerformMove()
{
	local FOM_Pawn FOMPawn;

	FOMPawn = FOM_Pawn(PCOwner.Pawn);

	if(FOMPawn != none)
	{
		FOMPawn.SetSliding(true);
		FOMPawn.SetCrouchSpeedPct(PercentGroundSpeedSliding);
	}
}

function PerformMove()
{
	local FOM_Pawn FOMPawn;

	`trace(, `yellow);

	if(PCOwner == none)
	{
		return;
	}

	FOMPawn = FOM_Pawn(PCOwner.Pawn);

	if(SlideTimer != none && FOMPawn != none && PCOwner.Pawn.Physics != PHYS_Falling)
	{
		PCOwner.bDuck = 1;
		
		if(SlideTimer.IsTimerActive())
		{
			SlideTimer.ClearMoveTimer();
		}

		SlideTimer.MoveFunctionToCall = FinishSlide;
		SlideTimer.SetNewTimer(SlideDuration, false);
	}
}

function FinishSlide()
{
	PostPerformMove();
	NotifyManagerMoveFinished();
}

function PostPerformMove()
{
	local FOM_Pawn FOMPawn;

	bMoveJustFinished = true;
	PCOwner.bDuck = 0;
	RequestedAction = NO_ACTION;

	FOMPawn = FOM_Pawn(PCOwner.Pawn);

	if(FOMPawn != none)
	{
		FOMPawn.SetSliding(false);
	}
}


DefaultProperties
{
	SlideDuration=0.5
	PercentGroundSpeedSliding=1.0
	MinimumSpeedToSlide=200;
}

class FOM_Move_Jump extends FOM_Move;

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
	return Super.CanDoMove() && PCOwner.Pawn.Physics != PHYS_Falling;
}

function PrePerformMove();

function PerformMove()
{
	`trace(, `yellow);
	if(PCOwner != none && PCOwner.Pawn != none && PCOwner.Pawn.Physics != PHYS_Falling)
	{
		PCOwner.bPressedJump = true;
	}
}

function PostPerformMove()
{
	RequestedAction = NO_ACTION;
	bMoveJustFinished = true;
}

event NotifyLanded(Vector HitNormal, Actor FloorActor)
{
	PostPerformMove();
	NotifyManagerMoveFinished();
}

DefaultProperties
{
	MovePriority=1.0
}

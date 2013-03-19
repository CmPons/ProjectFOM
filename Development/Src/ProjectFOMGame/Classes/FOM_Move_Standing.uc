class FOM_Move_Standing extends FOM_Move;

function bool CanDoMove()
{
	return true;
}

function array< class<FOM_Move> > GetNextMove()
{
	local array< class<FOM_Move> > Moves;

	if(RequestedAction == UP_ACTION)
	{
		Moves = PotentialUpActionMoves;
	}
	else if(RequestedAction == DOWN_ACTION)
	{
		Moves = PotentialDownActionMoves;
	}

	return Moves;
}

function PrePerformMove();
function PerformMove()
{
	`trace(, `yellow);
}

function PostPerformMove();

DefaultProperties
{
	bIsDefaultMoveState=true
}

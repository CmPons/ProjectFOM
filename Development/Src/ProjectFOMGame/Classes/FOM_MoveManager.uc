class FOM_MoveManager extends Actor
	HideCategories(Movement, Camera, Object, Mobile, TeamBeacon, Swimming, UDKPawn, Physics, Display, Debug, Collision, Attachment, Advanced);

// This holds all of the current moves available to the player
var() const editinline instanced Array<FOM_Move> MoveArray;

// The index of the current Move
var int CurrentMoveIndex;
// The PlayerController who owns this MoveManager
var FOM_PlayerController PCOwner;

function Init(FOM_PlayerController NewOwner)
{
	local int i;

	for(i = 0; i < MoveArray.Length; i++)
	{
		MoveArray[i].Init(NewOwner);

		if(MoveArray[i].IsDefaultMoveState())
		{
			CurrentMoveIndex = i;
			MoveArray[CurrentMoveIndex].SetMoveActive(true);
		}
	}
}

function RequestPerformAction(String NewAction)
{
	MoveArray[CurrentMoveIndex].RequestPerformAction(NewAction);
	QueryNextMove();
}

function QueryNextMove()
{
	local array< class<FOM_Move> > PossibleMoves;
	local int NextMoveIndex;

	PossibleMoves = MoveArray[CurrentMoveIndex].GetNextMove();
	
	NextMoveIndex = FindNextMove(PossibleMoves);

	if(NextMoveIndex != -1)
	{
		PerformNextMove(NextMoveIndex);
	}
}

function int FindNextMove(array< class<FOM_Move> > PossibleMoves)
{
	local int PossibleNextMoveIndex;
	local int i, ReturnIndex;
	local float CurrentPriority;

	CurrentPriority = -1;
	ReturnIndex = -1;

	for(i = 0; i < PossibleMoves.Length; i++)
	{
		PossibleNextMoveIndex = FindMoveByClass(PossibleMoves[i]);

		if(PossibleNextMoveIndex != -1 && MoveArray[PossibleNextMoveIndex] != none && MoveArray[PossibleNextMoveIndex].CanDoMove())
		{
			if(MoveArray[PossibleNextMoveIndex].MovePriority > CurrentPriority)
			{
				ReturnIndex = PossibleNextMoveIndex;
			}
		}
	}

	return ReturnIndex;
}

function PerformNextMove(int NextMoveIndex)
{
	if(NextMoveIndex == -1)
	{
		`warn(Self @ GetFuncName() @ "Invalid Move");
		return;
	}

	MoveArray[CurrentMoveIndex].SetMoveActive(false);

	CurrentMoveIndex = NextMoveIndex;
	MoveArray[CurrentMoveIndex].SetMoveActive(true);
	MoveArray[CurrentMoveIndex].PrePerformMove();
	MoveArray[CurrentMoveIndex].PerformMove();
}

/*
 * This function searches through the move array and returns the index of the move whose class
 * matches the NextMove. This function returns -1 if the move wasn't found.
 * @NextMove        The move searched for
 * @Return          The index of the next move.
 */
function int FindMoveByClass(class<FOM_Move> NextMove)
{
	local int i;

	for(i = 0; i < MoveArray.Length; i++)
	{
		if(MoveArray[i].Class == NextMove)
		{
			return i;
		}
	}

	return -1;
}

/*
 * When the Pawn of the owning PlayerController hit's a wall this function is called. Here we just pass the information to the current move.
 * @HitNormal           The normal of the wall we hit
 * @Wall                The Actor We hit             
 */
event NotifyHitWall(Vector HitNormal, Actor Wall)
{
	if(MoveArray.Length > 0 && MoveArray[CurrentMoveIndex] != none)
	{
		MoveArray[CurrentMoveIndex].NotifyHitWall(HitNormal, Wall);
	}
}

/*
 * When the pawn of the owning PlayerController lands after a jump this function is called. 
 * @HitNormal           The normal of the floor we landed on
 * @FloorActor          The actor we landed on
 */
event NotifyLanded(Vector HitNormal, Actor FloorActor)
{
	if(MoveArray.Length > 0 && MoveArray[CurrentMoveIndex] != none)
	{
		MoveArray[CurrentMoveIndex].NotifyLanded(HitNormal, FloorActor);
	}
}


/*
 * This is called from the current move when it has finished.
 * @Move            The move that finished.
 */
function NotifyCurrentMoveFinshed(FOM_Move Move)
{
	QueryNextMove();
}

// HELPER FUNCTIONS

/*
 * This function spawns a new move timer for a FOM_Move. Objects cannot spawn actors, so we use the movemanager to do that.
 */
function FOM_Move_Timer SpawnNewTimer()
{
	return Spawn(class'FOM_Move_Timer');
}

function Actor DoTrace(
	out vector HitLocation, 
	out vector HitNormal, 
	vector TraceEnd, 
	vector TraceStart, 
	optional bool bTraceActors, 
	optional vector Extent, 
	optional out TraceHitInfo HitInfo, 
	optional int ExtraTraceFlags)
{
	return Trace(HitLocation, HitNormal, TraceEnd, TraceStart, bTraceActors, Extent, HitInfo, ExtraTraceFlags);
}

function bool DoFastTrace(
	vector TraceEnd,
	vector TraceStart,
	optional vector BoxExtent,
	optional bool bTraceBullet)
{
	return FastTrace(TraceEnd, TraceStart, BoxExtent, bTraceBullet);
}

DefaultProperties
{
}

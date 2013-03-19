/*
 * The base move class which implements the IMove Interface
 * 
 * Author: Christopher Pons
 */
class FOM_Move extends Object Implements(IMove)
	HideCategories(Object)
	EditInlineNew
	Abstract;

// Constants
var const string UP_ACTION;
var const string STOP_UP_ACTION;
var const string DOWN_ACTION;
var const string STOP_DOWN_ACTION;
var const string NO_ACTION;

// True if the this move is the default move state for the player. The default move state is usually FOM_Move_Standing.
var() bool bIsDefaultMoveState;
// If multiple moves can be performed with one action (such as a jump and mantle or wall run) the move with the highest priority will be chosen
var() float MovePriority;
// The next requested action
var String RequestedAction;
// The PlayerController who own's this Move
var FOM_PlayerController PCOwner;
// Our MoveManager
var FOM_MoveManager MoveManager;
// True if this move is currently active. Only active moves can alter the pawns velocity and acceleration
var bool bActiveMove;
// True if this move just finished
var bool bMoveJustFinished;
// This is the class this move will return to upon finishing. If this move doesn't finish, like FOM_Move_Standing, this should be left none.
var class<FOM_Move> ParentMoveClass;

// Move that could potentially be performed given an up action
var() array< class<FOM_Move> > PotentialUpActionMoves;
// Moves that could potentially be performed given a down action
var() array< class<FOM_Move> > PotentialDownActionMoves;


function Init(FOM_PlayerController NewOwner)
{
	PCOwner = NewOwner;

	if(PCOwner != none)
	{
		MoveManager = PCOwner.MoveManager;
	}
}

function bool CanDoMove()
{
	return PCOwner != none && PCOwner.Pawn != none;
}

function SetMoveActive(bool bActive)
{
	bActivemove = bActive;
	bMoveJustFinished = false;
}

function RequestPerformAction(String NewAction)
{
	RequestedAction = NewAction;
}

function bool IsDefaultMoveState()
{
	return bIsDefaultMoveState;
}

function array< class<FOM_Move> > GetNextMove();

function PrePerformMove();
function PerformMove();
function PostPerformMove();

function NotifyManagerMoveFinished()
{
	if(MoveManager != none)
	{
		MoveManager.NotifyCurrentMoveFinshed(Self);
	}
}

event NotifyHitWall(Vector HitNormal, Actor Wall);
event NotifyLanded(Vector HitNormal, Actor FloorActor);


DefaultProperties
{
	MovePriority=0.0

	UP_ACTION="UpAction"
	STOP_UP_ACTION="StopUpAction"
	DOWN_ACTIOn="DownAction"
	STOP_DOWN_ACTION="StopDownAction"
	NO_ACTION=""

	ParentMoveClass=class'ProjectFOMGame.FOM_Move_Standing'

	bIsDefaultMoveState=false
	bActiveMove=false
}

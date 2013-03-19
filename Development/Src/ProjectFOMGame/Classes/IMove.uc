/*
 * This is the interface class for a move in FOM.
 * 
 * Author: Christopher Pons
 */
interface IMove;

function Init(FOM_PlayerController NewOwner);

// We pass a string in with this function because I found it really difficult to get the package to compile properly with a bunch of DependsOn indentifiers in class
// Declarations
function RequestPerformAction(String NewAction);

// Returns true whether this move can be performed
function bool CanDoMove();

// This function returns an array of possible moves based upon the input action. For example, if the RequestedAction was a DownAction and we are currently in the FOM_Move_Standing state
// This function would return an array filled with the FOM_Move_Crouch and FOM_Move_Slide classes. From here the MoveManager would find both moves and call CanDoMove on both. If it can do one of 
// those moves then the MoveManager switches the current move and calls PerformMove
function array< class<FOM_Move> > GetNextMove();

function PrePerformMove();
function PerformMove();
function PostPerformMove();

// Some moves such as sliding and vaulting should notify the MoveManager that they have finished in order to transition properly
function NotifyManagerMoveFinished();

// This function is called from the owning PlayerController when the Pawn hits a wall
event NotifyHitWall(Vector HitNormal, Actor Wall);
// This function is called from the owning PlayerController when the Pawn has landed
event NotifyLanded(Vector HitNormal, Actor FloorActor);


// This will let this move whether is currently being executed
function SetMoveActive(bool bActive);
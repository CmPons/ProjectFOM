/*
 * This class is used to set timers for the FOM_Move class becuase they are derived from Object.
 * Only one timer per FOM_Move_Timer class is allowed. To spawn a new FOM_Move_Timer use the 
 * SpawnNewTimer function in FOM_MoveManager.
 * 
 * Author: Christopher Pons
 */
class FOM_Move_Timer extends Actor;

delegate MoveFunctionToCall();

function PostBeginPlay()
{
	Super.PostBeginPlay();
}

/*
 * Each actor can only hold one timer!! This does not create a new timer each time it's called.
 */
function SetNewTimer(float Rate, bool bLoop)
{
	SetTimer(Rate, bLoop);
}

function bool MoveTimerRunning()
{
	return IsTimerActive();
}

function ClearMoveTimer()
{
	ClearTimer();
}

function Timer()
{
	MoveFunctionToCall();
}

DefaultProperties
{
}

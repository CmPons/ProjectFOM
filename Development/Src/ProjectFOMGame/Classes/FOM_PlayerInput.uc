/*
 * This class handles all the input for FOM.
 * 
 * Author: Christopher Pons
 */
class FOM_PlayerInput extends PlayerInput within FOM_PlayerController
	config(Input);

exec function UpAction()
{
	RequestPerformAction("UpAction");
}

exec function StopUpAction()
{
	RequestPerformAction("StopUpAction");
}

exec function DownAction()
{
	RequestPerformAction("DownAction");
}

exec function StopDownAction()
{
	RequestPerformAction("StopDownAction");
}

exec function DoFlushPersistentDebugLines()
{
	FlushPersistentDebugLines();
}

DefaultProperties
{
}

/*
 * This is the base GameInfo class for FOM.
 * 
 * Author: Christopher Pons
 */
class FOM_GameInfo extends GameInfo;

var const FOM_GameInfoProperties GameInfoProperties;

function Pawn SpawnDefaultPawnFor(Controller NewPlayer, NavigationPoint StartSpot)
{
	return SpawnDefaultPawnArchetypeFor(NewPlayer, StartSpot);
}

function Pawn SpawnDefaultPawnArchetypeFor(Controller NewPlayer, NavigationPoint StartSpot)
{
	local Rotator StartRotation;

	// Don't spawn with pitch or roll
	StartRotation.Yaw = StartSpot.Rotation.Yaw;

	if(GameInfoProperties != none && GameInfoProperties.DefaultPawnArchetype != none)
	{
		return Spawn(GameInfoProperties.DefaultPawnArchetype.Class,,, StartSpot.Location, StartRotation, GameInfoProperties.DefaultPawnArchetype);
	}
}

auto State PendingMatch
{
Begin:
	StartMatch();
}

defaultproperties
{
	GameInfoProperties=FOM_GameInfoProperties'FOM_Engine_Resources.GameInfo.GameInfoProperties'

	HUDType=class'GameFramework.MobileHUD'
	PlayerControllerClass=class'ProjectFOMGame.FOM_PlayerController'
	DefaultPawnClass=class'ProjectFOMGame.FOM_Pawn'
	bRestartLevel=false
	bDelayedStart=true
}



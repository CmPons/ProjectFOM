/*
 * This class is meant to be archetyped and holds all of the variables that are editable for the
 * GameInfo class.
 * 
 * Author: Christopher Pons
 */
class FOM_GameInfoProperties extends Object
	HideCategories(Object);

var(GameInfoProperties) const FOM_Pawn DefaultPawnArchetype;

DefaultProperties
{
	DefaultPawnArchetype=FOM_Pawn'FOM_Engine_Resources.Pawns.DefaultPawnArchetype'
}

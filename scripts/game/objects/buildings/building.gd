class_name Building
extends Node2D


# ============================================================================ #
#region Enums

## The building types available in the game.
enum BuildingType {
	NONE,
	LANDING_SITE,
	HOUSING,
	GREENHOUSE,
	RANCH,
	FISHERY,
	SOLAR_FARM,
	WIND_FARM,
	NUCLEAR_REACTOR,
	FACTORY,
}

#endregion
# ============================================================================ #


# ============================================================================ #
#region Constants

## [String] building name for each [enum BuildingType].
const BUILDING_NAME: Dictionary[BuildingType, String] = {
	BuildingType.NONE: "",
	BuildingType.LANDING_SITE: "Landing Site",
	BuildingType.HOUSING: "Housing",
	BuildingType.GREENHOUSE: "Greenhouse",
	BuildingType.RANCH: "Ranch",
	BuildingType.FISHERY: "Fishery",
	BuildingType.SOLAR_FARM: "Solar Farm",
	BuildingType.WIND_FARM: "Wind Farm",
	BuildingType.NUCLEAR_REACTOR: "Nuclear Reactor",
	BuildingType.FACTORY: "Factory",
}

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Returns the [enum Building.BuildingType] of this [Building] instance.[br]
## [br]
## Virtual method. Override this method in children scenes to provide correct
## building type.
func get_type() -> BuildingType:
	push_warning("Calling method 'get_type()' on generic 'Building' instance.")
	return BuildingType.NONE


## Returns a serialized [Dictionary] representing this building instance. Useful
## for storing the game session in a save file.[br]
## [br]
## Schema:
## [codeblock]
##     # TODO: Develop a schema and implement this function in children classes.
##     # See #11.
## [/codeblock]
## [br]
## [br]
## Virtual method. Override this method in children scenes to provide the
## appropriate return value.
func serialized() -> Dictionary[StringName, Variant]:
	push_warning("Calling method 'serialized()' on generic 'Building' instance.")
	return {}

#endregion
# ============================================================================ #

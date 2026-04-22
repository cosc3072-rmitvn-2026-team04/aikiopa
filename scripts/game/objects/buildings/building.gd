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

## [Building] asset location.
const BUILDING_ASSET_DIR: String = "res://assets/objects/"

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

#endregion
# ============================================================================ #

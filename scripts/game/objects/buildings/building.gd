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
const BUILDING_ASSET_DIR: String = "res://assets/objects/buildings/"

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
#region Exported properties

## Sprite variations.
@export var variations: Array[CompressedTexture2D] = []

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private variables

var _variation_index: int

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Returns the current index of sprite [member variations] of the building.
func get_variation_index() -> int:
	return _variation_index


## Sets the sprite variation of the building based on [param value] between
## [code]-1.0[/code] and [code]1.0[/code] (inclusive).[br]
## [br]
## The variation is calculated from the position of [param value] within the
## uniform intervals in the above [code][-1.0, 1.0][/code] range, determined by
## the size of [member variations].
func set_variation(value: float) -> void:
	if value < -1.0 or value > 1.0:
		push_error("Value %.2f for parameter 'value' is out of bound." % value)
		return
	if variations.is_empty():
		return

	var normalized_value: float = (value + 1.0) / 2.0
	var variation_index: int = int(normalized_value * variations.size())
	variation_index = clampi(variation_index, 0, variations.size() - 1)
	_variation_index = variation_index
	$Sprite2D.texture = variations[variation_index]


## Returns the [enum BuildingType] of this [Building] instance.[br]
## [br]
## Virtual method. Override in children scenes to provide the correct return
## value.
func get_type() -> BuildingType:
	push_warning("Calling method 'get_type()' on generic 'Building' instance.")
	return BuildingType.NONE

#endregion
# ============================================================================ #

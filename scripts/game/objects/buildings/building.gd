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

## The building classes available in the game.
enum BuildingClass {
	CLASS_NONE,
	CLASS_LANDING_SITE,
	CLASS_HOUSING,
	CLASS_FOOD,
	CLASS_ENERGY,
	CLASS_INDUSTRY,
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

## Definition dictionary of key [BuildingType] and corresponding [BuildingClass]
## value. For example: [code]BUILDING_CLASS_OF_TYPE[BuildingType.RANCH][/code]
## would be [constant CLASS_FOOD].
const BUILDING_CLASS_OF_TYPE: Dictionary[BuildingType, BuildingClass] = {
	BuildingType.NONE: BuildingClass.CLASS_NONE,
	BuildingType.LANDING_SITE: BuildingClass.CLASS_LANDING_SITE,
	BuildingType.HOUSING: BuildingClass.CLASS_HOUSING,
	BuildingType.GREENHOUSE: BuildingClass.CLASS_FOOD,
	BuildingType.RANCH: BuildingClass.CLASS_FOOD,
	BuildingType.FISHERY: BuildingClass.CLASS_FOOD,
	BuildingType.SOLAR_FARM: BuildingClass.CLASS_ENERGY,
	BuildingType.WIND_FARM: BuildingClass.CLASS_ENERGY,
	BuildingType.NUCLEAR_REACTOR: BuildingClass.CLASS_ENERGY,
	BuildingType.FACTORY: BuildingClass.CLASS_INDUSTRY,
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

## Static version of [method get_building_class].
static func get_building_class_of_type(building_type: BuildingType) -> BuildingClass:
	return BUILDING_CLASS_OF_TYPE[building_type]


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
	_variation_index = int(normalized_value * variations.size())
	_variation_index = clampi(_variation_index, 0, variations.size() - 1)
	$Sprite2D.texture = variations[_variation_index]


## Returns the [enum BuildingType] of this [Building] instance.[br]
## [br]
## Virtual method. Override in children scenes to provide the correct return
## value.
func get_type() -> BuildingType:
	push_warning("Calling method 'get_type()' on generic 'Building' instance.")
	return BuildingType.NONE


## Returns the [enum BuildingClass] of this [Building] instance.[br]
func get_building_class() -> BuildingClass:
	return BUILDING_CLASS_OF_TYPE[get_type()]

#endregion
# ============================================================================ #

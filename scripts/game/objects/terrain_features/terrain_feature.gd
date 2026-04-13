class_name TerrainFeature
extends Node2D


# ============================================================================ #
#region Enums

enum FeatureType {
	NONE,
	FISHES,
	FOREST,
	SAND_DUNES,
	MOUNTAIN,
	CHASM,
}

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Returns the [enum FeatureType] of this [TerrainFeature] instance.[br]
## [br]
## Virtual method. Override in children scenes to provide correct feature type.
func get_type() -> FeatureType:
	push_warning("Calling method 'get_type()' on generic 'TerrainFeature' instance.")
	return FeatureType.NONE

#endregion
# ============================================================================ #

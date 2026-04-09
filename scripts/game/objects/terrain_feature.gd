class_name TerrainFeature
extends Node2D


# ============================================================================ #
#region Enums

enum FeatureType {
	NULL,
	FISH,
	FOREST,
	SAND_DUNES,
	MOUNTAIN,
	CHASM,
}

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

# TODO: Implement this in children classes.
## Returns the [enum FeatureType] of this [TerrainFeature] instance.
func get_type() -> FeatureType:
	push_warning("Calling method 'get_type()' on generic 'TerrainFeature' instance.")
	return FeatureType.NULL

#endregion
# ============================================================================ #

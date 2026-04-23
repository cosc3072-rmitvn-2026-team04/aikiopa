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
#region Exported properties

## Sprite variations.
@export var variations: Array[CompressedTexture2D] = []

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Sets the sprite variation of the terrain feature based on [param value],
## between [code]-1.0[/code] and [code]1.0[/code] (inclusive).[br]
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
	$Sprite2D.texture = variations[variation_index]


## Returns the [enum FeatureType] of this [TerrainFeature] instance.[br]
## [br]
## Virtual method. Override in children scenes to provide the correct return
## value.
func get_type() -> FeatureType:
	push_warning("Calling method 'get_type()' on generic 'TerrainFeature' instance.")
	return FeatureType.NONE

#endregion
# ============================================================================ #

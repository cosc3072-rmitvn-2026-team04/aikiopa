class_name TerrainFeature
extends Node2D


# ============================================================================ #
#region Enums

## The terrain feature types available in the game.
enum FeatureType {
	NONE,
	FISHES,
	FOREST,
	SAND_DUNES,
	MOUNTAIN,
	CHASM,
}

## The highlight modes available for [TerrainFeature]s. See
## [method set_highlight].
enum HighlightMode {
	HIGHLIGHT_NEUTRAL,
	HIGHLIGHT_ALTERNATIVE,
	HIGHLIGHT_POSITIVE,
	HIGHLIGHT_NEGATIVE,
}

#endregion
# ============================================================================ #


# ============================================================================ #
#region Exported properties

@export_group("Sprite")

## Sprite variations.
@export var variations: Array[CompressedTexture2D] = []


@export_group("Highlight", "highlight")

## [Color] of the building highlight in neutral mode. See
## [method set_highlight].
@export var highlight_neutral: Color = Color.WHITE

## [Color] of the building highlight in alternative mode.
## See [method set_highlight].
@export var highlight_alternative: Color = Color.YELLOW

## [Color] of the building highlight in positive mode.
## See [method set_highlight].
@export var highlight_positive: Color = Color.GREEN

## [Color] of the building highlight in negative mode.
## See [method set_highlight].
@export var highlight_negative: Color = Color.RED

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	$HighlightSprite2D.hide()

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Sets the sprite variation of the terrain feature based on [param value]
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


## Displays the terrain feature highlight and sets its color to [param mode].
func set_highlight(mode: HighlightMode) -> void:
	var highlight_modulate: Color = Color.TRANSPARENT
	match mode:
		HighlightMode.HIGHLIGHT_NEUTRAL:
			highlight_modulate = highlight_neutral
		HighlightMode.HIGHLIGHT_ALTERNATIVE:
			highlight_modulate = highlight_alternative
		HighlightMode.HIGHLIGHT_POSITIVE:
			highlight_modulate = highlight_positive
		HighlightMode.HIGHLIGHT_NEGATIVE:
			highlight_modulate = highlight_negative
		_:
			push_error("Highlight mode '%s' not implemented" % [
				HighlightMode.keys()[mode],
			])
			return
	$HighlightSprite2D.modulate = highlight_modulate
	$HighlightSprite2D.show()


## Hides the terrain feature highlight.
func unset_highlight() -> void:
	$HighlightSprite2D.modulate = Color.TRANSPARENT
	$HighlightSprite2D.hide()

#endregion
# ============================================================================ #

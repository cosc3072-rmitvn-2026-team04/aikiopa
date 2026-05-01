class_name CardStackCountBubble
extends Sprite2D


# ============================================================================ #
#region Variables

## Array of font sizes indexed by the order of magnitude of the card stack
## count (see [method set_count]). Index 0 is used for numbers 1-9, index 1 for
## 10-99, index 2 for 100-999, etc.
@export var dynamic_font_sizes: Array[int] = []
var _count: int = 0

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Returns the screen size of this card stack count bubble.
func get_size() -> Vector2:
	return get_rect().size


## Sets the displayed card stack count to [param amount].
func set_count(amount: int) -> void:
	_count = amount
	%CardStackCountLabel.text = "%d🏠" % _count
	_update_font_size()

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private methods

func _update_font_size() -> void:
	if dynamic_font_sizes.is_empty():
		return

	var font_size_index: int = 0
	if _count > 0:
		font_size_index = floori(log(_count) / log(10))
	font_size_index = clampi(font_size_index, 0, dynamic_font_sizes.size() - 1)
	%CardStackCountLabel.add_theme_font_size_override(
			&"font_size",
			dynamic_font_sizes[font_size_index])

#endregion
# ============================================================================ #

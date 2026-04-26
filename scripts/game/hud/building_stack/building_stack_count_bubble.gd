class_name BuildingStackCountBubble
extends Sprite2D


# ============================================================================ #
#region Public methods

## Returns the screen size of this building card.
func get_size() -> Vector2:
	return get_rect().size


## Sets the displayed building stack count to [param amount].
func set_count(amount: int) -> void:
	%BuildingStackCountLabel.text = "%d🏠" % amount

#endregion
# ============================================================================ #

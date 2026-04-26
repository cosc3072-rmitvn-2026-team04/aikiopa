class_name BuildingStackCountBubble
extends Node2D


# ============================================================================ #
#region Public methods

## Returns the screen size of this building card.
func get_size() -> Vector2:
	return $BackgroundSprite2D.get_rect().size


## Sets the displayed building stack count to [param amount].
func set_count(amount: int) -> void:
	%BuildingStackCountLabel.text = "%d🏠" % amount

#endregion
# ============================================================================ #

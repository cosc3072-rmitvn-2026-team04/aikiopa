extends Node2D


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	show_highlight() # Enable highlight by default.

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Returns the building sprite of the building preview map insert for further
## manipulations.
func get_building_sprite() -> Sprite2D:
	return $BuildingSprite2D


## Shows the highlight under the building preview map insert.
func show_highlight() -> void:
	$HighlightSprite2D.show()


## Hides the highlight under the building preview map insert.
func hide_highlight() -> void:
	$HighlightSprite2D.hide()

#endregion
# ============================================================================ #

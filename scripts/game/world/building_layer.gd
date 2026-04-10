extends Node2D


# ============================================================================ #
#region Public variables

## The [Building] instances in the game. Identified by their [Vector2i]
## coordinates.
var buildings: Dictionary[Vector2i, Dictionary]

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Removes all buildings (child nodes).
func clear() -> void:
	if get_child_count() > 0:
		for building: Building in get_children():
			remove_child(building)
			building.queue_free()
	buildings.clear()

#endregion
# ============================================================================ #

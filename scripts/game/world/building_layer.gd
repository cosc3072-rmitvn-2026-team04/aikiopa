extends Node2D


# ============================================================================ #
#region Public methods

# Data schema: Dictionary[Vector2i, Dictionary[BuildingType, Node2D]]. The
# Node2D field should point to the corresponding instance of the matching
# building scene.
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

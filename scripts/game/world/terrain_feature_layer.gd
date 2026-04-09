extends Node2D


# ============================================================================ #
#region Public methods

# Data schema: Dictionary[Vector2i, Dictionary[TerrainType, Node2D]]. The Node2D
# field should point to the corresponding instance of the matching terrain
# feature scene.
var terrain_features: Dictionary[Vector2i, TerrainFeature]

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Removes all terrain features (child nodes).
func clear() -> void:
	for child: Node2D in get_children():
		remove_child(child)
		child.queue_free()
	terrain_features.clear()

#endregion
# ============================================================================ #

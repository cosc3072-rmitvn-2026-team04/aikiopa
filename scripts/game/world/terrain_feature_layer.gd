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
	if get_child_count() > 0:
		for terrain_feature: TerrainFeature in get_children():
			remove_child(terrain_feature)
			terrain_feature.queue_free()
	terrain_features.clear()

#endregion
# ============================================================================ #

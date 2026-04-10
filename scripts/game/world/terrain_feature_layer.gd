extends Node2D


# ============================================================================ #
#region Exported properties

@export var world: World = null

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private variables

var _fishes_scene: PackedScene =\
		preload("res://scenes/game/objects/terrain_features/fishes.tscn")
var _forest_scene: PackedScene =\
		preload("res://scenes/game/objects/terrain_features/forest.tscn")
var _sand_dunes_scene: PackedScene =\
		preload("res://scenes/game/objects/terrain_features/sand_dunes.tscn")
var _mountain_scene: PackedScene =\
		preload("res://scenes/game/objects/terrain_features/mountain.tscn")
var _chasm_scene: PackedScene =\
		preload("res://scenes/game/objects/terrain_features/chasm.tscn")

# The [TerrainFeature] instances in the game. Identified by their [Vector2i]
# coordinates.
var _terrain_features: Dictionary[Vector2i, TerrainFeature]

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
	_terrain_features.clear()


## Returns the [enum TerrainFeature.FeatureType] at [param coords].
func get_feature_at(coords: Vector2i) -> TerrainFeature.FeatureType:
	if not has_feature_at(coords):
		return TerrainFeature.FeatureType.NONE
	return _terrain_features[coords].get_type()


## Returns [code]true[/code] if there is a terrain feature at [param coords].
func has_feature_at(coords: Vector2i) -> bool:
	return _terrain_features.has(coords)


## Sets the terrain feature at [param coords] to one of
## [enum TerrainFeature.FeatureType].[br]
## [br]
## TODO: Deterministically assign random variations.
func set_feature_at(
		coords: Vector2i,
		feature_type: TerrainFeature.FeatureType
) -> void:
	var terrain_feature: TerrainFeature = null
	match feature_type:
		TerrainFeature.FeatureType.FISHES:
			terrain_feature = _fishes_scene.instantiate()
		TerrainFeature.FeatureType.FOREST:
			terrain_feature = _forest_scene.instantiate()
		TerrainFeature.FeatureType.SAND_DUNES:
			terrain_feature = _sand_dunes_scene.instantiate()
		TerrainFeature.FeatureType.MOUNTAIN:
			terrain_feature = _mountain_scene.instantiate()
		TerrainFeature.FeatureType.CHASM:
			terrain_feature = _chasm_scene.instantiate()
		_:
			push_error("Unable to set terrain feature at (%d, %d): Unknown 'feature_type' %d." % [
				coords.x, coords.y,
				feature_type,
			])
			return

	var terrain_tile_map_layer: TileMapLayer = world.get_terrain_tile_map_layer()
	_terrain_features.set(coords, terrain_feature)
	terrain_feature.position = terrain_tile_map_layer.map_to_local(coords)
	add_child(terrain_feature)


## Returns and destroys the terrain feature at [param coords].[br]
## [br]
## Returns [constant TerrainFeature.FeatureType.NONE] if there is no terrain
## feature at [param coords].
func remove_feature_at(coords: Vector2i) -> TerrainFeature.FeatureType:
	if not has_feature_at(coords):
		return TerrainFeature.FeatureType.NONE

	var terrain_feature: TerrainFeature = _terrain_features[coords]
	var terrain_feature_type: TerrainFeature.FeatureType = terrain_feature.get_type()
	_terrain_features.erase(coords)
	remove_child(terrain_feature)
	terrain_feature.queue_free()

	return terrain_feature_type

#endregion
# ============================================================================ #

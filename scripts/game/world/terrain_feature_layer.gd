extends Node2D


# ============================================================================ #
#region Exported properties

@export var world: World = null

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public variables

## The [TerrainFeature] instances in the game. Identified by their [Vector2i]
## coordinates.
var _terrain_features: Dictionary[Vector2i, TerrainFeature]

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private variables

var _terrain_feature_fishes: PackedScene =\
		preload("res://scenes/game/objects/terrain_features/fishes.tscn")
var _terrain_feature_forest: PackedScene =\
		preload("res://scenes/game/objects/terrain_features/forest.tscn")
var _terrain_feature_sand_dunes: PackedScene =\
		preload("res://scenes/game/objects/terrain_features/sand_dunes.tscn")
var _terrain_feature_mountain: PackedScene =\
		preload("res://scenes/game/objects/terrain_features/mountain.tscn")
var _terrain_feature_chasm: PackedScene =\
		preload("res://scenes/game/objects/terrain_features/chasm.tscn")

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
	if not _terrain_features.has(coords):
		return TerrainFeature.FeatureType.NONE
	return _terrain_features[coords].get_type()


## Sets the terrain feature at [param coords] to one of
## [enum TerrainFeature.FeatureType].[br]
## [br]
## TODO: Deterministically assign terrain feature variations at random.
func set_feature_at(
		coords: Vector2i,
		feature_type: TerrainFeature.FeatureType
) -> void:
	var terrain_tile_map_layer: TileMapLayer = world.get_terrain_tile_map_layer()

	match feature_type:
		TerrainFeature.FeatureType.FISHES:
			var fishes: TerrainFeature = _terrain_feature_fishes.instantiate()
			_terrain_features.set(coords, fishes)
			fishes.position = terrain_tile_map_layer.map_to_local(coords)
			add_child(fishes)
		TerrainFeature.FeatureType.FOREST:
			var forest: TerrainFeature = _terrain_feature_forest.instantiate()
			_terrain_features.set(coords, forest)
			forest.position = terrain_tile_map_layer.map_to_local(coords)
			add_child(forest)
		TerrainFeature.FeatureType.SAND_DUNES:
			var sand_dunes: TerrainFeature = _terrain_feature_sand_dunes.instantiate()
			_terrain_features.set(coords, sand_dunes)
			sand_dunes.position = terrain_tile_map_layer.map_to_local(coords)
			add_child(sand_dunes)
		TerrainFeature.FeatureType.MOUNTAIN:
			var mountain: TerrainFeature = _terrain_feature_mountain.instantiate()
			_terrain_features.set(coords, mountain)
			mountain.position = terrain_tile_map_layer.map_to_local(coords)
			add_child(mountain)
		TerrainFeature.FeatureType.CHASM:
			var chasm: TerrainFeature = _terrain_feature_chasm.instantiate()
			_terrain_features.set(coords, chasm)
			chasm.position = terrain_tile_map_layer.map_to_local(coords)
			add_child(chasm)
		_:
			push_error("Incorrect feature_type. Unable to set terrain feature at (%d, %d)." % [
				coords.x, coords.y
			])

#endregion
# ============================================================================ #

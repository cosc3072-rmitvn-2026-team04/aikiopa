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

# The terrain feature instances in the game, represented as a dictionary of key
# [Vector2i] coordinates and its correspoding [TerrainFeature] instance.
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


## Returns the [enum TerrainFeature.FeatureType] at [param coords].[br]
## [br]
## Returns [constant TerrainFeature.NONE] if there is no terrain feature at
## [param coords], [b][u]or[/u][/b] if [param coords] is located within an
## ungenerated chunk.
func get_feature_at(coords: Vector2i) -> TerrainFeature.FeatureType:
	if not has_feature_at(coords):
		return TerrainFeature.FeatureType.NONE
	return _terrain_features[coords].get_type()


## Returns a reference to the [TerrainFeature] instance at [param coords].
## Returns [code]null[/code] if there is no terrain feature at [param coords],
## [b][u]or[/u][/b] if [param coords] is located within an ungenerated
## chunk.[br]
## [br]
## [color=orange][b]WARNING:[/b] Extra caution must be taken when modifying the
## returned instance for it being a reference, and thus will produce
## side-effects on any modification to its properties.[/color]
func get_feature_instance_at(coords: Vector2i) -> TerrainFeature:
	if not has_feature_at(coords):
		return null
	return _terrain_features[coords]


## Returns [code]true[/code] if there is a terrain feature at [param coords].
## Returns [code]false[/code] if there is no terrain feature at [param coords],
## [b][u]or[/u][/b] if [param coords] is located within an ungenerated chunk.
func has_feature_at(coords: Vector2i) -> bool:
	return _terrain_features.has(coords)


## Sets the terrain feature at [param coords] to one of
## [enum TerrainFeature.FeatureType].[br]
## [br]
## Returns the reference to the newly created [TerrainFeature] instance if
## succeeded. Otherwise returns [code]null[/code] if there is already a terrain
## feature at [param coords], or if logic for [param feature_type] is not
## implemented.
func set_feature_at(
		coords: Vector2i,
		feature_type: TerrainFeature.FeatureType,
		variation_value: float
) -> TerrainFeature:
	if has_feature_at(coords):
		return null

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
			push_error("Terrain feature type '%s' not implemented." % [
				TerrainFeature.FeatureType.keys()[feature_type],
			])
			return null

	var terrain_tile_map_layer: TileMapLayer = world.get_terrain_tile_map_layer()
	_terrain_features.set(coords, terrain_feature)
	terrain_feature.set_variation(variation_value)
	terrain_feature.position = terrain_tile_map_layer.map_to_local(coords)
	add_child(terrain_feature)
	return terrain_feature


## Destroys the terrain feature at [param coords] and return its
## [enum TerrainFeature.FeatureType].[br]
## [br]
## Returns [constant TerrainFeature.NONE] if there is no terrain feature at
## [param coords], [b][u]or[/u][/b] if [param coords] is located within an
## ungenerated chunk.
func remove_feature_at(coords: Vector2i) -> TerrainFeature.FeatureType:
	if not has_feature_at(coords):
		return TerrainFeature.FeatureType.NONE

	var terrain_feature: TerrainFeature = _terrain_features[coords]
	var terrain_feature_type: TerrainFeature.FeatureType = terrain_feature.get_type()

	if (
			terrain_feature_type == TerrainFeature.FeatureType.FOREST
			and Global.game_state.enclosed_forest_coords.has(coords)
	):
			Global.game_state.enclosed_forest_coords.erase(coords)

	_terrain_features.erase(coords)
	remove_child(terrain_feature)
	terrain_feature.queue_free()

	return terrain_feature_type

#endregion
# ============================================================================ #

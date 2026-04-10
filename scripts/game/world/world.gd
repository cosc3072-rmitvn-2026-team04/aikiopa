class_name World
extends Node2D
## Represents terrains and buildings.


# ============================================================================ #
#region Enums

## Terrain types (including terrain features) in the game.
enum TerrainType {
	NONE,
	SHALLOW_WATER,
	SHALLOW_WATER_FISHES,
	DEEP_WATER,
	PLAIN,
	PLAIN_FOREST,
	PLAIN_MOUNTAIN,
	PLAIN_CHASM,
	GRASSLAND,
	GRASSLAND_FOREST,
	GRASSLAND_MOUNTAIN,
	GRASSLAND_CHASM,
	DESERT,
	DESERT_SAND_DUNES,
	DESERT_MOUNTAIN,
	DESERT_CHASM,
}

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private variables

var _generated_chunks: Dictionary[Vector2i, bool]

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Returns the [code]TerrainTileMapLayer[/code] node.
func get_terrain_tile_map_layer() -> TileMapLayer:
	return %TerrainTileMapLayer


## Returns the [code]TerrainFeatureLayer[/code] node.
func get_terrain_feature_layer() -> Node2D:
	return %TerrainFeatureLayer


## Returns the [code]BuildingLayer[/code] node.
func get_building_layer() -> Node2D:
	return %BuildingLayer


## Returns the size of generated world chunks.
func get_chunk_size() -> Vector2i:
	return %WorldGenerator.chunk_size


## Initializes a new randomized world if the optional parameter
## [param world_seed] is not given or is [code]null[/code]. Otherwise
## initializes a world with the given seed.
func initialize(world_seed: Variant = null) -> void:
	if world_seed and typeof(world_seed) != TYPE_INT:
		push_error(
				"Invalid parameter type for 'world_seed'. Must be int or null.")
		return
	%WorldGenerator.generate_seeds(world_seed)
	get_terrain_tile_map_layer().clear()
	get_terrain_feature_layer().clear()
	get_building_layer().clear()

	_generated_chunks.clear()


## Returns the current world's seed.
func get_seed() -> int:
	return %WorldGenerator.get_seed()


## Generates new world chunk at [param chunk_offset]. [param chunk_offset]
## defaults to [constant Vector2i.ZERO] - the chunk at world origin.[br]
## [br]
## Example: [code]Vector2i(2, -3)[/code] points to 2 chunks to the right and 3
## chunks to the bottom relative to the chunk at origin.
func create_chunk(chunk_offset: Vector2i = Vector2i.ZERO) -> void:
	if is_chunk_generated(chunk_offset):
		push_warning(
				"Previously generated chunk (%d, %d) is overwritten."
				% [chunk_offset.x, chunk_offset.y])
	%WorldGenerator.create_chunk(chunk_offset)
	_generated_chunks.set(chunk_offset, true)


## Returns the position of the [b]center[/b] of the chunk at
## [param chunk_offset].
func get_chunk_center_position(chunk_offset: Vector2i = Vector2i.ZERO) -> Vector2:
	@warning_ignore("integer_division")
	var tile_size: Vector2i = get_terrain_tile_map_layer().tile_set.tile_size
	var chunk_size: Vector2i = %WorldGenerator.chunk_size
	var chunk_screen_offset: Vector2 = Vector2(
			tile_size.x * chunk_size.x * chunk_offset.x,
			tile_size.y * chunk_size.y * chunk_offset.y)
	return (
			get_terrain_tile_map_layer().map_to_local(chunk_size * 0.5)
			+ chunk_screen_offset)


## Returns a list of offset positions of generated chunks.
func get_generated_chunks() -> Array[Vector2i]:
	return _generated_chunks.keys()


## Returns [code]true[/code] if the chunk at [param chunk_offset] is already
## generated.
func is_chunk_generated(chunk_offset: Vector2i) -> bool:
	return _generated_chunks.has(chunk_offset)


## Returns the 8 neighboring offset coordinates of the chunk at
## [param chunk_offset].
func get_neigboring_chunks(chunk_offset: Vector2i) -> Array[Vector2i]:
	return [
		chunk_offset + Vector2i.LEFT,
		chunk_offset + Vector2i.RIGHT,
		chunk_offset + Vector2i.UP,
		chunk_offset + Vector2i.DOWN,
		chunk_offset + Vector2i.UP + Vector2i.LEFT,
		chunk_offset + Vector2i.UP + Vector2i.RIGHT,
		chunk_offset + Vector2i.DOWN + Vector2i.LEFT,
		chunk_offset + Vector2i.DOWN + Vector2i.RIGHT,
	]


## Returns the [enum TerrainType] at [param coords].
func get_terrain_at(coords: Vector2i) -> TerrainType:
	var terrain_feature_layer: Node2D = get_terrain_feature_layer()

	var base_terrain_type: TerrainType = get_terrain_tile_map_layer()\
			.get_cell_tile_data(coords)\
			.get_custom_data("base_terrain_type")
	var terrain_feature_type: TerrainFeature.FeatureType =\
			terrain_feature_layer.get_feature_at(coords)

	var base_terrain_type_str: String =\
			TerrainType.keys()[base_terrain_type]
	if terrain_feature_type == TerrainFeature.FeatureType.NONE:
		return TerrainType.get(base_terrain_type_str)

	var terrain_feature_type_str: String =\
			TerrainFeature.FeatureType.keys()[terrain_feature_type]
	return TerrainType.get("%s_%s" % [
		base_terrain_type_str,
		terrain_feature_type_str,
	])


## Sets the terrain at [param coords] to one of [enum TerrainType].
func set_terrain_at(coords: Vector2i, terrain_type: TerrainType) -> void:
	var terrain_tile_map_layer: TileMapLayer = get_terrain_tile_map_layer()
	var terrain_features_layer: Node2D = get_terrain_feature_layer()

	terrain_tile_map_layer.set_cell(
		coords,
		get_terrain_tile_map_layer().SOURCE_ID,
		get_terrain_tile_map_layer().ATLAS_COORDS[terrain_type])

	match terrain_type:
		TerrainType.SHALLOW_WATER_FISHES:
			terrain_features_layer.set_feature_at(
					coords,
					TerrainFeature.FeatureType.FISHES)
		TerrainType.PLAIN_FOREST, TerrainType.GRASSLAND_FOREST:
			terrain_features_layer.set_feature_at(
					coords,
					TerrainFeature.FeatureType.FOREST)
		TerrainType.DESERT_SAND_DUNES:
			terrain_features_layer.set_feature_at(
					coords,
					TerrainFeature.FeatureType.SAND_DUNES)
		TerrainType.PLAIN_MOUNTAIN, TerrainType.GRASSLAND_MOUNTAIN, TerrainType.DESERT_MOUNTAIN:
			terrain_features_layer.set_feature_at(
					coords,
					TerrainFeature.FeatureType.MOUNTAIN)
		TerrainType.PLAIN_CHASM, TerrainType.GRASSLAND_CHASM, TerrainType.DESERT_CHASM:
			terrain_features_layer.set_feature_at(
					coords,
					TerrainFeature.FeatureType.CHASM)


## Returns [code]true[/code] if there is a [TerrainFeature] at [param coords].
func has_terrain_feature_at(coords: Vector2i) -> bool:
	return get_terrain_feature_layer().has_feature_at(coords)


## Returns and destroys the terrain feature at [param coords].[br]
## [br]
## Returns [constant TerrainFeature.FeatureType.NONE] if there is no terrain
## feature at [param coords].
func remove_terrain_feature_at(coords: Vector2i) -> TerrainFeature.FeatureType:
	return get_terrain_feature_layer().remove_feature_at(coords)


## Returns the [enum Building.BuildingType] at [param coords].
func get_building_at(coords: Vector2i) -> Building.BuildingType:
	return get_building_layer().get_building_at(coords)


## Returns [code]true[/code] if there is a [Building] at [param coords].
func has_building_at(coords: Vector2i) -> bool:
	return get_building_layer().has_building_at(coords)


## Sets the building at [param coords] to one of [enum Building.BuildingType].
## [color=orange][b][u]Warning:[/u] This will replace any existing
## building.[/b][/color][br]
## [br]
## Prints an error and do nothing if [param building_type] is unknown.[br]
## [br]
## Set [param quiet] to [code]true[/code] to execute without notifying other
## game systems. Useful for scripted game events.
func place_building_at(
		coords: Vector2i,
		building_type: Building.BuildingType,
		quiet: bool = false
) -> void:
	get_building_layer().place_building_at(coords, building_type, quiet)


## Returns and destroys the building at [param coords].[br]
## [br]
## Returns [constant Building.BuildingType.NONE] if there is no building at
## [param coords].
## [br]
## Set [param quiet] to [code]true[/code] to execute without notifying other
## game systems. Useful for scripted game events.
func destroy_building_at(coords: Vector2i) -> bool:
	return get_building_layer().destroy_building_at(coords)

#endregion
# ============================================================================ #

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
#region Exported properties

@export var building_ruleset_engine: BuildingRulesetEngine = null

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private variables

var _generated_chunks: Dictionary[Vector2i, bool]

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	UIEventBus.building_placement_requested.connect(
			_on_building_placement_requested)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods


## Returns the [World] coordinates of the cell containing the given
## [param local_position]. If [param local_position] is in global coordinates,
## consider using [method Node2D.to_local()] before passing it to this method.
## See also [method map_to_local()].
func local_to_map(local_position: Vector2) -> Vector2i:
	return get_terrain_tile_map_layer().local_to_map(local_position)


## Returns the centered local position of a cell in the [World]'s coordinate
## space. To convert the returned value into global position, use
## [method Node2D.to_global()]. See also [method local_to_map()].[br]
## [br]
## [b]Note:[/b] This may not correspond to the visual position of the tile, i.e.
## it ignores the [member TileData.texture_origin] property of individual tiles.
func map_to_local(coords: Vector2i) -> Vector2:
	return get_terrain_tile_map_layer().map_to_local(coords)


## Returns the [code]TerrainTileMapLayer[/code] node.
func get_terrain_tile_map_layer() -> TileMapLayer:
	return %TerrainTileMapLayer


## Returns the [code]TerrainFeatureLayer[/code] node.
func get_terrain_feature_layer() -> Node2D:
	return %TerrainFeatureLayer


## Returns the [code]BuildingLayer[/code] node.
func get_building_layer() -> Node2D:
	return %BuildingLayer


## Returns the [code]ShroudTileMapLayer[/code] node.
func get_shroud_tile_map_layer() -> TileMapLayer:
	return %ShroudTileMapLayer


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

	_generated_chunks.clear()


## Returns the current world's seed. Useful for saving and restoring game
## sessions.
func get_seed() -> int:
	return %WorldGenerator.get_seed()


## Returns the current world's seed and its corresponding internal terrain
## module seeds. Useful for debugging.
func get_seeds_internal() -> Dictionary[StringName, int]:
	return %WorldGenerator.get_seeds_internal()


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
	var cell_tile_data: TileData = get_terrain_tile_map_layer()\
			.get_cell_tile_data(coords)
	if not cell_tile_data:
		return TerrainType.NONE

	var base_terrain_type: TerrainType = cell_tile_data.get_custom_data(
			"base_terrain_type")
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


## Sets the terrain at [param coords] to one of [enum TerrainType], with
## [param variation] applied if there is a [TerrainFeature].
func set_terrain_at(
		coords: Vector2i,
		terrain_type: TerrainType,
		variation_value: float) -> void:
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
					TerrainFeature.FeatureType.FISHES,
					variation_value)
		TerrainType.PLAIN_FOREST, TerrainType.GRASSLAND_FOREST:
			terrain_features_layer.set_feature_at(
					coords,
					TerrainFeature.FeatureType.FOREST,
					variation_value)
		TerrainType.DESERT_SAND_DUNES:
			terrain_features_layer.set_feature_at(
					coords,
					TerrainFeature.FeatureType.SAND_DUNES,
					variation_value)
		TerrainType.PLAIN_MOUNTAIN, TerrainType.GRASSLAND_MOUNTAIN, TerrainType.DESERT_MOUNTAIN:
			terrain_features_layer.set_feature_at(
					coords,
					TerrainFeature.FeatureType.MOUNTAIN,
					variation_value)
		TerrainType.PLAIN_CHASM, TerrainType.GRASSLAND_CHASM, TerrainType.DESERT_CHASM:
			terrain_features_layer.set_feature_at(
					coords,
					TerrainFeature.FeatureType.CHASM,
					variation_value)


## Returns [code]true[/code] if there is a [TerrainFeature] at [param coords].
func has_terrain_feature_at(coords: Vector2i) -> bool:
	return get_terrain_feature_layer().has_feature_at(coords)


## Returns and destroys the terrain feature at [param coords].[br]
## [br]
## Returns [constant TerrainFeature.NONE] if there is no terrain feature at
## [param coords].
func remove_terrain_feature_at(coords: Vector2i) -> TerrainFeature.FeatureType:
	return get_terrain_feature_layer().remove_feature_at(coords)


## Returns the [enum Building.BuildingType] at [param coords].
func get_building_at(coords: Vector2i) -> Building.BuildingType:
	return get_building_layer().get_building_at(coords)


## Returns [code]true[/code] if there is a [Building] at [param coords].
func has_building_at(coords: Vector2i) -> bool:
	return get_building_layer().has_building_at(coords)


## Sets the building at [param coords] to one of [enum Building.BuildingType]
## with its sprite variation based on [param variation_value]. See
## [method Building.set_variation]. [color=orange][b][u]Warning:[/u] This will
## replace any existing building.[/b][/color][br]
## [br]
## Prints an error and do nothing if [param building_type] is unknown.[br]
func place_building_at(
		coords: Vector2i,
		building_type: Building.BuildingType,
		variation_value: float
) -> void:
	get_building_layer().place_building_at(coords, building_type, variation_value)


## Returns and destroys the building at [param coords].[br]
## [br]
## Returns [constant Building.NONE] if there is no building at [param coords].
func destroy_building_at(coords: Vector2i) -> Building.BuildingType:
	return get_building_layer().destroy_building_at(coords)


## Resets The Shroud to reveal only around the initial coordinate at the center
## of the [World].
func reset_shroud() -> void:
	get_shroud_tile_map_layer().reset()


## Returns the [enum ShroudTileMapLayer.ShroudType] at [param coords].
func get_shroud_at(coords: Vector2i) -> ShroudTileMapLayer.ShroudType:
	return get_shroud_tile_map_layer().get_shroud_at(coords)


## Returns The Shroud's internal data as a [Dictionary]. Useful for saving game
## sessions.
func get_shroud_data() -> Dictionary[StringName, Array]:
	return get_shroud_tile_map_layer().get_shroud_data()


## Sets The Shroud's internal data from [param shroud_data]. See
## [method ShroudTileMapLayer.get_shroud_data] for its schema. Useful for
## restoring game sessions.
func set_shroud_data(shroud_data: Dictionary[StringName, Array]) -> void:
	get_shroud_tile_map_layer().set_shroud_data(shroud_data)


## Efficiently re-renders The Shroud around the [param camera_position] (See
## [method Camera2D.position]). This method is optimized to only render the area
## within the player's camera plus the
## [member ShroudTileMapLayer.render_margin].
func render_shroud(camera_position: Vector2) -> void:
	get_shroud_tile_map_layer().render(camera_position)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to UIEventBus.building_placement_requested(
#		mouse_position: Vector2,
#		building_type: Building.BuildingType,
#		variation_value: float).
func _on_building_placement_requested(
		mouse_position: Vector2,
		building_type: Building.BuildingType,
		variation_value: float
) -> void:
	var map_coords: Vector2i = local_to_map(mouse_position)

	var ruleset_parse_result: Dictionary[StringName, Variant] =\
			building_ruleset_engine.parse_rules(map_coords, building_type, false)
	if (
			ruleset_parse_result.placement_check_status
			== BuildingRulesetEngine.PlacementCheckStatus.ALLOWED
	):
		place_building_at(map_coords, building_type, variation_value)
		var enclosed_forest_area: Array[Vector2i]
		for interaction_coords: Vector2i in ruleset_parse_result.interaction_result.keys():
			if get_terrain_at(interaction_coords) in [
				TerrainType.PLAIN_FOREST,
				TerrainType.GRASSLAND_FOREST,
			]:
				var terrain_feature_layer: Node2D = get_terrain_feature_layer()
				var forest_feature: TerrainFeature =\
						terrain_feature_layer.get_feature_instance_at(interaction_coords)
				if forest_feature:
					forest_feature.is_enclosed = true
					forest_feature.set_highlight(
							TerrainFeature.HighlightMode.HIGHLIGHT_ALTERNATIVE)
				else:
					push_error("Forest instance expected at (%d, %d). Got 'null' instead." % [
						interaction_coords.x,
						interaction_coords.y
					])
				enclosed_forest_area.append(interaction_coords)
				Global.game_state.enclosed_forest_coords.append(interaction_coords)
		GameplayEventBus.building_placed.emit(
				map_coords,
				building_type,
				variation_value,
				BuildingRulesetEngine.InteractionResult.sum(
						ruleset_parse_result.interaction_result.values()))
		if not enclosed_forest_area.is_empty():
			GameplayEventBus.forest_enclosed.emit(map_coords, enclosed_forest_area)

#endregion
# ============================================================================ #

class_name World
extends Node2D
## Represents terrains and buildings.


# ============================================================================ #
#region Signals

## Emitted when a building is successfully added.
@warning_ignore("unused_signal")
signal building_added(coords: Vector2i, type: BuildingType)

## Emitted when a building is successfully removed.
@warning_ignore("unused_signal")
signal building_removed(coords: Vector2i)

#endregion
# ============================================================================ #


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
	DESERT_DUNES,
	DESERT_MOUNTAIN,
	DESERT_CHASM,
}

## The building types available in the game.
enum BuildingType {
	NONE,
	LANDING_SITE,
	HOUSING,
	SOLAR_FARM,
	WIND_FARM,
	NUCLEAR_REACTOR,
	GREENHOUSE,
	RANCH,
	FISHERY,
	FACTORY,
}

#endregion
# ============================================================================ #


# ============================================================================ #
#region Constants

const BUILDING_NAME: Dictionary[BuildingType, String] = {
	BuildingType.NONE: "",
	BuildingType.LANDING_SITE: "Landing Site",
	BuildingType.HOUSING: "Housing",
	BuildingType.SOLAR_FARM: "Solar Farm",
	BuildingType.WIND_FARM: "Wind Farm",
	BuildingType.NUCLEAR_REACTOR: "Nuclear Reactor",
	BuildingType.GREENHOUSE: "Greenhouse",
	BuildingType.RANCH: "Ranch",
	BuildingType.FISHERY: "Fishery",
	BuildingType.FACTORY: "Factory",
}

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private variables

var _terrain_feature_mountain: PackedScene =\
		preload("res://scenes/game/objects/terrain_features/mountain.tscn")
var _terrain_feature_chasm: PackedScene =\
		preload("res://scenes/game/objects/terrain_features/chasm.tscn")
var _terrain_feature_sand_dunes: PackedScene =\
		preload("res://scenes/game/objects/terrain_features/sand_dunes.tscn")
var _terrain_feature_forest: PackedScene =\
		preload("res://scenes/game/objects/terrain_features/forest.tscn")
var _terrain_feature_fishes: PackedScene =\
		preload("res://scenes/game/objects/terrain_features/fishes.tscn")

var _generated_chunks: Dictionary[Vector2i, bool]
var _terrain_features: Dictionary[Vector2i, Node2D]

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Returns the [code]TerrainTileMapLayer[/code] node.
func get_terrain_tile_map_layer() -> TileMapLayer:
	return %TerrainTileMapLayer


## Returns the [code]TerrainFeatureLayer[/code] node.
func get_terrain_features_layer() -> TileMapLayer:
	return %TerrainFeatureLayer


## Returns the [code]BuildingLayer[/code] node.
func get_buildings_layer() -> TileMapLayer:
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


## Sets the terrain at [param coords] to one of [enum World.TerrainType].
## Automatically assign terrain feature variation(s) at random.
func set_terrain_at(coords: Vector2i, terrain_type: TerrainType) -> void:
	get_terrain_tile_map_layer().set_cell(
		coords,
		get_terrain_tile_map_layer().SOURCE_ID,
		get_terrain_tile_map_layer().ATLAS_COORDS[terrain_type])
	match terrain_type:
		TerrainType.PLAIN_MOUNTAIN, TerrainType.GRASSLAND_MOUNTAIN, TerrainType.DESERT_MOUNTAIN:
			var mountain: Node2D = _terrain_feature_mountain.instantiate()
			_terrain_features.set(coords, mountain)
			mountain.position = get_terrain_tile_map_layer()\
					.map_to_local(coords)
			get_terrain_features_layer().add_child(mountain)
		TerrainType.PLAIN_CHASM, TerrainType.GRASSLAND_CHASM, TerrainType.DESERT_CHASM:
			var chasm: Node2D = _terrain_feature_chasm.instantiate()
			_terrain_features.set(coords, chasm)
			chasm.position = get_terrain_tile_map_layer()\
					.map_to_local(coords)
			get_terrain_features_layer().add_child(chasm)
		TerrainType.DESERT_DUNES:
			var sand_dunes: Node2D = _terrain_feature_sand_dunes.instantiate()
			_terrain_features.set(coords, sand_dunes)
			sand_dunes.position = get_terrain_tile_map_layer()\
					.map_to_local(coords)
			get_terrain_features_layer().add_child(sand_dunes)
		TerrainType.PLAIN_FOREST, TerrainType.GRASSLAND_FOREST:
			var forest: Node2D = _terrain_feature_forest.instantiate()
			_terrain_features.set(coords, forest)
			forest.position = get_terrain_tile_map_layer()\
					.map_to_local(coords)
			get_terrain_features_layer().add_child(forest)
		TerrainType.SHALLOW_WATER_FISHES:
			var fishes: Node2D = _terrain_feature_fishes.instantiate()
			_terrain_features.set(coords, fishes)
			fishes.position = get_terrain_tile_map_layer()\
					.map_to_local(coords)
			get_terrain_features_layer().add_child(fishes)


# TODO: Implement this.
## Returns the [enum World.TerrainType] at [param coords].
func get_terrain_at(_coords: Vector2i) -> TerrainType:
	assert(false, "Game.get_terrain_at() not implemented")
	return TerrainType.NONE


# TODO: Implement this.
## Sets the building at [param coords] to one of [enum World.BuildingType].
## Automatically assign variation(s) at random.[br]
## [br]
## Returns [code]false[/code] if there is already an existing building at
## [param coords].
func set_building_at(_coords: Vector2i, _type: BuildingType) -> bool:
	assert(false, "Game.set_building_at() not implemented")
	return false


# TODO: Implement this.
## Removes the building at [param coords].[br]
## [br]
## Returns [code]false[/code] if there is no existing building at
## [param coords].
func remove_building_at(_coords: Vector2i, _type: BuildingType) -> bool:
	assert(false, "Game.remove_building_at() not implemented")
	return false


# TODO: Implement this.
## Returns the [enum World.BuildingType] at [param coords].
func get_building_at(_coords: Vector2i) -> BuildingType:
	assert(false, "Game.get_terrain_at() not implemented")
	return BuildingType.NONE

#endregion
# ============================================================================ #

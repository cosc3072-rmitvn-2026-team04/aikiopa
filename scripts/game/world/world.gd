class_name World
extends Node2D
## Represents terrains and buildings.


# ============================================================================ #
#region Signals

## Emitted when a building is successfully added.
@warning_ignore("unused_signal")
signal building_added(coords: Vector2i, type: BuildingTypes)

## Emitted when a building is successfully removed.
@warning_ignore("unused_signal")
signal building_removed(coords: Vector2i)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Enums

## Terrain types (including terrain features) in the game.
enum TerrainTypes {
	None,
	ShallowWater,
	ShallowWaterFishes,
	DeepWater,
	Plain,
	PlainForest,
	PlainMountain,
	PlainChasm,
	Grassland,
	GrasslandForest,
	GrasslandMountain,
	GrasslandChasm,
	Desert,
	DesertDunes,
	DesertMountain,
	DesertChasm,
}

## The building types available in the game.
enum BuildingTypes {
	None,
	LandingSite,
	Housing,
	SolarFarm,
	WindFarm,
	NuclearReactor,
	Greenhouse,
	Ranch,
	Fishery,
	Factory,
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

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	_generated_chunks.clear()

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


## Generates new [World] seeds, effectively creating a new world.
func generate_seeds() -> void:
	%WorldGenerator.generate_seeds()
	_generated_chunks.clear()


## Returns the current world's seeds.
func get_seeds() -> Dictionary[String, int]:
	return %WorldGenerator.get_seeds()


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


## Sets the terrain at [param coords] to one of [enum World.TerrainTypes].
## Automatically assign terrain feature variation(s) at random.
@warning_ignore("unused_parameter") # Remove when this function is implemented.
func set_terrain_at(coords: Vector2i, terrain_type: TerrainTypes) -> void:
	get_terrain_tile_map_layer().set_cell(
		coords,
		get_terrain_tile_map_layer().SOURCE_ID,
		get_terrain_tile_map_layer().ATLAS_COORDS[terrain_type])
	match terrain_type:
		TerrainTypes.PlainMountain, TerrainTypes.GrasslandMountain, TerrainTypes.DesertMountain:
			var mountain: Node2D = _terrain_feature_mountain.instantiate()
			mountain.position = get_terrain_tile_map_layer()\
					.map_to_local(coords)
			get_terrain_features_layer().add_child(mountain)
		TerrainTypes.PlainChasm, TerrainTypes.GrasslandChasm, TerrainTypes.DesertChasm:
			var chasm: Node2D = _terrain_feature_chasm.instantiate()
			chasm.position = get_terrain_tile_map_layer()\
					.map_to_local(coords)
			get_terrain_features_layer().add_child(chasm)
		TerrainTypes.DesertDunes:
			var sand_dunes: Node2D = _terrain_feature_sand_dunes.instantiate()
			sand_dunes.position = get_terrain_tile_map_layer()\
					.map_to_local(coords)
			get_terrain_features_layer().add_child(sand_dunes)
		TerrainTypes.PlainForest, TerrainTypes.GrasslandForest:
			var forest: Node2D = _terrain_feature_forest.instantiate()
			forest.position = get_terrain_tile_map_layer()\
					.map_to_local(coords)
			get_terrain_features_layer().add_child(forest)
		TerrainTypes.ShallowWaterFishes:
			var fishes: Node2D = _terrain_feature_fishes.instantiate()
			fishes.position = get_terrain_tile_map_layer()\
					.map_to_local(coords)
			get_terrain_features_layer().add_child(fishes)


## Returns the [enum World.TerrainTypes] at [param coords].
@warning_ignore("unused_parameter") # Remove when this function is implemented.
func get_terrain_at(coords: Vector2i) -> TerrainTypes:
	## TODO: Implement this.
	assert(false, "Game.get_terrain_at() not implemented")
	return TerrainTypes.None

## Sets the building at [param coords] to one of [enum World.BuildingTypes].
## Automatically assign variation(s) at random.[br]
## [br]
## Returns [code]false[/code] if there is already an existing building at
## [param coords].
@warning_ignore("unused_parameter") # Remove when this function is implemented.
func set_building_at(coords: Vector2i, type: BuildingTypes) -> bool:
	## TODO: Implement this.
	assert(false, "Game.set_building_at() not implemented")
	if false:
		building_added.emit(coords, type)
	return false


## Removes the building at [param coords].[br]
## [br]
## Returns [code]false[/code] if there is no existing building at
## [param coords].
@warning_ignore("unused_parameter") # Remove when this function is implemented.
func remove_building_at(coords: Vector2i, type: BuildingTypes) -> bool:
	## TODO: Implement this.
	assert(false, "Game.remove_building_at() not implemented")
	if false:
		building_removed.emit(coords)
	return false


## Returns the [enum World.BuildingTypes] at [param coords].
@warning_ignore("unused_parameter") # Remove when this function is implemented.
func get_building_at(coords: Vector2i) -> BuildingTypes:
	## TODO: Implement this.
	assert(false, "Game.get_terrain_at() not implemented")
	return BuildingTypes.None

#endregion
# ============================================================================ #

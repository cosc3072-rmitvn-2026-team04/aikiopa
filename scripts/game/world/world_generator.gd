class_name WorldGenerator
extends Node
## Handles procedural world generation.


# ============================================================================ #
#region Exported propertoes

@export_group("Height Map", "h")

# Height map generation noise algorithm. Produces Water / Plain / Mountain based
# on noise values.
@export var h_map: FastNoiseLite = null

## Affects how large/small the generated biomes would be.
@export_range(0.1, 10.0, 0.1, "or_greater") var h_noise_scale: float = 1.0

## Noise values below this generates Deep Water (water).
@export_range(-1.0, 1.0, 0.01) var h_water_height: float = -0.5

## Noise values between Water Height and this generates Plain (land). Noise
## values larger or equal to this generates Mountain.
@export_range(-1.0, 1.0, 0.01) var h_land_height: float = 0.5


# Moisture map generation noise algorithm. Produces Fertile Plain / Desert based
# on noise values.
@export_group("Moisture Map", "m")

# Moisture map generation noise algorithm. Produces Desert / Plain / Fertile
# Plain based on noise values.
@export var m_map: FastNoiseLite = null

## Affects how large/small the generated biomes would be.
@export_range(0.1, 10.0, 0.1, "or_greater") var m_noise_scale: float = 1.0

## Noise values below this generates Desert.
@export_range(-1.0, 1.0, 0.01) var m_desert_height: float = -0.5

## Noise values between Desert Height and this generates Plain. Noise values
## larger or equal to this generate Fertile Plain.
@export_range(-1.0, 1.0, 0.01) var m_plain_height: float = 0.5


# Forest generation noise algorithm. Produces Forest based on noise values
@export_group("Forest Map", "t")

# Forest map generation noise algorithm. Produces Forest based on noise values.
@export var t_map: FastNoiseLite = null

## Affects how large/small the generated biomes would be.
@export_range(0.1, 10.0, 0.1, "or_greater") var t_noise_scale: float = 1.0

## Noise values above this generates Forest.
@export_range(-1.0, 1.0, 0.01) var t_height: float = 0.0


# Fish generation noise algorithm. Produces Fish based on noise values
@export_group("Fish Map", "f")

# Fish map generation noise algorithm. Produces Fish based on noise values.
@export var f_map: FastNoiseLite = null

## Affects how large/small the generated biomes would be.
@export_range(0.1, 10.0, 0.1, "or_greater") var f_noise_scale: float = 1.0

## Noise values above this generates Forest.
@export_range(-1.0, 1.0, 0.01) var f_height: float = 0.0


# Chasm generation noise algorithm. Produces Chasm based on noise values
@export_group("Chasm Map", "c")

# Chasm map generation noise algorithm. Produces Chasm based on noise values.
@export var c_map: FastNoiseLite = null

## Affects how large/small the generated biomes would be.
@export_range(0.1, 10.0, 0.1, "or_greater") var c_noise_scale: float = 1.0

## Noise values above this generates Forest.
@export_range(-1.0, 1.0, 0.01) var c_height: float = 0.0


@export_group("Output")

## The amount of tiles generated at one time. Given in [Vector2i] dimensions.
@export var chunk_size: Vector2i = Vector2i(64, 64)

## The [World].
@export var world: World = null

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private variables

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Generates a new seeds for the generator, effectively creating a new world.
func generate_seeds() -> void:
	h_map.seed = _rng.randi()
	m_map.seed = _rng.randi()
	t_map.seed = _rng.randi()
	f_map.seed = _rng.randi()
	c_map.seed = _rng.randi()


## Returns the current world's seeds.
func get_seeds() -> Dictionary[String, int]:
	return {
		"height_map_seed": h_map.seed,
		"moisture_map_seed": m_map.seed,
		"forest_map_seed": t_map.seed,
		"fish_map_seed": f_map.seed,
		"chasm_map_seed": c_map.seed,
	}


## Generates new world chunk at [param chunk_offset]. [param chunk_offset]
## defaults to [constant Vector2i.ZERO] - the chunk at world origin.[br]
## [br]
## [param chunk_offset] should have [member Vector2i.x] and [member Vector2i.y]
## representing the [b]whole-chunk[/b] offset, i.e. [code]Vector2i(2, -3)[/code]
## points to 2 chunks to the right and 3 chunks to the bottom of the chunk at
## world origin.
func create_chunk(chunk_offset: Vector2i = Vector2i.ZERO) -> void:
	# Row-major mapping of the 2D terrain chunk.
	var chunk_linear_data: Array[World.TerrainTypes] = []

	world.get_terrain_tile_map_layer().clear()
	# TODO: This hangs the Godot Editor, find out why.
	# world.get_terrain_features_layer().clear()

	_create_chunk_height_map(chunk_linear_data, chunk_offset)
	_create_chunk_moisture_map(chunk_linear_data, chunk_offset)
	_create_chunk_forest_map(chunk_linear_data, chunk_offset)
	_create_chunk_fish_map(chunk_linear_data, chunk_offset)
	_create_chunk_chasm_map(chunk_linear_data, chunk_offset)
	_render_chunk(chunk_linear_data, chunk_offset)

	## TODO: Implement terrain features and chunk offset calculations.

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private methods

# TODO: Remove this @warning_ignore when [param chunk_offset] is implemented.
@warning_ignore("unused_parameter")
func _create_chunk_height_map(
		chunk_linear_data: Array[World.TerrainTypes],
		chunk_offset: Vector2i = Vector2i.ZERO) -> void:
	for x in range(chunk_size.x):
		for y in range(chunk_size.y):
			var noise_value: float = h_map.get_noise_2d(
					x * h_noise_scale,
					y * h_noise_scale)

			if noise_value < h_water_height:
				chunk_linear_data.append(World.TerrainTypes.DeepWater)
			elif noise_value < h_land_height:
				chunk_linear_data.append(World.TerrainTypes.Plain)
			else:
				chunk_linear_data.append(World.TerrainTypes.PlainMountain)


# TODO: Remove this @warning_ignore when [param chunk_offset] is implemented.
@warning_ignore("unused_parameter")
func _create_chunk_moisture_map(
		chunk_linear_data: Array[World.TerrainTypes],
		chunk_offset: Vector2i = Vector2i.ZERO) -> void:
	for x in range(chunk_size.x):
		for y in range(chunk_size.y):
			var noise_value: float = h_map.get_noise_2d(
					x * h_noise_scale,
					y * h_noise_scale)
			var index: int = Globals.coords_2d_to_linear_index(
					Vector2i(x, y),
					chunk_size)

			if chunk_linear_data[index] == World.TerrainTypes.Plain:
				if noise_value < m_desert_height:
					chunk_linear_data[index] = World.TerrainTypes.Desert
				elif noise_value >= m_plain_height:
					chunk_linear_data[index] = World.TerrainTypes.FertilePlain

			if chunk_linear_data[index] == World.TerrainTypes.PlainMountain:
				if noise_value < m_desert_height:
					chunk_linear_data[index] = World.TerrainTypes.DesertMountain
				elif noise_value >= m_plain_height:
					chunk_linear_data[index] = World.TerrainTypes.FertilePlainMountain


# TODO: Remove this @warning_ignore when [param chunk_offset] is implemented.
@warning_ignore("unused_parameter")
func _create_chunk_forest_map(
		chunk_linear_data: Array[World.TerrainTypes],
		chunk_offset: Vector2i = Vector2i.ZERO) -> void:
	for x in range(chunk_size.x):
		for y in range(chunk_size.y):
			var noise_value: float = t_map.get_noise_2d(
					x * t_noise_scale,
					y * t_noise_scale)
			var index: int = Globals.coords_2d_to_linear_index(
					Vector2i(x, y),
					chunk_size)

			if chunk_linear_data[index] == World.TerrainTypes.Plain:
				if noise_value > t_height:
					chunk_linear_data[index] = World.TerrainTypes.PlainForest

			if chunk_linear_data[index] == World.TerrainTypes.FertilePlain:
				if noise_value > t_height:
					chunk_linear_data[index] = World.TerrainTypes.FertilePlainForest


# TODO: Remove this @warning_ignore when [param chunk_offset] is implemented.
@warning_ignore("unused_parameter")
func _create_chunk_fish_map(
		chunk_linear_data: Array[World.TerrainTypes],
		chunk_offset: Vector2i = Vector2i.ZERO) -> void:
	for x in range(chunk_size.x):
		for y in range(chunk_size.y):
			var noise_value: float = t_map.get_noise_2d(
					x * t_noise_scale,
					y * t_noise_scale)
			var index: int = Globals.coords_2d_to_linear_index(
					Vector2i(x, y),
					chunk_size)

			if chunk_linear_data[index] == World.TerrainTypes.Plain:
				if noise_value > t_height:
					chunk_linear_data[index] = World.TerrainTypes.PlainForest

			if chunk_linear_data[index] == World.TerrainTypes.FertilePlain:
				if noise_value > t_height:
					chunk_linear_data[index] = World.TerrainTypes.FertilePlainForest


# TODO: Remove this @warning_ignore when [param chunk_offset] is implemented.
@warning_ignore("unused_parameter")
func _create_chunk_chasm_map(
		chunk_linear_data: Array[World.TerrainTypes],
		chunk_offset: Vector2i = Vector2i.ZERO) -> void:
	for x in range(chunk_size.x):
		for y in range(chunk_size.y):
			var noise_value: float = t_map.get_noise_2d(
					x * t_noise_scale,
					y * t_noise_scale)
			var index: int = Globals.coords_2d_to_linear_index(
					Vector2i(x, y),
					chunk_size)

			if chunk_linear_data[index] == World.TerrainTypes.Plain:
				if noise_value > t_height:
					chunk_linear_data[index] = World.TerrainTypes.PlainForest

			if chunk_linear_data[index] == World.TerrainTypes.FertilePlain:
				if noise_value > t_height:
					chunk_linear_data[index] = World.TerrainTypes.FertilePlainForest


# TODO: Remove this @warning_ignore when [param chunk_offset] is implemented.
@warning_ignore("unused_parameter")
func _render_chunk(
		chunk_linear_data: Array[World.TerrainTypes],
		chunk_offset: Vector2i = Vector2i.ZERO) -> void:
	# Render chunk_linear_data onto World.
	for index in range(chunk_linear_data.size()):
		var terrain_type: World.TerrainTypes = chunk_linear_data[index]
		world.set_terrain_at(
				Globals.linear_index_to_coords_2d(index, chunk_size),
				terrain_type)

	# Insert ShallowWater tiles.
	var tile_map: TileMapLayer = world.get_terrain_tile_map_layer()
	for index in range(chunk_linear_data.size()):
		if chunk_linear_data[index] == World.TerrainTypes.DeepWater:
			var coords: Vector2i = Globals.linear_index_to_coords_2d(
					index,
					chunk_size)
			var neighbors_coords: Array[Vector2i] = tile_map\
					.get_surrounding_cells(coords)
			for neighbor_coords in neighbors_coords:
				var atlas_coords: Vector2i = tile_map.get_cell_atlas_coords(neighbor_coords)
				if atlas_coords not in [
					tile_map.ATLAS_COORDS[World.TerrainTypes.DeepWater],
					tile_map.ATLAS_COORDS[World.TerrainTypes.ShallowWater],
					tile_map.ATLAS_COORDS[World.TerrainTypes.ShallowWaterFish],
				]:
					world.set_terrain_at(
							coords,
							World.TerrainTypes.ShallowWater)
					break

#endregion
# ============================================================================ #

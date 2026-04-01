class_name WorldGenerator
extends Node
## Handles procedural world generation.


# ============================================================================ #
#region Exported propertoes

@export_group("Height Map", "h")

# Height map generation noise algorithm. Produces Water / Plain / Mountain based
# on noise values.
@export var h_map: FastNoiseLite = preload(
		"res://resources/world_generator/height_map_noise.tres")

## Affects how large/small the generated biomes would be.
@export_range(0.1, 10.0, 0.1, "or_greater") var h_noise_scale: float = 1.0

## Noise values below this generates Deep Water (water).
@export_range(-1.0, 1.0, 0.01) var h_water_height: float = -0.5

## Noise values between Water Height and this generates Plain (land). Noise
## values above or equal to this generates Mountain.
@export_range(-1.0, 1.0, 0.01) var h_land_height: float = 0.5


# Moisture map generation noise algorithm. Produces Fertile Plain / Desert based
# on noise values.
@export_group("Moisture Map", "m")

# Moisture map generation noise algorithm. Produces Desert / Plain / Fertile
# Plain based on noise values.
@export var m_map: FastNoiseLite = preload(
		"res://resources/world_generator/moisture_map_noise.tres")

## Affects how large/small the generated biomes would be.
@export_range(0.1, 10.0, 0.1, "or_greater") var m_noise_scale: float = 1.0

## Noise values below this generates Desert.
@export_range(-1.0, 1.0, 0.01) var m_desert_height: float = -0.5

## Noise values between Desert Height and this generates Plain. Noise values
## above or equal to this generate Fertile Plain.
@export_range(-1.0, 1.0, 0.01) var m_plain_height: float = 0.5


# Chasm generation noise algorithm. Produces Chasm based on noise values.
@export_group("Chasm Map", "c")

# Chasm map generation noise algorithm. Produces Chasm based on noise values.
@export var c_map: FastNoiseLite = preload(
		"res://resources/world_generator/chasm_map_noise.tres")

## Affects how large/small the generated biomes would be.
@export_range(0.1, 10.0, 0.1, "or_greater") var c_noise_scale: float = 1.0

## Noise values above or equal to this generates Chasm.
@export_range(-1.0, 1.0, 0.01) var c_height: float = 0.0


# Dunes generation noise algorithm. Produces Dunes based on noise values.
@export_group("Dunes Map", "d")

# Forest map generation noise algorithm. Produces Forest based on noise values.
@export var d_map: FastNoiseLite = preload(
		"res://resources/world_generator/dunes_map_noise.tres")

## Affects how large/small the generated biomes would be.
@export_range(0.1, 10.0, 0.1, "or_greater") var d_noise_scale: float = 1.0

## Noise values above or equal to this generates Dunes.
@export_range(-1.0, 1.0, 0.01) var d_height: float = 0.0


# Forest generation noise algorithm. Produces Forest based on noise values.
@export_group("Forest Map", "t")

# Forest map generation noise algorithm. Produces Forest based on noise values.
@export var t_map: FastNoiseLite = preload(
		"res://resources/world_generator/forest_map_noise.tres")

## Affects how large/small the generated biomes would be.
@export_range(0.1, 10.0, 0.1, "or_greater") var t_noise_scale: float = 1.0

## Noise values above or equal to this generates Forest.
@export_range(-1.0, 1.0, 0.01) var t_height: float = 0.0


# Fish generation noise algorithm. Produces Fish based on noise values.
@export_group("Fish Map", "f")

# Fish map generation noise algorithm. Produces Fish based on noise values.
@export var f_map: FastNoiseLite = preload(
		"res://resources/world_generator/fish_map_noise.tres")

## Affects how large/small the generated biomes would be.
@export_range(0.1, 10.0, 0.1, "or_greater") var f_noise_scale: float = 1.0

## Noise values above or equal to this generates Fish.
@export_range(-1.0, 1.0, 0.01) var f_height: float = 0.0


@export_group("Output")

## The amount of tiles generated at once in a chunk. Given in [Vector2i]
## dimensions.
@export var chunk_size: Vector2i = Vector2i(32, 33)

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

## Generates new seeds for the generator, effectively creating a new world.
func generate_seeds() -> void:
	h_map.seed = _rng.randi()
	m_map.seed = _rng.randi()
	c_map.seed = _rng.randi()
	d_map.seed = _rng.randi()
	t_map.seed = _rng.randi()
	f_map.seed = _rng.randi()


## Returns the current world's seeds.
func get_seeds() -> Dictionary[String, int]:
	return {
		"height_map_seed": h_map.seed,
		"moisture_map_seed": m_map.seed,
		"chasm_map_seed": c_map.seed,
		"dunes_map_seed": d_map.seed,
		"forest_map_seed": t_map.seed,
		"fish_map_seed": f_map.seed,
	}


## Generates new world chunk at [param chunk_offset]. [param chunk_offset]
## defaults to [constant Vector2i.ZERO] - the chunk at world origin.[br]
## [br]
## Example: [code]Vector2i(2, -3)[/code] points to 2 chunks to the right and 3
## chunks to the bottom relative to the chunk at origin.
func create_chunk(chunk_offset: Vector2i = Vector2i.ZERO) -> void:
	# Row-major mapping of the 2D terrain chunk.
	var chunk_linear_data: Array[World.TerrainTypes] = []

	# Set chunk offset.
	h_map.offset = Vector3(
			chunk_offset.x * chunk_size.x * h_noise_scale,
			chunk_offset.y * chunk_size.y * h_noise_scale,
			0.0)
	m_map.offset = Vector3(
			chunk_offset.x * chunk_size.x * m_noise_scale,
			chunk_offset.y * chunk_size.y * m_noise_scale,
			0.0)
	c_map.offset = Vector3(
			chunk_offset.x * chunk_size.x * c_noise_scale,
			chunk_offset.y * chunk_size.y * c_noise_scale,
			0.0)
	d_map.offset = Vector3(
			chunk_offset.x * chunk_size.x * d_noise_scale,
			chunk_offset.y * chunk_size.y * d_noise_scale,
			0.0)
	t_map.offset = Vector3(
			chunk_offset.x * chunk_size.x * t_noise_scale,
			chunk_offset.y * chunk_size.y * t_noise_scale,
			0.0)
	f_map.offset = Vector3(
			chunk_offset.x * chunk_size.x * f_noise_scale,
			chunk_offset.y * chunk_size.y * f_noise_scale,
			0.0)

	# WARNING: DO NOT RE-ORDER THE FOLLOWING PRIVATE METHOD CALLS. IT WILL BREAK
	# THE PROCEDURAL GENERATION ALGORITHM.
	_create_chunk_height_map(chunk_linear_data)
	_create_chunk_moisture_map(chunk_linear_data)
	_create_chunk_chasm_map(chunk_linear_data)
	_create_chunk_dunes_map(chunk_linear_data)
	_create_chunk_forest_map(chunk_linear_data)
	_render_chunk(chunk_linear_data, chunk_offset)
	#_insert_chunk_shallow_water(chunk_linear_data, chunk_offset)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private methods


# Returns the [param coords]' surrounding noise map coordinates, adjusted for
# Godot's TileMapLayer hex coordinate system (odd-r). C.f.
# https://www.redblobgames.com/grids/hexagons/#coordinates-offset
func _get_surrounding_noise_coords(coords: Vector2i) -> Array[Vector2i]:
	var surrounding_coords: Array[Vector2i] = []

	surrounding_coords.append(coords + Vector2i.LEFT)
	surrounding_coords.append(coords + Vector2i.RIGHT)
	surrounding_coords.append(coords + Vector2i.UP)
	surrounding_coords.append(coords + Vector2i.DOWN)
	if posmod(coords.y, 2) == 0: # Even rows.
		surrounding_coords.append(coords + Vector2i.UP + Vector2i.LEFT)
		surrounding_coords.append(coords + Vector2i.DOWN + Vector2i.LEFT)
	else: # Odd rows.
		surrounding_coords.append(coords + Vector2i.UP + Vector2i.RIGHT)
		surrounding_coords.append(coords + Vector2i.DOWN + Vector2i.RIGHT)

	return surrounding_coords


# 1st Step.
func _create_chunk_height_map(chunk_linear_data: Array[World.TerrainTypes]) -> void:
	for y in range(chunk_size.y):
		for x in range(chunk_size.x):
			var noise_value: float = h_map.get_noise_2d(
					x * h_noise_scale,
					y * h_noise_scale)

			if noise_value < h_water_height:
				var water_type: World.TerrainTypes = World.TerrainTypes.DeepWater
				for neighbor_coords in _get_surrounding_noise_coords(Vector2i(x, y)):
					var neighbor_noise_value: float = h_map.get_noise_2d(
							neighbor_coords.x * h_noise_scale,
							neighbor_coords.y * h_noise_scale)
					if neighbor_noise_value >= h_water_height:
						water_type = World.TerrainTypes.ShallowWater
						break
				chunk_linear_data.append(water_type)
			elif noise_value < h_land_height:
				chunk_linear_data.append(World.TerrainTypes.Plain)
			else:
				chunk_linear_data.append(World.TerrainTypes.PlainMountain)


# 2nd Step.
func _create_chunk_moisture_map(chunk_linear_data: Array[World.TerrainTypes]) -> void:
	for y in range(chunk_size.y):
		for x in range(chunk_size.x):
			var noise_value: float = m_map.get_noise_2d(
					x * m_noise_scale,
					y * m_noise_scale)
			var index: int = Global.coords_2d_to_linear_index(
					Vector2i(x, y),
					chunk_size)

			if chunk_linear_data[index] == World.TerrainTypes.Plain:
				if noise_value < m_desert_height:
					chunk_linear_data[index] = World.TerrainTypes.Desert
				elif noise_value >= m_plain_height:
					chunk_linear_data[index] = World.TerrainTypes.Grassland

			if chunk_linear_data[index] == World.TerrainTypes.PlainMountain:
				if noise_value < m_desert_height:
					chunk_linear_data[index] = World.TerrainTypes.DesertMountain
				elif noise_value >= m_plain_height:
					chunk_linear_data[index] = World.TerrainTypes.GrasslandMountain


# 3rd Step.
func _create_chunk_chasm_map(chunk_linear_data: Array[World.TerrainTypes]) -> void:
	for y in range(chunk_size.y):
		for x in range(chunk_size.x):
			var noise_value: float = c_map.get_noise_2d(
					x * c_noise_scale,
					y * c_noise_scale)
			if noise_value < c_height:
				continue

			var index: int = Global.coords_2d_to_linear_index(
					Vector2i(x, y),
					chunk_size)
			match chunk_linear_data[index]:
				World.TerrainTypes.PlainMountain:
					chunk_linear_data[index] = World.TerrainTypes.PlainChasm
				World.TerrainTypes.GrasslandMountain:
					chunk_linear_data[index] = World.TerrainTypes.GrasslandChasm
				World.TerrainTypes.DesertMountain:
					chunk_linear_data[index] = World.TerrainTypes.DesertChasm


# 4th Step.
func _create_chunk_dunes_map(chunk_linear_data: Array[World.TerrainTypes]) -> void:
	for y in range(chunk_size.y):
		for x in range(chunk_size.x):
			var noise_value: float = d_map.get_noise_2d(
					x * d_noise_scale,
					y * d_noise_scale)
			if noise_value < d_height:
				continue

			var index: int = Global.coords_2d_to_linear_index(
					Vector2i(x, y),
					chunk_size)
			if chunk_linear_data[index] == World.TerrainTypes.Desert:
					chunk_linear_data[index] = World.TerrainTypes.DesertDunes


# 5th Step.
func _create_chunk_forest_map(chunk_linear_data: Array[World.TerrainTypes]) -> void:
	for y in range(chunk_size.y):
		for x in range(chunk_size.x):
			var noise_value: float = t_map.get_noise_2d(
					x * t_noise_scale,
					y * t_noise_scale)
			if noise_value < t_height:
				continue

			var index: int = Global.coords_2d_to_linear_index(
					Vector2i(x, y),
					chunk_size)
			match chunk_linear_data[index]:
				World.TerrainTypes.Plain:
					chunk_linear_data[index] = World.TerrainTypes.PlainForest
				World.TerrainTypes.Grassland:
					chunk_linear_data[index] = World.TerrainTypes.Grassland


# 6th Step. Renders [param chunk_linear_data] onto [World].
func _render_chunk(
		chunk_linear_data: Array[World.TerrainTypes],
		chunk_offset: Vector2i = Vector2i.ZERO
) -> void:
	for index in range(chunk_linear_data.size()):
		var terrain_type: World.TerrainTypes = chunk_linear_data[index]
		var coords: Vector2i = Global.linear_index_to_coords_2d(index, chunk_size)
		coords.x += chunk_offset.x * chunk_size.x
		coords.y += chunk_offset.y * chunk_size.y

		world.set_terrain_at(
				coords,
				terrain_type)


# 7th Step.
func _insert_chunk_shallow_water(
		chunk_linear_data: Array[World.TerrainTypes],
		chunk_offset: Vector2i = Vector2i.ZERO
) -> void:
	# Insert ShallowWater tiles.
	var tile_map: TileMapLayer = world.get_terrain_tile_map_layer()
	for index in range(chunk_linear_data.size()):
		if chunk_linear_data[index] == World.TerrainTypes.DeepWater:
			var coords: Vector2i = Global.linear_index_to_coords_2d(index, chunk_size)
			coords.x += chunk_offset.x * chunk_size.x
			coords.y += chunk_offset.y * chunk_size.y

			var neighbors_coords: Array[Vector2i] = tile_map.get_surrounding_cells(coords)
			for neighbor_coords in neighbors_coords:
				var atlas_coords: Vector2i = tile_map.get_cell_atlas_coords(neighbor_coords)
				if atlas_coords not in [
					tile_map.ATLAS_COORDS[World.TerrainTypes.None],
					tile_map.ATLAS_COORDS[World.TerrainTypes.ShallowWater],
					tile_map.ATLAS_COORDS[World.TerrainTypes.ShallowWaterFishes],
					tile_map.ATLAS_COORDS[World.TerrainTypes.DeepWater],
				]:
					var f_noise_value: float = f_map.get_noise_2d(
							coords.x * f_noise_scale,
							coords.y * f_noise_scale)

					if f_noise_value < f_height: # No fish.
						world.set_terrain_at(
								coords,
								World.TerrainTypes.ShallowWater)
					else: # Has fish
						world.set_terrain_at(
								coords,
								World.TerrainTypes.ShallowWaterFishes)

					break

#endregion
# ============================================================================ #

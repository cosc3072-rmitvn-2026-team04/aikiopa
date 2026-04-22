class_name WorldGenerator
extends Node
## Handles procedural world generation.


# ============================================================================ #
#region Exported properties

@export_group("Variation Map", "v")

# Variation map generation noise algorithm. Produce float values used to select
# random variations of a game object.
@export var v_map: FastNoiseLite = preload(
	"res://resources/world_generator/variation_map_noise.tres")


## Affects how large/small the generated variation areas would be.
@export_range(0.1, 1.0, 0.01, "or_greater") var v_noise_scale: float = 1.0

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

## Radius of the guaranteed buildable area in the center of the first chunk,
## where the player starts at.
@export_range(2, 12, 1, "suffix:tiles") var h_guaranteed_buildable_radius: int = 3


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
@export var chunk_size: Vector2i = Vector2i(16, 17)

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

## Generates new random seeds for the generator's internal terrain map modules,
## effectively creating a new world. Accepts an optional parameter
## [param rng_seed] to deterministically restore a world using the given seed.
func generate_seeds(rng_seed: Variant = null) -> void:
	if rng_seed:
		_rng.seed = rng_seed as int
	else:
		_rng.randomize()
	Global.game_state.world_seed = get_seed()
	v_map.seed = _rng.randi()
	h_map.seed = _rng.randi()
	m_map.seed = _rng.randi()
	c_map.seed = _rng.randi()
	d_map.seed = _rng.randi()
	t_map.seed = _rng.randi()
	f_map.seed = _rng.randi()


## Returns the current world's seed. Useful for saving and restoring game
## sessions.
func get_seed() -> int:
	return _rng.seed


## Returns the current world's seed and its corresponding internal terrain
## module seeds. Useful for debugging.
func get_internal_seeds() -> Dictionary[String, int]:
	return {
		"master": _rng.seed,
		"variation_map_seed": v_map.seed,
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
	var chunk_linear_data: Array[World.TerrainType] = []

	# Row-major mapping of the 2D terrain variation chunk.
	var chunk_linear_variation_data: Array[float]

	# Set chunk offset.
	v_map.offset = Vector3(
			chunk_offset.x * chunk_size.x * v_noise_scale,
			chunk_offset.y * chunk_size.y * v_noise_scale,
			0.0)
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
	_create_chunk_variation_map(chunk_linear_variation_data)
	_create_chunk_height_map(chunk_linear_data, chunk_offset)
	_create_chunk_moisture_map(chunk_linear_data)
	_create_chunk_chasm_map(chunk_linear_data)
	_create_chunk_dunes_map(chunk_linear_data)
	_create_chunk_forest_map(chunk_linear_data)
	_create_chunk_fish_map(chunk_linear_data)
	_render_chunk(chunk_linear_data, chunk_linear_variation_data, chunk_offset)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private methods


# Returns the [param coords]' surrounding noise map coordinates, adjusted for
# [param chunk_offset] in relation to Godot's TileMapLayer hex coordinate system
# (odd-r). Cf. https://www.redblobgames.com/grids/hexagons/#coordinates-offset
func _get_chunk_surrounding_noise_coords(
		coords: Vector2i,
		chunk_offset: Vector2i
) -> Array[Vector2i]:
	return (
			Math.HexGrid.get_offset_surrounding_neighbors(
				coords,
				Math.HexGrid.OffsetLayout.ODD_R) if chunk_offset.y & 0b1 == 0
			else
			Math.HexGrid.get_offset_surrounding_neighbors(
				coords,
				Math.HexGrid.OffsetLayout.EVEN_R))


# Ensures a buildable area in the center of the first chunk for the player to
# start on.
func _first_chunk_noise(noise_value: float, position: Vector2i) -> float:
	var cube_center: Vector3 = Vector3(Math.HexGrid.offset_to_cube(
			chunk_size * 0.5,
			Math.HexGrid.OffsetLayout.ODD_R))
	var cube_position: Vector3 = Vector3(Math.HexGrid.offset_to_cube(
			position,
			Math.HexGrid.OffsetLayout.ODD_R))
	var distance_to_chunk_center: float =\
			(cube_position - cube_center).length_squared()
	if distance_to_chunk_center <= pow(h_guaranteed_buildable_radius, 2):
		return (h_water_height + h_land_height) / 2
	return noise_value


# 1st Step.
func _create_chunk_variation_map(chunk_linear_variation_data: Array[float]) -> void:
	for y: int in range(chunk_size.y):
		for x: int in range(chunk_size.x):
			var noise_value: float = h_map.get_noise_2d(
					x * h_noise_scale,
					y * h_noise_scale)
			chunk_linear_variation_data.append(noise_value)


# 2nd Step.
func _create_chunk_height_map(
		chunk_linear_data: Array[World.TerrainType],
		chunk_offset: Vector2i
) -> void:
	for y: int in range(chunk_size.y):
		for x: int in range(chunk_size.x):
			var noise_value: float = h_map.get_noise_2d(
					x * h_noise_scale,
					y * h_noise_scale)
			if chunk_offset == Vector2i.ZERO:
				noise_value = _first_chunk_noise(
						noise_value,
						Vector2i(x, y))

			if noise_value < h_water_height:
				var water_type: World.TerrainType = World.TerrainType.DEEP_WATER
				for neighbor_coords in _get_chunk_surrounding_noise_coords(Vector2i(x, y), chunk_offset):
					var neighbor_noise_value: float = h_map.get_noise_2d(
							neighbor_coords.x * h_noise_scale,
							neighbor_coords.y * h_noise_scale)
					if chunk_offset == Vector2i.ZERO:
						neighbor_noise_value = _first_chunk_noise(
								neighbor_noise_value,
								neighbor_coords)

					if not (neighbor_noise_value < h_water_height):
						water_type = World.TerrainType.SHALLOW_WATER
						break
				chunk_linear_data.append(water_type)
			elif noise_value < h_land_height:
				chunk_linear_data.append(World.TerrainType.PLAIN)
			else:
				chunk_linear_data.append(World.TerrainType.PLAIN_MOUNTAIN)


# 3rd Step.
func _create_chunk_moisture_map(chunk_linear_data: Array[World.TerrainType]) -> void:
	for y: int in range(chunk_size.y):
		for x: int in range(chunk_size.x):
			var noise_value: float = m_map.get_noise_2d(
					x * m_noise_scale,
					y * m_noise_scale)
			var index: int = Math.Matrix.coords_2d_to_linear_index(
					Vector2i(x, y),
					chunk_size)

			if chunk_linear_data[index] == World.TerrainType.PLAIN:
				if noise_value < m_desert_height:
					chunk_linear_data[index] = World.TerrainType.DESERT
				elif noise_value >= m_plain_height:
					chunk_linear_data[index] = World.TerrainType.GRASSLAND

			if chunk_linear_data[index] == World.TerrainType.PLAIN_MOUNTAIN:
				if noise_value < m_desert_height:
					chunk_linear_data[index] = World.TerrainType.DESERT_MOUNTAIN
				elif noise_value >= m_plain_height:
					chunk_linear_data[index] = World.TerrainType.GRASSLAND_MOUNTAIN


# 4th Step. x and y are swapped to produce more interesting features.
func _create_chunk_chasm_map(chunk_linear_data: Array[World.TerrainType]) -> void:
	for x: int in range(chunk_size.x):
		for y: int in range(chunk_size.y):
			var noise_value: float = c_map.get_noise_2d(
					x * c_noise_scale,
					y * c_noise_scale)
			if noise_value < c_height:
				continue

			var index: int = Math.Matrix.coords_2d_to_linear_index(
					Vector2i(x, y),
					chunk_size)
			match chunk_linear_data[index]:
				World.TerrainType.PLAIN_MOUNTAIN:
					chunk_linear_data[index] = World.TerrainType.PLAIN_CHASM
				World.TerrainType.GRASSLAND_MOUNTAIN:
					chunk_linear_data[index] = World.TerrainType.GRASSLAND_CHASM
				World.TerrainType.DESERT_MOUNTAIN:
					chunk_linear_data[index] = World.TerrainType.DESERT_CHASM


# 5th Step. x and y are swapped to produce more interesting features.
func _create_chunk_dunes_map(chunk_linear_data: Array[World.TerrainType]) -> void:
	for x: int in range(chunk_size.x):
		for y: int in range(chunk_size.y):
			var noise_value: float = d_map.get_noise_2d(
					x * d_noise_scale,
					y * d_noise_scale)
			if noise_value < d_height:
				continue

			var index: int = Math.Matrix.coords_2d_to_linear_index(
					Vector2i(x, y),
					chunk_size)
			if chunk_linear_data[index] == World.TerrainType.DESERT:
					chunk_linear_data[index] = World.TerrainType.DESERT_SAND_DUNES


# 6th Step. x and y are swapped to produce more interesting features.
func _create_chunk_forest_map(chunk_linear_data: Array[World.TerrainType]) -> void:
	for x: int in range(chunk_size.x):
		for y: int in range(chunk_size.y):
			var noise_value: float = t_map.get_noise_2d(
					x * t_noise_scale,
					y * t_noise_scale)
			if noise_value < t_height:
				continue

			var index: int = Math.Matrix.coords_2d_to_linear_index(
					Vector2i(x, y),
					chunk_size)
			match chunk_linear_data[index]:
				World.TerrainType.PLAIN:
					chunk_linear_data[index] = World.TerrainType.PLAIN_FOREST
				World.TerrainType.GRASSLAND:
					chunk_linear_data[index] = World.TerrainType.GRASSLAND_FOREST


# 7th Step.
func _create_chunk_fish_map(chunk_linear_data: Array[World.TerrainType]) -> void:
	for index in range(chunk_linear_data.size()):
		if chunk_linear_data[index] == World.TerrainType.SHALLOW_WATER:
			var coords: Vector2i = Math.Matrix.linear_index_to_coords_2d(index, chunk_size)
			var noise_value: float = f_map.get_noise_2d(
					coords.x * f_noise_scale,
					coords.y * f_noise_scale)
			if noise_value >= f_height:
				chunk_linear_data[index] = World.TerrainType.SHALLOW_WATER_FISHES


# 8th Step. Renders [param chunk_linear_data] onto [World].
func _render_chunk(
		chunk_linear_data: Array[World.TerrainType],
		chunk_linear_variation_data: Array[float],
		chunk_offset: Vector2i
) -> void:
	for index in range(chunk_linear_data.size()):
		var terrain_type: World.TerrainType = chunk_linear_data[index]
		var coords: Vector2i = Math.Matrix.linear_index_to_coords_2d(index, chunk_size)
		var variation_value: float = chunk_linear_variation_data[
				Math.Matrix.coords_2d_to_linear_index(coords, chunk_size)]
		coords.x += chunk_offset.x * chunk_size.x
		coords.y += chunk_offset.y * chunk_size.y

		world.set_terrain_at(
				coords,
				terrain_type,
				variation_value)

#endregion
# ============================================================================ #

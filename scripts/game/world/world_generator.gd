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
@export_range(0.1, 0.1, 1.0, "or_greater") var h_noise_scale: float = 0.5

## Noise values below this generates Deep Water (water).
@export_range(-1.0, 1.0, 0.1) var h_water_height: float = -0.2

## Noise values between Water Height and this generates Plain (land). Noise
## values larger or equal to this generates Mountain.
@export_range(-1.0, 1.0, 0.1) var h_land_height: float = -0.4


# Moisture map generation noise algorithm. Produces Fertile Plain / Desert based
# on noise values
@export_group("Moisture Map", "m")

# Moisture map generation noise algorithm. Produces Desert / Plain / Fertile
# Plain based on noise values.
@export var m_map: FastNoiseLite = null

## Affects how large/small the generated biomes would be.
@export_range(0.1, 0.1, 1.0, "or_greater") var m_noise_scale: float = 0.5

## Noise values below this generates Desert.
@export_range(-1.0, 1.0, 0.1) var m_desert_height: float = -0.6

## Noise values between Desert Height and this generates Plain. Noise values
## larger or equal to this generate Fertile Plain.
@export_range(-1.0, 1.0, 0.1) var m_plain_height: float = -0.6


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


## Returns the current world's seeds.
func get_seeds() -> Dictionary[String, int]:
	return {
		"height_map_seed": h_map.seed,
		"moisture_map_seed": m_map.seed
	}


## Generates new chunk at [param offset]. [param offset] defaults to
## [constant Vector2i.ZERO] - the chunk at world origin.[br]
## [br]
## [param offset] should have [member Vector2i.x] and [member Vector2i.y]
## representing the [b]whole-chunk[/b] offset, i.e. [code]Vector2i(2, -3)[/code]
## points to 2 chunks to the right and 3 chunks to the bottom of the chunk at
## world origin.
func create_chunk(offset: Vector2i = Vector2i.ZERO) -> void:
	world.get_terrain_tile_map_layer().clear()
	# world.get_terrain_features_layer().clear()
	# world.get_buildings_layer().clear()

	# for x in range(chunk_size.x):
	# 	for y in range(chunk_size.y):
	# 		var noise_value: float = noise_generator.get_noise_2d(
	# 				x * noise_scale, y * noise_scale
	# 		)

	# 		if noise_value < water_height:
	# 			world.set_terrain_at(
	# 					Vector2i(x, y),
	# 					World.TerrainTypes.DeepWater
	# 			)
	# 		elif noise_value < plain_height:
	# 			world.set_terrain_at(
	# 					Vector2i(x, y),
	# 					World.TerrainTypes.Plain
	# 			)
	# 		elif noise_value < fertile_plain_height:
	# 			world.set_terrain_at(
	# 					Vector2i(x, y),
	# 					World.TerrainTypes.FertilePlain
	# 			)
	# 		elif noise_value < desert_height:
	# 			world.set_terrain_at(
	# 					Vector2i(x, y),
	# 					World.TerrainTypes.Desert
	# 			)
	# 		else:
	# 			world.set_terrain_at(
	# 					Vector2i(x, y),
	# 					World.TerrainTypes.PlainMountain
	# 			)

	## TODO: Implement terrain features and chunk offset calculations.

#endregion
# ============================================================================ #

class_name WorldGenerator
extends Node
## Handles procedural world generation.


# ============================================================================ #
#region Exported propertoes

@export_group("Noise Source")

## Terrain generation noise algorithm.
@export var noise_generator: FastNoiseLite = null

## Affects how large/small the generated terrain biomes would be.
@export var noise_scale: float = 0.5


@export_group("Terrain Tuning")
@export var water_height: float = -0.2
@export var plain_height: float = -0.4
@export var fertile_plain_height: float = -0.6
@export var desert_height: float = -0.8
@export var mountain_height: float = 0.0


@export_group("Output")
@export var chunk_size: Vector2i = Vector2i(128, 128)
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

## Generates a new seed for the generator, effectively creating a new world.
func generate_seed() -> void:
	noise_generator.seed = _rng.randi()


## Returns the current world seed.
func get_seed() -> int:
	return noise_generator.seed


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

	for x in range(chunk_size.x):
		for y in range(chunk_size.y):
			var noise_value: float = noise_generator.get_noise_2d(
					x * noise_scale, y * noise_scale
			)
			if noise_value < water_height:
				world.set_terrain_at(
						Vector2i(x, y),
						World.TerrainTypes.DeepWater
				)
			elif noise_value < plain_height:
				world.set_terrain_at(
						Vector2i(x, y),
						World.TerrainTypes.Plain
				)
			elif noise_value < fertile_plain_height:
				world.set_terrain_at(
						Vector2i(x, y),
						World.TerrainTypes.FertilePlain
				)
			elif noise_value < desert_height:
				world.set_terrain_at(
						Vector2i(x, y),
						World.TerrainTypes.Desert
				)
			elif noise_value < mountain_height:
				world.set_terrain_at(
						Vector2i(x, y),
						World.TerrainTypes.PlainMountain
				)

	## TODO: Implement terrain features and chunk offset calculations.

#endregion
# ============================================================================ #

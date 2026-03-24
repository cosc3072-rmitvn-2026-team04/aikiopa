extends Node


# ============================================================================ #
#region Exported propertoes

@export_group("Noise Source")

## Terrain generation noise algorithm.
@export var noise_generator: FastNoiseLite = null

## Affects how large/small the generated terrain biomes would be.
@export var noise_scale: float = 0.5


@export_group("Terrain Tuning")
@export var water_height: float = 0.0
@export var plain_height: float = 0.0
@export var fertile_plain_height: float = 0.0
@export var desert_height: float = 0.0
@export var mountain_height: float = 0.0


@export_group("Output")
@export var chunk_size: Vector2i = Vector2i(128, 128)
@export var terrain_layer: TileMapLayer = null
@export var terrain_features_layer: Node2D = null

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private variables

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _seed: int = int(NAN)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Generates a new seed for the generator, effectively creating a new world.
func generate_seed() -> void:
	_seed = _rng.randi()


## Returns the current world seed.
func get_seed() -> int:
	return _seed


## Generates new chunk at [param offset]. [param offset] defaults to
## [code]Vector2i(0, 0)[/code] - the origin chunk.
func create_chunk(offset: Vector2i = Vector2i(0, 0)) -> void:
	terrain_layer.clear()
	terrain_features_layer.clear()
	## TODO: Implement this.

#endregion
# ============================================================================ #

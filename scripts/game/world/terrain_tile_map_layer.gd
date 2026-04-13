extends TileMapLayer


## TileSet source for this [TileMapLayer].
const SOURCE_ID: int = 0

## Atlas coordinate data for [enum World.TerrainType].
const ATLAS_COORDS: Dictionary[World.TerrainType, Vector2i] = {
	World.TerrainType.NONE: Vector2i(-1, -1),
	World.TerrainType.SHALLOW_WATER: Vector2i(0, 0),
	World.TerrainType.SHALLOW_WATER_FISHES: Vector2i(0, 0),
	World.TerrainType.DEEP_WATER: Vector2i(1, 0),
	World.TerrainType.PLAIN: Vector2i(0, 1),
	World.TerrainType.PLAIN_FOREST: Vector2i(0, 1),
	World.TerrainType.PLAIN_MOUNTAIN: Vector2i(0, 1),
	World.TerrainType.PLAIN_CHASM: Vector2i(0, 1),
	World.TerrainType.GRASSLAND: Vector2i(1, 1),
	World.TerrainType.GRASSLAND_FOREST: Vector2i(1, 1),
	World.TerrainType.GRASSLAND_MOUNTAIN: Vector2i(1, 1),
	World.TerrainType.GRASSLAND_CHASM: Vector2i(1, 1),
	World.TerrainType.DESERT: Vector2i(2, 0),
	World.TerrainType.DESERT_SAND_DUNES: Vector2i(2, 0),
	World.TerrainType.DESERT_MOUNTAIN: Vector2i(2, 0),
	World.TerrainType.DESERT_CHASM: Vector2i(2, 0),
}

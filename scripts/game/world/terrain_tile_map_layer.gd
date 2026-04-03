extends TileMapLayer


## TileSet source for this [TileMapLayer].
const SOURCE_ID: int = 0

## Atlas coordinate data for [enum World.TerrainType].
const ATLAS_COORDS: Dictionary[World.TerrainType, Vector2i] = {
	World.TerrainType.None: Vector2i(-1, -1),
	World.TerrainType.ShallowWater: Vector2i(0, 0),
	World.TerrainType.ShallowWaterFishes: Vector2i(0, 0),
	World.TerrainType.DeepWater: Vector2i(1, 0),
	World.TerrainType.Plain: Vector2i(0, 1),
	World.TerrainType.PlainForest: Vector2i(0, 1),
	World.TerrainType.PlainMountain: Vector2i(0, 1),
	World.TerrainType.PlainChasm: Vector2i(0, 1),
	World.TerrainType.Grassland: Vector2i(1, 1),
	World.TerrainType.GrasslandForest: Vector2i(1, 1),
	World.TerrainType.GrasslandMountain: Vector2i(1, 1),
	World.TerrainType.GrasslandChasm: Vector2i(1, 1),
	World.TerrainType.Desert: Vector2i(2, 0),
	World.TerrainType.DesertDunes: Vector2i(2, 0),
	World.TerrainType.DesertMountain: Vector2i(2, 0),
	World.TerrainType.DesertChasm: Vector2i(2, 0),
}

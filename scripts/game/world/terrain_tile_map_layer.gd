extends TileMapLayer


## TileSet source for this [TileMapLayer].
const SOURCE_ID: int = 0

## Atlas coordinate data for [enum World.TerrainTypes].
const ATLAS_COORDS: Dictionary[World.TerrainTypes, Vector2i] = {
	World.TerrainTypes.ShallowWater: Vector2i(0, 0),
	World.TerrainTypes.ShallowWaterFishes: Vector2i(0, 0),
	World.TerrainTypes.DeepWater: Vector2i(1, 0),
	World.TerrainTypes.Plain: Vector2i(0, 1),
	World.TerrainTypes.PlainForest: Vector2i(0, 1),
	World.TerrainTypes.PlainMountain: Vector2i(0, 1),
	World.TerrainTypes.PlainChasm: Vector2i(0, 1),
	World.TerrainTypes.FertilePlain: Vector2i(1, 1),
	World.TerrainTypes.FertilePlainForest: Vector2i(1, 1),
	World.TerrainTypes.FertilePlainMountain: Vector2i(1, 1),
	World.TerrainTypes.FertilePlainChasm: Vector2i(1, 1),
	World.TerrainTypes.Desert: Vector2i(2, 0),
	World.TerrainTypes.DesertDunes: Vector2i(2, 0),
	World.TerrainTypes.DesertMountain: Vector2i(2, 0),
	World.TerrainTypes.DesertChasm: Vector2i(2, 0),
}

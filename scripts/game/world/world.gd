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

## Game terrain types including terrain features.
enum TerrainTypes {
	None,
	ShallowWater,
	ShallowWaterFish,
	DeepWater,
	Plain,
	PlainForest,
	PlainMountain,
	PlainChasm,
	FertilePlain,
	FertilePlainForest,
	FertilePlainMountain,
	FertilePlainChasm,
	Desert,
	DesertDunes,
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
#region Public methods

## Sets the terrain at [param coords] to one of [enum World.TerrainTypes].
## Automatically assign terrain feature variation(s) at random.
@warning_ignore("unused_parameter") # Remove when this function is implemented.
func set_terrain_at(coords: Vector2i, terrain: TerrainTypes) -> void:
	## TODO: Implement this.
	assert(false, "Game.set_terrain_at() not implemented")


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

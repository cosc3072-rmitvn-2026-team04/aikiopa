extends Node2D


# ============================================================================ #
#region Exported properties

@export var world: World = null

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private variables

var _landing_site_scene: PackedScene =\
		preload("res://scenes/game/objects/buildings/landing_site.tscn")
var _housing_scene: PackedScene =\
		preload("res://scenes/game/objects/buildings/housing.tscn")
var _greenhouse_scene: PackedScene =\
		preload("res://scenes/game/objects/buildings/greenhouse.tscn")
var _ranch_scene: PackedScene =\
		preload("res://scenes/game/objects/buildings/ranch.tscn")
var _fishery_scene: PackedScene =\
		preload("res://scenes/game/objects/buildings/fishery.tscn")
var _solar_farm_scene: PackedScene =\
		preload("res://scenes/game/objects/buildings/solar_farm.tscn")
var _wind_farm_scene: PackedScene =\
		preload("res://scenes/game/objects/buildings/wind_farm.tscn")
var _nuclear_reactor_scene: PackedScene =\
		preload("res://scenes/game/objects/buildings/nuclear_reactor.tscn")
var _factory_scene: PackedScene =\
		preload("res://scenes/game/objects/buildings/factory.tscn")

# The [Building] instances in the game. Identified by their [Vector2i]
# coordinates.
var _buildings: Dictionary[Vector2i, Building]

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Removes all buildings (child nodes).
func clear() -> void:
	if get_child_count() > 0:
		for building: Building in get_children():
			remove_child(building)
			building.queue_free()
	_buildings.clear()


## Returns the [enum Building.BuildingType] at [param coords].
func get_building_at(coords: Vector2i) -> Building.BuildingType:
	if not has_building_at(coords):
		return Building.BuildingType.NONE
	return _buildings[coords].get_type()


## Returns [code]true[/code] if there is a building at [param coords].
func has_building_at(coords: Vector2i) -> bool:
	return _buildings.has(coords)


## Sets the building at [param coords] to one of [enum Building.BuildingType].
## TODO: Deterministically assign variation(s) at random.[br]
## [br]
## Returns [code]false[/code] and prints an error if [param coords] is blocked
## by another building or [param building_type] is unknown.[br]
## [br]
## Set [param quiet] to [code]true[/code] to execute the placement without
## notifying other game systems. Useful for scripted game events.
func place_building_at(
		coords: Vector2i,
		building_type: Building.BuildingType,
		quiet: bool = false
) -> bool:
	if has_building_at(coords):
		push_error("Unable to set building at (%d, %d): Cell blocked by existing building." % [
				coords.x, coords.y
		])
		return false

	var building: Building = null
	match building_type:
		Building.BuildingType.LANDING_SITE:
			building = _landing_site_scene.instantiate()
		Building.BuildingType.HOUSING:
			building = _housing_scene.instantiate()
		Building.BuildingType.GREENHOUSE:
			building = _greenhouse_scene.instantiate()
		Building.BuildingType.RANCH:
			building = _ranch_scene.instantiate()
		Building.BuildingType.FISHERY:
			building = _fishery_scene.instantiate()
		Building.BuildingType.SOLAR_FARM:
			building = _solar_farm_scene.instantiate()
		Building.BuildingType.WIND_FARM:
			building = _wind_farm_scene.instantiate()
		Building.BuildingType.NUCLEAR_REACTOR:
			building = _nuclear_reactor_scene.instantiate()
		Building.BuildingType.FACTORY:
			building = _factory_scene.instantiate()
		_:
			push_error("Unable to set building at (%d, %d): Unknown 'building_type' %d." % [
				coords.x, coords.y,
				building_type,
			])
			return false

	var terrain_tile_map_layer: TileMapLayer = world.get_terrain_tile_map_layer()
	_buildings.set(coords, building)
	building.position = terrain_tile_map_layer.map_to_local(coords)
	add_child(building)

	if not quiet:
		GameplayEventBus.building_placed.emit(coords, building_type)
	return true


# TODO: Implement this in #87.
## Returns and destroys the building at [param coords].[br]
## [br]
## Returns [constant Building.BuildingType.NONE] if there is no building at
## [param coords].
func destroy_building_at(_coords: Vector2i) -> Building.BuildingType:
	push_error("Not implemented.")
	return Building.BuildingType.NONE

#endregion
# ============================================================================ #

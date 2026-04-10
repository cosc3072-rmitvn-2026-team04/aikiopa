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
func get_building_at(coords) -> Building.BuildingType:
	if not _buildings.has(coords):
		return Building.BuildingType.NONE
	return _buildings[coords].get_type()


## Sets the building at [param coords] to one of [enum Building.BuildingType].
## TODO: Deterministically assign variation(s) at random.[br]
## [br]
## Returns [code]false[/code] if [param coords] is blocked by terrain or another
## building; or if [param building_type] is unrecognized.
func set_building_at(
		coords: Vector2i,
		building_type: Building.BuildingType
) -> bool:
	if _buildings.has(coords):
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
			push_error("Unrecognized 'building_type' %d. Unable to set building at (%d, %d)." % [
				building_type,
				coords.x, coords.y
			])
			return false

	var terrain_tile_map_layer: TileMapLayer = world.get_terrain_tile_map_layer()
	_buildings.set(coords, building)
	building.position = terrain_tile_map_layer.map_to_local(coords)
	add_child(building)

	return true


# TODO: Implement this.
## Destroys the building at [param coords].[br]
## [br]
## Returns [code]false[/code] if there is no building at [param coords].
func destroy_building_at(_coords: Vector2i) -> bool:
	push_error("Not implemented.")
	return false

#endregion
# ============================================================================ #

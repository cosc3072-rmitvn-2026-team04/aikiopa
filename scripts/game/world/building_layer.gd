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
## [color=orange][b][u]Warning:[/u] This will replace any existing
## building.[/b][/color][br]
## TODO: Deterministically assign random variations.[br]
## [br]
## Prints an error and do nothing if [param building_type] is unknown.[br]
## [br]
## Set [param quiet] to [code]true[/code] to execute without notifying other
## game systems. Useful for scripted game events.
func place_building_at(
		coords: Vector2i,
		building_type: Building.BuildingType,
		quiet: bool = false
) -> void:
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
			return

	# Quietly clear existing building, if any.
	if has_building_at(coords):
		destroy_building_at(coords, true)

	# Clear terrain feature, if any.
	var terrain_feature_layer: Node2D = world.get_terrain_feature_layer()
	if terrain_feature_layer.has_feature_at(coords):
		terrain_feature_layer.remove_feature_at(coords)

	# Insert the building.
	var terrain_tile_map_layer: TileMapLayer = world.get_terrain_tile_map_layer()
	_buildings.set(coords, building)
	building.position = terrain_tile_map_layer.map_to_local(coords)
	add_child(building)

	if not quiet:
		GameplayEventBus.building_placed.emit(coords, building_type)


## Returns and destroys the building at [param coords].[br]
## [br]
## Returns [constant Building.BuildingType.NONE] if there is no building at
## [param coords].
## [br]
## Set [param quiet] to [code]true[/code] to execute without notifying other
## game systems. Useful for scripted game events.
func destroy_building_at(
		coords: Vector2i,
		quiet: bool = false
) -> Building.BuildingType:
	if not has_building_at(coords):
		return Building.BuildingType.NONE

	var building: Building = _buildings[coords]
	var building_type: Building.BuildingType = building.get_type()
	_buildings.erase(coords)
	remove_child(building)
	building.queue_free()

	if not quiet:
		GameplayEventBus.building_destroyed.emit(coords, building_type)
	return building_type

#endregion
# ============================================================================ #

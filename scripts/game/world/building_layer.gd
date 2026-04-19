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
	Global.game_state.buildings.clear()


## Returns the [enum Building.BuildingType] at [param coords].
func get_building_at(coords: Vector2i) -> Building.BuildingType:
	if not has_building_at(coords):
		return Building.BuildingType.NONE
	return Global.game_state.buildings[coords].get_type()


## Returns a reference to the [Building] instance at [param coords]. Returns
## [code]null[/code] if there is no terrain feature at the specified
## coordinates.[br]
## [br]
## [color=orange][b]WARNING:[/b] Extra caution must be taken when modifying the
## returned instance for it being a reference, and thus will produce
## side-effects on any modification to its properties.[/color]
func get_building_instance_at(coords: Vector2i) -> Building:
	if not has_building_at(coords):
		return null
	return Global.game_state.buildings[coords]


## Returns [code]true[/code] if there is a building at [param coords].
func has_building_at(coords: Vector2i) -> bool:
	return Global.game_state.buildings.has(coords)


## Sets the building at [param coords] to one of [enum Building.BuildingType].
## [color=orange][b][u]Warning:[/u] This will replace any existing
## building.[/b][/color][br]
## TODO: Deterministically assign random variations.[br]
## [br]
## Prints an error and do nothing if [param building_type] is unknown.[br]
func place_building_at(
		coords: Vector2i,
		building_type: Building.BuildingType
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
	if world.has_terrain_feature_at(coords):
		world.remove_terrain_feature_at(coords)

	# Insert the building.
	var terrain_tile_map_layer: TileMapLayer = world.get_terrain_tile_map_layer()
	Global.game_state.buildings.set(coords, building)
	building.position = terrain_tile_map_layer.map_to_local(coords)
	add_child(building)

	# Update [member _edge_coords].
	var is_edge: bool = false
	var surrounding_neighbor_coords: Array[Vector2i] =\
			Math.HexGrid.get_offset_surrounding_neighbors(
					coords,
					Math.HexGrid.OffsetLayout.ODD_R)
	for neighbor_coords: Vector2i in surrounding_neighbor_coords:
		if not has_building_at(neighbor_coords):
			is_edge = true

		var neighbor_is_edge: bool = true
		var neighbor_surrounding_neighbor_coords: Array[Vector2i] =\
				Math.HexGrid.get_offset_surrounding_neighbors(
						neighbor_coords,
						Math.HexGrid.OffsetLayout.ODD_R)
		neighbor_surrounding_neighbor_coords.erase(coords)
		for neighbor_neighbor_coords: Vector2i in neighbor_surrounding_neighbor_coords:
			if not has_building_at(neighbor_neighbor_coords):
				neighbor_is_edge = false
				break
		if neighbor_is_edge:
			Global.game_state.edge_coords.erase(neighbor_coords)
	if is_edge:
		Global.game_state.edge_coords.append(coords)
	else:
		Global.game_state.edge_coords.erase(coords)


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

	var building: Building = Global.game_state.buildings[coords]
	var building_type: Building.BuildingType = building.get_type()
	Global.game_state.buildings.erase(coords)
	remove_child(building)
	building.queue_free()

	if not quiet:
		GameplayEventBus.building_destroyed.emit(coords, building_type)
	return building_type

#endregion
# ============================================================================ #

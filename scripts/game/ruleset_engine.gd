class_name RulesetEngine
extends Node
## Evaluates the core interactions between building and terrain in the game
## through stateless validation methods.


# ============================================================================ #
#region Constants

const BUILDING_V_TERRAIN_RULES = []

#endregion
# ============================================================================ #


# ============================================================================ #
#region Exported properties

@export var world: World

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	UIEventBus.building_placement_requested.connect(
			_on_building_placement_requested)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

func is_clear(coords: Vector2i) -> bool:
	return not world.has_building_at(coords)


func has_adjacent_building(coords: Vector2i) -> bool:
	var surrounding_neighbor_coords: Array[Vector2i] =\
			Math.HexGrid.get_offset_surrounding_neighbors(
					coords,
					Math.HexGrid.OffsetLayout.ODD_R)
	for neighbor_coords in surrounding_neighbor_coords:
		if world.has_building_at(neighbor_coords):
			return true
	return false


func is_blocked(_coords: Vector2i, _building_type: Building.BuildingType) -> bool:
	return false

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to
# UIEventBus.building_placement_requested(
#		mouse_position: Vector2,
#		building: Building.BuildingType).
func _on_building_placement_requested(
		mouse_position: Vector2,
		building: Building.BuildingType) -> void:
	var world_coords: Vector2i = %World.get_terrain_tile_map_layer().local_to_map(
			mouse_position)

	if has_adjacent_building(world_coords) and is_clear(world_coords):
		world.place_building_at(world_coords, building)

#endregion
# ============================================================================ #

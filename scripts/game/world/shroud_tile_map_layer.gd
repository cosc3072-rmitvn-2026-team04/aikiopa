class_name ShroudTileMapLayer
extends TileMapLayer


# ============================================================================ #
#region Exported properties

## The vision radius around the edge coordinates of the colony. The Shroud
## covers and hides coordinates beyond this range.
@export_range(1, 10, 1, "suffix:tiles") var vision_range: int = 1
@export var world: World = null

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private variables

# The list of coordinates currently at the edge of the colony.
var _colony_surrounding_edges_coords: Array[Vector2i] = []

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	GameplayEventBus.building_placed.connect(_on_building_placed)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Resets The Shroud to reveal only around the initial coordinate at the center
## of the [World].
func reset() -> void:
	var world_center_coords: Vector2i = world.get_chunk_size() / 2
	_colony_surrounding_edges_coords = []
	_colony_surrounding_edges_coords.append(world_center_coords)


## Returns the list of coordinates currently at the edge of the colony. Useful
## for saving and restoring game sessions.
func get_colony_surrounding_edges_coords() -> Array[Vector2i]:
	return _colony_surrounding_edges_coords


## Re-renders The Shroud based on the coordinates currently at the edge of the
## colony. See [method get_colony_surrounding_edges_coords].
func update(_coords: Vector2i) -> void:
	# TODO: Implement this. See algorithm in #48.
	pass

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to GameplayEventBus.building_placed(
#		coords: Vector2i,
#		building_type: Building.BuildingType)
func _on_building_placed(
		coords: Vector2i,
		_building_type: Building.BuildingType
) -> void:
	update(coords)
	
#endregion
# ============================================================================ #

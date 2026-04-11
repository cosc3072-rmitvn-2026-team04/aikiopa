class_name ShroudTileMapLayer
extends TileMapLayer
## The Shroud. It covers the distant undiscovered reaches of the planet!


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
	@warning_ignore("integer_division")
	var world_center_coords: Vector2i = world.get_chunk_size() / 2
	_colony_surrounding_edges_coords = []
	_colony_surrounding_edges_coords.append(world_center_coords)


## Returns the list of coordinates currently at the edge of the colony. Useful
## for saving and restoring game sessions.
func get_colony_surrounding_edges_coords() -> Array[Vector2i]:
	return _colony_surrounding_edges_coords


## Efficiently re-renders The Shroud around the [param camera_coords] given in
## tile coordinates (See [method TileMapLayer.local_to_map]). This method is
## optimized to only render the area within the player's camera.[br]
## [br]
## Set [param margin] to a positive value to expand the rendered area by that
## amount of tiles.
func render(_camera_coords: Vector2i, _margin: int = 0) -> void:
	# var _margin: int = _margin if margin >= 0 else 0
	var viewport_rect: Rect2 = get_viewport_rect()
	print(viewport_rect.position)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to GameplayEventBus.building_placed(
#		coords: Vector2i,
#		building_type: Building.BuildingType)
func _on_building_placed(
		_coords: Vector2i,
		_building_type: Building.BuildingType
) -> void:
	# TODO: Implement this. See algorithm in #48.
	pass

#endregion
# ============================================================================ #

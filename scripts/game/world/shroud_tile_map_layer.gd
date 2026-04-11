class_name ShroudTileMapLayer
extends TileMapLayer
## The Shroud. It covers the distant undiscovered reaches of the planet!


# ============================================================================ #
#region Enums

enum ShroudType {
	THIN,
	THICK,
}

#endregion
# ============================================================================ #


# ============================================================================ #
#region Constants

## TileSet source for this [TileMapLayer].
const SOURCE_ID: int = 0

## Atlas coordinate data for [enum ShroudType].
const ATLAS_COORDS: Dictionary[ShroudType, Vector2i] = {
	ShroudType.THIN: Vector2i(1, 0),
	ShroudType.THICK: Vector2i(0, 0),
}

#endregion
# ============================================================================ #


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
var _cleared_shroud_coords: Array[Vector2i] = []
var _thin_shroud_coords: Array[Vector2i] = []

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
	_colony_surrounding_edges_coords.clear()
	_colony_surrounding_edges_coords.append(world_center_coords)
	_cleared_shroud_coords.clear()
	_cleared_shroud_coords.append(world_center_coords)
	_cleared_shroud_coords.append_array(
			Math.HexGrid.get_offset_surrounding_neighbors(
					world_center_coords,
					Math.HexGrid.OffsetLayout.ODD_R))


## Returns the list of coordinates currently at the edge of the colony. Useful
## for saving and restoring game sessions.
func get_colony_surrounding_edges_coords() -> Array[Vector2i]:
	return _colony_surrounding_edges_coords


## Efficiently re-renders The Shroud around the [param camera_position] (See
## [method Camera2D.position]). This method is optimized to only render the area
## within the player's camera.[br]
## [br]
## Set [param margin] to a positive value to expand the rendered area by that
## amount of tiles.
func render(camera_position: Vector2, margin: int = 0) -> void:
	if margin < 0:
		push_warning("'margin' should be greater or equal to 0. Using 0 instead.")
	var calculated_margin: int = margin if margin >= 0 else 0

	var viewport_rect_size: Vector2 = get_viewport_rect().size
	var viewport_top_left: Vector2 = (
			camera_position -
			viewport_rect_size / 2
	)
	var viewport_bottom_right: Vector2 = (
			camera_position
			+ viewport_rect_size / 2
	)
	var top_left_map_coords: Vector2i = local_to_map(viewport_top_left)
	top_left_map_coords -= Vector2i.ONE * calculated_margin
	var bottom_right_map_coords: Vector2i = local_to_map(viewport_bottom_right)
	bottom_right_map_coords += Vector2i.ONE * calculated_margin

	clear()
	for x in range(top_left_map_coords.x, bottom_right_map_coords.x + 1):
		for y in range(top_left_map_coords.y, bottom_right_map_coords.y + 1):
			var map_coords: Vector2i = Vector2i(x, y)
			if map_coords in _thin_shroud_coords:
				set_cell(map_coords, SOURCE_ID, ATLAS_COORDS[ShroudType.THIN])
			elif map_coords not in (_cleared_shroud_coords + _thin_shroud_coords):
				set_cell(map_coords, SOURCE_ID, ATLAS_COORDS[ShroudType.THICK])

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

class_name ShroudTileMapLayer
extends TileMapLayer
## The Shroud. It covers the distant undiscovered reaches of the planet!


# ============================================================================ #
#region Enums

enum ShroudType {
	CLEARED,
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

## The expanded margin rendered outside of the viewport.
@export_range(0, 20, 1, "suffix:tiles") var render_margin: int = 0

@export var world: World = null

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private variables

var _cleared_shroud_coords: Array[Vector2i] = []
var _thin_shroud_coords: Array[Vector2i] = []

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	GameplayEventBus.building_placed.connect(_on_building_placed)
	UIEventBus.gameplay_debug_mode_shroud_toggled.connect(
			_on_gameplay_debug_mode_shroud_toggled)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Resets The Shroud to reveal only around the initial coordinate at the center
## of the [World].
func reset() -> void:
	@warning_ignore("integer_division")
	var world_center_coords: Vector2i = world.get_chunk_size() / 2
	_cleared_shroud_coords.clear()
	_thin_shroud_coords.clear()
	_append_vision_area_from_range_at(world_center_coords)


## Returns the [enum ShroudType] at [param coords].
func get_shroud_at(coords: Vector2i) -> ShroudType:
	var cell_tile_data: Variant = get_cell_tile_data(coords)
	if not cell_tile_data:
		return ShroudType.CLEARED
	return cell_tile_data.get_custom_data("shroud_type") as ShroudType


## Returns The Shroud's internal data as a dictionary of keys:
## [code]&"cleared_shroud_coords"[/code] and
## [code]&"thin_shroud_coords"[/code].[br]
## [br]
## - [code]&"cleared_shroud_coords"[/code] is the list of coordinates where The
## Shroud is set to [constant CLEARED].[br]
## [br]
## - [code]&"thin_shroud_coords"[/code] is the list of coordinates where The
## Shroud is set to [constant THIN].[br]
## [br]
## Useful for saving game sessions.
func get_shroud_data() -> Dictionary[StringName, Array]:
	return {
		&"cleared_shroud_coords": _cleared_shroud_coords,
		&"thin_shroud_coords": _thin_shroud_coords,
	}


## Sets The Shroud's internal data from [param shroud_data]. See
## [method get_shroud_data] for its schema. Useful for restoring game sessions.
func set_shroud_data(shroud_data: Dictionary[StringName, Array]) -> void:
	_cleared_shroud_coords = shroud_data.cleared_shroud_coords
	_thin_shroud_coords = shroud_data.thin_shroud_coords


## Efficiently re-renders The Shroud around the [param camera_position] (See
## [method Camera2D.position]). This method is optimized to only render the area
## within the player's camera plus the [member render_margin].
func render(camera_position: Vector2) -> void:

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
	top_left_map_coords -= Vector2i.ONE * render_margin
	var bottom_right_map_coords: Vector2i = local_to_map(viewport_bottom_right)
	bottom_right_map_coords += Vector2i.ONE * render_margin

	clear()
	for x: int in range(top_left_map_coords.x, bottom_right_map_coords.x + 1):
		for y: int in range(top_left_map_coords.y, bottom_right_map_coords.y + 1):
			var map_coords: Vector2i = Vector2i(x, y)
			if map_coords in _thin_shroud_coords:
				set_cell(map_coords, SOURCE_ID, ATLAS_COORDS[ShroudType.THIN])
			elif map_coords not in (_cleared_shroud_coords + _thin_shroud_coords):
				set_cell(map_coords, SOURCE_ID, ATLAS_COORDS[ShroudType.THICK])


#endregion
# ============================================================================ #


# ============================================================================ #
#region Private methods

func _append_vision_area_from_range_at(coords: Vector2i) -> void:
	var surrounding_neighbor_coords: Array[Vector2i] =\
			Math.HexGrid.get_offset_surrounding_neighbors(
					coords,
					Math.HexGrid.OffsetLayout.ODD_R)
	_cleared_shroud_coords.append_array(surrounding_neighbor_coords.filter(
			func (neighbor_coords: Vector2i) -> bool:
				return neighbor_coords not in _cleared_shroud_coords))
	if coords not in _cleared_shroud_coords:
		_cleared_shroud_coords.append(coords)

	_thin_shroud_coords.append_array(
			Math.HexGrid.get_offset_area_from_range_at(
					coords,
					vision_range,
					Math.HexGrid.OffsetLayout.ODD_R).filter(
							func (in_range_coords) -> bool:
								return (
										in_range_coords.distance_squared_to(coords) > 1
										and in_range_coords not in _cleared_shroud_coords
										and in_range_coords not in _thin_shroud_coords
							)))
	for neighbor_coords: Vector2i in surrounding_neighbor_coords:
		_thin_shroud_coords.erase(neighbor_coords)
	_thin_shroud_coords.erase(coords)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to GameplayEventBus.building_placed(
#		coords: Vector2i,
#		building_type: Building.BuildingType).
#		interaction_result: BuildingRulesetEngine.InteractionResult).
func _on_building_placed(
		coords: Vector2i,
		_building_type: Building.BuildingType,
		_interaction_result: BuildingRulesetEngine.InteractionResult
) -> void:
	_append_vision_area_from_range_at(coords)
	Global.game_state.shroud_data = get_shroud_data()


# Listens to UIEventBus.gameplay_debug_mode_shroud_toggled(toggled_on: bool).
func _on_gameplay_debug_mode_shroud_toggled(toggled_on: bool) -> void:
	visible = toggled_on

#endregion
# ============================================================================ #

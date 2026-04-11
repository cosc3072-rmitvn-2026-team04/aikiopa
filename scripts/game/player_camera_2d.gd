extends Camera2D


## Speed in pixels per second of the camera's panning.
@export_range(500.0, 5000.0, 50.0, "suffix:px/s") var pan_speed: int = 2500
@export var world: World = null


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	GameplayEventBus.building_placed.connect(_on_building_placed)

	$ReferenceRect.editor_only = true
	$ReferenceRect/ReferenceLabel.visible = false
	GameplayEventBus.gameplay_debug_mode_toggled.connect(
			_on_gameplay_debug_mode_toggled)


func _process(delta: float) -> void:
	var movement: Vector2 = Input.get_vector(
			"player_camera_left",
			"player_camera_right",
			"player_camera_up",
			"player_camera_down")
	if movement:
		position += movement * pan_speed * delta

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Returns the tile position of the camera on the map. Undefined behavior if
## [member world] is not set.
func get_tile_map_position() -> Vector2i:
	if world:
		return world.get_terrain_tile_map_layer().local_to_map(position)
	return Vector2i(-1, -1)


## Returns the chunk offset that the camera is in. Undefined behavior if
## [member world] is not set.
func get_chunk_position() -> Vector2i:
	if get_tile_map_position() == Vector2i(INF, INF):
		return get_tile_map_position()
	var map_position: Vector2 = Vector2(get_tile_map_position())

	var chunk_size: Vector2 = Vector2(world.get_chunk_size())
	return Vector2i(
			roundi(map_position.x / chunk_size.x - 0.5),
			roundi(map_position.y / chunk_size.y - 0.5))

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to
# GameplaEventBus.building_placed(
#		coords: Vector2i,
#		building_type: Building.BuildingType).
func _on_building_placed(
		coords: Vector2i,
		_building_type: Building.BuildingType
) -> void:
	position = world.get_terrain_tile_map_layer().map_to_local(coords)


# Listens to GameplayEventBus.gameplay_debug_mode_toggled(value: bool).
func _on_gameplay_debug_mode_toggled(value: bool) -> void:
	if value:
		$ReferenceRect.editor_only = false
		$ReferenceRect/ReferenceLabel.visible = true
	else:
		make_current()
		$ReferenceRect.editor_only = true
		$ReferenceRect/ReferenceLabel.visible = false

#endregion
# ============================================================================ #

extends Camera2D


# ============================================================================ #
#region Exported properties

@export_group("Pan", "pan")

## Speed of the camera's panning. Only affects keyboard-controlled camera
## panning.
@export_range(50.0, 5000.0, 5.0, "suffix:px/s") var pan_speed: int = 2500


@export_group("Zoom", "zoom")

## Mininimum camera zoom (zoom out).
@export_range(0.5, 1.0, 0.01) var zoom_min: float = 1.0

## Maximum camera zoom (zoom in).
@export_range(1.0, 2.0, 0.01) var zoom_max: float = 1.0

## The amount of zoom change per zoom command from the player.
@export_range(0.01, 0.1, 0.01) var zoom_increment: float = 0.01

## The rate of zoom per [method Node._process] frame.
@export_range(1.0, 100.0, 1.0) var zoom_rate: float =  1.0

@export_group("", "")


@export var world: World = null

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private properties

var _target_zoom: float = 1.0

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	_target_zoom = 1.0

	GameplayEventBus.building_placed.connect(_on_building_placed)

	$ReferenceRect.editor_only = true
	$ReferenceRect/ReferenceLabel.visible = false
	GameplayEventBus.gameplay_debug_mode_toggled.connect(
			_on_gameplay_debug_mode_toggled)


func _process(delta: float) -> void:
	# Keyboard-controlled panning.
	var movement: Vector2 = Input.get_vector(
			"player_camera_left",
			"player_camera_right",
			"player_camera_up",
			"player_camera_down")
	if movement:
		position += movement * pan_speed * delta / zoom

	# Keyboard-controlled zooming.
	if (
			$KeyboardZoomDelayTimer.is_stopped()
			and	Input.is_action_pressed("player_camera_zoom_in")
			and zoom.x < zoom_max
	):
		_zoom_in()
		$KeyboardZoomDelayTimer.start()
	if (
			$KeyboardZoomDelayTimer.is_stopped()
			and Input.is_action_pressed("player_camera_zoom_out")
			and zoom.x > zoom_min
	):
		_zoom_out()
		$KeyboardZoomDelayTimer.start()

	# Zoom interpolation (linear).
	if not is_equal_approx(zoom.x, _target_zoom):
		zoom = lerp(zoom, _target_zoom * Vector2.ONE, zoom_rate * delta)

	# Camera panning limits.
	var shroud_tile_map_layer: TileMapLayer = world.get_shroud_tile_map_layer()
	var map_coords: Vector2i = shroud_tile_map_layer.local_to_map(position)


func _unhandled_input(event: InputEvent) -> void:
	# Mouse-controlled panning.
	# TODO: This doesn't work. Fix it.
	if event is InputEventMouseMotion and event.button_mask == MOUSE_BUTTON_MASK_MIDDLE:
		position -= event.screen_relative * zoom

	# Mouse-controlled zooming.
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_in()
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_out()

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
#region Private methods

func _zoom_in() -> void:
	_target_zoom = min(_target_zoom + zoom_increment, zoom_max)


func _zoom_out() -> void:
	_target_zoom = max(_target_zoom - zoom_increment, zoom_min)

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

extends Camera2D


const MIN_ZOOM: float = 0.1
const MAX_ZOOM: float = 10.0
const ZOOM_SPEED: float = 0.01


## Camera panning speed (scaled to [member Camera2D.zoom]).
@export var pan_speed: int = 15
@export var world: World = null
@export var building_stack_controller: BuildingStackController = null


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	%DebugCanvasLayer.visible = false
	GameplayEventBus.gameplay_debug_mode_toggled.connect(
			_on_gameplay_debug_mode_toggled)
	%AddBuildingButton.pressed.connect(_on_add_building_button_pressed)
	%PopBuildingButton.pressed.connect(_on_pop_building_button_pressed)


func _process(delta: float) -> void:
	var tile_map_position: Vector2i =\
			world.get_terrain_tile_map_layer().local_to_map(position)
	%CameraMapCoordsLabel.text = "(%d, %d)" % [
		tile_map_position.x,
		tile_map_position.y,
	]
	%CameraZoomLabel.text = "Zoom: %.2f" % [zoom.x]

	if is_current():
		var movement: Vector2 = Vector2.ZERO
		if Input.is_action_pressed("debug_camera_left"):
			movement += Vector2.LEFT
		if Input.is_action_pressed("debug_camera_right"):
			movement += Vector2.RIGHT
		if Input.is_action_pressed("debug_camera_up"):
			movement += Vector2.UP
		if Input.is_action_pressed("debug_camera_down"):
			movement += Vector2.DOWN
		movement = movement.normalized()
		position += movement * (pan_speed * 100 / zoom.x) * delta

		if Input.is_action_pressed("debug_camera_zoom_in") and zoom.x < MAX_ZOOM:
			zoom += Vector2.ONE * ZOOM_SPEED
		if Input.is_action_pressed("debug_camera_zoom_out") and zoom.x > MIN_ZOOM:
			zoom -= Vector2.ONE * ZOOM_SPEED

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to GameplayEventBus.gameplay_debug_mode_toggled(value: bool).
func _on_gameplay_debug_mode_toggled(value: bool) -> void:
	if value:
		make_current()
		%DebugCanvasLayer.visible = true
	else:
		%DebugCanvasLayer.visible = false


# Listens to %AddBuildingButton.pressed.
func _on_add_building_button_pressed() -> void:
	building_stack_controller.add_building()


# Listens to %PopBuildingButton.pressed.
func _on_pop_building_button_pressed() -> void:
	building_stack_controller.pop_building()

#endregion
# ============================================================================ #

extends Camera2D


# ============================================================================ #
#region Exported properties

@export_group("Pan", "pan")

## Speed of the camera's panning. Only affects keyboard-controlled camera
## panning.
@export_range(50.0, 5000.0, 5.0, "suffix:px/s") var pan_speed: int = 2500


@export_group("Zoom", "zoom")

## Mininimum camera zoom (zoom out).
@export_range(0.1, 1.0, 0.01) var zoom_min: float = 1.0

## Maximum camera zoom (zoom in).
@export_range(1.0, 3.0, 0.01) var zoom_max: float = 1.0

## The amount of zoom change per zoom command from the player.
@export_range(0.01, 0.1, 0.01) var zoom_increment: float = 0.01

## The rate of zoom per [method Node._process] frame.
@export_range(1.0, 100.0, 1.0) var zoom_rate: float =  1.0

@export_group("", "")


@export var world: World = null
@export var building_stack_controller: BuildingStackController = null

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private properties

var _target_zoom: float = 0.5

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	%DebugCanvasLayer.visible = false
	UIEventBus.gameplay_debug_mode_toggled.connect(
			_on_gameplay_debug_mode_toggled)
	%AddBuildingButton.pressed.connect(_on_add_building_button_pressed)
	%PopBuildingButton.pressed.connect(_on_pop_building_button_pressed)
	%ShroudDisplayCheckBox.toggled.connect(_on_shroud_display_check_button_toggled)


func _process(delta: float) -> void:
	var tile_map_position: Vector2i =\
			world.local_to_map(position)
	%CameraMapCoordsLabel.text = "(%d, %d)" % [
		tile_map_position.x,
		tile_map_position.y,
	]
	%CameraZoomLabel.text = "Zoom: %.2f" % [zoom.x]

	if is_current():
		var movement: Vector2 = Input.get_vector(
				"debug_camera_left",
				"debug_camera_right",
				"debug_camera_up",
				"debug_camera_down")
		position += movement * pan_speed * delta / zoom

		# Keyboard-controlled zooming.
		if (
				$KeyboardZoomDelayTimer.is_stopped()
				and	Input.is_action_pressed("debug_camera_zoom_in")
				and zoom.x < zoom_max
		):
			_zoom_in()
			$KeyboardZoomDelayTimer.start()
		if (
				$KeyboardZoomDelayTimer.is_stopped()
				and Input.is_action_pressed("debug_camera_zoom_out")
				and zoom.x > zoom_min
		):
			_zoom_out()
			$KeyboardZoomDelayTimer.start()

		# Zoom interpolation (linear).
		if not is_equal_approx(zoom.x, _target_zoom):
			zoom = lerp(zoom, _target_zoom * Vector2.ONE, zoom_rate * delta)

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

# Listens to UIEventBus.gameplay_debug_mode_toggled(toggled_on: bool).
func _on_gameplay_debug_mode_toggled(toggled_on: bool) -> void:
	if toggled_on:
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


# Listens to %ShroudDisplayCheckBox.toggled(toggled_on: bool).
func _on_shroud_display_check_button_toggled(toggled_on: bool) -> void:
	UIEventBus.gameplay_debug_mode_shroud_toggled.emit(toggled_on)

#endregion
# ============================================================================ #

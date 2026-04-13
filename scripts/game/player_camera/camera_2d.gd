extends Camera2D


# ============================================================================ #
#region Public variables

## Mininimum camera zoom (zoom out).
var zoom_min: float = 1.0

## Maximum camera zoom (zoom in).
var zoom_max: float = 1.0

## The amount of zoom change per zoom command from the player.
var zoom_increment: float = 0.01

## The rate of zoom per [method Node._process] frame.
var zoom_rate: float =  1.0

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
	$ReferenceRect.editor_only = true
	$ReferenceRect/ReferenceLabel.visible = false
	UIEventBus.gameplay_debug_mode_toggled.connect(
			_on_gameplay_debug_mode_toggled)


func _process(delta: float) -> void:
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


func _unhandled_input(event: InputEvent) -> void:
	# Mouse-controlled zooming.
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_in()
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_out()

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
		$ReferenceRect.editor_only = false
		$ReferenceRect/ReferenceLabel.visible = true
	else:
		make_current()
		$ReferenceRect.editor_only = true
		$ReferenceRect/ReferenceLabel.visible = false

#endregion
# ============================================================================ #

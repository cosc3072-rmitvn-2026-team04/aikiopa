extends Camera2D


## Camera panning speed (scaled to [member Camera2D.zoom]).
@export var pan_speed: int = 25


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	GameplayEventBus.gameplay_debug_mode_toggled.connect(
			_on_gameplay_debug_mode_toggled)


func _process(delta: float) -> void:
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

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to GameplayEventBus.gameplay_debug_mode_toggled(value: bool).
func _on_gameplay_debug_mode_toggled(value: bool) -> void:
	if value:
		make_current()

#endregion
# ============================================================================ #

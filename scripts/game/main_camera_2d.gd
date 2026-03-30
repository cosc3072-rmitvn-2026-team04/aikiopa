extends Camera2D


## Speed in pixels per second of the camera's panning.
@export_range(500.0, 5000.0, 100.0, "suffix:px/s") var pan_speed: int = 2500


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	GameplayEventBus.gameplay_debug_mode_toggled.connect(
			_on_gameplay_debug_mode_toggled)


func _process(delta: float) -> void:
	var movement: Vector2 = Input.get_vector(
			"ui_left",
			"ui_right",
			"ui_up",
			"ui_down")
	if movement:
		position += movement * pan_speed * delta

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

func _on_gameplay_debug_mode_toggled(value: bool) -> void:
	if value:
		$ReferenceRect.editor_only = false
	else:
		make_current()
		$ReferenceRect.editor_only = true

#endregion
# ============================================================================ #

extends Sprite2D


# ============================================================================ #
#region Signals

## Emitted when the button is pressed.
@warning_ignore("unused_signal")
signal pressed

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if get_rect().has_point(to_local(event.position)):
			scale = Vector2.ONE * 1.1
		else:
			scale = Vector2.ONE
			return

	if event is InputEventMouseButton and event.pressed:
		var is_event_inside: bool = get_rect().has_point(to_local(event.position))
		if is_event_inside and event.button_index == MOUSE_BUTTON_LEFT:
			pressed.emit()
			get_viewport().set_input_as_handled()

#endregion
# ============================================================================ #

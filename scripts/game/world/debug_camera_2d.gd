extends Camera2D


func _process(delta: float) -> void:
	var movement: Vector2 = Input.get_vector(
			"ui_left",
			"ui_right",
			"ui_up",
			"ui_down"
	)
	if movement:
		position += movement * 1000 * delta

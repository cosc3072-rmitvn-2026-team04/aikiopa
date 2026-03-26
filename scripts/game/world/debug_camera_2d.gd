extends Camera2D


@export var pan_speed: int = 25


func _process(delta: float) -> void:
	var movement: Vector2 = Input.get_vector(
			"ui_left",
			"ui_right",
			"ui_up",
			"ui_down"
	)
	if movement:
		position += movement * (pan_speed * 100 / zoom.x) * delta

extends Node2D


## Removes all buildings (child nodes).
func clear() -> void:
	for child: Node2D in get_children():
		child.queue_free()

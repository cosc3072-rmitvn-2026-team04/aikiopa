extends Node2D


## Removes all terrain features (child nodes).
func clear() -> void:
	for child: Node2D in get_children():
		child.queue_free()

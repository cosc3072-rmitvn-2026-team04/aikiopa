extends Sprite2D


@export var terrain: TileMapLayer
@export var terrain_position: Vector2i = Vector2i(0, 0)


@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	var local_position: Vector2 = terrain.map_to_local(terrain_position)
	position = local_position

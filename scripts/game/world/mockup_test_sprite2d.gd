extends Sprite2D


@export var terrain: TileMapLayer
@export var terrain_position: Vector2i = Vector2i(0, 0)


func _process(_delta: float) -> void:
	var local_position: Vector2 = terrain.map_to_local(terrain_position)
	position = local_position

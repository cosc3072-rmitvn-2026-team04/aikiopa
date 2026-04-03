extends Panel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	center_to_parent_panel()


func center_to_parent_panel():
	var parent = $MarginContainer/Panel
	var sprite = %BuildingSprite2D
	sprite.position = parent.size / 2
	

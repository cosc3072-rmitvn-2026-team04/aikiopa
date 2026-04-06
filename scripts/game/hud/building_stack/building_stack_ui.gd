extends Control


@export var card_spread_curve: Curve
@export_range(0, 120, 1, "suffix:px") var card_separation: int = 0
@export_range(0, 720, 1, "suffix:px") var container_height: int = 520
@export var container_padding: Vector2i = Vector2i.ZERO

var _building_card_scene = preload("res://scenes/game/hud/building_stack/building_card.tscn")


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	GameplayEventBus.building_stack_building_added.connect(
			_on_building_stack_building_added)
	GameplayEventBus.building_stack_building_popped.connect(
			_on_building_stack_building_popped)
	%BuildingStackCountLabel.text = "%d" % Global.game_state.building_stack.size()


func _process(_delta: float) -> void:
	pass

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to
# GameplayEventBus.building_stack_building_added(building: World.BuildingType).
func _on_building_stack_building_added(building: World.BuildingType) -> void:
	var building_card: BuildingCard = _building_card_scene.instantiate()
	var building_card_size: Vector2i = building_card.get_size()
	building_card.position = Vector2(
			building_card_size.x * 0.5,
			size.y - building_card_size.y * 0.5
	)
	building_card.position += Vector2(container_padding.x, -container_padding.y)
	%BuildingStack.add_child(building_card)
	%BuildingStackCountLabel.text = "%d" % Global.game_state.building_stack.size()
	print("building added: %s" % [World.BuildingType.keys()[building]])


# Listens to
# GameplayEventBus.building_stack_building_popped(building: World.BuildingType).
func _on_building_stack_building_popped(building: World.BuildingType) -> void:
	var top_building_card: BuildingCard = %BuildingStack.get_child(1)
	%BuildingStack.remove_child(top_building_card)
	%BuildingStackCountLabel.text = "%d" % Global.game_state.building_stack.size()
	top_building_card.queue_free()
	print("building popped: %s" % [World.BuildingType.keys()[building]])

#endregion
# ============================================================================ #

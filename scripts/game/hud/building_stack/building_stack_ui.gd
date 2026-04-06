extends Control


@export var card_spread_curve: Curve
@export_range(0, 120, 1, "suffix:px") var card_separation: int = 0
@export_range(0, 720, 1, "suffix:px") var container_height: int = 0

var _building_card_scene = preload("res://scenes/game/hud/building_stack/building_card.tscn")


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	GameplayEventBus.building_stack_building_added.connect(
			_on_building_stack_building_added)
	GameplayEventBus.building_stack_building_popped.connect(
			_on_building_stack_building_popped)
	GameplayEventBus.building_stack_size_changed.connect(
			_on_building_stack_size_changed)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to
# GameplayEventBus.building_stack_building_added(building: World.BuildingType).
func _on_building_stack_building_added(building: World.BuildingType) -> void:
	var building_card: Node2D = _building_card_scene.instantiate()
	building_card.position += building_card.get_size() / 2
	%BuildingStack.add_child(building_card)
	print("building added: %s" % [World.BuildingType.keys()[building]])


# Listens to
# GameplayEventBus.building_stack_building_popped(building: World.BuildingType).
func _on_building_stack_building_popped(building: World.BuildingType) -> void:
	print("building popped: %s" % [World.BuildingType.keys()[building]])


# Listens to
# GameplayEventBus.building_stack_count_changed(old_amount: int, new_amount: int).
func _on_building_stack_size_changed(_old_amount: int, new_amount: int):
	%BuildingStackCountLabel.text = "%d" % new_amount
	print("Stack size: %d" % new_amount)

#endregion
# ============================================================================ #

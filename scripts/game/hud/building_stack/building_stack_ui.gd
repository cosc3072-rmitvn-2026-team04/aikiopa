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

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

func _on_building_stack_building_added(building: World.BuildingType) -> void:
	var building_card: Node2D = _building_card_scene.instantiate()
	building_card.position += building_card.size * 2
	%BuildingStack.add_child(building_card)
	print("building added: %s" % [World.BuildingType.keys()[building]])


func _on_building_stack_building_popped(building: World.BuildingType) -> void:
	print("building popped: %s" % [World.BuildingType.keys()[building]])

#endregion
# ============================================================================ #

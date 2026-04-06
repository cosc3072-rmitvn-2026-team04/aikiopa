extends Control


# ============================================================================ #
#region Exported properties

@export var card_spread_curve: Curve
@export_range(0, 120, 1, "suffix:px") var card_separation: int = 0
@export_range(0, 720, 1, "suffix:px") var container_height: int = 520
@export var container_padding: Vector2i = Vector2i.ZERO

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private variables

var _building_card_scene = preload("res://scenes/game/hud/building_stack/building_card.tscn")

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	GameplayEventBus.building_stack_building_added.connect(
			_on_building_stack_building_added)
	GameplayEventBus.building_stack_building_popped.connect(
			_on_building_stack_building_popped)

	var placeholder_card: InstancePlaceholder = %BuildingStack.get_child(0)
	%BuildingStack.remove_child(placeholder_card)
	placeholder_card.queue_free()

	%BuildingStackCountLabel.text = "%d" % Global.game_state.building_stack.size()

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private methods

func _update_building_card_positions() -> void:
	var building_card_count: int = %BuildingStack.get_child_count()
	var building_cards: Array[Node] = %BuildingStack.get_children()
	for index in range(building_card_count):
		var building_card: BuildingCard = building_cards[index]
		var building_card_size: Vector2i = building_card.get_size()

		# Set position.
		building_card.position = Vector2(
				building_card_size.x * 0.5,
				size.y - building_card_size.y * 0.5
				- (building_card_size.y + card_separation) * index
		)

		# Add padding.
		building_card.position += Vector2(
				container_padding.x,
				-container_padding.y)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to
# GameplayEventBus.building_stack_building_added(building: World.BuildingType).
func _on_building_stack_building_added(building: World.BuildingType) -> void:
	var building_card: BuildingCard = _building_card_scene.instantiate()
	building_card.set_type(building)
	%BuildingStack.add_child(building_card)
	%BuildingStackCountLabel.text = "%d" % Global.game_state.building_stack.size()
	_update_building_card_positions()


# Listens to
# GameplayEventBus.building_stack_building_popped(building: World.BuildingType).
func _on_building_stack_building_popped(_building: World.BuildingType) -> void:
	var top_building_card: BuildingCard = %BuildingStack.get_child(0)
	%BuildingStack.remove_child(top_building_card)
	%BuildingStackCountLabel.text = "%d" % Global.game_state.building_stack.size()
	_update_building_card_positions()
	top_building_card.queue_free()

#endregion
# ============================================================================ #

extends Control


# ============================================================================ #
#region Exported properties

@export var revealed_card_spread_curve: Curve
@export_range(0, 520, 1, "suffix:px") var max_revealed_card_offset: int = 0
@export_range(0, 250, 1, "suffix:px") var collapsed_card_offset: int = 0
@export_range(0, 1080, 1, "suffix:px") var max_container_height: int = 1080
@export_range(1, 10, 1, "suffix:cards") var max_revealed_card_count: int = 1
@export var container_padding: Vector2i = Vector2i.ZERO

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private variables

var _building_card_scene = preload(
		"res://scenes/game/hud/building_stack/building_card.tscn")

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
#region Public methods

## Redraws the Building Stack UI.
func redraw() -> void:
	_update_building_card_positions()
	_update_building_stack_position()

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private methods

func _update_building_card_positions() -> void:
	var building_card_count: int = %BuildingStack.get_child_count()
	var building_cards: Array[Node] = %BuildingStack.get_children()
	for index: int in range(building_card_count):
		var building_card: BuildingCard = building_cards[index]
		var building_card_size: Vector2i = building_card.get_size()

		# Make sure all card positions are uniform, since picked building cards
		# has an offset y position. See [member BuildingCard.picked_offset].
		#
		# Without this, the unset_picked behavior would work incorrectly when
		# new cards are added while the player is still picking up a building
		# card.
		if building_card.is_picked():
			building_card.unset_picked()

		# Set position.
		building_card.position = Vector2(
				building_card_size.x * 0.5,
				size.y - building_card_size.y * 0.5
		)

		if index < building_card_count - max_revealed_card_count:
			building_card.position.y -= collapsed_card_offset * index
		else:
			var collapsed_card_stack_height: float = max(
					(
							collapsed_card_offset
							* (building_card_count - max_revealed_card_count - 1)
					), 0)
			var revealed_card_index: int = min(
					(
							-building_card_count
							+ max_revealed_card_count
							+ index
					), index)
			building_card.position.y -= collapsed_card_stack_height
			building_card.position.y -= (
					max_revealed_card_offset
					* revealed_card_spread_curve.sample(
							float(revealed_card_index) / (max_revealed_card_count - 1))
			)
			if building_card_count > max_revealed_card_count:
				building_card.position.y -= collapsed_card_offset

		# Add padding.
		building_card.position += Vector2(
				container_padding.x,
				-container_padding.y)


func _update_building_stack_position() -> void:
	%BuildingStack.position = Vector2.ZERO

	var building_card_count: int = %BuildingStack.get_child_count()
	if building_card_count == 0:
		return

	var top_building_card: BuildingCard = %BuildingStack.get_child(-1)
	var bottom_building_card: BuildingCard = %BuildingStack.get_child(0)
	var container_height: float = (
			bottom_building_card.position.y + bottom_building_card.get_size().y
			- top_building_card.position.y + top_building_card.get_size().y
	)
	if container_height > max_container_height:
		%BuildingStack.position.y += (
				container_height - max_container_height
				- container_padding.y
		)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to
# GameplayEventBus.building_stack_building_added(
#		building_type: Building.BuildingType).
func _on_building_stack_building_added(
		building_type: Building.BuildingType
) -> void:
	var building_card: BuildingCard = _building_card_scene.instantiate()
	building_card.set_type(building_type)
	%BuildingStack.add_child(building_card)
	%BuildingStack.move_child(building_card, 0)
	%BuildingStack.get_child(-1).set_pickable()
	%BuildingStackCountLabel.text = "%d" % Global.game_state.building_stack.size()
	_update_building_card_positions()
	_update_building_stack_position()


# Listens to
# GameplayEventBus.building_stack_building_popped(building: Building.BuildingType).
func _on_building_stack_building_popped(_building: Building.BuildingType) -> void:
	var top_building_card: BuildingCard = %BuildingStack.get_child(-1)
	%BuildingStack.remove_child(top_building_card)
	if %BuildingStack.get_child_count() != 0:
		%BuildingStack.get_child(-1).set_pickable()
	%BuildingStackCountLabel.text = "%d" % Global.game_state.building_stack.size()
	_update_building_card_positions()
	_update_building_stack_position()
	top_building_card.queue_free()

#endregion
# ============================================================================ #

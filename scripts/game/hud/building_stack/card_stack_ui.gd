extends Node2D


# ============================================================================ #
#region Exported properties

@export var revealed_card_spread_curve: Curve
@export_range(0, 520, 1, "suffix:px") var max_revealed_card_offset: int = 0
@export_range(0, 250, 1, "suffix:px") var collapsed_card_offset: int = 0
@export_range(0, 1080, 1, "suffix:px") var max_container_height: int = 1080
@export_range(1, 10, 1, "suffix:cards") var max_revealed_card_count: int = 1
@export_range(0.01, 5.0, 0.01, "suffix:s") var container_tween_update_duration: float = 0.5
@export var container_padding: Vector2i = Vector2i.ZERO

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private variables

var _building_card_scene = preload(
		"res://scenes/game/hud/card_stack/building_card.tscn")
# TODO: Add disaster card scene here.

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	GameplayEventBus.session_created.connect(_on_session_created)
	GameplayEventBus.session_restored.connect(_on_session_restored)
	GameplayEventBus.card_stack_card_added.connect(
			_on_card_stack_card_added)
	GameplayEventBus.card_stack_card_popped.connect(
			_on_card_stack_card_popped)
	GameplayEventBus.game_over.connect(_on_game_over)

	# UI layout positioning setup.
	var reference_card: BuildingCard = %CardStack.get_child(0)
	var card_size: Vector2i = reference_card.get_size()
	var card_stack_count_bubble_size: Vector2 = %CardStackCountBubble.get_size()
	var card_stack_count_bubble_offset: Vector2 = %CardStackCountBubble.offset
	%CardStackCountBubble.position = Vector2(
			card_size.x + container_padding.x * 2,
			(
					get_viewport_rect().size.y
					- card_stack_count_bubble_size.y
					- card_stack_count_bubble_offset.y
					- container_padding.y
			))
	%CardStack.remove_child(reference_card)
	reference_card.queue_free()
	%CardStack.position = Vector2.DOWN * get_viewport_rect().size.y

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Redraws the Building Stack UI.
func redraw() -> void:
	_update_card_positions()
	_update_card_stack_position()

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private methods

# TODO: Update this (#21).
func _add_card(
		building_type: Building.BuildingType,
		variation_value: float
) -> void:
	var building_card: BuildingCard = _building_card_scene.instantiate()
	building_card.set_type_and_variation(building_type, variation_value)
	%CardStack.add_child(building_card)
	%CardStack.move_child(building_card, 0)
	%CardStack.get_child(-1).set_pickable()
	%CardStackCountBubble.set_count(Global.game_state.card_stack.size())


# TODO: Update this (#21).
func _pop_card() -> void:
	var top_building_card: BuildingCard = %CardStack.get_child(-1)
	%CardStack.remove_child(top_building_card)
	if %CardStack.get_child_count() != 0:
		%CardStack.get_child(-1).set_pickable()
	%CardStackCountBubble.set_count(Global.game_state.card_stack.size())
	top_building_card.queue_free()


# TODO: Update this (#21).
func _update_card_positions() -> void:
	var building_card_count: int = %CardStack.get_child_count()
	var building_cards: Array[Node] = %CardStack.get_children()
	for index: int in range(building_card_count):
		var building_card: BuildingCard = building_cards[index]
		var building_card_size: Vector2 = building_card.get_size()

		# Make sure all card positions are uniform, since picked building cards
		# has an offset y position. See [member BuildingCard.picked_offset].
		#
		# Without this, the unset_picked behavior would work incorrectly when
		# new cards are added while the player is still picking up a building
		# card.
		if building_card.is_picked():
			building_card.unset_picked(true)

		# Set position.
		building_card.position = Vector2(
				building_card_size.x * 0.5,
				get_viewport_rect().size.y - building_card_size.y * 0.5)
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


# TODO: Update this (#21).
func _update_card_stack_position() -> void:
	var building_card_count: int = %CardStack.get_child_count()
	if building_card_count == 0:
		return

	var target_position = Vector2.ZERO
	var top_building_card: BuildingCard = %CardStack.get_child(-1)
	var bottom_building_card: BuildingCard = %CardStack.get_child(0)
	var container_height: float = (
			bottom_building_card.position.y + bottom_building_card.get_size().y
			- top_building_card.position.y + top_building_card.get_size().y
	)
	if container_height > max_container_height:
		target_position.y += (
				container_height - max_container_height
				- container_padding.y
		)
	else:
		target_position = Vector2.ZERO

	var tween: Tween = create_tween()
	tween.tween_property(
			%CardStack, "position",
			target_position, container_tween_update_duration)\
					.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to GameplayEventBus.session_created(save_slot_index: int).
func _on_session_created(_save_slot_index: int) -> void:
	# INFO: No need to load anything here since Global.game_state.card_stack
	# should be empty at the start a new sessions. The [Game] and
	# [CardStackController] would handle the remaining logic.
	# WARNING: This is tightly coupled to the session creation and restoration
	# logic. See [method _on_session_restored] below.
	pass


# Listens to GameplayEventBus.session_restored(save_slot_index: int).
func _on_session_restored(_save_slot_index: int) -> void:
	# INFO: Load the card stack of the restored session from
	# Global.game_state.card_stack.
	# WARNING: This is tightly coupled to the session restoration logic in
	# [Game] and [CardStackController]. May become problematic later in
	# development, fix if needed (#173). Maintain extra caution around this for
	# now.
	var card_stack_count: int = Global.game_state.card_stack.size()
	for index: int in range(card_stack_count - 1, -1, -1):
		var building_dictionary: Dictionary[StringName, Variant] =\
				Global.game_state.card_stack[index]
		_on_card_stack_card_added(
				building_dictionary.building_type,
				building_dictionary.variation_value)
		%CardStackCountBubble.set_count(
				card_stack_count - index)


# Listens to GameplayEventBus.card_stack_card_added(
#		building_type: Building.BuildingType,
#		variation_value: float).
func _on_card_stack_card_added(
		building_type: Building.BuildingType,
		variation_value: float
) -> void:
	%AnimationPlayer.play("add_building_card")
	_add_card(building_type, variation_value)
	redraw()


# Listens to GameplayEventBus.card_stack_card_popped(
#		building: Building.BuildingType,
#		variation_value: float).
func _on_card_stack_card_popped(
		_building: Building.BuildingType,
		_variation_value: float
) -> void:
	_pop_card()
	redraw()


# Listens to GameplayEventBus.game_over(
#		population_reached: int,
#		game_over_type: Game.GameOverType).
func _on_game_over(_population: int, _game_over_type: Game.GameOverType) -> void:
	if %CardStack.get_child_count() > 0:
		for card: BuildingCard in %CardStack.get_children():
			card.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		%AnimationPlayer.play("game_over")

#endregion
# ============================================================================ #

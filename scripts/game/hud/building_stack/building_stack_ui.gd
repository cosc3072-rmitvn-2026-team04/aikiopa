extends Node2D


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
	GameplayEventBus.session_created.connect(_on_session_created)
	GameplayEventBus.session_restored.connect(_on_session_restored)
	GameplayEventBus.building_stack_building_added.connect(
			_on_building_stack_building_added)
	GameplayEventBus.building_stack_building_popped.connect(
			_on_building_stack_building_popped)
	GameplayEventBus.game_over.connect(_on_game_over)

	# UI layout positioning setup.
	var reference_building_card: BuildingCard = %BuildingStack.get_child(0)
	var building_card_size: Vector2i = reference_building_card.get_size()
	var building_stack_count_bubble_size: Vector2 = %BuildingStackCountBubble.get_size()
	var building_stack_count_bubble_offset: Vector2 = %BuildingStackCountBubble.offset
	%BuildingStackCountBubble.position = Vector2(
			building_card_size.x + container_padding.x * 2,
			(
					get_viewport_rect().size.y
					- building_stack_count_bubble_size.y
					- building_stack_count_bubble_offset.y
					- container_padding.y
			))
	%BuildingStack.remove_child(reference_building_card)
	reference_building_card.queue_free()

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

func _add_building_card(
		building_type: Building.BuildingType,
		variation_value: float
) -> void:
	var building_card: BuildingCard = _building_card_scene.instantiate()
	building_card.set_type_and_variation(building_type, variation_value)
	%BuildingStack.add_child(building_card)
	%BuildingStack.move_child(building_card, 0)
	%BuildingStack.get_child(-1).set_pickable()
	%BuildingStackCountBubble.set_count(Global.game_state.building_stack.size())


func _pop_building_card() -> void:
	var top_building_card: BuildingCard = %BuildingStack.get_child(-1)
	%BuildingStack.remove_child(top_building_card)
	if %BuildingStack.get_child_count() != 0:
		%BuildingStack.get_child(-1).set_pickable()
	%BuildingStackCountBubble.set_count(Global.game_state.building_stack.size())
	top_building_card.queue_free()


func _update_building_card_positions() -> void:
	var building_card_count: int = %BuildingStack.get_child_count()
	var building_cards: Array[Node] = %BuildingStack.get_children()
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

# Listens to GameplayEventBus.session_created(save_slot_index: int).
func _on_session_created(_save_slot_index: int) -> void:
	# INFO: No need to load anything here since Global.game_state.building_stack
	# should be empty at the start a new sessions. The [Game] and
	# [BuildingStackController] would handle the remaining logic.
	# WARNING: This is tightly coupled to the session creation and restoration
	# logic. See [method _on_session_restored] below.
	pass


# Listens to GameplayEventBus.session_restored(save_slot_index: int).
func _on_session_restored(_save_slot_index: int) -> void:
	# INFO: Load the building stack of the restored session from
	# Global.game_state.building_stack.
	# WARNING: This is tightly coupled to the session restoration logic in
	# [Game] and [BuildingStackController]. May become problematic later in
	# development, fix if needed (#173). Maintain extra caution around this for
	# now.
	var building_stack_count: int = Global.game_state.building_stack.size()
	for index: int in range(building_stack_count - 1, -1, -1):
		var building_dictionary: Dictionary[StringName, Variant] =\
				Global.game_state.building_stack[index]
		_on_building_stack_building_added(
				building_dictionary.building_type,
				building_dictionary.variation_value)
		%BuildingStackCountBubble.set_count(
				building_stack_count - index)


# Listens to GameplayEventBus.building_stack_building_added(
#		building_type: Building.BuildingType,
#		variation_value: float).
func _on_building_stack_building_added(
		building_type: Building.BuildingType,
		variation_value: float
) -> void:
	%AnimationPlayer.play("add_building_card")
	_add_building_card(building_type, variation_value)
	redraw()


# Listens to GameplayEventBus.building_stack_building_popped(
#		building: Building.BuildingType,
#		variation_value: float).
func _on_building_stack_building_popped(
		_building: Building.BuildingType,
		_variation_value: float
) -> void:
	_pop_building_card()
	redraw()


# Listens to GameplayEventBus.game_over(
#		population_reached: int,
#		game_over_type: Game.GameOverType).
func _on_game_over(_population: int, _game_over_type: Game.GameOverType) -> void:
	if %BuildingStack.get_child_count() > 0:
		for building_card: BuildingCard in %BuildingStack.get_children():
			building_card.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		%AnimationPlayer.play("game_over")

#endregion
# ============================================================================ #

extends SfxController


# ============================================================================ #
#region Exported properties

@export var world: World = null

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private variables

var _last_preview_cursor_coords: Vector2i
var _is_preview_cursor_snapped: bool = false

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	super()

	GameplayEventBus.reward_triggered.connect(_on_reward_triggered)
	GameplayEventBus.building_placed.connect(_on_building_placed)
	GameplayEventBus.forest_enclosed.connect(_on_forest_enclosed)
	GameplayEventBus.building_stack_building_added.connect(_on_building_stack_building_added)
	UIEventBus.building_card_picked.connect(_on_building_card_picked)
	UIEventBus.building_card_dropped.connect(_on_building_card_dropped)
	UIEventBus.preview_cursor_snapped.connect(_on_preview_cursor_snapped)
	UIEventBus.preview_cursor_unsnapped.connect(_on_preview_cursor_unsnapped)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to GameplayEventBus.reward_triggered(reward: RewardController.Reward).
func _on_reward_triggered(_reward: RewardController.Reward) -> void:
	play_sound(&"MilestoneReached")


# Listens to GameplayEventBus.building_placed(
#		coords: Vector2i,
#		building_type: Building.BuildingType,
#		variation_value: float,
#		interaction_result: BuildingRulesetEngine.InteractionResult).
func _on_building_placed(
		coords: Vector2i,
		_building_type: Building.BuildingType,
		_variation_value: float,
		_interaction_result: BuildingRulesetEngine.InteractionResult
) -> void:
	play_sound_2d(&"BuildingPlaced2D", world.map_to_local(coords),
			false, true, true)


# Listens to GameplayEventBus.forest_enclosed(coords: Vector2i).
func _on_forest_enclosed(coords: Vector2i) -> void:
	play_sound_2d(&"ForestEnclosed2D", world.map_to_local(coords),
			false, false, true)


# Listens to GameplayEventBus.building_stack_building_added(
#		building_type: Building.BuildingType,
#		variation_value: float).
func _on_building_stack_building_added(
		_building_type: Building.BuildingType,
		_variation_value: float
) -> void:
	play_sound(&"BuildingCardAdded", false, true)


# Listens to UIEventBus.building_card_picked(
#		building_type: Building.BuildingType,
#		variation_value: float).
func _on_building_card_picked(
		_building_type: Building.BuildingType,
		_variation_value: float
) -> void:
	play_sound(&"BuildingCardPicked", false, true)


# Listens to UIEventBus.building_card_dropped(
#		building_type: Building.BuildingType,
#		variation_value: float).
func _on_building_card_dropped(
		_building_type: Building.BuildingType,
		_variation_value: float
) -> void:
	play_sound(&"BuildingCardDropped", false, true)


# Listens to UIEventBus.preview_cursor_snapped(
#		coords: Vector2i,
#		picked_building_type: Building.BuildingType,
#		variation_value: float,
#		placement_check_status: BuildingRulesetEngine.PlacementCheckStatus,
#		interaction_result: BuildingRulesetEngine.InteractionResult).
func _on_preview_cursor_snapped(
		coords: Vector2i,
		_picked_building_type: Building.BuildingType,
		_variation_value: float,
		_placement_check_status: BuildingRulesetEngine.PlacementCheckStatus,
		_interaction_result: BuildingRulesetEngine.InteractionResult
) -> void:
	if _last_preview_cursor_coords != coords:
		_is_preview_cursor_snapped = false
		_last_preview_cursor_coords = coords
	if not _is_preview_cursor_snapped:
		play_sound_2d(&"CursorSnapped2D", world.map_to_local(coords),
				false, false, true)
		_is_preview_cursor_snapped = true


# Listens to UIEventBus.preview_cursor_unsnapped.
func _on_preview_cursor_unsnapped() -> void:
	_is_preview_cursor_snapped = false

#endregion
# ============================================================================ #

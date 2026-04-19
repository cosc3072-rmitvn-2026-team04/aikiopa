extends GameUI


# ============================================================================ #
#region Exported properties

@export var world: World = null
@export var population_controller: PopulationController = null
@export var reward_controller: RewardController = null

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private variables

# The building card currently on the player's hand to be placed down in the
# [World].
var _picked_building: Building.BuildingType = Building.BuildingType.NONE

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	_update_population_milestone_progress_bar(null)
	_update_population_label()

	UIEventBus.building_card_picked.connect(_on_building_card_picked)
	UIEventBus.building_card_dropped.connect(_on_building_card_dropped)
	UIEventBus.preview_cursor_snapped.connect(_on_preview_cursor_snapped)
	UIEventBus.preview_cursor_unsnapped.connect(_on_preview_cursor_unsnapped)
	GameplayEventBus.building_placed.connect(_on_building_placed)
	GameplayEventBus.population_changed.connect(_on_population_changed)


func _input(event: InputEvent) -> void:
	if (
			_picked_building != Building.BuildingType.NONE
			and	event is InputEventMouseButton
			and event.pressed
			and event.button_index == MOUSE_BUTTON_LEFT
	):
		UIEventBus.building_placement_requested.emit(
				world.get_local_mouse_position(),
				_picked_building)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins

func _activate_population_milestone_preview_progress_bar(
		interaction_result: BuildingRulesetEngine.InteractionResult
) -> void:
	var population_milestones_reached: int =\
			Global.game_state.population_milestones_reached
	var previous_population_milestone: int = (
			0 if population_milestones_reached == 0
			else reward_controller.get_population_milestone(
					population_milestones_reached - 1)
	)
	var current_population_milestone: int =\
			reward_controller.get_population_milestone(population_milestones_reached)

	var bar: ProgressBar = %PopulationMilestonePreviewProgressBar
	if bar.has_theme_stylebox_override(&"fill"):
		bar.remove_theme_stylebox_override(&"fill")
	if interaction_result.get_population_change() >= 0:
		bar.max_value = (
				current_population_milestone
				- previous_population_milestone
		)
		bar.value = (
				population_controller.get_population()
				+ interaction_result.get_population_change()
				- previous_population_milestone
		)
		bar.add_theme_stylebox_override(&"fill", load(bar.STYLE_BOX_BAR_POSITIVE))
	else:
		bar.max_value = (
				current_population_milestone
				- previous_population_milestone
		)
		bar.value = (
				population_controller.get_population()
				- previous_population_milestone
		)
		bar.add_theme_stylebox_override(&"fill", load(bar.STYLE_BOX_BAR_NEGATIVE))


func _deactivate_population_milestone_preview_progress_bar() -> void:
	var population_milestones_reached: int =\
			Global.game_state.population_milestones_reached
	var previous_population_milestone: int = (
			0 if population_milestones_reached == 0
			else reward_controller.get_population_milestone(
					population_milestones_reached - 1)
	)
	var current_population_milestone: int =\
			reward_controller.get_population_milestone(population_milestones_reached)

	var bar: ProgressBar = %PopulationMilestonePreviewProgressBar
	bar.max_value = current_population_milestone - previous_population_milestone
	bar.value = 0.0


func _update_population_milestone_progress_bar(
		interaction_result: BuildingRulesetEngine.InteractionResult
) -> void:
	var population_milestones_reached: int =\
			Global.game_state.population_milestones_reached
	var previous_population_milestone: int = (
			0 if population_milestones_reached == 0
			else reward_controller.get_population_milestone(
					population_milestones_reached - 1)
	)
	var current_population_milestone: int =\
			reward_controller.get_population_milestone(population_milestones_reached)

	var bar: ProgressBar = %PopulationMilestoneProgressBar
	if interaction_result: # Updates on preview cursor snapping.
		if interaction_result.get_population_change() <= 0:
			bar.max_value = (
					current_population_milestone
					- previous_population_milestone
			)
			bar.value = (
					population_controller.get_population()
					+ interaction_result.get_population_change()
					- previous_population_milestone
			)
	if not interaction_result: # Normal updates after population changes.
		bar.max_value = (
				current_population_milestone
				- previous_population_milestone
		)
		bar.value = (
				population_controller.get_population()
				- previous_population_milestone
		)


func _update_population_label() -> void:
	var population_milestones_reached: int =\
			Global.game_state.population_milestones_reached
	var current_population_milestone: int =\
			reward_controller.get_population_milestone(population_milestones_reached)

	var label: Label = %PopulationLabel
	label.text = "%d/%d👨‍🚀" % [
		population_controller.get_population(),
		current_population_milestone,
	]

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to
# UIEventBus.building_card_picked(building_type: Building.BuildingType).
func _on_building_card_picked(building_type: Building.BuildingType) -> void:
	_picked_building = building_type


# Listens to building_card_dropped(building: Building.BuildingType).
func _on_building_card_dropped(_building: Building.BuildingType) -> void:
	_picked_building = Building.BuildingType.NONE


# Listens to preview_cursor_snapped(
#		coords: Vector2i,
#		picked_building_type: Building.BuildingType,
#		placement_check_status: BuildingRulesetEngine.PlacementCheckStatus,
#		interaction_result: BuildingRulesetEngine.InteractionResult).
func _on_preview_cursor_snapped(
		_coords: Vector2i,
		_picked_building_type: Building.BuildingType,
		placement_check_status: BuildingRulesetEngine.PlacementCheckStatus,
		interaction_result: BuildingRulesetEngine.InteractionResult
) -> void:
	if placement_check_status == BuildingRulesetEngine.PlacementCheckStatus.ALLOWED:
		_activate_population_milestone_preview_progress_bar(interaction_result)
		_update_population_milestone_progress_bar(interaction_result)


func _on_preview_cursor_unsnapped() -> void:
	_deactivate_population_milestone_preview_progress_bar()
	_update_population_milestone_progress_bar(null)


# Listens to GameplayEventBus.building_placed(
#		coords: Vector2i,
#		building_type: Building.BuildingType).
#		interaction_result: BuildingRulesetEngine.InteractionResult).
func _on_building_placed(
		_coords: Vector2i,
		_building_type: Building.BuildingType,
		_interaction_result: BuildingRulesetEngine.InteractionResult
) -> void:
	_picked_building = Building.BuildingType.NONE


# Listens to
# GameplayEventBus.population_changed(old_amount: int, new_amount: int).
func _on_population_changed(_old_amount: int, _new_amount: int) -> void:
	_update_population_milestone_progress_bar(null)
	_update_population_label()

#endregion
# ============================================================================ #

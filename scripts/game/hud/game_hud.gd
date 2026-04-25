extends GameUI


# ============================================================================ #
#region Exported properties

@export_group("Animation")


@export_subgroup("Population Label", "population_label")

## Maximum scale multiplier reached when the population label is animated for
## positive changes.
@export_range(1.0, 1.5, 0.01) var population_label_max_scale: float = 1.0

## Maximum scale multiplier reached when the population label is animated for
## negative changes.
@export_range(0.5, 1.0, 0.01) var population_label_min_scale: float = 1.0

## The duration (in seconds) of the initial scaling phase when the label
## transitions from its default [Vector2.ONE] scale to its target max/min scale.
@export_range(0.01, 1.0, 0.01, "suffix:s")
var population_label_tween_in_duration: float = 0.5

## The duration (in seconds) of the return scaling phase where the label
## transitions from its target max/min scale back to its default
## [constant Vector2.ONE] scale.
@export_range(0.01, 1.0, 0.01, "suffix:s")
var population_label_tween_out_duration: float = 0.5


@export_subgroup("Population Milestone Progress Bar", "population_milestone_progress_bar")

## The speed (in seconds per population) of the population progress bar
## transition animation.
@export_range(0.1, 1.0, 0.1, "suffix:s/pop")
var population_milestone_progress_bar_tween_speed: float = 0.1

## The maximum duration (in seconds) for the population progress bar transition
## animation.
@export_range(0.1, 5.0, 0.1, "suffix:s")
var population_milestone_progress_bar_max_tween_duration: float = 5.0



@export_group("", "")

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
var _picked_building_variation_value: float = INF
var _first_load: bool = true
var _progress_bar_animating: bool = false

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	_reset_population_milestone_progress_bar()
	_update_population_label()
	%GameSavedLabel.hide()

	UIEventBus.building_card_picked.connect(_on_building_card_picked)
	UIEventBus.building_card_dropped.connect(_on_building_card_dropped)
	UIEventBus.preview_cursor_snapped.connect(_on_preview_cursor_snapped)
	UIEventBus.preview_cursor_unsnapped.connect(_on_preview_cursor_unsnapped)
	GameplayEventBus.building_placed.connect(_on_building_placed)
	GameplayEventBus.population_changed.connect(_on_population_changed)
	GameplayEventBus.session_saved.connect(_on_session_saved)


func _input(event: InputEvent) -> void:
	if (
			_picked_building != Building.BuildingType.NONE
			and	event is InputEventMouseButton
			and event.pressed
			and event.button_index == MOUSE_BUTTON_LEFT
	):
		UIEventBus.building_placement_requested.emit(
				world.get_local_mouse_position(),
				_picked_building,
				_picked_building_variation_value)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private methods

func _activate_population_milestone_preview_progress_bar(
		old_population: int,
		new_population
) -> void:
	var population_change: int = new_population - old_population
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
	if population_change > 0:
		bar.max_value = (
				current_population_milestone
				- previous_population_milestone
		)
		bar.value = (
				old_population
				+ population_change
				- previous_population_milestone
		)
		bar.add_theme_stylebox_override(&"fill", load(bar.STYLE_BOX_BAR_POSITIVE))
	else:
		bar.max_value = (
				current_population_milestone
				- previous_population_milestone
		)
		bar.value = (
				old_population
				- previous_population_milestone
		)
		bar.add_theme_stylebox_override(&"fill", load(bar.STYLE_BOX_BAR_NEGATIVE))
	bar.flash_start()


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
	bar.value = population_controller.get_population() - previous_population_milestone
	bar.flash_reset()


func _reset_population_milestone_progress_bar() -> void:
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
	bar.max_value = current_population_milestone - previous_population_milestone
	bar.value = 0.0


func _update_population_milestone_progress_bar(
		old_population: int,
		new_population: int,
		is_preview: bool = false,
		animated: bool = true
) -> void:
	var population_change = new_population - old_population
	var population_milestones_reached: int =\
			Global.game_state.population_milestones_reached
	var previous_population_milestone: int = (
			0 if population_milestones_reached == 0
			else reward_controller.get_population_milestone(
					population_milestones_reached - 1)
	)
	var current_population_milestone: int =\
			reward_controller.get_population_milestone(population_milestones_reached)
	var target_value: float = (
			old_population + population_change - previous_population_milestone
			if is_preview and population_change <= 0
			else new_population - previous_population_milestone
	)

	var bar: ProgressBar = %PopulationMilestoneProgressBar
	if is_preview:
		bar.max_value = (
				current_population_milestone
				- previous_population_milestone
		)
		if population_change <= 0:
			if animated:
				var tween: Tween = create_tween()
				var duration: float = min(2.0, absf(
						(target_value - bar.value)
						* population_milestone_progress_bar_tween_speed
				))
				tween.tween_property(bar, "value", target_value, duration)\
						.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			else:
				bar.value = target_value
		else:
			bar.value = old_population - previous_population_milestone
		return
	if animated:
		_progress_bar_animating = true
		var max_duration: float = population_milestone_progress_bar_max_tween_duration
		var tween: Tween = create_tween()
		var milestone_crossed: bool = (
				target_value < bar.value
				and old_population < previous_population_milestone
		)
		if milestone_crossed:
			var duration_to_full: float = absf((
					previous_population_milestone - old_population)
					* population_milestone_progress_bar_tween_speed
			)
			var duration_from_empty: float = absf((
					target_value *
					population_milestone_progress_bar_tween_speed
			))
			var total_duration: float = duration_to_full + duration_from_empty
			if total_duration > max_duration:
				duration_to_full = max_duration * duration_to_full / total_duration
				duration_from_empty = max_duration * duration_from_empty / total_duration
			tween.tween_property(bar, "value", bar.max_value, duration_to_full)\
					.set_trans(Tween.TRANS_LINEAR)
			tween.tween_callback(func () -> void:
					bar.max_value = (
							current_population_milestone
							- previous_population_milestone
					)
					bar.value = 0.0)
			tween.tween_property(bar, "value", target_value, duration_from_empty)\
					.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		else:
			var duration: float = min(max_duration, absf(
					(target_value - bar.value)
					* population_milestone_progress_bar_tween_speed
			))
			tween.tween_property(bar, "value", target_value, duration)\
					.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		tween.tween_callback(func () -> void: _progress_bar_animating = false)
	else:
		bar.max_value = (
				current_population_milestone
				- previous_population_milestone
		)
		bar.value = target_value


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


func _animate_population_label(negative: bool) -> void:
	var target_scale: float = (
			population_label_min_scale if negative
			else population_label_max_scale
	)
	var in_duration: float = population_label_tween_in_duration
	var out_duration: float = population_label_tween_out_duration

	var label: Label = %PopulationLabel
	label.pivot_offset_ratio = Vector2.ONE / 2

	var tween: Tween = create_tween()
	tween.tween_property(label, "scale", Vector2.ONE * target_scale, in_duration)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(label, "scale", Vector2.ONE, out_duration)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to UIEventBus.building_card_picked(
#		building_type: Building.BuildingType,
#		variation_value: float).
func _on_building_card_picked(
		building_type: Building.BuildingType,
		variation_value: float
) -> void:
	_picked_building = building_type
	_picked_building_variation_value = variation_value


# Listens to UIEventBus.building_card_dropped(
#		building_type: Building.BuildingType,
#		variation_value: float).
func _on_building_card_dropped(
		_building: Building.BuildingType,
		_variation_value: float
) -> void:
	_picked_building = Building.BuildingType.NONE
	_picked_building_variation_value = INF


# Listens to UIEventBus.preview_cursor_snapped(
#		coords: Vector2i,
#		picked_building_type: Building.BuildingType,
#		variation_value: float,
#		placement_check_status: BuildingRulesetEngine.PlacementCheckStatus,
#		interaction_result: BuildingRulesetEngine.InteractionResult).
func _on_preview_cursor_snapped(
		_coords: Vector2i,
		_picked_building_type: Building.BuildingType,
		_variation_value: float,
		placement_check_status: BuildingRulesetEngine.PlacementCheckStatus,
		interaction_result: BuildingRulesetEngine.InteractionResult
) -> void:
	if placement_check_status == BuildingRulesetEngine.PlacementCheckStatus.ALLOWED:
		var old_population: int = population_controller.get_population()
		var new_population: int = old_population + interaction_result.get_population_change()
		_activate_population_milestone_preview_progress_bar(
				old_population,
				new_population)
		if not _progress_bar_animating:
			_update_population_milestone_progress_bar(
					old_population,
					new_population,
					true)


# Listens to UIEventBus.preview_cursor_unsnapped.
func _on_preview_cursor_unsnapped() -> void:
	_deactivate_population_milestone_preview_progress_bar()
	if not _progress_bar_animating:
		_update_population_milestone_progress_bar(
				population_controller.get_population(),
				population_controller.get_population(),
				true)


# Listens to GameplayEventBus.building_placed(
#		coords: Vector2i,
#		building_type: Building.BuildingType),
#		variation_value: float,
#		interaction_result: BuildingRulesetEngine.InteractionResult).
func _on_building_placed(
		_coords: Vector2i,
		_building_type: Building.BuildingType,
		_variation_value: float,
		_interaction_result: BuildingRulesetEngine.InteractionResult
) -> void:
	_picked_building = Building.BuildingType.NONE
	_picked_building_variation_value = INF


# Listens to
# GameplayEventBus.population_changed(old_amount: int, new_amount: int).
func _on_population_changed(old_amount: int, new_amount: int) -> void:
	if _first_load:
		_first_load = false
		_update_population_milestone_progress_bar(old_amount, new_amount, false, false)
	else:
		_update_population_milestone_progress_bar(old_amount, new_amount)
		_progress_bar_animating = true
	_update_population_label()
	_animate_population_label(new_amount - old_amount < 0)


# Listens to GameplayEventBus.session_saved(save_slot_index: int).
func _on_session_saved(_save_slot_index: int) -> void:
	# TODO: This could be made prettier using a Tween animation on its modulate.
	var game_saved_label_timer: Timer = %GameSavedLabel.get_node("Timer")
	%GameSavedLabel.show()
	game_saved_label_timer.start()
	await game_saved_label_timer.timeout
	%GameSavedLabel.hide()

#endregion
# ============================================================================ #

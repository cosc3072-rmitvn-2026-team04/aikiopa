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
	_update_population_milestone_progress_bar()
	_update_population_label()

	UIEventBus.building_card_picked.connect(_on_building_card_picked)
	UIEventBus.building_card_dropped.connect(_on_building_card_dropped)
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

func _update_population_milestone_progress_bar() -> void:
	var bar: ProgressBar = %PopulationMilestoneProgressBar
	bar.max_value = reward_controller.get_population_milestone(
			Global.game_state.population_milestones_reached)
	bar.value = population_controller.get_population()


func _update_population_label() -> void:
	var label: Label = %PopulationLabel
	label.text = "%d/%d" % [
		population_controller.get_population(),
		reward_controller.get_population_milestone(
				Global.game_state.population_milestones_reached)
	]

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to UIEventBus.building_card_picked(building: Building.BuildingType).
func _on_building_card_picked(building: Building.BuildingType) -> void:
	_picked_building = building


# Listens to building_card_dropped(building: Building.BuildingType).
func _on_building_card_dropped(_building: Building.BuildingType) -> void:
	_picked_building = Building.BuildingType.NONE


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
	_update_population_milestone_progress_bar()
	_update_population_label()

#endregion
# ============================================================================ #

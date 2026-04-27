class_name PopulationController
extends Node


@export var building_ruleset_engine: BuildingRulesetEngine = null


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	GameplayEventBus.building_placed.connect(
			_on_building_placed)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Returns the current amount of population.
func get_population() -> int:
	return Global.game_state.population


## Sets the population to [param amount]. [param amount] must be a non-negative
## value.
func set_population(amount: int) -> void:
	if amount < 0:
		push_error("Invalid population amount. Must be non-negative.")
		return
	var old_amount: int = Global.game_state.population
	Global.game_state.population = amount
	GameplayEventBus.population_changed.emit(old_amount, amount)


## Change the population by [param amount]. Increases the population if
## [param amount] is greater than [code]0[/code], decreases the population if
## [param amount] is lesser than [code]0[/code], and does nothing if
## [param amount] is equal to [code]0[/code].
func change_population(amount: int) -> void:
	if amount == 0:
		return
	set_population(Global.game_state.population + amount)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to GameplayEventBus.building_placed(
#		coords: Vector2i,
#		building_type: Building.BuildingType),
#		variation_value: float,
#		interaction_result: BuildingRulesetEngine.InteractionResult).
func _on_building_placed(
		_coords: Vector2i,
		_building_type: Building.BuildingType,
		_variation_value: float,
		interaction_result: BuildingRulesetEngine.InteractionResult
) -> void:
	if not interaction_result:
		push_error(
				"Unexpected value for 'interaction_result':"
				+ "Should not be 'null' at this stage.")
		return
	if get_population() + interaction_result.get_population_change() < 0:
		set_population(0)
	else:
		change_population(interaction_result.get_population_change())

#endregion
# ============================================================================ #

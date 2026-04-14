class_name RewardController
extends Node
## Controls the rewards given to the player based on
## [member Global.GameState.turns_elapsed] and
## [member Global.GameState.population]. See [member reward_amount].


# ============================================================================ #
#region Exported properties

@export_group("Reward")

## The amount of building cards that the player would receive when reaching a
## population milestone.
@export_range(1, 50, 1, "or_greater", "suffix:buildings") var reward_amount: int = 1


@export_group("Difficulty")

## The higher this number the harder the game would be.
@export_range(0.0, 25.0, 0.1, "or_greater") var difficulty: float = 0.0

## Tune this number based on empirical testing, to be close to the ability of
## the average player.
@export_range(1, 25, 1, "or_greater")
var estimated_population_gain_per_turn: int = 1


@export_group("", "")

@export var population_controller: PopulationController = null

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	GameplayEventBus.population_changed.connect(_on_population_changed)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private methods

func get_population_milestone(index: int) -> int:
	var x: float = 10.0 if index == 0 else index * 20.0
	var k: float = difficulty
	var n: float = estimated_population_gain_per_turn
	var f_x: float = k * pow(x / n, 2) + n * x
	return ceili(f_x / (k * x)) * int(k * x)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to GameplayEventBus.population_changed(
#		old_amount: int,
#		new_amount: int).
func _on_population_changed(_old_amount: int, _new_amount: int) -> void:
	var current_population: int = population_controller.get_population()
	var next_population_milestone: int = get_population_milestone(
			Global.game_state.milestones_reached)
	if current_population >= next_population_milestone:
		GameplayEventBus.reward_triggered.emit(Reward.new(0, reward_amount))
		Global.game_state.milestones_reached += 1

#endregion
# ============================================================================ #


# ============================================================================ #
#region Inner classes

## Represents the result of the interaction between a building and its
## surrounding [World] environment when it is placed.
class Reward extends RefCounted:

	var _population_bonus: int
	var _building_bonus: int


	## Instantiates and initializes a [Reward] with [param population_bonus] and
	## [param building_bonus].[br]
	## [br]
	## If either [param population_bonus] or [param building_bonus] is smaller
	## than [code]0[/code], the value of [code]0[/code] would be used instead.
	func _init(population_bonus, building_bonus) -> void:
		set_population_bonus(population_bonus)
		set_building_bonus(building_bonus)


	## Returns the population bonus reward.
	func get_population_bonus() -> int:
		return _population_bonus


	## Sets the population bonus reward if [param population_bonus] is greater
	## or equal to [code]0[/code]. Otherwise sets it to [code]0[/code].
	func set_population_bonus(population_bonus: int) -> void:
		_population_bonus = 0 if population_bonus < 0 else population_bonus


	## Returns the building bonus reward.
	func get_building_bonus() -> int:
		return _building_bonus


	## Sets the building bonus reward if [param building_bonus] is greater or
	## equal to [code]0[/code]. Otherwise sets it to [code]0[/code].
	func set_building_bonus(building_bonus: int) -> void:
		_building_bonus = 0 if building_bonus < 0 else building_bonus

#endregion
# ============================================================================ #

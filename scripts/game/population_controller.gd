class_name PopulationController
extends Node


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
	GameplayEventBus.population_changed.emit(Global.game_state.population, amount)
	Global.game_state.population = amount


## Increase the population by [param amount]. [param amount] must be greater
## than 0.
func increase_population(amount: int) -> void:
	if amount < 1:
		push_error("Invalid population increment amount. Must be greater than 0.")
		return
	set_population(Global.game_state.population + amount)


## Decrease the population by [param amount]. [param amount] must be greater
## than 0.
func decrease_population(amount: int) -> void:
	if amount < 1:
		push_error("Invalid population decrement amount. Must be greater than 0.")
		return
	if amount > Global.game_state.population:
		set_population(0)
	else:
		set_population(Global.game_state.population - amount)

#endregion
# ============================================================================ #

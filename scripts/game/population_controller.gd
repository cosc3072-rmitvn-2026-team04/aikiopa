class_name PopulationController
extends Node


var _population: int = 0


# ============================================================================ #
#region Public methods

## Returns the current amount of population.
func get_population() -> int:
	return _population


## Sets the population to [param amount]. [param amount] must be a non-negative
## value.
func set_population(amount: int) -> void:
	if amount < 0:
		push_error("Invalid population amount. Must be non-negative.")
		return
	GameplayEventBus.population_changed.emit(_population, amount)
	_population = amount


## Increase the population by [param amount]. [param amount] must be greater
## than 0.
func increase_population(amount: int) -> void:
	if amount < 1:
		push_error("Invalid population increment amount. Must be greater than 0.")
		return
	set_population(_population + amount)


## Decrease the population by [param amount]. [param amount] must be greater
## than 0.
func decrease_population(amount: int) -> void:
	if amount < 1:
		push_error("Invalid population decrement amount. Must be greater than 0.")
		return
	if amount > _population:
		set_population(0)
	else:
		set_population(_population - amount)

#endregion
# ============================================================================ #

extends Node
## Autoload singleton bus for gameplay signals.[br]
## [br]
## Add your gameplay-related signals in here. Other scenes/objects can then have
## global access to these signals. [br]
## [br]
## Remember to include necessary documentation and turn off the
## [code]unused_signal[/code] warning with
## [code]@warning_ignore("unused_signal")[/code] before the signal
## declaration.[br]
## [br]
## Example:
## [codeblock]
## ## Emitted when the player health is reduced to [param health] amount.
## @warning_ignore("unused_signal")
## signal player_hurt(health: float)
## [/codeblock]


## Emitted when a [param building_type] is added to the bottom of the building
## stack. See [BuildingStackController].
@warning_ignore("unused_signal")
signal building_stack_building_added(building_type: Building.BuildingType)


## Emitted when the [param_building_type] at the top of the building stack is
## popped off. See [BuildingStackController].
@warning_ignore("unused_signal")
signal building_stack_building_popped(building_type: Building.BuildingType)


## Emitted when a [Building] of [param building_type] is successfully added at
## [param coords] in the [World].
@warning_ignore("unused_signal")
signal building_placed(
		coords: Vector2i,
		building_type: Building.BuildingType,
		interaction_result: BuildingRulesetEngine.InteractionResult)


## Emitted when a [Building] of [param building_type] at [param coords] is
## destroyed.
@warning_ignore("unused_signal")
signal building_destroyed(coords: Vector2i, building_type: Building.BuildingType)


## Emitted when the population has just been changed from [param old_amount] to
## [param new_amount].
@warning_ignore("unused_signal")
signal population_changed(old_amount: int, new_amount: int)

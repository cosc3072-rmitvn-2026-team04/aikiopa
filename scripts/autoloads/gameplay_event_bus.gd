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


## Emitted when a new game session has been created and assigned to the save
## file at [param save_slot_index] in [constant GameSaveService.SAVE_FILES].
@warning_ignore("unused_signal")
signal session_created(save_slot_index: int)


## Emitted when a game session has completed loading from the save file at
## [param save_slot_index] in [constant GameSaveService.SAVE_FILES].
@warning_ignore("unused_signal")
signal session_restored(save_slot_index: int)


## Emitted when a game session has been saved in the save file at
## [param save_slot_index] in [constant GameSaveService.SAVE_FILES].
@warning_ignore("unused_signal")
signal session_saved(save_slot_index: int)


## Emitted when the [RewardController] determines that the [param reward] should
## be given to the player.
@warning_ignore("unused_signal")
signal reward_triggered(reward: RewardController.Reward)


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


# TODO: At the moment nothing is listening to this. Implement in #21.
## Emitted when a [Building] of [param building_type] at [param coords] is
## destroyed.
@warning_ignore("unused_signal")
signal building_destroyed(coords: Vector2i, building_type: Building.BuildingType)


## Emitted when the population has just been changed from [param old_amount] to
## [param new_amount].
@warning_ignore("unused_signal")
signal population_changed(old_amount: int, new_amount: int)


## Emitted when game over conditions has been satisfied. See
## [method Game.is_game_over].[br]
## [br]
## [param population_reached] is the amount of population reached at the end of
## the session when the game ended with [param game_over_type].
@warning_ignore("unused_signal")
signal game_over(population_reached: int, game_over_type: Game.GameOverType)

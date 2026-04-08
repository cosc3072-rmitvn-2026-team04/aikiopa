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


## Emitted when a new random building is added to the bottom of the building
## stack. [param building] identifies the [World.BuildingType] the added
## building.
@warning_ignore("unused_signal")
signal building_stack_building_added(building: World.BuildingType)


## Emitted when the building at the top of the building stack is popped off.
## [param building] identifies the [World.BuildingType] of the popped building.
@warning_ignore("unused_signal")
signal building_stack_building_popped(building: World.BuildingType)


## Emitted when the player picks up a [param building] card.
@warning_ignore("unused_signal")
signal building_card_picked(building: World.BuildingType)


## Emitted when the player drops the [param building] card back to the building
## stack.
@warning_ignore("unused_signal")
signal building_card_dropped(building: World.BuildingType)


## Emitted when the population has just been changed from [param old_amount] to
## [param new_amount].
@warning_ignore("unused_signal")
signal population_changed(old_amount: int, new_amount: int)


## Emitted when [member Global.gameplay_debug_mode_enabled] changes to
## [param value].
@warning_ignore("unused_signal")
signal gameplay_debug_mode_toggled(value: bool)

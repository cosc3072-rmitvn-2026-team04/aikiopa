extends Node
## Autoload singleton bus for user interface signals.[br]
## [br]
## Add your UI-related signals in here. Other scenes/objects can then have
## global access to these signals. [br]
## [br]
## Remember to include necessary documentation and turn off the
## [code]unused_signal[/code] warning with
## [code]@warning_ignore("unused_signal")[/code] before the signal
## declaration.[br]
## [br]
## Example:
## [codeblock]
## ## Emitted when the player opens the inventory UI.
## @warning_ignore("unused_signal")
## signal inventory_opened
## [/codeblock]


## Emitted when the player picks up a [param building] card from the building
## stack in the Game HUD.
@warning_ignore("unused_signal")
signal building_card_picked(building_type: Building.BuildingType)


## Emitted when the player drops the [param building] card back to the building
## stack in the Game HUD.
@warning_ignore("unused_signal")
signal building_card_dropped(building_type: Building.BuildingType)


## Emitted when the building preview cursor snaps into a tile at [param coords]
## for the [param picked_building_type]. The calculated resulting game effects
## are given in [param placement_check_status] and [param interaction_result].
@warning_ignore("unused_signal")
signal preview_cursor_snapped(
		coords: Vector2i,
		picked_building_type: Building.BuildingType,
		placement_check_status: BuildingRulesetEngine.PlacementCheckStatus,
		interaction_result: BuildingRulesetEngine.InteractionResult)


## Emitted when the building preview cursor unsnaps. See
## [signal preview_cursor_snapped].
@warning_ignore("unused_signal")
signal preview_cursor_unsnapped()


## Emitted when the player attempts to use the building card they have on hand
## (picked up) to place [param building_type] at [param mouse_position].[br]
## [br]
## [b]Note:[/b] [param mouse_position] is NOT the corresponding tile position
## in the [World]. Use [method World.local_to_map] to convert it to the [World]
## space coordinates.
@warning_ignore("unused_signal")
signal building_placement_requested(
        mouse_position: Vector2,
        building_type: Building.BuildingType)


## Emitted when [member Global.gameplay_debug_mode_enabled] changes to the value
## of [param toggled_on].
@warning_ignore("unused_signal")
signal gameplay_debug_mode_toggled(toggled_on: bool)


## Emitted when the player requests to show/hide The Shroud from gameplay debug
## mode.
@warning_ignore("unused_signal")
signal gameplay_debug_mode_shroud_toggled(toggled_on: bool)

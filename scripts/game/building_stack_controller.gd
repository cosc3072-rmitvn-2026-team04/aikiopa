class_name BuildingStackController
extends Node
## Manages the player's building card stack. In computer science terms, this
## works as a
## [url=https://en.wikipedia.org/wiki/Queue_(abstract_data_type)]queue[/url].


## The non-uniform weights used for random building generation. Building types
## with higher weights appear more often than those with lower weights.[br]
## [br]
## Used as input for the internal [method RandomNumberGenerator.rand_weighted]
## calls in this [BuildingStackController].[br]
## [br]
## [b]Note:[/b] Setting a weight to [code]0[/code] means the corresponding
## building would never appear.[br]
## [br]
## [color=red][b]WARNING: Do not add any new Key/Value pair into this
## property in the Godot Editor. Doing so will result in undefined
## behavior.[/b][/color]
@export var building_type_weights: Dictionary[World.BuildingType, float] = {
	World.BuildingType.HOUSING: 1.0,
	World.BuildingType.GREENHOUSE: 1.0,
	World.BuildingType.RANCH: 1.0,
	World.BuildingType.FISHERY: 1.0,
	World.BuildingType.SOLAR_FARM: 1.0,
	World.BuildingType.WIND_FARM: 1.0,
	World.BuildingType.NUCLEAR_REACTOR: 1.0,
	World.BuildingType.FACTORY: 1.0,
}

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


# ============================================================================ #
#region Public methods

## Initializes the building stack generator, or restore a previous state by
## providing [param building_queue] [param session_seed], and
## [param session_state] with non empty values.[br]
## [br]
## [b]Note:[/b] Do not set [param session_state] to arbitrary values, since the
## internal [RandomNumberGenerator] requires its state to have certain qualities
## to behave properly. It should only be set to values that came from
## [method get_session_state].
func initialize_session(
		building_queue: Array[World.BuildingType],
		session_seed: Variant = null,
		session_state: Variant = null
) -> void:
	if (
			(not session_seed and session_state)
			or (session_seed and not session_state)
	):
		push_error("Both 'session_seed' and 'session_state' must be set.")
		return

	if session_seed and session_state:
		_rng.seed = session_seed
		_rng.state = session_state
	else:
		_rng.randomize()

	Global.game_state.building_stack = building_queue


## Returns the seed of the internal [RandomNumberGenerator]. Useful for saving
## and restoring game sessions.
func get_session_seed() -> int:
	return _rng.seed


## Returns the state of the internal [RandomNumberGenerator]. Useful for saving
## and restoring game sessions.
func get_session_state() -> int:
	return _rng.state


## Adds a random [enum World.BuildingType] to the bottom of the building stack,
## then returns that building type.
func add_building() -> void:
	var new_building_type_index: int =_rng.rand_weighted(
			PackedFloat32Array(building_type_weights.values()))
	var new_building_type: World.BuildingType =\
			World.GENERATED_BUILDING_TYPES[new_building_type_index]
	Global.game_state.building_stack.push_front(new_building_type)
	GameplayEventBus.building_stack_building_added.emit(new_building_type)


## Pops and returns the building type at the top of the building stack. Returns
## [constant World.BuildingType.NONE] if the building stack is already empty.
func pop_building() -> World.BuildingType:
	if is_empty():
		return World.BuildingType.NONE
	var building_type: World.BuildingType =\
			Global.game_state.building_stack.pop_back()
	GameplayEventBus.building_stack_building_popped.emit(building_type)
	return building_type


## Removes all buildings from the building stack.
func clear_building_queue() -> void:
	Global.game_state.building_stack.clear()


## Returns the number of building in the building stack. Empty building stack
## always returns [code]0[/code]. See also [method is_empty].
func size() -> int:
	return Global.game_state.building_stack.size()


## Returns [code]true[/code] if the building stack is empty ([code][][/code]).
## See also [method size].
func is_empty() -> bool:
	return Global.game_state.building_stack.is_empty()

#endregion
# ============================================================================ #

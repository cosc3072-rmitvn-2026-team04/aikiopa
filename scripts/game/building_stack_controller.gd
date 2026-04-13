class_name BuildingStackController
extends Node
## Manages the player's building card stack. In computer science terms, this
## works as a
## [url=https://en.wikipedia.org/wiki/Queue_(abstract_data_type)]queue[/url].


# ============================================================================ #
#region Exported properties

@export_group("Generator")

## The non-uniform weights used for random building generation. Building types
## with higher weights appear more often than those with lower weights.[br]
## [br]
## Used as input for the internal [method RandomNumberGenerator.rand_weighted]
## calls in this [BuildingStackController].[br]
## [br]
## [b]Note:[/b] Setting a weight to [code]0[/code] means the corresponding
## building would never appear.[br]
## [br]
## [color=red][b]WARNING: Do not add/remove any Key/Value pair into this
## property in the Godot Editor. Doing so will result in undefined
## behavior.[/b][/color]
@export var building_type_weights: Dictionary[Building.BuildingType, float] = {
	Building.BuildingType.LANDING_SITE: 0.0,
	Building.BuildingType.HOUSING: 1.0,
	Building.BuildingType.GREENHOUSE: 1.0,
	Building.BuildingType.RANCH: 1.0,
	Building.BuildingType.FISHERY: 1.0,
	Building.BuildingType.SOLAR_FARM: 1.0,
	Building.BuildingType.WIND_FARM: 1.0,
	Building.BuildingType.NUCLEAR_REACTOR: 1.0,
	Building.BuildingType.FACTORY: 1.0,
}

## The buildings guaranteed to be generated at the start of each new session.
@export var guaranteed_starting_buildings: Array[Building.BuildingType] = []

## The number of random [BuildingCard]s that the player receives in each new
## session, in addition to the [member guaranteed_starting_buildings].
@export_range(1, 50, 1) var starting_random_buildings_count: int = 1


@export_group("", "")

@export var building_ruleset_engine: BuildingRulesetEngine = null

#endregion
# ============================================================================ #


# ============================================================================ #
#region Variables

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	GameplayEventBus.building_placed.connect(_on_building_placed)

#endregion
# ============================================================================ #


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
		building_queue: Array[Building.BuildingType],
		session_seed: Variant = null,
		session_state: Variant = null
) -> void:
	if (
			(not session_seed and session_state)
			or (session_seed and not session_state)
	):
		push_error("Both parameters 'session_seed' and 'session_state' must be set.")
		return

	if session_seed and session_state:
		_rng.seed = session_seed
		_rng.state = session_state
		Global.game_state.building_stack = building_queue
	else:
		_rng.randomize()
		for building_type in guaranteed_starting_buildings:
			add_building(building_type)
			# TODO: Workaround: Without this line, rapid adding of buildings
			# would make the building stack UI put its cards at the wrong
			# positions. Fix this. If not possible then find out where to put
			# the hard-coded 0.1 seconds into an exported property, or as a
			# constant in [Global].
			await get_tree().create_timer(0.1).timeout
		for iteration: int in range(starting_random_buildings_count):
			add_building()
			# TODO: Workaround: Without this line, rapid adding of buildings
			# would make the building stack UI put its cards at the wrong
			# positions. Fix this. If not possible then find out where to put
			# the hard-coded 0.1 seconds into an exported property, or as a
			# constant in [Global].
			await get_tree().create_timer(0.1).timeout


## Returns the seed of the internal [RandomNumberGenerator]. Useful for saving
## and restoring game sessions.
func get_session_seed() -> int:
	return _rng.seed


## Returns the state of the internal [RandomNumberGenerator]. Useful for saving
## and restoring game sessions.
func get_session_state() -> int:
	return _rng.state


## Adds a random [enum Building.BuildingType] to the bottom of the building
## stack.[br]
## [br]
## If [param building_type] is provided, adds that to the building stack instead.
func add_building(
		building_type: Building.BuildingType = Building.BuildingType.NONE
) -> void:
	if building_type != Building.BuildingType.NONE:
		Global.game_state.building_stack.push_front(building_type)
		GameplayEventBus.building_stack_building_added.emit(building_type)
		return

	var new_building_type: Building.BuildingType = (
			_rng.rand_weighted(PackedFloat32Array(building_type_weights.values()))
			+ 1 # Skip Building.BuildingType.NONE.
	) as Building.BuildingType
	Global.game_state.building_stack.push_front(new_building_type)
	GameplayEventBus.building_stack_building_added.emit(new_building_type)


## Pops and returns the building type at the top of the building stack. Returns
## [constant Building.BuildingType.NONE] if the building stack is already empty.
func pop_building() -> Building.BuildingType:
	if is_empty():
		return Building.BuildingType.NONE
	var building_type: Building.BuildingType =\
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


# ============================================================================ #
#region Signal listeners

# Listens to GameplayEventBus.building_placed(
#		coords: Vector2i,
#		building_type: Building.BuildingType).
#		interaction_result: BuildingRulesetEngine.InteractionResult).
func _on_building_placed(
		_coords: Vector2i,
		building_type: Building.BuildingType,
		interaction_result: BuildingRulesetEngine.InteractionResult
) -> void:
	var building_stack_top: Building.BuildingType =\
			Global.game_state.building_stack.back()
	if building_stack_top != building_type:
		push_error("Top building card (%s) does not match placed building (%s)" % [
			Building.BuildingType.keys()[building_stack_top],
			Building.BuildingType.keys()[building_type],
		])
		return
	if not interaction_result:
		push_error(
				"Unexpected value for 'interaction_result':"
				+ "Should not be 'null' at this stage.")
		return
	for interation: int in range(interaction_result.get_building_bonus()):
		add_building()

	pop_building()

#endregion
# ============================================================================ #

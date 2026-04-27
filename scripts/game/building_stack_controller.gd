class_name BuildingStackController
extends Node
## Manages the player's building card stack. In computer science terms, this
## works as a
## [url=https://en.wikipedia.org/wiki/Queue_(abstract_data_type)]queue[/url].


# ============================================================================ #
#region Constants

## Maximum amount of allowed rerolls for the internal generator when it cannot
## generate a building with available placement for the player to not get stuck.
const MAX_REROLL_COUNT: int = 10_000

#endregion
# ============================================================================ #


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

@export var world: World = null
@export var building_ruleset_engine: BuildingRulesetEngine = null

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private variables

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	GameplayEventBus.building_placed.connect(_on_building_placed)
	GameplayEventBus.reward_triggered.connect(_on_reward_triggered)

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
	else:
		_rng.randomize()
		Global.game_state.building_stack_seed = get_session_seed()
		for building_type:Building.BuildingType in guaranteed_starting_buildings:
			add_building(building_type)
		for iteration: int in range(starting_random_buildings_count):
			add_building()
		Global.game_state.building_stack_state = get_session_state()


## Returns the seed of the internal [RandomNumberGenerator]. Useful for saving
## and restoring game sessions.
func get_session_seed() -> int:
	return _rng.seed


## Returns the state of the internal [RandomNumberGenerator]. Useful for saving
## and restoring game sessions.
func get_session_state() -> int:
	return _rng.state


## Adds a random [enum Building.BuildingType] to the bottom of the building
## stack, then returns it. Only generates buildings that has a valid tile to
## be placed on. Returns [constant Building.NONE] if cannot roll for a suitable
## building type before reaching [constant MAX_REROLL_COUNT].[br]
## [br]
## If [param building_type] is provided, adds that to the building stack
## instead.
func add_building(
		building_type: Building.BuildingType = Building.BuildingType.NONE
) -> Building.BuildingType:
	var building_dictionary: Dictionary[StringName, Variant] = {
		&"building_type": building_type,
		&"variation_value": 0.0,
	}

	if building_type != Building.BuildingType.NONE:
		building_dictionary.variation_value = _generate_variation_value()
		Global.game_state.building_stack.push_front(building_dictionary)
		GameplayEventBus.building_stack_building_added.emit(
				building_dictionary.building_type,
				building_dictionary.variation_value)
		return building_type

	var new_building_type: Building.BuildingType = Building.BuildingType.NONE
	var valid_placement_count: int = 0
	var reroll_count: int = 0
	while valid_placement_count == 0 and reroll_count < MAX_REROLL_COUNT:
		# BUG: In some rare cases this still rolls Fishery when there is no
		# valid placement. Investigate and fix.
		reroll_count += 1

		new_building_type = (
				_rng.rand_weighted(PackedFloat32Array(building_type_weights.values()))
				+ 1 # Skip Building.BuildingType.NONE.
		) as Building.BuildingType
		Global.game_state.building_stack_state = get_session_state()

		# Loop through all buildings at the edge of the colony.
		for edge_coords in Global.game_state.edge_coords:

			# Loop through all neighbors of each edge building.
			var edge_surrounding_neighbor_coords: Array[Vector2i] =\
					Math.HexGrid.get_offset_surrounding_neighbors(
							edge_coords,
							Math.HexGrid.OffsetLayout.ODD_R)
			for edge_neighbor_coords: Vector2i in edge_surrounding_neighbor_coords:
				var ruleset_parse_result: Dictionary[StringName, Variant] =\
						building_ruleset_engine.parse_rules(
								edge_neighbor_coords,
								new_building_type)
				if (
						# Find valid space for 'new_building_type'.
						ruleset_parse_result.placement_check_status
						== BuildingRulesetEngine.PlacementCheckStatus.ALLOWED
				):
					valid_placement_count += 1

		var building_stack_building_type_only: Array[Building.BuildingType] = []
		building_stack_building_type_only = Array(Global.game_state.building_stack.map(
				func (
						building_dictionary_from_stack: Dictionary[StringName, Variant]
				) -> Building.BuildingType:
						return building_dictionary_from_stack.building_type),
				TYPE_INT, "", null)
		if (
				# The building stack has more cards of 'new_building_type' than
				# there is available space for it.
				building_stack_building_type_only.count(new_building_type)
				>= valid_placement_count
		):
			valid_placement_count = 0 # Reset and go to the next reroll.

	if new_building_type == Building.BuildingType.NONE:
		push_error("Reroll exhausted: Could not find a suitable building type.")
		return new_building_type

	building_dictionary.building_type = new_building_type
	building_dictionary.variation_value = _generate_variation_value()
	Global.game_state.building_stack.push_front(building_dictionary)
	GameplayEventBus.building_stack_building_added.emit(
			building_dictionary.building_type,
			building_dictionary.variation_value)
	return new_building_type


## Pops and returns the building type at the top of the building stack. Returns
## [constant Building.NONE] if the building stack is already empty.
func pop_building() -> Building.BuildingType:
	if is_empty():
		return Building.BuildingType.NONE
	var building_dictionary: Dictionary[StringName, Variant] =\
			Global.game_state.building_stack.pop_back()
	GameplayEventBus.building_stack_building_popped.emit(
			building_dictionary.building_type,
			building_dictionary.variation_value)
	return building_dictionary.building_type


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
#region Private methods

func _generate_variation_value() -> float:
	var variation_value: float = _rng.randf_range(-1.0, 1.0)
	Global.game_state.building_stack_state = get_session_state()
	return variation_value

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to GameplayEventBus.building_placed(
#		coords: Vector2i,
#		building_type: Building.BuildingType,
#		variation_value: float,
#		interaction_result: BuildingRulesetEngine.InteractionResult).
func _on_building_placed(
		_coords: Vector2i,
		building_type: Building.BuildingType,
		_variation_value: float,
		interaction_result: BuildingRulesetEngine.InteractionResult
) -> void:
	var building_stack_top: Building.BuildingType =\
			Global.game_state.building_stack.back().building_type
	if building_stack_top != building_type:
		# WARNING: DO NOT REMOVE THIS CHECK. It is useful for catching quiet
		# semantic errors produced by any regressions in [BuildingStackUI],
		# which is tightly coupled to multiple game systems. This is obviously
		# suboptimal, but fix (#173) is not needed for now.
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


# Listens to GameplayEventBus.reward_triggered(reward: RewardController.Reward).
func _on_reward_triggered(reward: RewardController.Reward) -> void:
	for iteration: int in range(reward.get_building_bonus()):
		add_building()

#endregion
# ============================================================================ #

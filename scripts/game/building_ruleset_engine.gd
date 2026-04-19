class_name BuildingRulesetEngine
extends Node
## Evaluates the core interactions between building and terrain in the game
## through stateless validation methods.


# ============================================================================ #
#region Enums

enum PlacementCheckStatus {
	## Undefined behavior.
	UNDEFINED = 1,

	## Placement is allowed.
	ALLOWED = 0,

	## Placement blocked: On invalid terrain.
	BLOCKED_BY_TERRAIN = -1,

	## Placement blocked: Not adjacent to existing building(s).
	BLOCKED_BY_DISCONNECTION = -2,

	## Placement blocked: Existing building is in the way.
	BLOCKED_BY_BUILDING = -3,

	## Placement blocked: Not allowed by adjacent building(s).
	BLOCKED_BY_ADJACENT_BUILDING = -4,
}

#endregion
# ============================================================================ #


# ============================================================================ #
#region Exported properties

@export_group("Combo Rules", "combo_rule")

## The amount of population gained per forest tile when a region of forest is
## enclosed.
@export_range(1, 100, 1, "suffix:pops/tile")
var combo_rule_forest_population_gain: int = 10

## The amount of building bonus gained per forest tile when a region of forest
## is enclosed.
@export_range(0, 50, 1, "suffix:buildings/tile")
var combo_rule_forest_building_bonus_gain: int = 0


@export_group("", "")

@export var world: World

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private variables

## Building versus Terrain ruleset. Schema:
## [codeblock]
## {
##     [
##         Building.BuildingType,
##         World.TerrainType,
##     ]: [PlacementCheckStatus, InteractionResult]
## }
## [/codeblock]
## [color=red][b]Internal game mechanics loaded at [method Node._ready]. Do not
## modify during runtime.[/b][/color]
var _bvt_rules: Dictionary[Array, Array] = {}

## Building versus adjacent Building ruleset. Schema:
## [codeblock]
## {
##     [
##         Building.BuildingType,
##         Building.BuildingType, # The adjacent building.
##     ]: [PlacementCheckStatus, InteractionResult]
## }
## [/codeblock]
## [color=red][b]Internal game mechanics loaded at [method Node._ready]. Do not
## modify during runtime.[/b][/color]
var _bvb_rules: Dictionary[Array, Array] = {}

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	_bvt_rules = _load_ruleset_bvt()
	_bvb_rules = _load_ruleset_bvb()

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Returns a dictionary consisting of two elements:[br]
## - [code]&"placement_check_status"[/code]: Calculated
## [enum PlacementCheckStatus] for [param building_type] at [param coords].[br]
## - [code]&"interaction_result"[/code]: Calculated total
## [BuildingRulesetEngine.InteractionResult] between [param building_type] and
## the environment around [param coords]. Will be [code]null[/code] if
## [code]&"placement_check_status"[/code] is any value other than
## [constant BuildingRulesetEngine.PlacementCheckStatus.ALLOWED].[br]
## [br]
## [b]Advanced:[/b] For more granular output, set [param summarized] to
## [code]false[/code]. The total [code]&"interaction_result"[/code] will
## instead be divided and returned as a
## [code]Dictionary[Vector2i, BuildingRulesetEngine.InteractionResult][/code]
## with each key-value pair corresponding to a unit
## [BuildingRulesetEngine.InteractionResult] value coming from its [Vector2i]
## key. If [code]&"placement_check_status"[/code] is [code]null[/code], this
## will consist of a single key-value pair of [param coords] and
## [code]null[/code], i.e. [code]{ coords: null }[/code].[br]
## [br]
## [color=orange][b]WARNING:[/b] Since the return schema of this method is loose
## ([code]&"interaction_result"[/code] can be either one object or a dictionary
## of coordinates-object pairs), extra caution must be taken to manage and keep
## track of the returned output.[/color]
func parse_rules(
		coords: Vector2i,
		building_type: Building.BuildingType,
		summarized: bool = true
) -> Dictionary[StringName, Variant]:
	if not _has_adjacent_building(coords):
		return _create_parse_result(
				PlacementCheckStatus.BLOCKED_BY_DISCONNECTION,
				{ coords: null }, summarized)

	if not _is_clear_of_building(coords):
		return _create_parse_result(
				PlacementCheckStatus.BLOCKED_BY_BUILDING,
				{ coords: null }, summarized)

	#region Step 1: Building versus Terrain check
	# Step 1: Building versus Terrain check. Must pass before next step.
	var bvt_parse_result: Array[Variant] = _bvt_rules[[
		building_type, world.get_terrain_at(coords)
	]]
	if bvt_parse_result[0] != PlacementCheckStatus.ALLOWED:
		return _create_parse_result(
				bvt_parse_result[0],
				{ coords: null }, summarized)
	var parse_result: Dictionary[StringName, Variant] = _create_parse_result(
			bvt_parse_result[0],
			{ coords: bvt_parse_result[1].duplicate() },
			summarized)
	#endregion

	#region Step 2: Building versus adjacent Building(s) check
	# Step 2: Building versus adjacent Building(s) check. Previous step must
	# pass.
	var surrounding_neighbor_coords: Array[Vector2i] =\
			Math.HexGrid.get_offset_surrounding_neighbors(
					coords,
					Math.HexGrid.OffsetLayout.ODD_R)
	for neighbor_coords: Vector2i in surrounding_neighbor_coords:
		if world.has_building_at(neighbor_coords):

			#region Main rules
			var neighbor_building_type: Building.BuildingType = \
					world.get_building_at(neighbor_coords)
			var bvb_parse_result: Array[Variant] = _bvb_rules[[
				building_type, neighbor_building_type
			]]
			if bvb_parse_result[0] != PlacementCheckStatus.ALLOWED:
				# WARN: Known limitation - this only keeps the last non-allowed
				# placement check status.
				parse_result.placement_check_status = bvb_parse_result[0]
				if summarized:
					parse_result.interaction_result = null
					return parse_result
				parse_result.interaction_result.set(neighbor_coords, null)
			elif summarized:
				parse_result.interaction_result.set_population_change(
						parse_result.interaction_result.get_population_change()
						+ bvb_parse_result[1].get_population_change())
				parse_result.interaction_result.set_building_bonus(
						parse_result.interaction_result.get_building_bonus()
						+ bvb_parse_result[1].get_building_bonus())
			else:
				parse_result.interaction_result.set(
						neighbor_coords,
						bvb_parse_result[1].duplicate())
			#endregion

			#region Special cases
			# Special case for Housing versus Solar Farm / Wind Farm: If the
			# Solar Farm / Wind Farm is on Desert or Desert Sand Dunes: +5 pops
			# instead.
			#
			# WARNING: This solution is not scalable. Find a different approach
			# if the scope grows.
			if (
					(
							building_type == Building.BuildingType.HOUSING
							and neighbor_building_type in [
								Building.BuildingType.SOLAR_FARM,
								Building.BuildingType.WIND_FARM,
							]
							and (world.get_terrain_at(neighbor_coords) in [
								World.TerrainType.DESERT,
								World.TerrainType.DESERT_SAND_DUNES,
							])
					) or (
							building_type in [
								Building.BuildingType.SOLAR_FARM,
								Building.BuildingType.WIND_FARM,
							]
							and (
									neighbor_building_type
									== Building.BuildingType.HOUSING
							) and (world.get_terrain_at(coords) in [
								World.TerrainType.DESERT,
								World.TerrainType.DESERT_SAND_DUNES,
							])
					)
			):
				var interaction_result: InteractionResult = (
					parse_result.interaction_result if summarized
					else parse_result.interaction_result[neighbor_coords]
				)
				interaction_result.set_population_change(
						interaction_result.get_population_change()
						+ 3) # Increase reward to +5 pops.
			#endregion
	#endregion

	#region Step 3: Forest enclosure check
	# Step 3: Forest enclosure check. Previous step must pass.
	var enclosed_forest_area: Array[Vector2i] = _get_enclosed_forest_area_at(coords)
	if not enclosed_forest_area.is_empty():
		for enclosed_forest_coords: Vector2i in enclosed_forest_area:
			if summarized:
				parse_result.interaction_result.set_population_change(
						parse_result.interaction_result.get_population_change()
						+ combo_rule_forest_population_gain)
				parse_result.interaction_result.set_building_bonus(
						parse_result.interaction_result.get_building_bonus()
						+ combo_rule_forest_building_bonus_gain)
			else:
				parse_result.interaction_result.set(
						enclosed_forest_coords,
						InteractionResult.new(
								combo_rule_forest_population_gain,
								combo_rule_forest_building_bonus_gain))
	#endregion

	return parse_result

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private methods

func _load_ruleset_bvt() -> Dictionary[Array, Array]:
	if not FileAccess.file_exists(Global.BVT_RULESET_PATH):
		push_error("File not found: '%s'." % Global.BVT_RULESET_PATH)
		return {}

	var ruleset: Dictionary[Array, Array] = {}
	var file: FileAccess = FileAccess.open(Global.BVT_RULESET_PATH, FileAccess.READ)
	var csv_header: Array = Array(file.get_csv_line(","))

	while file.get_position() < file.get_length():
		var csv_line: Array = Array(file.get_csv_line(","))
		if csv_line.size() != csv_header.size():
			continue # Skip malformed lines.

		var key: Array[int] = [
			int(csv_line[0]) as Building.BuildingType,
			int(csv_line[1]) as World.TerrainType]
		var value: Array[Variant] = [
			int(int(csv_line[2]) as PlacementCheckStatus),
			null
		]
		if value[0] == PlacementCheckStatus.ALLOWED:
			value[1] = InteractionResult.new(
					int(csv_line[3]),
					int(csv_line[4]))

		ruleset.set(key, value)

	file.close()
	return ruleset


func _load_ruleset_bvb() -> Dictionary[Array, Array]:
	if not FileAccess.file_exists(Global.BVB_RULESET_PATH):
		push_error("File not found: '%s'." % Global.BVB_RULESET_PATH)
		return {}

	var ruleset: Dictionary[Array, Array] = {}
	var file: FileAccess = FileAccess.open(Global.BVB_RULESET_PATH, FileAccess.READ)
	var csv_header: Array = Array(file.get_csv_line(","))

	while file.get_position() < file.get_length():
		var csv_line: Array = Array(file.get_csv_line(","))
		if csv_line.size() != csv_header.size():
			continue # Skip malformed lines.

		var key: Array[int] = [
			int(csv_line[0]) as Building.BuildingType,
			int(csv_line[1]) as Building.BuildingType]
		var value: Array[Variant] = [
			int(int(csv_line[2]) as PlacementCheckStatus),
			null
		]
		if value[0] == PlacementCheckStatus.ALLOWED:
			value[1] = InteractionResult.new(
					int(csv_line[3]),
					int(csv_line[4]))

		ruleset.set(key, value)

	file.close()
	return ruleset


func _is_clear_of_building(coords: Vector2i) -> bool:
	return not world.has_building_at(coords)


func _has_adjacent_building(coords: Vector2i) -> bool:
	var surrounding_neighbor_coords: Array[Vector2i] =\
			Math.HexGrid.get_offset_surrounding_neighbors(
					coords,
					Math.HexGrid.OffsetLayout.ODD_R)
	for neighbor_coords: Vector2i in surrounding_neighbor_coords:
		if world.has_building_at(neighbor_coords):
			return true
	return false


func _get_enclosed_forest_area_at(coords: Vector2i) -> Array[Vector2i]:
	const FOREST_TERRAIN_TYPES: Array[World.TerrainType] = [
		World.TerrainType.PLAIN_FOREST,
		World.TerrainType.GRASSLAND_FOREST,
	]
	const BLOCKER_TERRAIN_TYPES: Array[World.TerrainType] = [
		World.TerrainType.DEEP_WATER,
		World.TerrainType.SHALLOW_WATER,
		World.TerrainType.SHALLOW_WATER_FISHES,
		World.TerrainType.PLAIN_MOUNTAIN,
		World.TerrainType.GRASSLAND_MOUNTAIN,
		World.TerrainType.DESERT_MOUNTAIN,
		World.TerrainType.PLAIN_CHASM,
		World.TerrainType.GRASSLAND_CHASM,
		World.TerrainType.DESERT_CHASM,
	]

	var discovered_forest_coords: Array[Vector2i] = []

	# TODO: Implement this.

	return discovered_forest_coords


func _create_parse_result(
		placement_check_status: PlacementCheckStatus,
		interaction_results: Dictionary[Vector2i, InteractionResult],
		summarized: bool
) -> Dictionary[StringName, Variant]:
	var parse_result: Dictionary[StringName, Variant] = {}
	parse_result.set(&"placement_check_status", placement_check_status)

	if summarized:
		if interaction_results.values().has(null):
			parse_result.set(&"interaction_result", null)
		else:
			var summarized_interaction_result: InteractionResult =\
					InteractionResult.new(0, 0)
			for unit_interaction_result: InteractionResult in interaction_results.values():
				summarized_interaction_result.set_population_change(
						summarized_interaction_result.get_population_change()
						+ unit_interaction_result.get_population_change())
				summarized_interaction_result.set_building_bonus(
						summarized_interaction_result.get_building_bonus()
						+ unit_interaction_result.get_building_bonus())
			parse_result.set(&"interaction_result", summarized_interaction_result)
	else:
		parse_result.set(&"interaction_result", interaction_results)

	return parse_result

#endregion
# ============================================================================ #


# ============================================================================ #
#region Inner classes

## Represents the result of the interaction between a building and its
## surrounding [World] environment when it is placed.
class InteractionResult extends RefCounted:

	var _population_change: int = 0
	var _building_bonus: int = 0


	## Returns a summarized [BuildingRulesetEngine.InteractionResult] from a
	## list of component [param interaction_results].
	static func sum(interaction_results: Array[InteractionResult]) -> InteractionResult:
		var summarized_interaction_result: InteractionResult =\
				InteractionResult.new(0, 0)
		for interaction_result: InteractionResult in interaction_results:
			summarized_interaction_result.set_population_change(
					summarized_interaction_result.get_population_change()
					+ interaction_result.get_population_change())
			summarized_interaction_result.set_building_bonus(
					summarized_interaction_result.get_building_bonus()
					+ interaction_result.get_building_bonus())
		return summarized_interaction_result


	## Instantiates and initializes a [BuildingRulesetEngine.InteractionResult]
	## with [param population_change] and [param building_bonus].[br]
	## [br]
	## If [param building_bonus] is negative, the building bonus is set to
	## [code]0[/code].
	func _init(population_change, building_bonus) -> void:
		set_population_change(population_change)
		set_building_bonus(building_bonus)


	## Creates a copy of the [BuildingRulesetEngine.InteractionResult], then
	## returns it. Use this method to pass
	## [BuildingRulesetEngine.InteractionResult] instances by value instead of
	## by reference.
	func duplicate() -> InteractionResult:
		return InteractionResult.new(_population_change, _building_bonus)


	## Returns the population change after the interaction.
	func get_population_change() -> int:
		return _population_change


	## Sets the population change after the interaction.
	func set_population_change(population_change: int) -> void:
		_population_change = population_change


	## Returns the building bonus received after the interaction.
	func get_building_bonus() -> int:
		return _building_bonus


	## Sets the building bonus received after the interaction if
	## [param building_bonus] is greater or equal to [code]0[/code]. Otherwise
	## sets it to [code]0[/code].
	func set_building_bonus(building_bonus: int) -> void:
		_building_bonus = 0 if building_bonus < 0 else building_bonus

#endregion
# ============================================================================ #

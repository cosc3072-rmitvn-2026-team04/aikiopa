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
## [code]null[/code], i.e. [code]{ coords: null }[/code].
func parse_rules(
		coords: Vector2i,
		building_type: Building.BuildingType,
		summarized: bool = true
) -> Dictionary[StringName, Variant]:
	if not _has_adjacent_building(coords):
		return {
			&"placement_check_status": PlacementCheckStatus.BLOCKED_BY_DISCONNECTION,
			&"interaction_result": null,
		}

	if not _is_clear_of_building(coords):
		return {
			&"placement_check_status": PlacementCheckStatus.BLOCKED_BY_BUILDING,
			&"interaction_result": null,
		}

	var parse_result: Dictionary[StringName, Variant] = {}

	# Step 1: Building versus Terrain check. Must pass before next step.
	var bvt_parse_result: Array[Variant] = _bvt_rules[[
		building_type, world.get_terrain_at(coords)
	]]
	if bvt_parse_result[0] != PlacementCheckStatus.ALLOWED:
		return {
			&"placement_check_status": bvt_parse_result[0],
			&"interaction_result": null,
		}
	parse_result = {
		&"placement_check_status": bvt_parse_result[0],
		&"interaction_result": bvt_parse_result[1].duplicate(),
	}

	# Step 2: Building versus adjacent Building check. Previous step must pass.
	var surrounding_neighbor_coords: Array[Vector2i] =\
			Math.HexGrid.get_offset_surrounding_neighbors(
					coords,
					Math.HexGrid.OffsetLayout.ODD_R)
	for neighbor_coords: Vector2i in surrounding_neighbor_coords:
		if world.has_building_at(neighbor_coords):
			var neighbor_building_type: Building.BuildingType = \
					world.get_building_at(neighbor_coords)
			var bvb_parse_result: Array[Variant] = _bvb_rules[[
				building_type, neighbor_building_type
			]]
			if bvb_parse_result[0] != PlacementCheckStatus.ALLOWED:
				return {
					&"placement_check_status": bvb_parse_result[0],
					&"interaction_result": null,
				}

			parse_result.interaction_result.set_population_change(
					parse_result.interaction_result.get_population_change()
					+ bvb_parse_result[1].get_population_change())
			parse_result.interaction_result.set_building_bonus(
					parse_result.interaction_result.get_building_bonus()
					+ bvb_parse_result[1].get_building_bonus())

			# Special case for Housing versus Solar Farm or Wind Farm: If Solar
			# Farm or Wind Farm on Desert or Desert Sand Dunes: +5 pops instead.
			# INFO: Make this more scalable if needed.
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
				parse_result.interaction_result.set_population_change(
						parse_result.interaction_result.get_population_change()
						+ 3) # Increase reward to +5 pops.

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

#endregion
# ============================================================================ #


# ============================================================================ #
#region Inner classes

## Represents the result of the interaction between a building and its
## surrounding [World] environment when it is placed.
class InteractionResult extends RefCounted:

	var _population_change: int = 0
	var _building_bonus: int = 0


	## Instantiates and initializes an [InteractionResult] with
	## [param population_change] and [param building_bonus].[br]
	## [br]
	## If [param building_bonus] is negative, the building bonus is set to
	## [code]0[/code].
	func _init(population_change, building_bonus) -> void:
		set_population_change(population_change)
		set_building_bonus(building_bonus)


	## Creates a copy of the [InteractionResult], then returns it. Use this
	## method to pass [InteractionResult] insteances by value instead of by
	## reference.
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

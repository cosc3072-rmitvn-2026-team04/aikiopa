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

## Returns a dictionary consisting of [enum PlacementCheckStatus] and
## [InteractionResult] for the [param coords] if a building of
## [param building_type] is placed on its tile.[br]
## [br]
## The returned [InteractionResult] will be [code]null[/code] if the returned
## [enum PlacementCheckStatus] is any value other than
## [constant BuildingRulesetEngine.PlacementCheckStatus.ALLOWED].
func parse_rules(
		coords: Vector2i,
		building_type: Building.BuildingType
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
		&"interaction_result": bvt_parse_result[1],
	}

	# TODO: Implement this so that it checks all neighbors.
	# Step 2: Building versus adjacent Building check. Previous step must pass.
	#var bvb_parse_result: Array[Variant] = _bvb_rules[[
	#	building_type, building_type # TODO: This should be that of neighbors!
	#]]
	#if bvb_parse_result[0] != PlacementCheckStatus.ALLOWED:
	#	return {
	#		&"placement_check_status": bvb_parse_result[0],
	#		&"interaction_result": null,
	#	}
	#parse_result = {
	#	&"placement_check_status": bvb_parse_result[0],
	#	&"interaction_result": bvb_parse_result[1] + bvt_parse_result[1],
	#}

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
	for neighbor_coords in surrounding_neighbor_coords:
		if world.has_building_at(neighbor_coords):
			return true
	return false

#endregion
# ============================================================================ #


# ============================================================================ #
#region Inner classes

class InteractionResult extends RefCounted:
	## Represents the result of the interaction between a building and its
	## surrounding [World] environment when it is placed.

	var _population_change: int = 0
	var _building_bonus: int = 0


	## Instantiates and initializes an [InteractionResult] with
	## [param population_change] and [param building_bonus].[br]
	## [br]
	## If [param building_bonus] is negative, the building bonus would be set to
	## [code]0[/code].
	func _init(population_change, building_bonus) -> void:
		set_population_change(population_change)
		set_building_bonus(building_bonus)


	## Returns the population change after the interaction.
	func get_population_change() -> int:
		return _population_change


	## Sets the population change after the interaction.
	func set_population_change(population_change: int) -> void:
		_population_change = population_change


	## Returns the building bonus received after the interaction.
	func get_building_bonus() -> int:
		return _building_bonus


	## Sets the building bonus received after the interaction. If
	## [param building_bonus] is negative, the building bonus would be set to
	## [code]0[/code].
	func set_building_bonus(building_bonus: int) -> void:
		_building_bonus = 0 if building_bonus < 0 else building_bonus

#endregion
# ============================================================================ #

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

	## Placement blocked: Not adjacent to existing building(s).
	BLOCKED_BY_DISCONNECTION = -1,

	## Placement blocked: On invalid terrain.
	BLOCKED_BY_TERRAIN = -2,

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
## [color=red][b]Internal game mechanics. Do not modify during runtime.[/b][/color]
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
## [color=red][b]Internal game mechanics. Do not modify during runtime.[/b][/color]
var _bvb_rules: Dictionary[Array, Array] = {}

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

	# TODO: Implement this.
	return {
		&"placement_check_status": PlacementCheckStatus.ALLOWED,
		&"interaction_result": InteractionResult.new(0, 0),
	}
	#var parse_result: Dictionary[StringName, Variant] = {}

	#var bvt_parse_result: Array[Variant] = _bvt_rules[[
	#	world.get_terrain_at(coords), building_type
	#]]
	#if bvt_parse_result[0] != PlacementCheckStatus.ALLOWED:
	#	return {
	#		&"placement_check_status": bvt_parse_result[0],
	#		&"interaction_result": bvt_parse_result[1],
	#	}
	#parse_result = {
	#	&"placement_check_status": bvt_parse_result[0],
	#	&"interaction_result": bvt_parse_result[1],
	#}

	#var bvb_parse_result: Array[Variant] = _bvb_rules[[
	#	world.get_terrain_at(coords), building_type
	#]]
	#if bvb_parse_result[0] != PlacementCheckStatus.ALLOWED:
	#	return {
	#		&"placement_check_status": bvb_parse_result[0],
	#		&"interaction_result": bvb_parse_result[1],
	#	}
	#parse_result = {
	#	&"placement_check_status": bvb_parse_result[0],
	#	&"interaction_result": bvb_parse_result[1],
	#}

	#return parse_result

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private methods

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

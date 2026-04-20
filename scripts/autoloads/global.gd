extends Node
## Global game scope data and functions.


# ============================================================================ #
#region Enums
#endregion
# ============================================================================ #


# ============================================================================ #
#region Constants

## Assets location for [Building]s.
const BUILDING_ASSET_DIR: String = "res://assets/objects/"

## Assets location for [BuildingCard]s.
const BUILDING_CARD_ASSET_DIR: String =\
		"res://assets/user_interface/building_stack/building_card/"

## Ruleset - Building versus Terrain location.
const BVT_RULESET_PATH: String = "res://resources/rulesets/bvt.csv"

## Ruleset - Building versus adjacent Building location.
const BVB_RULESET_PATH: String = "res://resources/rulesets/bvb.csv"

## Savegame location.
const SAVE_DIR: String = "user://saves/"

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public variables

## The platform that the game is running on. Can be either
## [code]"Windows Desktop"[/code], [code]"Linux Desktop"[/code], or
## [code]"Android Mobile"[/code].
var os_platform: StringName
var game_state: GameState

## If [code]true[/code], debugging tools would be activated while the game is
## running.
var gameplay_debug_mode_enabled: bool = false

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	var os_name: String = OS.get_name()
	match os_name:
		"Windows":
			os_platform = "Windows Desktop"
		_:
			printerr("Platform not supported: %s", os_name)
			get_tree().quit()

	game_state = GameState.new()


func _exit_tree() -> void:
	game_state.queue_free()

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods
#endregion
# ============================================================================ #


# ============================================================================ #
#region Inner classes

## Game state data. Contains relevant information on the current state of the
## game.
class GameState extends Node:

	## The population in the current game session.
	var population: int = 0

	## The amount of population milestones already reached in the current game
	## session.
	var population_milestones_reached: int = 0

	## The building stack in the current game session.
	var building_stack: Array[Building.BuildingType] = []

	## The [Building] instances in the game. Identified by their [Vector2i]
	## coordinates.
	var buildings: Dictionary[Vector2i, Building] = {}

	## The list of building coordinates at the colony's edge.
	var edge_coords: Array[Vector2i] = []

	## The list of Forest coordinates already enclosed by the colony.
	var enclosed_forest_coords: Array[Vector2i] = []


	## Resets the game state.
	func reset() -> void:
		population = 0
		population_milestones_reached = 0
		building_stack = []
		buildings = {}
		edge_coords = []
		enclosed_forest_coords = []

#endregion
# ============================================================================ #

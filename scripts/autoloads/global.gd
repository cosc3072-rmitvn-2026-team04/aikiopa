extends Node
## Global game scope data and functions.


# ============================================================================ #
#region Enums
#endregion
# ============================================================================ #


# ============================================================================ #
#region Constants

## Ruleset - Building versus Terrain location.
const BVT_RULESET_PATH = "res://resources/rulesets/bvt.csv"

## Ruleset - Building versus adjacent Building location.
const BVB_RULESET_PATH = "res://resources/rulesets/bvb.csv"

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

	## The building stack in the current game session.
	var building_stack: Array[Building.BuildingType] = []

	## The [Building] instances in the game. Identified by their [Vector2i]
	## coordinates.
	var buildings: Dictionary[Vector2i, Building] = {}

	## The list consisting of coordinates of the colony's edge buildings.
	var edge_coords: Array[Vector2i] = []


	## Resets the game state.
	func reset() -> void:
		population = 0
		building_stack = []
		buildings = {}
		edge_coords = []


#endregion
# ============================================================================ #

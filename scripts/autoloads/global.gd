extends Node
## Global scope. Also handles low-level bootstrap and teardown procedures.


# ============================================================================ #
#region Public variables

## The platform that the game is running on. Can be either
## [code]"Windows Desktop"[/code], [code]"Linux Desktop"[/code], or
## [code]"Android Mobile"[/code].
var os_platform: StringName

## The index of the save file in [constant GameSaveService.SAVE_FILES] currently
## assigned to the active game session. All game progress will be saved into and
## restored from this file.
var current_save_slot_index: int

## Set to [code]true[/code] if the current active game session state should be
## randomized for a new run. Otherwise its state would be loaded from the save
## file at [member Global.current_save_slot_index].
var is_new_game: bool = true

## The current state of the game session. [code]null[/code] if no active
## session.
var game_state: GameState

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
	_bootstrap()


func _exit_tree() -> void:
	_teardown()

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private methods

func _bootstrap() -> void:
	GameSaveService.verify_save_directory()
	game_state = GameState.new()


func _teardown() -> void:
	pass # Add teardown logic here.

#endregion
# ============================================================================ #


# ============================================================================ #
#region Inner classes

## Game state data. Contains relevant information on the current state of the
## game.
class GameState extends RefCounted:
	## The [World] map seed of the current game session.[br]
	## [br]
	## [b]Note:[/b] The [code]0[/code] value documented here is a placeholder,
	## and not the actual default seed.[br]
	## [br]
	## [color=orange][b]WARNING:[/b] This affects the internal logic of
	## [WorldGenerator]. DO NOT modify directly. Assign values using
	## [method WorldGenerator.get_seed] instead.[/color]
	var world_seed: int = 0

	## The RNG seed of the [BuildingStackController].[br]
	## [br]
	## [b]Note:[/b] The [code]0[/code] value documented here is a placeholder,
	## and not the actual default seed.[br]
	## [br]
	## [color=orange][b]WARNING:[/b] This affects the internal logic of
	## [BuildingStackController]. DO NOT modify directly. Assign values using
	## [method BuildingStackController.get_session_seed] instead.[/color]
	var building_stack_seed: int = 0

	## The RNG state of the [BuildingStackController].[br]
	## [br]
	## [b]Note:[/b] The [code]0[/code] value documented here is a placeholder,
	## and not the actual default state.[br]
	## [br]
	## [color=orange][b]WARNING:[/b] This affects the internal logic of
	## [BuildingStackController]. DO NOT modify directly. Assign values using
	## [method BuildingStackController.get_session_state] instead.[/color]
	var building_stack_state: int = 0

	## The building stack in the current game session.
	var building_stack: Array[Building.BuildingType] = []

	## The building instances in the current game session, represented as a
	## dictionary of key [Vector2i] coordinates and its corresponding [Building]
	## instance.[br]
	## [br]
	## [color=red][b]WARNING:[/b] This must be kept in sync with
	## [member building_metadata]. Failure to do so will result in undefined
	## behavior.[/color]
	var building_instances: Dictionary[Vector2i, Building] = {}

	## The building metadata in the current game session, represented as a
	## dictionary of key [Vector2i] coordinates and its corresponding
	## [enum Building.BuildingType] value.[br]
	## [br]
	## To access the building instances in the game, use
	## [member building_instances] instead.[br]
	## [br]
	## [color=red][b]WARNING:[/b] This must be kept in sync with
	## [member building_instances]. Failure to do so will result in undefined
	## behavior.[/color]
	var building_metadata: Dictionary[Vector2i, Building.BuildingType]

	## The list of building coordinates at the colony's edge.
	var edge_coords: Array[Vector2i] = []

	## The list of Forest coordinates already enclosed by the colony.
	var enclosed_forest_coords: Array[Vector2i] = []

	## The data representing The Shroud. See
	## [method ShroudTileMapLayer.get_shroud_data] for its schema.[br]
	## [br]
	## [color=orange][b]WARNING:[/b] This affects the internal logic of
	## [ShroudTileMapLayer]. Take precaution when modifying directly. Prefer the
	## safer [method ShroudTileMapLayer.set_shroud_data] instead.[/color]
	var shroud_data: Dictionary[StringName, Array] = {}

	## The population in the current game session.
	var population: int = 0

	## The amount of population milestones already reached in the current game
	## session.
	var population_milestones_reached: int = 0


	## Resets the game state.
	func reset() -> void:
		world_seed = 0
		building_stack_seed = 0
		building_stack_state = 0
		building_stack = []
		building_instances = {}
		edge_coords = []
		enclosed_forest_coords = []
		shroud_data = {}
		population = 0
		population_milestones_reached = 0

#endregion
# ============================================================================ #

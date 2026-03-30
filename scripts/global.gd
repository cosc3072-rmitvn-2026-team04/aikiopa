extends Node
## Global game scope data and functions.


# ============================================================================ #
#region Enums
#endregion
# ============================================================================ #


# ============================================================================ #
#region Constants

## Savegame location.
const SAVE_DIR: String = "user://saves"

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

## Converts the linear mapping row-major [param index] to its corresponding 2D
## space coordinates.[br]
## [br]
## [param size_2d] is the dimensions (rows x columns) of the target 2D space.
func linear_index_to_coords_2d(index: int, size_2d: Vector2i) -> Vector2i:
	assert(index < size_2d.x * size_2d.y, "Index out of range.")
	@warning_ignore("integer_division")
	return Vector2i(index % size_2d.x, int(index / size_2d.x))


## Converts the 2D space [param coords] to its corresponding linear mapping
## row-major index.[br]
## [br]
## [param size_2d] is the dimensions (rows x columns) of the source 2D space.
func coords_2d_to_linear_index(coords: Vector2i, size_2d: Vector2i) -> int:
	assert(
			coords.x < size_2d.x and coords.y < size_2d.y,
			"Coordinates out of range.")
	return coords.y * size_2d.x + coords.x

#endregion
# ============================================================================ #


# ============================================================================ #
#region Inner classes

## Game state data. Contains relevant information on the current state of the
## game.
class GameState extends Node:
	pass

#endregion
# ============================================================================ #

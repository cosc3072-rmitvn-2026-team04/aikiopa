class_name NamespaceGlobal
extends Node2D


# ============================================================================ #
#region Enums
#endregion
# ============================================================================ #


# ============================================================================ #
#region Constants
#endregion
# ============================================================================ #


# ============================================================================ #
#region Public variables

## The platform that the game is running on. Can be either
## [code]"Windows Desktop"[/code], [code]"Linux Desktop"[/code], or
## [code]"Android Mobile"[/code].
var os_platform: StringName
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
## game, for use with a [StateMachine] and its [State]s.
class GameState extends Node:
	pass

#endregion
# ============================================================================ #

extends Node2D
## Responsible for the main gameplay loop


enum GameModes {
	TUTORIAL,
	FREE_PLAY,
}

@export var game_mode: GameModes = GameModes.FREE_PLAY


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	pass

#endregion
# ============================================================================ #

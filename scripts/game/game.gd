extends Node2D
## Responsible for the main gameplay loop.


enum GameModes {
	TUTORIAL,
	FREE_PLAY,
}

@export var game_mode: GameModes = GameModes.FREE_PLAY


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	%MainCamera2D.make_current()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug_mode"):
		if %MainCamera2D.is_current():
			%DebugCamera2D.make_current()
			%MainCamera2D/ReferenceRect.editor_only = false
		elif %DebugCamera2D.is_current():
			%MainCamera2D.make_current()
			%MainCamera2D/ReferenceRect.editor_only = true

#endregion
# ============================================================================ #

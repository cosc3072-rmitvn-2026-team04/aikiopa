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
	%World.generate_seeds()
	%World.create_chunk(Vector2i.ZERO) # Create first chunk.

	%MainCamera2D.make_current()
	%MainCamera2D.position = %World.get_chunk_center_position()
	%MainCamera2D.reset_smoothing()

	%DebugCamera2D.position = %World.get_chunk_center_position()
	%DebugCamera2D.reset_smoothing()


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

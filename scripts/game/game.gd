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

	# Generate first chunk at the center and its surrounding chunks.
	%World.create_chunk(Vector2i.ZERO)
	%World.create_chunk(Vector2i.LEFT)
	%World.create_chunk(Vector2i.RIGHT)
	%World.create_chunk(Vector2i.UP)
	%World.create_chunk(Vector2i.DOWN)
	%World.create_chunk(Vector2i.UP + Vector2i.LEFT)
	%World.create_chunk(Vector2i.UP + Vector2i.RIGHT)
	%World.create_chunk(Vector2i.DOWN + Vector2i.LEFT)
	%World.create_chunk(Vector2i.DOWN + Vector2i.RIGHT)

	# Main camera setup.
	%MainCamera2D.make_current()
	%MainCamera2D.position = %World.get_chunk_center_position()
	%MainCamera2D.reset_smoothing()

	# Debug camera setup.
	%DebugCamera2D.position = %World.get_chunk_center_position()
	%DebugCamera2D.reset_smoothing()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_gameplay_debug_mode"):
		Global.gameplay_debug_mode_enabled = not Global.gameplay_debug_mode_enabled
		GameplayEventBus.gameplay_debug_mode_toggled.emit(
				Global.gameplay_debug_mode_enabled)

#endregion
# ============================================================================ #

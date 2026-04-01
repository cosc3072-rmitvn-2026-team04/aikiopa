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
	# World setup.
	%World.generate_seeds()
	%World.create_chunk(Vector2i.ZERO)

	# Main camera setup.
	%MainCamera2D.make_current()
	%MainCamera2D.position = %World.get_chunk_center_position()
	%MainCamera2D.reset_smoothing()

	# Debug camera setup.
	%DebugCamera2D.position = %World.get_chunk_center_position()
	%DebugCamera2D.reset_smoothing()


func _process(_delta: float) -> void:
	var camera_chunk_position: Vector2i = %MainCamera2D.get_chunk_position()
	for neighbor_chunk in %World.get_neigboring_chunks(camera_chunk_position):
		if not %World.is_chunk_generated(neighbor_chunk):
			%World.create_chunk(neighbor_chunk)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_gameplay_debug_mode"):
		Global.gameplay_debug_mode_enabled = not Global.gameplay_debug_mode_enabled
		GameplayEventBus.gameplay_debug_mode_toggled.emit(Global.gameplay_debug_mode_enabled)

#endregion
# ============================================================================ #

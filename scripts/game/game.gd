extends Node2D
## Responsible for the main gameplay loop.


enum GameModes {
	TUTORIAL,
	FREE_PLAY,
}

# ============================================================================ #
#region Variables

@export var game_mode: GameModes = GameModes.FREE_PLAY

@onready var _building_stack_controller: Node = %BuildingStackController

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	# TODO: Add world restore functionality by providing world_seed when needed.
	# Implement in #11.
	_init_world()

	# TODO: Add population restore functionality when restoring a session.
	# Implement in #11.
	_init_population()

	# TODO: Add building stack restore functionality by providing session_seed
	# and session_state when needed. Implement in #11.
	_init_building_stack([])

	_init_cameras()

	UIEventBus.building_placement_requested.connect(
			_on_building_placement_requested)


func _process(_delta: float) -> void:
	_process_auto_world_gen()


func _input(event: InputEvent) -> void:
	_input_update_gameplay_debug_mode(event)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private methods

#region _ready()

func _init_world(world_seed: Variant = null) -> void:
	%World.initialize(world_seed)
	%World.create_chunk(Vector2i.ZERO)


func _init_population() -> void:
	%PopulationController.set_population(0)


func _init_building_stack(
		building_queue: Array[Building.BuildingType],
		session_seed: Variant = null,
		session_state: Variant = null
) -> void:
	_building_stack_controller.initialize_session(
			building_queue,
			session_seed,
			session_state)


func _init_cameras() -> void:
	# Main camera setup.
	%PlayerCamera2D.make_current()
	%PlayerCamera2D.position = %World.get_chunk_center_position()
	%PlayerCamera2D.reset_smoothing()

	# Debug camera setup.
	%DebugCamera2D.position = %World.get_chunk_center_position()
	%DebugCamera2D.reset_smoothing()

#endregion


#region _process()

func _process_auto_world_gen() -> void:
	var camera_chunk_position: Vector2i = %PlayerCamera2D.get_chunk_position()
	for neighbor_chunk in %World.get_neigboring_chunks(camera_chunk_position):
		if not %World.is_chunk_generated(neighbor_chunk):
			%World.create_chunk(neighbor_chunk)

#endregion


#region _input()

func _input_update_gameplay_debug_mode(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_gameplay_debug_mode"):
		Global.gameplay_debug_mode_enabled = not Global.gameplay_debug_mode_enabled
		GameplayEventBus.gameplay_debug_mode_toggled.emit(Global.gameplay_debug_mode_enabled)

#endregion

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to
# UIEventBus.building_placement_requested(
#		mouse_position: Vector2,
#		building: Building.BuildingType).
func _on_building_placement_requested(
		mouse_position: Vector2,
		building: Building.BuildingType) -> void:
	var map_coords: Vector2i = %World.get_terrain_tile_map_layer().local_to_map(
			mouse_position)

	print("Trying to place building %s at (%d, %d) - screen pos: (%d, %d)" % [
		Building.BuildingType.keys()[building],
		map_coords.x, map_coords.y,
		mouse_position.x, mouse_position.y,
	])

#endregion
# ============================================================================ #

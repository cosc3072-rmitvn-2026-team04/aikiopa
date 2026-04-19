extends Node2D
## Responsible for the main gameplay loop.


# ============================================================================ #
#region Enums

enum GameModes {
	TUTORIAL,
	FREE_PLAY,
}

#endregion
# ============================================================================ #


# ============================================================================ #
#region Exported properties

@export var container_scene: GameScene2D = null

#endregion
# ============================================================================ #


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
	Global.game_state.reset()

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
	_init_game_menu()
	_init_game_over_menu()


func _process(_delta: float) -> void:
	_process_auto_world_generation()
	_render_shroud()
	if is_game_over(
			Global.game_state.building_stack.size(),
			Global.game_state.population,
			Global.game_state.buildings.size()):
		%GameOverMenu.open()
		%GameOverMenu.set_population(Global.game_state.population)
		GameplayEventBus.game_over.emit(Global.game_state.population)


func _input(event: InputEvent) -> void:
	_input_command_game_menu(event)
	_input_update_gameplay_debug_mode(event)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Returns [code][/code] if game over conditions has been satisfied.
func is_game_over(
		building_stack_count: int,
		population: int,
		buildings_placed: int
) -> bool:
	if buildings_placed > 1:
		if building_stack_count == 0:
			return true
		if population == 0:
			return true
	return false

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private methods

#region _ready()

func _init_world(world_seed: Variant = null) -> void:
	%World.initialize(world_seed)
	%World.create_chunk(Vector2i.ZERO)

	var world_center_coords: Vector2i = %World.get_chunk_size() / 2
	%World.remove_terrain_feature_at(world_center_coords)
	%World.place_building_at(
			world_center_coords,
			Building.BuildingType.LANDING_SITE) # Quiet placement.

	%World.reset_shroud()


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
	%PlayerCamera.make_current()
	%PlayerCamera.position = %World.get_chunk_center_position()
	%PlayerCamera.reset_smoothing()

	# Debug camera setup.
	%DebugCamera2D.position = %World.get_chunk_center_position()
	%DebugCamera2D.reset_smoothing()


func _init_game_menu() -> void:
	%GameMenu.acted.connect(_on_game_menu_acted)
	%GameMenu.close()


func _init_game_over_menu() -> void:
	%GameOverMenu.acted.connect(_on_game_over_menu_acted)
	%GameOverMenu.close()

#endregion


#region _process()

func _process_auto_world_generation() -> void:
	var camera_chunk_position: Vector2i = %PlayerCamera.get_chunk_position()
	for neighbor_chunk: Vector2i in %World.get_neigboring_chunks(camera_chunk_position):
		if not %World.is_chunk_generated(neighbor_chunk):
			%World.create_chunk(neighbor_chunk)


func _render_shroud() -> void:
	%World.render_shroud(%PlayerCamera.position)

#endregion


#region _input()

func _input_command_game_menu(event: InputEvent) -> void:
	if event.is_action_pressed("ui_quit"):
		%GameMenu.open()
		get_tree().paused = true


func _input_update_gameplay_debug_mode(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_gameplay_debug_mode"):
		Global.gameplay_debug_mode_enabled = not Global.gameplay_debug_mode_enabled
		UIEventBus.gameplay_debug_mode_toggled.emit(Global.gameplay_debug_mode_enabled)

#endregion

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to %GameMenu.acted(action: StringName).
func _on_game_menu_acted(action: StringName) -> void:
	match action:
		&"resume":
			%GameMenu.close()
		&"save_session":
			%GameMenu.close()
			push_error("Not implemented.")
		&"quit_to_main_menu":
			%GameMenu.close()
			container_scene.scene_finished.emit(GameScene2D.SceneKey.MAIN_MENU)


# Listes to %GameOverMenu.acted(action: StringName).
func _on_game_over_menu_acted(action: StringName) -> void:
	match action:
		&"save_snapshot":
			%GameMenu.close()
			push_error("Not implemented.")
		&"new_session":
			%GameMenu.close()
			container_scene.scene_finished.emit(GameScene2D.SceneKey.FREE_PLAY)
		&"quit_to_main_menu":
			%GameMenu.close()
			container_scene.scene_finished.emit(GameScene2D.SceneKey.MAIN_MENU)

#endregion
# ============================================================================ #

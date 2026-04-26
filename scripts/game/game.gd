class_name Game
extends Node2D
## Responsible for the main gameplay loop.


# ============================================================================ #
#region Enums

enum GameMode {
	PLAY,
	GALLERY, # TODO: Implement this mode in #149.
}

enum GameOverType {
	NONE,
	NO_BUILDING_CARD,
	NO_POPULATION,
}

#endregion
# ============================================================================ #


# ============================================================================ #
#region Exported properties

@export var game_mode: GameMode = GameMode.PLAY
@export var autosave: bool = true # TODO: Move this into Settings (#14).
@export var autosave_interval: int = 15 # TODO: Move this into Settings (#14).
@export var container_scene: GameScene2D = null

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private variables

var _save_slot_index: int = -1
var _turns_elapsed: int = 0
var _game_over: bool = false
var _save_dirty: bool = false
var _debug_mode_enabled: bool
@onready var _building_stack_controller: Node = %BuildingStackController

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	_save_slot_index = Global.current_save_slot_index
	_debug_mode_enabled = false

	_init_autosave()
	if Global.is_new_game:
		Global.game_state = Global.GameState.new()
		_init_world()
		_init_population(0)
		_init_building_stack()
		GameplayEventBus.session_created.emit(_save_slot_index)
		_save_session()
		_save_dirty = false
	else:
		Global.game_state = GameSaveService.load(_save_slot_index)
		_load_world()
		_init_population(Global.game_state.population)
		_init_building_stack(
				Global.game_state.building_stack_seed,
				Global.game_state.building_stack_state)
		GameplayEventBus.session_restored.emit(_save_slot_index)

	_init_cameras()
	_init_game_menu()
	_init_game_over_menu()


func _process(_delta: float) -> void:
	_process_auto_world_generation()
	_render_shroud()

	var building_stack_count: int = Global.game_state.building_stack.size()
	var population: int = Global.game_state.population
	if is_game_over(
			building_stack_count,
			population,
			Global.game_state.building_instances.size()):
		if not _game_over:
			_game_over = true
			_save_dirty = false
			%GameOverMenu.open()
			var game_over_type: GameOverType = (
					GameOverType.NO_BUILDING_CARD if building_stack_count == 0
					else GameOverType.NO_POPULATION if population == 0
					else GameOverType.NONE
			)
			GameplayEventBus.game_over.emit(population, game_over_type)
			GameSaveService.delete(_save_slot_index)


func _input(event: InputEvent) -> void:
	_input_command_game_menu(event)
	_input_update_gameplay_debug_mode(event)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Returns [code]true[/code] if the current game state has changed from the last
## game save.
func is_save_dirty() -> bool:
	return _save_dirty


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

func _save_session() -> void:
	GameSaveService.save(Global.game_state, _save_slot_index)
	GameplayEventBus.session_saved.emit(_save_slot_index)


func _init_autosave() -> void:
	GameplayEventBus.building_placed.connect(_on_building_placed)


func _init_world(world_seed: Variant = null) -> void:
	%World.initialize(world_seed)
	%World.create_chunk(Vector2i.ZERO)

	var world_center_coords: Vector2i = %World.get_chunk_size() / 2
	%World.place_building_at(
			world_center_coords,
			Building.BuildingType.LANDING_SITE,
			0.0)

	%World.reset_shroud()
	Global.game_state.shroud_data = %World.get_shroud_data()


func _load_world() -> void:
	%World.initialize(Global.game_state.world_seed)
	%World.create_chunk(Vector2i.ZERO)

	var building_coords: Array[Vector2i] = Global.game_state.building_metadata.keys()
	for index: int in range(building_coords.size()):
		var map_coords: Vector2i = building_coords[index]
		%World.place_building_at(
				map_coords,
				Global.game_state.building_metadata.get(map_coords).building_type,
				Global.game_state.building_metadata.get(map_coords).variation_value)

	%World.reset_shroud()
	%World.set_shroud_data(Global.game_state.shroud_data)


func _init_population(population: int) -> void:
	%PopulationController.set_population(population)


func _init_building_stack(
		session_seed: Variant = null,
		session_state: Variant = null
) -> void:
	_building_stack_controller.initialize_session(
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
		_debug_mode_enabled = not _debug_mode_enabled
		UIEventBus.gameplay_debug_mode_toggled.emit(_debug_mode_enabled)

#endregion

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to GameplayEventBus.building_placed(
#		coords: Vector2i,
#		building_type: Building.BuildingType,
#		variation_value: float,
#		interaction_result: BuildingRulesetEngine.InteractionResult).
func _on_building_placed(
		_coords: Vector2i,
		_building_type: Building.BuildingType,
		_variation_value: float,
		_interaction_result: BuildingRulesetEngine.InteractionResult
) -> void:
	_turns_elapsed += 1
	_save_dirty = true
	if (
			autosave and _turns_elapsed % autosave_interval == 0
			and is_save_dirty() and not _game_over
	):
		_save_session()
		_save_dirty = false


# Listens to %GameMenu.acted(action: StringName).
func _on_game_menu_acted(action: StringName) -> void:
	match action:
		&"resume":
			%GameMenu.close()
		&"save_session":
			%GameMenu.close()
			_save_session()
			_save_dirty = false
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
			Global.is_new_game = true
			container_scene.scene_finished.emit(GameScene2D.SceneKey.PLAY)
		&"quit_to_main_menu":
			%GameMenu.close()
			container_scene.scene_finished.emit(GameScene2D.SceneKey.MAIN_MENU)

#endregion
# ============================================================================ #

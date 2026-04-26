class_name GameLogManager
extends Node
## Handles session logging. Only available for sessions in [constant Game.PLAY]
## mode.


# ============================================================================ #
#region Constants

# Log location.
const LOG_DIR: String = "user://session_logs/"

#endregion
# ============================================================================ #


# ============================================================================ #
#region Exported properties

## If [code]true[/code], the game session will be logged.
@export var enabled: bool = true

## The maximum amount of log files kept in [constant LOG_DIR]. Old logs are
## deleted to make room for new ones.
@export_range(1, 100, 1, "or_greater") var max_log_files: int = 100

@export var world: World = null

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private variables

var _time_string: String
var _save_slot_index: int
var _is_new_game: bool
var _seeds: Dictionary[StringName, int]
var _entry_count: int

var _file: FileAccess

#endregion
# ============================================================================ #



# ============================================================================ #
#region Exported properties

func _ready() -> void:
	if enabled:
		verify_log_directory()

		_time_string = Time.get_datetime_string_from_system()
		var log_file_name: String = "session%s.log" % _time_string.replace_char(
				":".unicode_at(0), ".".unicode_at(0))
		var log_file_path: String = LOG_DIR.path_join(log_file_name)
		_file = FileAccess.open(log_file_path, FileAccess.WRITE)
		if not _file:
			var error = FileAccess.get_open_error()
			push_error("Cannot open log file '%s' (%d). Logging disabled." % [
				log_file_path,
				error,
			])
			return

		_entry_count = -1
		_file.store_line(_make_log_header())
		GameplayEventBus.session_created.connect(_on_session_created)
		GameplayEventBus.session_restored.connect(_on_session_restored)
		GameplayEventBus.session_saved.connect(_on_session_saved)
		GameplayEventBus.reward_triggered.connect(_on_reward_triggered)
		GameplayEventBus.population_changed.connect(_on_population_changed)
		GameplayEventBus.game_over.connect(_on_game_over)


func _exit_tree() -> void:
	if _file:
		_file.store_line("END")
		_file.close()

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Ensure that [constant LOG_DIR] exists in the file system.
func verify_log_directory() -> void:
	if not DirAccess.dir_exists_absolute(LOG_DIR):
		var error: Error = DirAccess.make_dir_recursive_absolute(LOG_DIR)
		if error != Error.OK:
			push_error("Failed to create log directory at '%s'." % LOG_DIR)
		return

	var log_files: Array = Array(DirAccess.get_files_at(LOG_DIR))
	log_files = log_files.filter(func (log_file: String) -> bool:
			return log_file.ends_with(".log"))
	if log_files.size() >= max_log_files:
		for index: int in range(0, log_files.size() - max_log_files + 1):
			DirAccess.remove_absolute(LOG_DIR.path_join(log_files[index]))

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private methods

func _make_log_header() -> String:
	var game_version: String = ProjectSettings.get_setting("application/config/version")
	return "%s\n%s\n" % [
		"AIKIOPA version %s" % game_version,
		"Game session logging started at %s" % _time_string,
	]


func _make_log_metadata() -> String:
	var metadata_string: String = "Save slot: %d (%s)\nSeeds:\n" % [
		_save_slot_index,
		"NEW SESSION" if _is_new_game else "RESTORED SESSION",
	]
	for seed_name: StringName in _seeds.keys():
		var seed_value: int = _seeds[seed_name]
		metadata_string += "  %s: %d\n" % [seed_name, seed_value]
	return metadata_string


func _make_log_line() -> String:
	_entry_count += 1
	return "%d: %d Building Card(s), %d Placed Building(s), %d Population, Milestone %d" % [
		_entry_count,
		Global.game_state.building_stack.size(),
		Global.game_state.building_instances.size(),
		Global.game_state.population,
		Global.game_state.population_milestones_reached
	]

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to GameplayEventBus.session_created(save_slot_index: int).
func _on_session_created(save_slot_index: int) -> void:
	_save_slot_index = save_slot_index
	_is_new_game = true
	_seeds = world.get_seeds_internal()
	_entry_count = 0
	if _file:
		_file.store_line(_make_log_metadata())
		_file.store_line("BEGIN")


# Listens to GameplayEventBus.session_restored(save_slot_index: int).
func _on_session_restored(save_slot_index: int) -> void:
	_save_slot_index = save_slot_index
	_is_new_game = false
	_seeds = world.get_seeds_internal()
	_entry_count = 0
	if _file:
		_file.store_line(_make_log_metadata())
		_file.store_line("BEGIN")


# Listens to GameplayEventBus.session_saved(save_slot_index: int).
func _on_session_saved(save_slot_index: int) -> void:
	if _file:
		_file.store_line("Session saved to save slot %d" % save_slot_index)


# Listens to GameplayEventBus.reward_triggered(reward: RewardController.Reward).
func _on_reward_triggered(reward: RewardController.Reward) -> void:
	if _file:
		_file.store_line("Reward triggered: %+d pop(s), %+d building(s)" % [
			reward.get_population_bonus(),
			reward.get_building_bonus(),
		])


# Listens to
# GameplayEventBus.population_changed(old_amount: int, new_amount: int).
func _on_population_changed(_old_amount: int, _new_amount: int) -> void:
	if _file:
		_file.store_line(_make_log_line())


# Listens to GameplayEventBus.game_over(
#		population_reached: int,
#		game_over_type: Game.GameOverType).
func _on_game_over(
		_population_reached: int,
		game_over_type: Game.GameOverType
) -> void:
	if _file:
		_file.store_line("Game Over: %s" % Game.GameOverType.keys()[game_over_type])

#endregion
# ============================================================================ #

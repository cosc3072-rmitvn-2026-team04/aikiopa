class_name GameSaveService
extends Object
## Handles saving and restoring game sessions.


# ============================================================================ #
#region Constants

## Save location.
const SAVE_DIR: String = "user://saves/"

## Save file names. Must be unique and follow the format
## [code]"slot_x.save"[/code] where [code]'x'[/code] is the slot number starting
## from [code]1[/code]. Saving logic is limited to these save files.
const SAVE_FILES: Array[String] = [
	"slot_1.save",
	"slot_2.save",
	"slot_3.save",
]

## Extension of temporary buffer swap files.
const SWAP_FILE_EXT: String = ".swp"

## Extension of backup save files.
const BACKUP_FILE_EXT: String = ".backup"

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Ensure that [constant SAVE_DIR] exists in the file system.
static func verify_save_directory() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		var error: Error = DirAccess.make_dir_recursive_absolute(SAVE_DIR)
		if error != Error.OK:
			push_error("Failed to create save directory at '%s'." % SAVE_DIR)


## Returns the total number of save slots.
static func get_save_slot_count() -> int:
	return SAVE_FILES.size()


## Returns an array of booleans indicating whether a save file exists for each
## slot.[br]
## [br]
## The indices of the returned array correspond to the indices of
## [constant SAVE_FILES]. A value of [code]true[/code] means the file exists,
## and a value of [code]false[/code] means the slot is empty.
static func get_save_slot_usage_status() -> Array[bool]:
	return Array(SAVE_FILES.map(func (save_file_name: String):
			return FileAccess.file_exists(SAVE_DIR.path_join(save_file_name))),
			TYPE_BOOL, "", null)


## Writes [param game_state] to the save file at [param slot_index] of
## [constant SAVE_FILES]. Automatically generates and includes metadata header
## (see [method get_header]). Create the save file if not already exist.[br]
## [br]
## Returns [code]true[/code] if the operation is successful. Otherwise returns
## [code]false[/code] and prints the relevant error.
static func save(game_state: Global.GameState, slot_index: int) -> bool:
	if not game_state:
		push_error("Fatal: 'game_state' cannot be 'null'.")
		return false

	if slot_index < 0 or slot_index >= SAVE_FILES.size():
		push_error("Fatal: 'slot_index' out of bound.")
		return false

	var error: Error = Error.OK
	var file_path: String = SAVE_DIR.path_join(SAVE_FILES[slot_index])

	#region Write to swap file
	var swap_file_path: String = file_path + SWAP_FILE_EXT
	var file: FileAccess = FileAccess.open(swap_file_path, FileAccess.WRITE)
	if not file:
		error = FileAccess.get_open_error()
		push_error("Fatal: Cannot open temporary file '%s' (%d)." % [
			swap_file_path,
			error,
		])
		return false

	# INFO: The hard-coded serialization logic here is intentional to maintain
	# a strict and secure data schema.
	var header: Dictionary[StringName, Variant] = {
		&"version": ProjectSettings.get_setting("application/config/version"),
		&"population": game_state.population,
		&"timestamp": int(Time.get_unix_time_from_system()),
	}
	file.store_var(header, false)
	file.store_var(game_state.world_seed, false)
	file.store_var(game_state.building_stack_seed, false)
	file.store_var(game_state.building_stack_state, false)
	file.store_var(game_state.building_stack, false)
	file.store_var(game_state.building_metadata, false)
	file.store_var(game_state.edge_coords, false)
	file.store_var(game_state.enclosed_forest_coords, false)
	file.store_var(game_state.shroud_data, false)
	file.store_var(game_state.population, false)
	file.store_var(game_state.population_milestones_reached, false)
	error = file.get_error()
	if error != OK:
		push_error("Fatal: Disk write failed (%d)." % error)
		file.close()
		return false
	#endregion

	file.close()

	#region Atomic swap
	var backup_file_path: String = file_path + BACKUP_FILE_EXT

	if FileAccess.file_exists(backup_file_path):
		error = DirAccess.remove_absolute(backup_file_path)
		if error != Error.OK:
			push_error("Fatal: Failed to remove old backup '%s'." % backup_file_path)
			return false

	if FileAccess.file_exists(file_path):
		error = DirAccess.rename_absolute(file_path, backup_file_path)
		if error != Error.OK:
			push_error("Fatal: Failed to generate backup '%s' from '%s'." % [
				backup_file_path,
				file_path,
			])
			return false

	error = DirAccess.rename_absolute(swap_file_path, file_path)
	if error != Error.OK:
		push_error("Fatal: Failed to save temp '%s' into '%s'." % [
			swap_file_path,
			file_path,
		])
		return false
	#endregion

	return true


## Reads and returns the metadata header of the save file at
## [param slot_index] of [constant SAVE_FILES].[br]
## [br]
## The returned metadata is a dictionary of keys: [code]"&version"[/code],
## [code]"&population"[/code], and [code]"&timestamp"[/code].[br]
## [br]
## - [code]"&version"[/code] is game version producing the save file.[br]
## [br]
## - [code]"&population"[/code] is population reached when the session is
## saved.[br]
## [br]
## - [code]"&timestamp"[/code] is the Unix timestamp of the most recent write to
## the save file.[br]
## [br]
## Returns [code]{}[/code] (empty dictionary) and print the relevant error if
## the operation is unsuccessful.[br]
## [br]
## [b]Note:[/b] To get the full [Global.GameState] content of the save file, use
## [method load].
static func get_header(slot_index) -> Dictionary[StringName, Variant]:
	if slot_index < 0 or slot_index >= SAVE_FILES.size():
		push_error("Fatal: 'slot_index' out of bound.")
		return {}

	var error: Error = Error.OK
	var file_path: String = SAVE_DIR.path_join(SAVE_FILES[slot_index])
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		error = FileAccess.get_open_error()
		push_error("Fatal: Cannot open save file '%s'." % [
			file_path,
			error,
		])
		return {}

	var header: Dictionary[StringName, Variant] = file.get_var()

	file.close()

	return header


## Reads the save file at [param slot_index] of [constant SAVE_FILES] and
## returns the saved [Global.GameState].[br]
## [br]
## Returns [code]null[/code] and print the relevant error if the operation is
## unsuccessful.
static func load(slot_index: int) -> Global.GameState:
	if slot_index < 0 or slot_index >= SAVE_FILES.size():
		push_error("Fatal: 'slot_index' out of bound.")
		return null

	var error: Error = Error.OK
	var file_path: String = SAVE_DIR.path_join(SAVE_FILES[slot_index])
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		error = FileAccess.get_open_error()
		push_error("Fatal: Cannot open save file '%s'." % [
			file_path,
			error,
		])
		return null

	# gdlint:ignore = function-variable-name
	var _header: Dictionary[StringName, Variant] = file.get_var()

	# INFO: The hard-coded deserialization logic here is intentional to maintain
	# a strict and secure data schema.
	var game_state: Global.GameState = Global.GameState.new()
	game_state.world_seed = file.get_var(false)
	game_state.building_stack_seed = file.get_var(false)
	game_state.building_stack_state = file.get_var(false)
	game_state.building_stack = file.get_var(false)
	game_state.building_metadata = file.get_var(false)
	game_state.edge_coords = file.get_var(false)
	game_state.enclosed_forest_coords = file.get_var(false)
	game_state.shroud_data = file.get_var(false)
	game_state.population = file.get_var(false)
	game_state.population_milestones_reached = file.get_var(false)
	error = file.get_error()
	if error != OK:
		push_error("Fatal: Disk read failed (%d)." % error)
		file.close()
		return null

	file.close()

	return game_state


## Deletes the save file at [param slot_index] of [constant SAVE_FILES], thus.
## freeing up, or "emptying" that slot.[br]
## [br]
## Returns [code]true[/code] if the operation is successful. Otherwise returns
## [code]false[/code] and prints the relevant error.
static func delete(slot_index) -> bool:
	if slot_index < 0 or slot_index >= SAVE_FILES.size():
		push_error("Fatal: 'slot_index' out of bound.")
		return false

	var error: Error = Error.OK
	var file_path: String = SAVE_DIR.path_join(SAVE_FILES[slot_index])
	var target_file_paths: Array[String] = [
		file_path,
		file_path + BACKUP_FILE_EXT,
		file_path + SWAP_FILE_EXT,
	]
	for target_file_path: String in target_file_paths:
		if FileAccess.file_exists(target_file_path):
			error = DirAccess.remove_absolute(target_file_path)
			if error != Error.OK:
				push_error("Fatal: Failed to remove '%s'." % target_file_path)
				return false

	return true

#endregion
# ============================================================================ #

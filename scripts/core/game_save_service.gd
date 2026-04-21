class_name GameSaveService
extends Object
## Handles saving and restoring game sessions.


# ============================================================================ #
#region Constants

## Save location.
const SAVE_DIR: String = "user://saves/"

## Save file names. Saving is limited to these slots only.
const SAVE_FILES: Array[String] = [
	"slot_1.save",
	"slot_2.save",
	"slot_3.save",
]

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Ensure that [constant SAVE_DIR] exists in the file system.
static func verify_save_directory() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)


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
	var result: Array = SAVE_FILES.map(
			func (save_file_name: String):
				return FileAccess.file_exists(SAVE_DIR.path_join(save_file_name)))
	return Array(result, TYPE_BOOL, "", null)


## Writes [param game_state] to the save file at [param slot_index] of
## [constant SAVE_FILES]. Automatically generates and includes metadata header
## (see [method get_header]). Create the save file if not already exist.[br]
## [br]
## Returns [code]true[/code] if the operation is successful. Otherwise returns
## [code]false[/code] and prints the relevant error.
static func save(_game_state: Global.GameState, _slot_index: int) -> bool:
	return false


## Reads and returns the metadata header of the save file at
## [param slot_index] of [constant SAVE_FILES].[br]
## [br]
## The returned metadata includes the following fields:[br]
## - [code]"&population"[/code]: The population reached when the session is last
## saved.[br]
## - [code]"&timestamp"[/code]: The Unix timestamp of the most recent write to
## the save file.[br]
## [br]
## Returns [code]{}[/code] (empty dictionary) and print the relevant error if
## the operation is unsuccessful.[br]
## [br]
## [b]Note:[/b] To get the full [Global.GameState] content of the save file, use
## [method load].
static func get_header(_slot_index) -> Dictionary[StringName, Variant]:
	return {}


## Reads the save file at [param slot_index] of [constant SAVE_FILES] and
## returns the saved [Global.GameState].[br]
## [br]
## Returns [code]null[/code] and print the relevant error if the operation is
## unsuccessful.
static func load(_slot_index: int) -> Global.GameState:
	return Global.GameState.new()


## Deletes the save file at [param slot_index] of [constant SAVE_FILES], thus.
## freeing up, or "emptying" that slot.[br]
## [br]
## Returns [code]true[/code] if the operation is successful. Otherwise returns
## [code]false[/code] and prints the relevant error.
static func delete(_slot_index) -> bool:
	return false

#endregion
# ============================================================================ #

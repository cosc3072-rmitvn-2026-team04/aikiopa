class_name GameSaveService
extends Object
## Handles saving and restoring game sessions.


# ============================================================================ #
#region Constants

## Save location.
const SAVE_DIR: String = "user://saves/"

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

static func verify_save_directory() -> void:
	pass


static func save(_game_state: Global.GameState) -> bool:
	return false


static func load() -> Global.GameState:
	return Global.GameState.new()

#endregion
# ============================================================================ #

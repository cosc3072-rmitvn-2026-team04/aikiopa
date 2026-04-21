class_name GameSaveService
extends Object
## Handles saving and restoring game sessions.


static func save(_game_state: Global.GameState) -> bool:
	return false


static func load() -> Global.GameState:
	return Global.GameState.new()

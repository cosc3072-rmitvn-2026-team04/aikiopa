extends GameScene2D


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	%MainMenuUI.acted.connect(_on_main_menu_ui_acted)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to %MainMenuUI.acted(action: StringName).
func _on_main_menu_ui_acted(action: StringName) -> void:
	match action:
		&"start":
			scene_finished.emit(SceneKey.PLAY)
			Global.game_state = Global.GameState.new()
		&"gallery":
			scene_finished.emit(SceneKey.GALLERY_LOADER)
		&"settings":
			scene_finished.emit(SceneKey.SETTINGS)
		&"credits":
			scene_finished.emit(SceneKey.CREDITS)
		&"quit":
			get_tree().quit()

#endregion
# ============================================================================ #

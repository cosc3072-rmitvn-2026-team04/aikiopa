extends GameScene2D


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	%MainMenuUI.acted.connect(_on_main_menu_ui_acted)
	%GameVersionLabel.text = "v%s" % ProjectSettings.get_setting(
			"application/config/version")

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to %MainMenuUI.acted(action: StringName).
func _on_main_menu_ui_acted(action: StringName) -> void:
	match action:
		&"start":
			scene_finished.emit(SceneKey.SAVE_LOADER)
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

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
		"prologue_tutorial":
			scene_finished.emit(SceneKey.TUTORIAL)
		"free_play":
			scene_finished.emit(SceneKey.FREE_PLAY)
		"settings":
			scene_finished.emit(SceneKey.SETTINGS)
		"credits":
			scene_finished.emit(SceneKey.CREDITS)
		"exit":
			get_tree().quit()
#endregion
# ============================================================================ #

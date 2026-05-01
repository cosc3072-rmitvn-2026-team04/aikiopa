class_name MainMenu
extends GameScene2D


# ============================================================================ #
#region Static variables

## If [code]true[/code], scene transition in animation is enabled for the
## [MainMenu] scene. Setting this to [code]false[/code] would disable the
## animation for the next transition into this scene.[br]
## [br]
## Automatically resets to [code]true[/code] after the [MainMenu] scene is
## ready (see [signal Node.ready]).
static var scene_transition_in_enabled: bool = true

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	%GameVersionLabel.text = "v%s" % ProjectSettings.get_setting(
			"application/config/version")

	# Show the SceneTransitionCanvasLayer because it is set to hidden in the
	# Godot editor for easier debugging.
	%SceneTransitionCanvasLayer.show()
	_scene_transition_in()
	if not scene_transition_in_enabled:
		scene_transition_in_enabled = true
	_show_ui()

	%MainMenuUI.acted.connect(_on_main_menu_ui_acted)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private methods

func _scene_transition_in() -> void:
	%SceneTransitionAnimationPlayer.play(&"transition_in")
	if not scene_transition_in_enabled:
		%SceneTransitionCanvasLayer.hide()
		%SceneTransitionAnimationPlayer.advance(
				%SceneTransitionAnimationPlayer.get_animation(&"transition_in").length)
	else:
		await %SceneTransitionAnimationPlayer.animation_finished
		%SceneTransitionCanvasLayer.hide()


func _show_ui() -> void:
	%MainMenuUIAnimationPlayer.play("show_ui")
	await %MainMenuUIAnimationPlayer.animation_finished


func _hide_ui() -> void:
	%MainMenuUIAnimationPlayer.play("hide_ui")
	await %MainMenuUIAnimationPlayer.animation_finished

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to %MainMenuUI.acted(action: StringName).
func _on_main_menu_ui_acted(action: StringName) -> void:
	match action:
		&"start":
			await _hide_ui()
			scene_finished.emit(SceneKey.SAVE_LOADER)
		&"gallery":
			await _hide_ui()
			scene_finished.emit(SceneKey.GALLERY_LOADER)
		&"settings":
			await _hide_ui()
			scene_finished.emit(SceneKey.SETTINGS)
		&"credits":
			await _hide_ui()
			scene_finished.emit(SceneKey.CREDITS)
		&"quit":
			get_tree().quit()

#endregion
# ============================================================================ #

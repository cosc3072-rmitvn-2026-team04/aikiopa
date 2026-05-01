class_name Play
extends GameScene2D


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	_scene_transition_in()

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private methods

func _scene_transition_in() -> void:
	%SceneTransitionAnimationPlayer.play(&"transition_in")
	await %SceneTransitionAnimationPlayer.animation_finished
	%SceneTransitionCanvasLayer.hide()
	%LoadBackgroundColorRect.color = ProjectSettings.get_setting(
			"rendering/environment/defaults/default_clear_color")

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins

## Triggers a scene switch to [param scene_key].
func switch_scene(scene_key: SceneKey) -> void:
	scene_finished.emit(scene_key)

#endregion
# ============================================================================ #

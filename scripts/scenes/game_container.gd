class_name GameContainer
extends GameScene2D
## Container [GameScene2D] for [Game] sessions.


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	# Show the SceneTransitionCanvasLayer because it is set to hidden in the
	# Godot editor for easier debugging.
	%SceneTransitionCanvasLayer.show()
	await _scene_transition_in()
	scene_transition_in_finished.emit.call_deferred()

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Triggers a scene switch to [param scene_key].
func switch_scene(scene_key: SceneKey) -> void:
	await _scene_transition_out()
	scene_transition_out_started.emit(Color.BLACK)
	scene_finished.emit(scene_key)

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


func _scene_transition_out() -> void:
	%SceneTransitionCanvasLayer.show()
	%SceneTransitionAnimationPlayer.play(&"transition_out")
	await %SceneTransitionAnimationPlayer.animation_finished

#endregion
# ============================================================================ #

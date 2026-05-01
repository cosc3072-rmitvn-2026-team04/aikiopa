extends Node
## Game entry point.


var _current_scene_key: GameScene2D.SceneKey
var _current_scene: Node


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	get_window().set_min_size(Vector2i(
			ProjectSettings.get_setting("display/window/size/viewport_width"),
			ProjectSettings.get_setting("display/window/size/viewport_height")))
	_current_scene_key = GameScene2D.SceneKey.SPLASH_SCREEN
	_current_scene = null


func _process(_delta: float) -> void:
	if _current_scene == null:
		_current_scene = load(GameScene2D.GAME_SCENE[_current_scene_key]).instantiate()
		add_child(_current_scene)
		move_child(_current_scene, 0)
		_current_scene.scene_transition_out_started.connect(
				_on_scene_transition_out_started)
		_current_scene.scene_transition_in_finished.connect(
				_on_scene_transition_in_finished)
		_current_scene.scene_finished.connect(_on_scene_finished)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to _current_scene.scene_transition_out_started(
#		background_color: Color).
func _on_scene_transition_out_started(background_color: Color) -> void:
	%SceneTransitionBackgroundCanvasLayer.show()
	%SceneTransitionBackgroundColorRect.color = background_color


# Listens to _current_scene.scene_transition_in_finished.
func _on_scene_transition_in_finished() -> void:
	%SceneTransitionBackgroundCanvasLayer.hide()


# Listens to _current_scene.scene_finished(next_scene_key: SceneKey).
func _on_scene_finished(next_scene_key: GameScene2D.SceneKey) -> void:
	if _current_scene:
		_current_scene.queue_free()
		_current_scene = null
	_current_scene_key = next_scene_key

#endregion
# ============================================================================ #

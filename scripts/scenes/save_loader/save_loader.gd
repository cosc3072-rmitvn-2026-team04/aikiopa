class_name SaveLoader
extends GameScene2D


# ============================================================================ #
#region Static variables

static var _refreshing: bool = false

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private variables

var _save_slot_scene: PackedScene = preload("res://scenes/save_loader/save_slot.tscn")

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	_scene_transition_in(_refreshing)
	if _refreshing:
		_refreshing = false

	%BackButton.pressed.connect(_on_back_button_pressed)
	%SaveLoaderUI.acted.connect(_on_save_loader_ui_acted)
	%SaveLoaderUI.acted_with_data.connect(_on_save_loader_ui_acted_with_data)

	var save_slot_usage_status: Array[bool] = GameSaveService.get_save_slot_usage_status()
	for index: int in GameSaveService.get_save_slot_count():
		var save_slot: PanelContainer = _save_slot_scene.instantiate()
		save_slot.container_ui = %SaveLoaderUI
		save_slot.assign_save_index(index)
		save_slot.set_slot_number(index + 1)
		if save_slot_usage_status[index]:
			var save_header: Dictionary[StringName, Variant]
			save_header = GameSaveService.get_header(index)
			save_slot.set_slot_used(save_header)
		else:
			save_slot.set_slot_empty()
		%SaveSlotContainer.add_child(save_slot)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private methods

func _scene_transition_in(refreshing: bool) -> void:
	%SceneTransitionAnimationPlayer.play(&"transition_in")
	if refreshing:
		%SceneTransitionCanvasLayer.hide()
		%SceneTransitionAnimationPlayer.advance(
				%SceneTransitionAnimationPlayer.get_animation(&"transition_in").length)
	else:
		await %SceneTransitionAnimationPlayer.animation_finished
		%SceneTransitionCanvasLayer.hide()


func _scene_transition_out() -> void:
	%SceneTransitionCanvasLayer.show()
	%SceneTransitionAnimationPlayer.play(&"transition_out")
	await %SceneTransitionAnimationPlayer.animation_finished

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to %BackButton.pressed.
func _on_back_button_pressed() -> void:
	MainMenu.scene_transition_in_enabled = false
	scene_finished.emit(SceneKey.MAIN_MENU)


# Listens to %SaveLoaderUI.acted(action: StringName).
func _on_save_loader_ui_acted(action: StringName) -> void:
	match action:
		&"refresh":
			_refreshing = true
			scene_finished.emit(GameScene2D.SceneKey.SAVE_LOADER)


# Listens to %SaveLoaderUI.acted_with_data(action: StringName, data: Variant).
func _on_save_loader_ui_acted_with_data(
		action: StringName,
		data: Variant
) -> void:
	match action:
		&"new_session":
			Global.current_save_slot_index = int(data)
			Global.is_new_game = true
			%SceneTransitionCanvasLayer.show()
			await _scene_transition_out()
			scene_finished.emit(GameScene2D.SceneKey.PLAY)
		&"load_session":
			Global.current_save_slot_index = int(data)
			Global.is_new_game = false
			await _scene_transition_out()
			scene_finished.emit(GameScene2D.SceneKey.PLAY)

#endregion
# ============================================================================ #

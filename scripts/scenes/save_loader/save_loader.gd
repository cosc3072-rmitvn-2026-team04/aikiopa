extends GameScene2D


# ============================================================================ #
#region Private variables

var _save_slot_scene: PackedScene = preload("res://scenes/save_loader/save_slot.tscn")

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	%BackButton.pressed.connect(_on_back_button_pressed)

	var save_slot_usage_status: Array[bool] = GameSaveService.get_save_slot_usage_status()
	for index: int in GameSaveService.get_save_slot_count():
		var save_slot: PanelContainer = _save_slot_scene.instantiate()
		save_slot.container_scene = self
		save_slot.assign_save_index(index)
		save_slot.set_slot_number(index + 1)
		if save_slot_usage_status[index]:
			save_slot.set_slot_used()
		else:
			save_slot.set_slot_empty()
		%SaveSlotContainer.add_child(save_slot)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to %BackButton.pressed.
func _on_back_button_pressed() -> void:
	scene_finished.emit(SceneKey.MAIN_MENU)

#endregion
# ============================================================================ #

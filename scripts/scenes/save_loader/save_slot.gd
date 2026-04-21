extends PanelContainer


# ============================================================================ #
#region Exported properties

@export var container_scene: GameScene2D

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private variables

var _save_slot_index: int = -1

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Assigns this save slot to the save file [param index] in
## [constant GameSaveService.SAVE_FILES].
func assign_save_index(index: int) -> void:
	_save_slot_index = index


## Sets the slot number in the [code]SlotNameLabel[/code].
func set_slot_number(number: int) -> void:
	%SlotNameLabel.text = "SLOT %d" % [number]


## Sets the slot as empty (has no game save).
func set_slot_empty() -> void:
	%NewButton.pressed.connect(_on_new_button_pressed)

	%LoadButton.hide()
	%SavePopulationLabel.hide()
	%SaveDateTimeLabel.hide()
	%DeleteButton.hide()
	%DeleteConfirmationContainer.hide()


## Sets the slot as used (has game save).
func set_slot_used() -> void:
	%NewButton.hide()
	%SlotEmptyLabel.hide()
	%DeleteConfirmationContainer.hide()

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

func _on_new_button_pressed() -> void:
	Global.current_save_slot_index = _save_slot_index
	Global.game_state = Global.GameState.new()
	container_scene.scene_finished.emit(GameScene2D.SceneKey.PLAY)

#endregion
# ============================================================================ #

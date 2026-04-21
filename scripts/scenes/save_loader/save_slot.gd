extends PanelContainer


# ============================================================================ #
#region Private variables

var _save_index: int = -1

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Assigns this save slot to the save file [param index] in
## [constant GameSaveService.SAVE_FILES].
func assign_save_index(index: int) -> void:
	_save_index = index


## Sets the slot number in the [code]SlotNameLabel[/code].
func set_slot_number(number: int) -> void:
	%SlotNameLabel.text = "SLOT %d" % [number]


## Sets the slot as empty (has no game save).
func set_slot_empty() -> void:
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

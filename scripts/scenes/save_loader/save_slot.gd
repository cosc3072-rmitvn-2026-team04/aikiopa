extends PanelContainer


# ============================================================================ #
#region Variables

@export var slot_index: int = 0

#endregion

# ============================================================================ #


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	%SlotNameLabel.text = "SLOT %d" % [slot_index + 1]

	%NewButton.hide()
	%LoadButton.hide()
	%SlotEmptyLabel.hide()
	%SaveDateTimeLabel.hide()
	%DeleteButton.hide()
	%DeleteConfirmationContainer.hide()

#endregion
# ============================================================================ #

extends PanelContainer


# ============================================================================ #
#region Exported properties

@export var container_ui: GameUI

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private variables

var _save_slot_index: int = -1

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	container_ui.refresh_ui_sfx()

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
	%SaveDatetimeLabel.hide()
	%DeleteButton.hide()
	%DeleteConfirmContainer.hide()


## Sets the slot as used (has game save) and display information from
## [param save_header].
func set_slot_used(save_header: Dictionary[StringName, Variant]) -> void:
	const MONTH_STRINGS: Array[String] = [
		"Jan", "Feb", "Mar",
		"Apr", "May", "Jun",
		"Jul", "Aug", "Sep",
		"Oct", "Nov", "Dec",
	]

	%NewButton.hide()
	%SlotEmptyLabel.hide()
	%DeleteConfirmContainer.hide()

	%LoadButton.pressed.connect(_on_load_button_pressed)
	%DeleteButton.pressed.connect(_on_delete_button_pressed)
	%DeleteConfirmNoButton.pressed.connect(_on_delete_confirm_no_button_pressed)
	%DeleteConfirmYesButton.pressed.connect(_on_delete_confirm_yes_button_pressed)

	%SavePopulationLabel.text = "%d🧑‍🚀" % [save_header.population]

	var save_timestamp: int = save_header.timestamp
	save_timestamp += Time.get_time_zone_from_system().bias * 60
	var save_datetime_dict: Dictionary = Time.get_datetime_dict_from_unix_time(
			save_timestamp)
	%SaveDatetimeLabel.text = "%d:%02d %s\n%d %s %d" % [
		(
				save_datetime_dict.hour if save_datetime_dict.hour <= 12
				else save_datetime_dict.hour - 12
		),
		save_datetime_dict.minute,
		"AM" if save_datetime_dict.hour < 12 else "PM",
		save_datetime_dict.day,
		MONTH_STRINGS[save_datetime_dict.month - 1],
		save_datetime_dict.year,
	]

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to %NewButton.pressed.
func _on_new_button_pressed() -> void:
	container_ui.acted_with_data.emit(&"new_session", _save_slot_index)


# Listens to %LoadButton.pressed.
func _on_load_button_pressed() -> void:
	container_ui.acted_with_data.emit(&"load_session", _save_slot_index)


# Listens to %Delete.pressed.
func _on_delete_button_pressed() -> void:
	%DeleteButton.hide()
	%DeleteConfirmContainer.show()


# Listens to %DeleteConfirmNoButton.pressed.
func _on_delete_confirm_no_button_pressed() -> void:
	%DeleteButton.show()
	%DeleteConfirmContainer.hide()


# Listens to %DeleteConfirmYesButton.pressed.
func _on_delete_confirm_yes_button_pressed() -> void:
	%DeleteConfirmContainer.hide()
	GameSaveService.delete(_save_slot_index)
	container_ui.acted.emit(&"refresh")

#endregion
# ============================================================================ #
